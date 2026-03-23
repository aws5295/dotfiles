# ANSI terminal color variables — used in prompt and alias output.
# Usage: echo "${Red}error text${Rst}"
#
# Alternative: autoload -U colors && colors
# then use: echo "${fg[red]}text${reset_color}"

TC='\e['               # ANSI escape sequence prefix
Rst="${TC}0m"          # reset all colors and styles back to default
Black="${TC}30m"
Red="${TC}31m"
Green="${TC}32m"
Yellow="${TC}33m"
Blue="${TC}34m"
Purple="${TC}35m"
Cyan="${TC}36m"
White="${TC}37m"
