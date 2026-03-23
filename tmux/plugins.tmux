# ── Tmux Plugin Manager (TPM) ─────────────────────────────────────────────────
# TPM is installed by install.sh into ~/.tmux/plugins/tpm
# After adding a plugin here, press Ctrl+A I inside tmux to install it.
# To update plugins: Ctrl+A U. To remove: Ctrl+A Alt+U.

set -g @plugin 'tmux-plugins/tpm'           # the plugin manager itself
set -g @plugin 'tmux-plugins/tmux-sensible'  # a set of sensible default tmux settings everyone can agree on

# Dracula color theme for the status bar
set -g @plugin 'dracula/tmux'

# tmux-resurrect: manually save and restore tmux sessions across system restarts
# Save: Ctrl+A Ctrl+S  |  Restore: Ctrl+A Ctrl+R
set -g @plugin 'tmux-plugins/tmux-resurrect'

# tmux-continuum: automatically saves the session every 15 minutes and restores on tmux start
set -g @plugin 'tmux-plugins/tmux-continuum'
