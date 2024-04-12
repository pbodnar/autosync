#!/bin/bash

# This is an attempt to mimic the functionality of the `lsyncd` daemon, which is not available on Windows.
# In its core, this script is a simple loop of `inotifywait` and `rsync` as discussed here:
#
# https://stackoverflow.com/questions/12460279/how-to-keep-two-folders-automatically-synchronized
#
# Prerequisites:
#
# * `inotifywait` in PATH. For Windows, it needs to be downloaded/built from https://github.com/thekid/inotify-win.
# * `rsync` in PATH. Fow Windows, it can be installed via/into Cygwin, or MSYS2.

# Stop on any error
set -e

# Exit if there are not at least 2 arguments
if [ "$#" -lt 2 ]; then
    echo "Not enough arguments."
    echo "Usage: $0 SRC [SRC]... DEST"
    echo "* Both SRC and DEST are paths, which can be relative or absolute."
    echo "* The SRC paths are passed unmodified to inotifywait."
    echo "* All the paths are passed to rsync, run 'rsync --help' to get information about the possible DEST variations."
    echo "   On Windows, paths are converted to the Linux format via 'cygpath', before being passed to rsync."
    echo "WARNING: The script will not work if the paths contain spaces."
    exit 1
fi

# We pass all but the last argument to inotifywait, we pass all arguments to rsync
first_args=("${@:1:$#-1}")
all_args=("$@")

# Overridable options to be passed to inotifywait and rsync
INOTIFYWAIT_OPTS=${INOTIFYWAIT_OPTS:-"-r"}
RSYNC_OPTS=${RSYNC_OPTS:-"-avz"}

# Make the main loop interruptible by handling Ctrl+C
function handle_sigint() {
    echo "Script terminated by user."
    exit 0
}
trap handle_sigint SIGINT

# Convert paths to Linux format if we are on Windows
if [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]]; then
    # Just for the special case when using Cygwin's rsync from Git Bash (better use the MSYS2's there),
    # see https://stackoverflow.com/questions/29941966/rsync-cwrsync-in-gitbash-the-source-and-destination-cannot-both-be-remote/67658259#67658259.
    export MSYS_NO_PATHCONV=1

    # Note: If the path doesn't look like a Windows path,
    # cygpath will return it as is (which we want).
    all_args=($(printf "%s\0" "${all_args[@]}" | xargs -0 cygpath))
fi

# Main loop
echo "# Starting the sync loop"
while true; do
    echo "# Syncing..."
    rsync $RSYNC_OPTS "${all_args[@]}"
    echo "# Waiting for changes..."
    inotifywait $INOTIFYWAIT_OPTS "${first_args[@]}"
done
