#! /bin/bash

# This script will clone (if not yet cloned) or fetch (if already cloned) repositories specified in the data catalog
# to the specified destination directory.

data_catalog="${1}"
dest_dir="${2}"
git_command="${3}"
git_token_file="${4}"

if [ -z "${dest_dir}" ]
then
    echo "Usage: $0 <data_catalog> <destination dir> [<git-command>] [<github-token>]"
    echo "Will check out all repositories in data catalog to destination dir"
    exit 1
fi

if [ -z "${git_command}" ]
then
    git_command=fetch
fi

if [ -n "${git_token_file}" ]
then
    url_host="https:\/\/$(cat "${git_token_file}")@"
else
    url_host="git@github.com:"
fi

data_catalog="${data_catalog}"
basedir="$(cd $(dirname "$0") && pwd)"

cd "${dest_dir}" || exit 1

for repourl in $(python "${basedir}/listrepos.py" "${data_catalog}" | sed -e "s/https:\/\/github.com\//${url_host}/" -e 's/"//g')
do
    echo "${repourl}"
    reponameext="$(basename "${repourl}")"
    reponame="${reponameext%.*}"

    if [ ! -d "${reponame}" ]
    then
        echo "Cloning ${reponame}..."
        git clone "${repourl}"
    else
        echo "Fetching ${reponame}..."
        pushd "${reponame}" || exit 1
        git ${git_command} --all
        popd || exit 1
    fi
done
