# lidless 👁

**The eye that never closes.** Keeps your Mac awake for a set time, **even
with the lid shut**, then puts sleep back the way it was. One terminal
command, one menu bar button.

Handy for a long job (an overnight build, a big download, a backup) that
should not die because the Mac dozed off, without having to remember to turn
sleep back on afterwards.

> **With the lid closed, the Mac runs hot and drains the battery.** Plug it in
> and leave it on a clear surface, never in a bag.

## Install

Needs macOS 12 or later (Intel or Apple Silicon) and, for the button,
[Homebrew](https://brew.sh).

```bash
git clone https://github.com/zenud/lidless.git
cd lidless
./install.sh
```

The installer asks for your password once, to set up the service. After
that, nothing does. It does four things:

1. Copies the command to `~/.local/bin/lidless`.
2. Installs the service: a small background program that macOS starts by
   itself, and the only part that runs as administrator.
3. Installs [SwiftBar](https://swiftbar.app) with Homebrew if it is not there
   yet. SwiftBar is the app that displays the button.
4. Copies the button into SwiftBar's plugin folder (`~/.swiftbar` unless you
   already picked another one), starts SwiftBar and adds it to your login
   items, so the button is back after every restart.

For the command and the service, with no button and no SwiftBar:

```bash
./install.sh --no-button
```

## Usage

### The button

A moon icon appears in the menu bar.

1. Click it and pick a duration: 30 min, 1 h, 2 h, 4 h, 8 h or **No end**.
2. The icon turns into an eye, with the end time next to it (∞ with no end).

During a session the menu offers **Stop**, or a new duration that replaces
the running one.

### The command

| Command | What it does |
|---|---|
| `lidless` | stays awake for 2 hours |
| `lidless 4h` | 4 hours |
| `lidless 90m` | 90 minutes |
| `lidless noend` | until you stop it, restarts included |
| `lidless stop` | ends the session and restores sleep |
| `lidless status` | tells whether a session is running, and whether the Mac slept during it |

The command prints the end time and returns straight away: you can close the
Terminal window, the session carries on. `lidless stop` ends it, within five
seconds.

The screens still switch off after their usual delay: that is not sleep.
`lidless status` reads the system's power log and tells which one happened.

On battery, a session ends by itself under 10 % of charge, so the Mac goes to
sleep instead of running flat and switching off. Plugged in, the charge does
not matter.

## How it works

The command and the button only write the end time into the file
`/var/db/lidless`. macOS (launchd) starts the service every time that file
changes. The service runs `pmset -a disablesleep 1`, the macOS setting that
forbids sleep altogether, waits until the end time, then runs
`pmset -a disablesleep 0`. That setting is reserved for administrators, which
is why the service runs as one, and why the installer asks for your password.

The service also starts with the Mac: after a shutdown or a crash it resumes
the session if there is time left on it, and puts sleep back otherwise.

## Limits

- The display can still turn off: only the system stays awake.
- There is no protection against a low battery or overheating.
- Any user account on the Mac can start or stop a session, with no password.

## Uninstall

```bash
sudo launchctl bootout system/io.github.zenud.lidless   # stops the service and restores sleep
sudo rm /Library/LaunchDaemons/io.github.zenud.lidless.plist /Library/PrivilegedHelperTools/lidless /var/db/lidless
rm ~/.local/bin/lidless
rm ~/.swiftbar/lidless.30s.sh    # or wherever your SwiftBar plugin folder is
brew uninstall --cask swiftbar   # only if you do not use SwiftBar for anything else
```

## License

[MIT](LICENSE)
