#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"&>/dev/null &&pwd)" # SCRIPT_DIR

systemctl restart --user kwin_x11.service
systemctl restart --user fcitx.service
