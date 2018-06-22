#!/bin/bash
set -x
set -e
set -u

export release=0.3.0 # release number for coen
export DATE=20180311 #`date +%Y%m%d` # Selected date for version packages
export dist=stretch # Debian Distribution
export arch=amd64 # Target architecture
export SHASUM="52ab766f63016081057cd2c856f724f77d71f9e424193fe56e6a52fcb4271a9e  -"
export SOURCE_DATE_EPOCH="$(date --utc --date="$DATE" +%s)" # defined by reproducible-builds.org
export WD=/opt/coen-${release}	# Working directory to create the ISO
export ISONAME=${WD}-${arch}.iso # Final name of the ISO image
export TOOL=/tools # Tools
export HOOKS=/tools/hooks # Hooks
export PACKAGE=/tools/packages # Packages
