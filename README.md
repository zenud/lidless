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

The installer does not ask for a password. It does three things:

1. Copies the command to `~/.local/bin/lidless`.
2. Installs [SwiftBar](https://swiftbar.app) with Homebrew if it is not there
   yet. SwiftBar is the app that displays the button.
3. Copies the button into SwiftBar's plugin folder (`~/.swiftbar` unless you
   already picked another one) and starts SwiftBar.

For the command alone, with no button and no SwiftBar:

```bash
./install.sh --no-button
```

To get the button back after a restart, click it, then **SwiftBar**, and turn
on **Launch at Login**.

## Usage

### The button

A moon icon appears in the menu bar.

1. Click it and pick a duration: 30 min, 1 h, 2 h, 4 h or 8 h.
2. Type your password in the macOS dialog.
3. The icon turns into an eye, with the end time next to it (this can take up
   to 30 seconds to show).

During a session the menu offers **Stop**, or a new duration that replaces
the running one.

### The command

| Command | What it does |
|---|---|
| `lidless` | stays awake for 2 hours |
| `lidless 4h` | 4 hours |
| `lidless 90m` | 90 minutes |
| `lidless stop` | ends the session and restores sleep |

The command asks for your password once, prints the end time, then holds the
Terminal window until the end. Ctrl-C, or closing the window, ends the
session and restores sleep.

## How it works

`lidless` runs `pmset -a disablesleep 1`, the macOS setting that forbids
sleep altogether, waits for the duration you asked for, then runs
`pmset -a disablesleep 0`. That setting is reserved for administrators, hence
the password.

During a session, the file `/var/run/lidless` holds the process number and the
end time. The button reads it to show the eye and the time.

## Limits

- **If the Mac shuts down or crashes during a session**, sleep can stay
  disabled. Run `lidless stop` to restore it.
- The display can still turn off: only the system stays awake.
- There is no protection against a low battery or overheating.
- Every start and every stop asks for the password.

## Uninstall

```bash
lidless stop
rm ~/.local/bin/lidless
rm ~/.swiftbar/lidless.30s.sh    # or wherever your SwiftBar plugin folder is
brew uninstall --cask swiftbar   # only if you do not use SwiftBar for anything else
```

## License

[MIT](LICENSE)
