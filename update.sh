#!/bin/bash

REPO_PATH=git/dotfiles
CONFIG_PATH=$REPO_PATH/.config

# Home dotfiles
cp -u ~/.bashrc ~/$REPO_PATH/
cp -u ~/.bash_aliases ~/$REPO_PATH/
cp -au ~/.vim ~/$REPO_PATH/
cp -u ~/.vimrc ~/$REPO_PATH/

# .config dotfiles
cp -u ~/.config/beets/config.yaml ~/$CONFIG_PATH/beets/
cp -u ~/.config/i3/config ~/$CONFIG_PATH/i3/
cp -u ~/.config/redshift/redshift.conf ~/$CONIFG_PATH/redshift/
