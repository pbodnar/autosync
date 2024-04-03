# autosyncdir

A simple bash script which lets you _automatically_ synchronize one or more directories to a target folder
whenever files in the watched directories change.

This is a much more primitive variant of the [lsyncd][lsyncd] tool.
Unlike `lsyncd` though, this script can also run in Cygwin terminal or in Git Bash on Windows.

## Installation

1. Download the `autosyncdir.sh` script to any directory on your PC.
   You can also do that by Git-cloning the whole project.
2. The script relies on `inotifywait` and `rsync`.
   Parent directories of these programs need to be in the system PATH
   (see script's source code for more details).
3. Put the script's directory to the system PATH, so that you can run it easily just by its name.

## Usage

Simply run the script without any parameters in order to get the basic usage help.

Press <kbd>Ctrl+C</kbd> at any time to terminate the script.

### Ad-hoc script usage

You can run the script directly for an ad-hoc usage, e.g.:

```text
$ autosyncdir.sh /path/to/source_dir1 /path/to/source_dir2 /path/to/target_dir
Starting the sync loop
===> Watching /path/to/source_dir1 -r*.* for create, modify, delete, move
===> Watching /path/to/source_dir2 -r*.* for create, modify, delete, move
```

### Persisted script usage

Usually, you will want to prepare another script where you can persist
what you need to synchronize.

Here is an example of such a script (name it e.g. `sync_my_dirs.sh`):

```bash
#!/bin/bash

# Starts to automatically watch and sync all my directories.

server_cfg=~/server/cfg

autosyncdir.sh ~/project1/env/devel $server_cfg/project1 &
autosyncdir.sh ~/project2/env/devel $server_cfg/project2 &

wait
```

[lsyncd]: hhtps://github.com/lsyncd/lsyncd
