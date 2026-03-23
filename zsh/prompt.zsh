# Shell prompt: displays  <current dir> <user>@<host> <$>
# The prompt character ($) is magenta on success, red if the last command failed.

_prompt_char() {
  local pc="${DOT_PROMPT_CHAR:-$}"   # allow overriding the prompt char via env var
  echo -n "%(?.%F{magenta}.%F{red})${pc}%f"
}

# %F{color}...%f = set/reset foreground color
# %1~            = current directory (last component only)
# %n             = username
# %m             = short hostname
PROMPT="%F{blue}%1~%f %F{cyan}%n%f%F{red}@%f%F{yellow}%m%f $(_prompt_char) "
