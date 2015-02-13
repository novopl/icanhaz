#!/bin/bash
ZSH_COMP_PATH='/usr/share/zsh/functions/Completion'
BIN_DIR='/usr/bin'
INSTALL_DIR='/usr/share/icanhaz'


if [ $# -eq 1 ] && [ $1 == 'uninstall' ]; then
    echo Uninstalling icanhaz
    rm "$BIN_DIR/icanhaz"
    rm -rf "$INSTALL_DIR/plugins"
    rmdir "$INSTALL_DIR"
    if [ -e "$ZSH_COMP_PATH/_icanhaz" ]; then
        echo -e "Removing ZSH autocompletion from \e[1m$ZSH_COMP_PATH\e[0m"
        rm "$ZSH_COMP_PATH/_icanhaz"
    fi
else
    echo -e "Installing icanhaz into \e[1m$INSTALL_DIR\e[0m"
    mkdir -p "$INSTALL_DIR/plugins"
    cp ./icanhaz.sh "$BIN_DIR/icanhaz"
    cp -r ./plugins/* "$INSTALL_DIR/plugins/"
    cp -r ./install.sh "$INSTALL_DIR/"

    # Install zsh completion
    if [ -e "$ZSH_COMP_PATH" ]; then
        echo -e "Installing ZSH autocompletion into \e[1m$ZSH_COMP_PATH\e[0m"
        cp ./zshcompletion/_icanhaz "$ZSH_COMP_PATH"
    fi
fi
