# Shell prompt: displays  <current dir> <context> <$>
# The prompt character ($) is magenta on success, red if the last command failed.
#
# Context is determined by environment:
#   - Gitpod CDE:     "CDE"
#   - Other machines: $DOT_CONTEXT (set in secrets/local.zsh), fallback to short hostname

_prompt_char() {
  local pc="${DOT_PROMPT_CHAR:-$}"   # allow overriding the prompt char via env var
  echo -n "%(?.%F{magenta}.%F{red})${pc}%f"
}

_prompt_context() {
  if [[ -n "$GITPOD_API_URL" ]]; then
    echo "CDE"
  else
    echo "${DOT_CONTEXT:-$(hostname -s)}"
  fi
}

# PROMPT_SUBST allows $(...) command substitutions to be evaluated on each render
setopt PROMPT_SUBST

# %F{color}...%f = set/reset foreground color
# %1~            = current directory (last component only)
# %n             = username
# %*             = current time (HH:MM:SS, 24-hour)
# Single quotes prevent expansion at assignment time — functions run on each render
PROMPT='%F{blue}%1~%f %F{cyan}%n%f%F{green}@%f%F{magenta}$(_prompt_context)%f %F{yellow}%*%f $(_prompt_char) '
