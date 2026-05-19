#!/usr/bin/env bash

install_editor_extensions() {
  local editor_cli="$1"
  local editor_name="$2"
  local extensions_file="$DOTFILES/vscode/extensions"
  local installed_exts
  local ext
  local ext_normalized

  # Some environments have editor CLI stubs that do not support extension installs.
  if ! command -v "$editor_cli" &>/dev/null || ! "$editor_cli" --list-extensions &>/dev/null; then
    warn "$editor_cli not found or does not support extension installs — skipping"
    return
  fi

  info "installing $editor_name extensions..."
  installed_exts="$("$editor_cli" --list-extensions | tr '[:upper:]' '[:lower:]')"

  while IFS= read -r ext || [[ -n "$ext" ]]; do
    [[ "$ext" =~ ^[[:space:]]*$ || "$ext" =~ ^[[:space:]]*# ]] && continue

    ext_normalized="$(echo "$ext" | tr '[:upper:]' '[:lower:]')"
    if echo "$installed_exts" | grep -qx "$ext_normalized"; then
      info "  $ext already installed, skipping"
    else
      "$editor_cli" --install-extension "$ext" || warn "failed to install $editor_name extension: $ext"
    fi
  done < "$extensions_file"
}
