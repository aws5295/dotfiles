# Dracula theme configuration.
# Full list of options: https://draculatheme.com/tmux

# Show powerline-style arrow separators between status bar segments
set -g @dracula-show-powerline true

# Show tmux window flags (e.g. * for current window, - for last window)
set -g @dracula-show-flags true

# Hide plugin segments that have no data to display
set -g @dracula-show-empty-plugins false

# Show CPU percentage rather than load average in the CPU widget
set -g @dracula-cpu-display-load false

# Icon shown on the far left of the status bar (options: session, smiley, window, or a custom string)
set -g @dracula-show-left-icon smiley

# Status bar widgets to display (left to right)
set -g @dracula-plugins "cpu-usage ram-usage git"
