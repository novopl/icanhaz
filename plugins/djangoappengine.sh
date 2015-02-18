#!/bin/bash
declare -A COMMANDZ
COMMANDZ=(
    [devsrv]='cmd_gae_devsrv'
    [deploy]='cmd_gae_deploy'
)
export COMMANDZ


#----------------------------------------------------------------------------//
function cmd_gae_devsrv() {
    icanhaz clean
    sysmsg "STARTIN TEH SERVR"
    ./manage.py runserver $@
}
#----------------------------------------------------------------------------//
function cmd_gae_deploy() {
    sysmsg "UPLOADIN TEH APP 2 TEH SERVR"
    local lxmlpath=${PYLIBDIR}/lxml
    $(test -d ${lxmlpath})
    local haslxml=$?

    if [  ${haslxml} -eq 0 ]; then
        sysmsg "Moving lxml away for deployment"
        mv ${PYLIBDIR}/lxml ../
    fi

    ./manage.py deploy $@

    if [  ${haslxml} -eq 0 ]; then
        sysmsg "Moving lxml back into libs"
        mv ../lxml ${PYLIBDIR}
    fi
}
