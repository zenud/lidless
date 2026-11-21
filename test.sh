#!/bin/bash
# Checks the command and the service loop against a fake pmset and a temporary state file.
#   ./test.sh
set -e
cd "$(dirname "$0")"
t=$(mktemp -d)
trap 'rm -rf "$t"' EXIT
sed "s|^STATE=/var/db/lidless|STATE=$t/state|" lidless > "$t/lidless"
# Fake pmset: "-g batt" and "-g log" print the files of the same name, "-g"
# reports the last value written, anything else records the value it is given.
cat > "$t/pmset" <<FAKE
#!/bin/sh
l="$t/pmset.log"
[ "\$2" = batt ] && { cat "$t/batt" 2>/dev/null; exit; }
[ "\$2" = log ] && { cat "$t/log" 2>/dev/null; exit; }
[ "\$1" = -g ] && { echo " SleepDisabled \$(tail -1 "\$l")"; exit; }
echo "\$3" >> "\$l"
FAKE
chmod +x "$t/lidless" "$t/pmset"
export PATH="$t:$PATH"

! "$t/lidless" 1h 2>/dev/null                 # no state file = service not installed
echo 0 > "$t/state"
! "$t/lidless" 1x 2>/dev/null                 # bad duration
"$t/lidless" daemon                           # idle: restores sleep and leaves
[ "$(cat "$t/pmset.log")" = 0 ]

"$t/lidless" 90m >/dev/null
end=$(cat "$t/state"); now=$(date +%s)
[ $((end - now)) -ge 5399 ] && [ $((end - now)) -le 5400 ]

"$t/lidless" daemon & d=$!
sleep 1
echo 0 >> "$t/pmset.log"                      # something else re-enables sleep mid-session
sleep 6                                       # the service puts it back on its next pass
"$t/lidless" stop >/dev/null
wait "$d"                                     # leaves within 5 s of the stop
[ "$(tr '\n' ' ' < "$t/pmset.log")" = "0 1 0 1 0 " ]

"$t/lidless" status | grep -q "No session"
"$t/lidless" 1h >/dev/null
"$t/lidless" status | grep -q "No sleep"
printf '2999-01-01 00:00:00 +0100 Sleep  \tEntering Sleep state due to X\n' > "$t/log"
"$t/lidless" status | grep -q "Slept 1 time"

printf "Now drawing from 'Battery Power'\n -InternalBattery-0\t9%%; discharging\n" > "$t/batt"
"$t/lidless" daemon                           # on battery under 10 %: ends the session by itself
[ "$(cat "$t/state")" = 0 ] && [ "$(tail -1 "$t/pmset.log")" = 0 ]
! "$t/lidless" 1h 2>/dev/null                 # and refuses to start a new one
printf "Now drawing from 'AC Power'\n -InternalBattery-0\t9%%; charging\n" > "$t/batt"
"$t/lidless" 1h >/dev/null                    # plugged in: the charge does not matter
echo "ok"
