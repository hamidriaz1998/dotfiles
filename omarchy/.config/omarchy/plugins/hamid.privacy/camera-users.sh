#!/bin/bash

# Names of processes holding a /dev/video* camera, one per line, deduplicated.
# Walks the user's own /proc/<pid>/fd links (always readable) because camera
# devices are often root-only, so fuser can't open them. One find, no per-fd
# forks: this runs every few seconds. Idea from bjarneo/sashimi.

find /proc/[0-9]*/fd -maxdepth 1 -lname '/dev/video*' -printf '%h\n' 2>/dev/null |
  cut -d/ -f3 | sort -u | xargs -r ps -o comm= -p 2>/dev/null | sort -u
