#!/bin/bash
# ---------------------------------------------------------------
# Ninja Build System
# ---------------------------------------------------------------
set -eE
set -o pipefail

# Must be done first.
this=$(cd $(dirname $0) && pwd)
cd $this

# ---------------------------------------------------------------
# Includes
# ---------------------------------------------------------------
source util.sh

# ---------------------------------------------------------------
# Initialization
# ---------------------------------------------------------------
# This must be a lowercase short word with no spaces describing
# the software being built. Folders/links will be named with
# this.
project_key="ninja"
bin_name=ninja

tools="$HOME/dev/tools"
mkdir -p "$tools"
prefix="$tools/$project_key"
# Only needed in builds that don't have an install step.
mkdir -p $prefix

acct="dpacbach"
repo="ninja"

# ---------------------------------------------------------------
# Create Work Area
# ---------------------------------------------------------------
cd /tmp

work=$project_key-build

[[ -d $work ]] && /bin/rm -rf "$work"
mkdir -p $work
cd $work

# ---------------------------------------------------------------
# Clone Repo
# ---------------------------------------------------------------
git clone --depth=1       \
          --branch=master \
          https://github.com/$acct/$repo

cd $repo

# ---------------------------------------------------------------
# Configure
# ---------------------------------------------------------------
mkdir build && cd build

cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo

# ---------------------------------------------------------------
# Build
# ---------------------------------------------------------------
make -j$(build_threads)

[[ -x ninja ]]
cp ninja $prefix/ninja

# ---------------------------------------------------------------
# Test Run
# ---------------------------------------------------------------
$prefix/ninja --version

# ---------------------------------------------------------------
# Make Links
# ---------------------------------------------------------------
mkdir -p ~/bin
rm -f ~/bin/ninja
ln -s $tools/$project_key/ninja ~/bin/ninja

# ---------------------------------------------------------------
# Finish
# ---------------------------------------------------------------
log "success."
