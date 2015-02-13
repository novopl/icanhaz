## Introduction

#### About the project

I wrote this script to help me with simple tasks that can be achieved with
a few lines of bash. Instead of having multiple few-line scripts laying around
`icanhaz` provides a unified way to call those scripts and have them saved
per directory, globally or for the current user. I have no intention of turning
this into full blown management software, its niche is between a bash command
and a proper script/management tools.

If you're using `zsh` as your shell, you can also benefit from a simple
completion script that will autocomplete icanhaz commands available in the
current context.

#### Commands

`icanhaz` is built around commands, the `icanhaz.sh` script is just a very
simple execution system built around bash. Commands are just plain bash
functions, they can do whatever you like.

## Installation

```shell
$ git clone https://github.com/novopl/icanhaz.git
$ cd icanhaz
$ sudo ./install.sh
```

This will copy `icanhaz.sh` to `/usr/bin/icanhaz` and install all the default
plugins into `/usr/share/icanhaz/plugins`.

#### Uninstall

The `install.sh` script can also remove `icanhaz` from the system, just call it
with `uninstall` as the only argument. During the installation, the copy
of `install.sh` is made in the installation directory (`/usr/share/icanhaz` by
default).

```shell
$ /usr/share/icanhaz/install.sh uninstall
```

This will remove the script along with all its global configuration files and
plugins. The user configuration (stored in `~/.icanhaz`) won't be deleted.


# Documentation

#### Available commands

The number of commands available to the user depends on the current working
directory and can be queried with `icanhaz -l`. The commands available in the
current context can come from the following source:

- System global commands stored in `/usr/share/icanhaz/plugins`
- User commands stored in `~/.icanhaz/plugins`
- Local commands defined in the `./icanhazrc` file in the current working
  directory.

Each level overwrites the previous one, so if there are any conflicts, the
user plugins overwrite system plugins and local plugins overwrite the user
plugins.

#### Creating commands

Commands are just bash functions. To make them visible for the system, you only
need to export them as a `COMMANDZ` dictionary.

Aa an example, here is the *clean* command supplied with the installation.

```shell
declare -A COMMANDZ
COMMANDZ=(
    [clean]='cmd_clean'
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
```


#### Executing commands
```
$ icanhaz <command> [command arguments]
```


## Sample `icanhazrc` file

```shell
declare -A COMMANDZ
COMMANDZ=(
    [build]='cmd_build'
    [deploy]='cmd_deploy'
    [pymod]='cmd_pymod'
)

#----------------------------------------------------------------------------//
function cmd_build() {
    # Build project using your build tools of choice
    my_build_tool --some-default --custom-options $@
    # Add some additional post-build steps
    cp some_file other_file
}
#----------------------------------------------------------------------------//
function cmd_deploy() {
    # Build project first
    cmd_build

    # Set the destination host, first argument and defaults to  
    local host=$1
    if [ $# -lt 1 ]; then
        host="http://localhost:8000"
    fi

    # Upload app to $host
    myuploadscript $host
}
#----------------------------------------------------------------------------//
function cmd_pymod() {
    # Create a new python module in the given directory

    if [ $# -lt 1 ]; then
        echo "USAGE: icanhaz pymod <path_to_new_module>"
    else
        mkdir $1
        touch $1/__init__.py
    fi
}
```

The above `icanhazrc` file will enable three commands: `build`, `deploy` and
`pymod`.

The `build` command takes no arguments by itself, but passes
everything to the custom build system. This way you can easily set up some
defaults to save you typing while maintaining the flexibility to customize
each call according to your needs.

The `deploy` command has one
optional argument (the target host) and `pymod` has one mandatory argument -
the path to newly created python module.


```shell
$ icanhaz build
$ icanhaz build --custom-buildsystem-opts
$ icanhaz deploy
$ icanhaz deploy target.host.com
$ icanhaz pymod mymodule
```

## Supplied commands

#### `clean`

**Example:**
```
$ icanhaz clean
```

Cleanup the directory recursively. By default it will remove all files
matching `*~` and `*swp`. You can change the list of file patterns to delete by
defining an array named `CLEANPTTRNS` somewhere in your `icanhazrc` file.

#### `icanhazrc`

**Example:**
```shell
$ icanhaz icanhazrc
```

Create new `icanhazrc` file in the current working directory. It will have
all the required definitions plus a sample command as a quick reference.

## Autocompletion

For `zsh` there is a simple autocompletion script that will match a command
from the ones available in the current context. All other arguments will be
matched using `zsh` built-in file matcher.
