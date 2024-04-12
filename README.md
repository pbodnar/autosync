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

_On Windows_, you will typically run the script from Git Bash ("a customized distro of MSYS2";
part of Git for Windows), or Cygwin terminal.

### Ad-hoc script usage

You can run the script directly for an ad-hoc usage.

_On Windows:_

```text
$ autosyncdir.sh 'c:\path\to\source_dir1\' 'c:\path\to\source_dir2\' 'c:\path\to\target_dir'
$ # an alternative with forward slashes:
$ # autosyncdir.sh c:/path/to/source_dir1/ c:/path/to/source_dir2/ c:/path/to/target_dir
# Starting the sync loop
# Syncing...
sending incremental file list

sent 98 bytes  received 12 bytes  220.00 bytes/sec
total size is 13  speedup is 0.12
# Waiting for changes...
===> Watching c:\path\to\source_dir1\ -r*.* for create, modify, delete, move
===> Watching c:\path\to\source_dir2\ -r*.* for create, modify, delete, move
```

_On Linux:_

```text
$ autosyncdir.sh /path/to/source_dir1/ /path/to/source_dir2/ /path/to/target_dir
# Starting the sync loop
# Syncing...
sending incremental file list

sent 98 bytes  received 12 bytes  220.00 bytes/sec
total size is 13  speedup is 0.12
# Waiting for changes...
===> Watching /path/to/source_dir1/ -r*.* for create, modify, delete, move
===> Watching /path/to/source_dir2/ -r*.* for create, modify, delete, move
```

### Persisted script usage

Usually, you will want to prepare another script where you can persist
all what you need to synchronize.

Here is an example of such a script (name it e.g. `sync_my_dirs.sh`).

_On Windows:_

```bash
#!/bin/bash

# Starts to automatically watch and sync all my directories.

server_cfg='c:\server1\cfg'

autosyncdir.sh 'c:\project1\env\devel\' $server_cfg'\project1' &
autosyncdir.sh 'c:\project2\env\devel\' $server_cfg'\project2' &

wait
```

_On Linux:_

```bash
#!/bin/bash

# Starts to automatically watch and sync all my directories.

server_cfg=~/server1/cfg

autosyncdir.sh ~/project1/env/devel/ $server_cfg/project1 &
autosyncdir.sh ~/project2/env/devel/ $server_cfg/project2 &

wait
```

### Passing custom options to inotifywait and rsync

You can override options which are passed by the script to `inotifywait` and `rsync`
by setting environment variables as in the following example.

```bash
#!/bin/bash

# default: "-r" (recursive)
export INOTIFYWAIT_OPTS=" "

# WARNING: Be careful with the --delete option, as it will delete missing files in the target directory!
# default: "-avz" (archive, verbose, compress)
export RSYNC_OPTS="-avz --delete"

autosyncdir.sh /path/to/source_dir /path/to/target_dir
```

[lsyncd]: hhtps://github.com/lsyncd/lsyncd
