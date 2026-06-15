#!/bin/bash
# Created: Sat, Apr 04, 2026, at 04:00:43 PM
#
# @Purpose:
# 	Install the applescript-core first-party apps directly from the web.

set -e

PROJECT_CORE_DIR="$HOME/Projects/@roycetech/applescript-core"

if [ ! -d "$PROJECT_CORE_DIR" ]; then
    echo "E: applescript-core project was not found"
    exit 1
fi

PROJECT_DIR="$HOME/Projects/@roycetech/applescript-core-apps1"
REPO_URL="https://github.com/roycetech/applescript-core-apps1"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "Cloning lightweight repository..."
    git clone --depth=1 "$REPO_URL" "$PROJECT_DIR"
else
    echo "Updating lightweight repository..."
    git -C "$PROJECT_DIR" pull --depth=1 --rebase
fi

sudo mkdir -p /Library/Script\ Libraries/core/test
sudo mkdir -p /Library/Script\ Libraries/core/app

echo "Adding $(whoami) to the wheel group and allowing group write access to the Script Libraries folder..."
sudo dseditgroup -o edit -a "$(whoami)" -t user wheel \
  && sudo chmod g+w "/Library/Script Libraries" \
  && sudo chmod g+w "/Library/Script Libraries/core" \
  && sudo chmod g+w "/Library/Script Libraries/core/test" \
  && sudo chmod g+w "/Library/Script Libraries/core/app"

cd "$PROJECT_DIR"
make set-computer-deploy-type

PROCESS_SCPT="/Library/Script Libraries/core/process.scpt"
if [ ! -f "$PROCESS_SCPT" ]; then
    echo "core/process not found; building from applescript-core..."
    (cd "$PROJECT_CORE_DIR" && make build-process)
else
    echo "✅ core/process already installed: $PROCESS_SCPT"
fi

make build-base-app build-automator build-finder build-safari build-script-editor build-terminal 
