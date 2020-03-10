#! /bin/bash

# This script will show the number of commits between develop and master for all repositories 
# found in the data catalog, provided the repository is cloned in the specified destination directory.

data_catalog="${1}"
dest_dir="${2}"

if [ -z "${dest_dir}" ]
then
    echo "Usage: $0 <data_catalog> <destination dir>"
    echo "Will check out all repositories in data catalog to destination dir"
    exit 1
fi

data_catalog="${data_catalog}"

cd "${dest_dir}" || exit 1

for repourl in $(jq '.dataset[].distribution[] | select(.format=="gitrepo") | .downloadURL' "${data_catalog}" | sed -e 's/"//g')
do
    reponameext="$(basename "$repourl")"
    reponame="${reponameext%.*}"

    if [ -d "${reponame}" ]
    then
        pushd "${reponame}" > /dev/null || exit 1
        commitcount=$(git rev-list --left-right --count origin/master..origin/develop | awk '{print $2}')
        if [ "${commitcount}" -ne 0 ]
        then
            compareurl="${repourl%.*}/compare/master...develop"
        else
            compareurl=
        fi
        printf "%-40s %5d   %s\n" "${reponame}" "${commitcount}" "${compareurl}"
        popd > /dev/null || exit 1
    else
        echo "${reponame}: N/A, not cloned"
    fi
done
