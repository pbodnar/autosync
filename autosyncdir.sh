#!/bin/bash

# This is an attempt to mimic the functionality of the `lsyncd` daemon, which is not available on Windows.
# In its core, this script is a simple loop of `inotifywait` and `rsync` as discussed here:
#
# https://stackoverflow.com/questions/12460279/how-to-keep-two-folders-automatically-synchronized
#
# Prerequisites:
#
# * `inotifywait` in PATH. For Windows, it needs to be downloaded/built from https://github.com/thekid/inotify-win.
# * `rsync` in PATH. Fow Windows, it can be installed via/into Cygwin, or downloaded from
#   [MSYS2](https://stackoverflow.com/questions/75752274/rsync-for-windows-that-runs-with-git-for-windows-mingw-tools).

# Stop on any error
set -e

# Exit if there are not at least 2 arguments
if [ "$#" -lt 2 ]; then
    echo "Not enough arguments."
    echo "Usage: $0 SRC [SRC]... DEST"
    echo "All the arguments are passed unmodified to rsync, so just run 'rsync --help' to get information about the possible DEST argument variations."
    exit 1
fi

# We pass all but the last argument to inotifywait, we pass all arguments to rsync
last_arg=${@:$#}
first_args=("${@:1:$#-1}")

# Make the main loop interruptible by handling Ctrl+C
function handle_sigint() {
    echo "Script terminated by user."
    exit 0
}
trap handle_sigint SIGINT

# Main loop
echo "Starting the sync loop"
while true; do 
    inotifywait -r "${first_args[@]}"
    rsync -avz "${first_args[@]}" "$last_arg"
done
