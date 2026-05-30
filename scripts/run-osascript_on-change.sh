# @Purpose: 
#   Watch the filesystem for changes and run the specified AppleScript file, 
#       usually triggering the spotCheck routine.

# @Created: Wed, May 27, 2026, at 08:32:28 AM
#   Copied from applescript-core-apps3/scripts/run-osascript_on-change.sh.

# Can handle spaces in the filepath DID NOT WORK.
fswatch -e ".*" -i ".*\\.applescript$" . | while IFS= read -r filepath; do
  clear
  osascript "$filepath"
done