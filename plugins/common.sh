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
#----------------------------------------------------------------------------//
function cmd_clean() {
    sysmsg "CLEANIN DIS SHIT"
    for pttrn in "${CLEANPTTRNS[@]}"; do
        #sysmsg "  - Cleaning \"${pttrn}\""
        rm -rf $(find -L -iname "${pttrn}")
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
