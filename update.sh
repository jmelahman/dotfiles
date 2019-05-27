#!/bin/bash

REPO_PATH=git/dotfiles
CONFIG_PATH=$REPO_PATH/.config

# Home dotfiles
cp -u ~/.bashrc ~/$REPO_PATH/
cp -u ~/.bash_aliases ~/$REPO_PATH/

# .config dotfiles
cp -u ~/.config/i3/config ~/$CONFIG_PATH/
cp -u ~/.config/redshift/redshift.conf ~/$CONIFG_PATH/
