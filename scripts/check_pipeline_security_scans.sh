#!/bin/bash
# Check pipeline security by examining cloudbuild.yaml for presence of security scanners.

repodir="${1}"

if [ -z "${repodir}" ]
then
    echo "Usage: $0 <repodir>"
    exit 1
fi

cd "${repodir}" || exit 1

declare -A pindex
pindex=([HasApp]=0 [IsAPI]=1 [SAST]=2 [DAST]=3 [UnitTst]=4 [Zally]=5)
ptitles=("HasApp" "IsAPI" "SAST" "DAST" "UnitTst" "Zally")
pformat="%-40s"
pline="----------------------------------------"

for index in "${!ptitles[@]}"
do
    pformat="${pformat} %-7s"
    pline="${pline}--------"
    ptotals[index]=0
    pcountok[index]=0
    pstats[index]="-"
done

pformat="${pformat}\n"

echo "Pipeline security scan status $(date)"
echo
printf "${pformat}" "Pipeline" ${ptitles[@]}
echo "${pline}"

function update_stats
{
    vtitle="${1}"
    vresult="${2}"

    pstats[pindex["${vtitle}"]]="${vresult}"

    if [ "${vresult}" != "-" ]
    then
        ((ptotals[pindex[${vtitle}]]++))
    fi

    if [ "${vresult}" == "ok" ] || [ "${vresult}" == "Y" ]
    then
        ((pcountok[pindex[${vtitle}]]++))
    fi
}

for cloudbuild in $(find . -name cloudbuild.yaml -exec grep -le "app deploy" -e "'app'" {} \; | sort)
do
    pipeline=$(dirname "${cloudbuild}")
    update_stats "HasApp" "Y"
    update_stats "IsAPI" "$(grep -q "openapi" "${cloudbuild}" && echo "Y" || echo "N")"

    update_stats "SAST" "$(grep -q cloudbuilder-sast "${cloudbuild}"  && echo "ok" || echo "misses")"
    update_stats "DAST" "$(grep -q cloudbuilder-dast "${cloudbuild}"  && echo "ok" || echo "misses")"

    if [ "${pstats[pindex[IsAPI]]}" == "Y" ]
    then
        update_stats "UnitTst" "$(grep -q cloudbuilder-unittest "${cloudbuild}"  && echo "ok" || echo "misses")"
        update_stats "Zally" "$(grep -q cloudbuilder-zally "${cloudbuild}"  && echo "ok" || echo "misses")"
    else
        update_stats "UnitTst" "-"
        update_stats "Zally" "-"
    fi

    printf "${pformat}" "${pipeline}" ${pstats[@]}
done

for index in "${!ptitles[@]}"
do
    ptotalstats[index]="${pcountok[index]}/${ptotals[index]}"
done

echo "${pline}"
printf "${pformat}" "TOTALS" ${ptotalstats[@]}
