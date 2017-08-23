#!/bin/sh
git log --format='  - [`%h`](https://github.com/STEllAR-GROUP/hpx/commit/%H) %s' --author='Denis Blank' | tac
