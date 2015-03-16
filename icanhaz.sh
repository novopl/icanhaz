[ -z "$VERBOSE" ] && VERBOSE=0
SYSDIR="$ICANHAZ_INSTALL_DIR"
USERDIR="$HOME/.icanhaz"
GLOBALCONF="/etc/icanhazrc"
USERCONF=$(find ~ -maxdepth 1 -name "\.icanhazrc")
LOCALCONF="icanhazrc"
declare -A ALL_CMDS

# Load configuration
function sysmsg() {
    local now=$(date "+%I:%M:%S %p")
    echo -e "\e[90m${now}\e[39m $@"
}
function dbgmsg() {
    if [ $VERBOSE -gt 0 ]; then
        local now=$(date "+%I:%M:%S %p")
        echo -e "\e[90m${now}\e[39m $@"
    fi
}
function dbgmsgv() {
    if [ $VERBOSE -gt 1 ]; then
        local now=$(date "+%I:%M:%S %p")
        echo -e "\e[90m${now}\e[39m $@"
    fi
}
function dbgmsgvv() {
    if [ $VERBOSE -gt 2 ]; then
        local now=$(date "+%I:%M:%S %p")
        echo -e "\e[90m${now}\e[39m $@"
    fi
}
export -f sysmsg
export -f dbgmsg
export -f dbgmsgv
export -f dbgmsgvv
export PATH="$USERDIR/bin:$ICANHAZ_INSTALL_DIR/bin:$PATH"


#----------------------------------------------------------------------------//
function main() {
    dbgmsg "Loading configuration"

    # Parse command line
    local action=""
    while getopts "lh" o;
    do
        case "$o" in
            l)  action="list";;
            h)  action="help";;
            *)  usage;;
        esac
    done
    shift $((OPTIND-1))

    load_plugins "${SYSDIR}/plugins"
    load_plugins "${USERDIR}/plugins"
    load_configuration

    case "$action" in
        list)   list_all_commands;;
        help)   print_help;;
        *   )   if [ $# -lt 1 ]; then
                    print_help
                else
                    execute_cmd $@
                fi;;
    esac
}
#----------------------------------------------------------------------------//
function usage() {
    echo "Usage: $0 [-lh] <command> <command arguments>"
    exit 1;
}
#----------------------------------------------------------------------------//
function print_help() {
    echo "Usage: $0 [-lh] <command> <command arguments>" 1>&2
    echo ""
    echo "  -l          list all available commands without any formatting."
    echo "  -h          Print this help."
    echo ""
    print_all_commands
}
#----------------------------------------------------------------------------//
function parse_cmdline() {
    while getopts "lh" o;
    do
        echo "OPTION $o"
        case "$o" in
            l)  list_all_commands;;
            h)  print_help;;
            *)  usage;;
        esac
    done
    shift $((OPTIND-1))
}
#----------------------------------------------------------------------------//
function load_plugins() {
    local srcdir=$1
    dbgmsg "Loading plugins from $srcdir"
    if [[ -d $srcdir ]]; then
        for plugin in $(find "${srcdir}" -iname "*.sh"); do
            dbgmsg "Loading $plugin"
            source $plugin
            for cmdname in ${!COMMANDZ[@]}; do
                dbgmsg "  [cmd] $cmdname"
                ALL_CMDS[$cmdname]=${COMMANDZ[$cmdname]}
            done
        done
    else
        echo -e "\e[1m$srcdir\e[0m does not exist"
    fi
}
#----------------------------------------------------------------------------//
function load_configuration() {
    if [ -e "${GLOBALCONF}" ]; then
        dbgmsg "Loading ${GLOBALCONF}"
        source ${GLOBALCONF}
        for cmdname in ${!COMMANDZ[@]}; do
            sysmsg "  [cmd] $cmdname"
            ALL_CMDS[$cmdname]=${COMMANDZ[$cmdname]}
        done
    else
        dbgmsg "No global configuration found"
    fi

    if [ -e "${USERCONF}" ]; then
        dbgmsg "Loading ${USERCONF}"
        source ${USERCONF}
        for cmdname in ${!COMMANDZ[@]}; do
            dbgmsg "  [cmd] $cmdname"
            ALL_CMDS[$cmdname]=${COMMANDZ[$cmdname]}
        done
    else
        dbgmsg "No user configuration found"
    fi

    if [ -e "${LOCALCONF}" ]; then
        dbgmsg "Loading ${LOCALCONF}"
        source ${LOCALCONF}
        for cmdname in ${!COMMANDZ[@]}; do
            dbgmsg "  [cmd] $cmdname"
            ALL_CMDS[$cmdname]=${COMMANDZ[$cmdname]}
        done
    else
        dbgmsg "No local configuration found"
    fi
}
#----------------------------------------------------------------------------//
function list_all_commands() {
    # List all available commands without any formatting
    echo "${!ALL_CMDS[@]}"
}
#----------------------------------------------------------------------------//
function print_all_commands() {
    # Print nicely formatted list of all available commands.
    echo "Available commands:"
    local sorted=($(echo "${!ALL_CMDS[@]}" | sed 's/ /\n/g' | sort))
    for cmdname in "${sorted[@]}"; do
        echo "  ${cmdname}"
    done
}
#----------------------------------------------------------------------------//
function execute_cmd() {
    # Execute command
    cmd=$1
    shift 1

    for cmdname in "${!ALL_CMDS[@]}"; do
        if [ "${cmdname}" == "${cmd}" ]; then
            cmdfunc=${ALL_CMDS[$cmdname]}
            dbgmsg "Executing ${cmdname}:${cmdfunc}"
            ${cmdfunc} $@
            exit
        fi
    done

    # Try passing the command to manage py
    if [ -e manage.py ]; then
        sysmsg "THAR IZ NO COMMAND '${cmd}' PASSIN TO ./manage.py"
        ./manage.py ${cmd} $@
    else
        sysmsg "Command '${cmd}' not found"
    fi
}

main $@
