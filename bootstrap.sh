#!/bin/bash
failed=()

confirm() {
  # $1 = prompt text. Returns success (0) only on an explicit y/Y answer. Anything else, including just hitting enter, is treated as no.
  local reply
  read -r -p "$1 [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

# --- Homebrew itself ---
if command -v brew >/dev/null 2>&1; then
  echo "Homebrew: already installed"
else
  echo "Homebrew: not found"
  if confirm "Install Homebrew now?"; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Load brew into THIS shell so the installs below can find it. The installer sets up shell config for future shells, not this one.
    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  else
    echo "Homebrew is required for everything below — stopping here."
    exit 1
  fi
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew was installed but isn't on PATH in this shell yet."
  echo "Restart your terminal and re-run this script to continue."
  exit 1
fi

install_formula() {
  local name="$1"
  if brew list --formula "$name" >/dev/null 2>&1; then
    echo "$name: already installed"
    return
  fi
  if confirm "Install $name?"; then
    if brew install "$name"; then
      echo "$name: installed"
    else
      echo "$name: install FAILED"
      failed+=("$name")
    fi
  else
    echo "$name: skipped"
  fi
}

install_cask() {
  local name="$1"
  if brew list --cask "$name" >/dev/null 2>&1; then
    echo "$name: already installed"
    return
  fi
  if confirm "Install $name?"; then
    if brew install --cask "$name"; then
      echo "$name: installed"
    else
      echo "$name: install FAILED"
      failed+=("$name")
    fi
  else
    echo "$name: skipped"
  fi
}

echo ""
echo "=== Terminal / shell ==="
install_cask ghostty
install_formula tmux
install_formula starship
install_formula zoxide
install_formula fzf
install_formula zsh-autosuggestions
install_formula zsh-syntax-highlighting

echo ""
echo "=== File & text viewing ==="
install_formula bat
install_formula ripgrep
install_formula fd
install_formula eza

echo ""
echo "=== Git tooling ==="
install_formula git-delta
install_formula lazygit
install_formula gh

echo ""
echo "=== Work-specific ==="
install_formula direnv
install_formula yq

echo ""
echo "=== Monitoring / reference ==="
install_formula btop
install_formula tealdeer

echo ""
echo "=== Fonts ==="
install_cask font-jetbrains-mono-nerd-font

echo ""
if [[ ${#failed[@]} -eq 0 ]]; then
  echo "Done — no failures."
else
  echo "Done, but these failed to install: ${failed[*]}"
  echo "(check the brew output above for why, then re-run this script)"
fi
echo ""
echo "If tealdeer was just installed, run once: tldr --update"
echo "Next: run setup.sh to symlink your config files into this repo."
