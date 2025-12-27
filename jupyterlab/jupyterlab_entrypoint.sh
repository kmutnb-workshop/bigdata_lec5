#!/usr/bin/env bash
set -euo pipefail

TOKEN="${JUPYTER_TOKEN:-}"
exec start-notebook.py   --ServerApp.token="${TOKEN}"   --ServerApp.ip=0.0.0.0   --ServerApp.open_browser=False
