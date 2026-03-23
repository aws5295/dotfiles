# -*- mode: sh -*-
# Machine-local secrets — copy this file to secrets/local.zsh and fill in values.
# secrets/local.zsh is gitignored and never committed.
#
# To create: cp secrets/example.zsh secrets/local.zsh

# ── Shell prompt ──────────────────────────────────────────────────────────────
# Label shown in the prompt to identify this machine (e.g. Vanta, personal)
DOT_CONTEXT=""

# ── Vanta / ona CLI ───────────────────────────────────────────────────────────
# IDs used by the cde() function in work/vanta.zsh.
# Find them with: ona project list -o json / ona environment list-classes -o json

# ona project ID for the default project
ONA_PROJECT_ID=""

# ona environment class ID for r7a.4xlarge in Ohio
ONA_OHIO_CLASS_ID=""
