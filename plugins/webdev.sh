#!/bin/bash
declare -A COMMANDZ
COMMANDZ=(
    [init-dev]='cmd_gae_init_dev_env'
    [pylib]='pylib_install'
)
export COMMANDZ

PYLIBDIR="lib/py"
CLEANPTTRNS=("*~" "*swp" "*.pyc" "__pycache__")
CLEANEXCL=("virtualenv")
export PATH="$(pwd)/google_appengine:$PATH"
export PYTHONPATH="${PYLIBDIR}"
export DJANGO_SETTINGS_MODULE="settings"


#----------------------------------------------------------------------------//
function call_verbose() {
    if [ $VERBOSE -gt 0 ]; then
        $@ 
    else
        $@ &> /dev/null
    fi
}
#----------------------------------------------------------------------------//
function pylib_install() {
    if [ ! -e 'loadenv.sh' ]; then
        echo -e "-- \e[91mloadenv.sh script not found!\e[39m"
        exit -2
    fi
    source loadenv.sh &> /dev/null
    local pkgRootDir=$(pwd)
    local envLibs=$(realpath nocommit/virtualenv/lib/python2.?/site-packages)
    local pkg=$1

    if [ -z $VIRTUAL_ENV ]; then
        echo -e "-- \e[31mNo virtualenv detected\e[0m"
        return
    fi

    local pipOpts=''
    [ $VERBOSE -eq 0 ] && pipOpts='--quiet'

    echo -e "-- \e[1mInstalling \e[0m\e[32m$pkg\e[0m \e[1mfrom pypi\e[0m"
    pip install $pkg $pipOpts

    # If more than one argument was given, the link to the newly installed
    # package will be created. The second argument is the name of the python
    # module that was installed by the current package, and optional
    # 3rd argument is the name of the resulting link inside $PYLIBDIR and it
    # defaults to the python module name (second argument) if not specified.
    if [[ $# -ge 2 ]]; then
        if [ -z $PYLIBDIR ]; then
            [ $VERBOSE > 0 ] && echo -e "-- \e[33m\$PYLIBDIR not defined\e[0m"
            return
        fi

        local linkSrc=$2
        local linkDst="$linkSrc"
        [[ $# -ge 2 ]] && linkDst=$3

        cd "$PYLIBDIR"
        echo -e "-- \e[1mSymlinking \e[0m\e[32m$linkSrc\e[0m" \
                "\e[1mfrom virtualenv to \e[0m./lib/py/$linkDst"

        ln -s "$envLibs/$linkSrc" "./$linkDst"
        cd "$pkgRootDir"
    fi
}
#----------------------------------------------------------------------------//
function ensure_appengine_sdk() {
    if [ ! -e './google_appengine' ]; then
        read  -e -p ">> Enter path to Google AppEngine installation: " gpath
        if [ ! -e "$gpath/google" ]             || \
           [ ! -e "$gpath/dev_appserver.py" ]   || \
           [ ! -e "$gpath/appcfg.py" ];         then
            echo -e "-- \e[91mInvalid Google AppEngine SDK path!\e[39m"
            exit -1
        fi
        local lnkPath='./google_appengine'
        echo -e "-- \e[1mAppEngine SDK path:\e[0m $gpath"
        echo -e "-- \e[1mCreating symlink to AppEngine SDK\e[0m: $lnkPath"
        ln -s $(realpath "$gpath") ./google_appengine
    fi
}
#----------------------------------------------------------------------------//
function ensure_virtualenv() {
    local envPath=$1
    if [ -d "$envPath" ] && [ -x "$envPath/bin/python" ]; then
        echo -e "-- virtualenv \e[1m$envPath\e[0m already exists"
    else
        echo -e "-- \e[1mCreating virtualenv in\e[0m $envPath"
        virtualenv -p /usr/bin/python2 "$envPath"
    fi
}
#----------------------------------------------------------------------------//
function cmd_gae_init_dev_env() {
    ensure_appengine_sdk
    ensure_virtualenv './nocommit/virtualenv'

    local verboseOpt=''
    [ $VERBOSE -gt 0 ] && verboseOpt='-v'

    echo -e "-- \e[1mInstalling \e[0mNode.js\e[1m modules\e[0m"
    call_verbose npm install

    echo -e "-- \e[1mInstalling \e[0mbower\e[1m modules\e[0m"
    bowerinstall.py $verboseOpt

    echo -e "-- \e[1mBuilding frontend\e[0m"
    call_verbose grunt build

    echo -e "\e[92mDevelopment environment ready!\e[0m"
}
