# dotfiles

Personal macOS shell and terminal configuration. Managed with symlinks, so
the files in this repo are the actual live config: editing one edits the other,
nothing to keep manually in sync.

## What's here

| File | Symlinked to | Covers |
|---|---|---|
| `zshrc` | `~/.zshrc` | zsh: starship prompt, zoxide, fzf, autosuggestions, syntax highlighting, completion, history |
| `vimrc` | `~/.vimrc` | vim config |
| `gitconfig` | `~/.gitconfig` | git, with delta as the diff pager |
| `ghostty/config.ghostty` | `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty` | Ghostty terminal |
| `bootstrap.sh` | N/A | installs every tool these configs depend on |
| `setup.sh` | N/A | symlinks each file above into its live location |

tmux isn't part of this setup yet.

## New machine setup

```bash
git clone git@github.com:singhn15/dotfiles.git ~/Projects/dotrepo
cd ~/Projects/dotrepo
bash bootstrap.sh   # Homebrew + every dependency (Ghostty included), y/n per item
bash setup.sh       # symlinks the configs above into place
```

Both scripts are safe to rerun: already installed tools and
already symlinked files are skipped, not repeated.

## How it works
bootstrap.sh checks each required tool against what Homebrew already has installed and only prompts for the ones actually missing. Nothing gets installed without an explicit yes. Homebrew itself is included in that check, so this works as the very first step on a brand new machine.

`setup.sh` moves each live config file into this repo (first run only) and
replaces it with a symlink pointing back here. If the repo already has a
tracked copy of a file (e.g. after cloning onto a new machine) and a live
file also already exists there, the live one is backed up to `<file>.bak`
rather than overwritten.
