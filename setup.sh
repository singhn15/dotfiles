#!/bin/bash
# setup.sh — bootstraps symlinks between ~/dotfiles and their live locations.
#
# Two use cases, same script:
#  1. First run on this machine: adopts your existing live config files
#     INTO ~/dotfiles (moves them, doesn't copy), then symlinks the live
#     paths back to the repo. Nothing is fabricated or overwritten — it
#     picks up whatever's actually on disk right now.
#  2. Fresh machine: after `git clone` this repo to ~/dotfiles and running
#     this script again, the repo already has tracked files, so it treats
#     the repo as the source of truth — any conflicting live file gets
#     backed up to <file>.bak rather than silently overwritten, then the
#     live path is symlinked to the repo's version.
#
# Safe to re-run. Already-symlinked paths are skipped.
#
# PREREQUISITE: run this only after tmux.conf is placed at ~/.tmux.conf and
# git-delta-setup.sh has been run at least once, if this is the very first
# time setting up on this machine (so there's something real to adopt for
# those two files, rather than adopting an empty stub).

set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Using dotfiles repo: $DOTFILES"

link() {
  local live="$1" dest_name="$2"
  local target="$DOTFILES/$dest_name"

  if [ -L "$live" ]; then
    echo "skip (already linked): $live"
    return
  fi

  if [ -f "$target" ]; then
    # Repo already tracks this file (e.g. cloned on a new machine) —
    # treat the repo as the source of truth. Don't let a pre-existing
    # live file (e.g. a fresh app's default config) silently clobber it.
    if [ -f "$live" ]; then
      mv "$live" "$live.bak"
      echo "backed up pre-existing $live -> $live.bak (repo version wins)"
    fi
  elif [ -f "$live" ]; then
    mkdir -p "$(dirname "$target")"
    mv "$live" "$target"
    echo "adopted $live into repo as $dest_name"
  else
    mkdir -p "$(dirname "$target")"
    touch "$target"
    echo "note: neither $live nor $target existed — created empty $target"
  fi

  mkdir -p "$(dirname "$live")"
  ln -s "$target" "$live"
  echo "linked: $live -> $target"
}

link "$HOME/.zshrc" "zshrc"
# link "$HOME/.tmux.conf" "tmux.conf"
link "$HOME/.vimrc" "vimrc"
link "$HOME/.gitconfig" "gitconfig"
link "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty" "ghostty/config.ghostty"

cd "$DOTFILES"
if [ ! -d .git ]; then
  git init -q
  echo "initialized git repo at $DOTFILES"
fi

echo ""
echo "Done. Review with: cd $DOTFILES && git status"
echo "First commit:      cd $DOTFILES && git add -A && git commit -m 'Initial dotfiles'"
echo "Create private repo + push (requires gh auth login once):"
echo "  cd $DOTFILES && gh repo create dotfiles --private --source=. --remote=origin --push"