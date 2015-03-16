#!/bin/bash
# For more information about icanhaz, visit: http://github.com/novopl/icanhaz
declare -A COMMANDZ
COMMANDZ=(
    [clean]='cmd_clean'
    [icanhazrc]='cmd_icanhazrc'
)

CLEANPTTRNS=(
    "*~"
    "*swp"
)
CLEANEXCL=(
)
#----------------------------------------------------------------------------//
function cmd_clean() {
    sysmsg "CLEANIN DIS SHIT"
    local exclude=''

    for expttrn in "${CLEANEXCL[@]}"; do
        exclude="$exclude -not -ipath $expttrn"
    done


    for pttrn in "${CLEANPTTRNS[@]}"; do
        files=$(find -L ./ -iname "$pttrn" $exclude)
        sysmsg "  - Cleaning \"${pttrn}\""
        dbgmsg "     \e[1mWorking dir: \e[0m$(pwd)"
        dbgmsg "     \e[90mEXCLUDE: $exclude\e[0m"
        dbgmsg "     \e[90mrm -rf \$(find -L ./ -iname "$pttrn" $exclude)\e[0m"

        [ -n "$files" ] && dbgmsgv "\r\e[90m$files\e[0m"
        rm -rf $files
    done
}
#----------------------------------------------------------------------------//
function cmd_icanhazrc() {
    sysmsg "CREATIN LOCAL ICANHAZ CONFIGURATION IN \e[1m$(pwd)\e[0m"
    touch $(pwd)/icanhazrc
    echo '#!/bin/bash' > $(pwd)/icanhazrc
    echo '# For more information about icanhaz, visit: http://github.com/novopl/icanhaz' >> $(pwd)/icanhazrc
    echo 'declare -A COMMANDZ' >> $(pwd)/icanhazrc
    echo 'COMMANDZ=(' >> $(pwd)/icanhazrc
    echo "    [sample-cmd]='cmd_sample'" >> $(pwd)/icanhazrc
    echo ")" >> $(pwd)/icanhazrc
    echo "" >> $(pwd)/icanhazrc
    echo '#----------------------------------------------------------------------------//' >> $(pwd)/icanhazrc
    echo 'function cmd_sample() {' >> $(pwd)/icanhazrc
    echo '    # Implement your command here' >> $(pwd)/icanhazrc
    echo '    echo "my icanhaz command"' >> $(pwd)/icanhazrc
    echo '}' >> $(pwd)/icanhazrc
    echo "" >> $(pwd)/icanhazrc
}
