#!/bin/bash
# Checks the command and the service loop against a fake pmset and a temporary state file.
#   ./test.sh
set -e
cd "$(dirname "$0")"
t=$(mktemp -d)
trap 'rm -rf "$t"' EXIT
sed "s|^STATE=/var/db/lidless|STATE=$t/state|" lidless > "$t/lidless"
printf '#!/bin/sh\necho "$3" >> "%s/pmset.log"\n' "$t" > "$t/pmset"
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
"$t/lidless" stop >/dev/null
wait "$d"                                     # leaves within 5 s of the stop
[ "$(tr '\n' ' ' < "$t/pmset.log")" = "0 1 0 " ]
echo "ok"
