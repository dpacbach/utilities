#!/bin/bash
# This script will INSTALL the latest tag of Catch2 into the
# $HOME/.local/ prefix.  It can also be used to update to the
# latest version.
set -e
set -o pipefail

cd /tmp

work=catch2-build

[[ -d $work ]] && /bin/rm -rf "$work"
mkdir -p $work
cd $work

die() {
  echo "$@" >&2
  exit 1
}

acct="catchorg"
repo="Catch2"

latest_github_repo_tag() {
    local acct_name="$1"
    local repo_name="$2"
    local api_url="https://api.github.com/repos/$acct_name/$repo_name/tags"
    # FROM: "name": "v8.1.0338",
    # TO:   v8.1.0338
    curl --silent $api_url | grep '"name":'            \
                           | grep -v -i develop        \
                           | head -n1                  \
                           | sed -r 's/.*"(.*)",?/\1/'
}

clone_latest_tag() {
    local acct_name="$1"
    local repo_name="$2"
    # non-local
    version=$(latest_github_repo_tag $acct_name $repo_name)
    echo "Latest version of $acct_name/$repo_name: $version"
    sleep 3
    git clone --depth=1 --branch=$version https://github.com/$acct_name/$repo_name
}

clone_latest_tag $acct $repo
cd $repo
mkdir build
cd build

prefix="$HOME/.local"

cmake .. -DCMAKE_INSTALL_PREFIX="$prefix"

if which nproc 2>/dev/null; then
    threads=$(nproc --all)
else
    threads=4
fi

make -j$threads
make -j$threads test
make install