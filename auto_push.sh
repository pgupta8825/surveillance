#!/bin/bash

# Path to the directory you want to monitor
WATCH_DIR="/var/lib/motion"
# Path to your git repository (this is the directory where you initialized git)
REPO_DIR="/var/lib/motion" 

# GitHub repository info
REPO_URL="https://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@github.com/pgupta8825/surveillance.git"

BRANCH="master"  # or 'main', depending on your default branch

# Log file to track commit timestamps
LOG_FILE="/var/lib/motion/commit_log.txt"

# Navigate to the repository directory
cd $REPO_DIR

# Loop indefinitely to watch for new files
while true; do
  # Wait for new .mkv file creation in the watch directory
  inotifywait -m -e create --format '%f' $WATCH_DIR | while read NEW_FILE
  do
    # Check if the new file is an .mkv file
    if [[ "$NEW_FILE" == *.mkv ]]; then
      echo "New video file detected: $NEW_FILE"
      
      # Check if the file has been staged or committed already
      if git ls-files --error-unmatch "$WATCH_DIR/$NEW_FILE" > /dev/null 2>&1; then
        echo "File $NEW_FILE is already tracked. Skipping."
      else
        # Add new files to git
        git add "$WATCH_DIR/$NEW_FILE"
        
        # Commit the changes
        git commit -m "Add new video: $NEW_FILE"
        
        # Push the changes to GitHub
        git push origin $BRANCH
        echo "Pushed new video: $NEW_FILE"
        
        # Log the commit time and file name to the log file
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Committed and pushed $NEW_FILE" >> $LOG_FILE
      fi
    fi
  done
done
