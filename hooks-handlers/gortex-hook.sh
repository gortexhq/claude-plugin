#!/usr/bin/env bash
# gortex marketplace-plugin hook wrapper.
# Locates the gortex binary on PATH and forwards the Claude Code hook
# event to `gortex hook`. Falls back to a soft-fail (warn-and-exit-0)
# when gortex is not installed, so a missing binary never blocks the
# user's session — the marketplace plugin can always be installed in
# advance of the binary.
#
# Install gortex via:  curl -fsSL https://get.gortex.dev | sh
set -u

if ! command -v gortex >/dev/null 2>&1; then
  echo "gortex binary not found on PATH — install via 'curl -fsSL https://get.gortex.dev | sh' to enable graph-aware hooks." >&2
  exit 0
fi

exec gortex hook "$@"
