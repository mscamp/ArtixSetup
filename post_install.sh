#!/usr/bin/env bash

# Ensure that .ssh folder exists
if [ ! -d "$HOME/.ssh" ]; then
	echo "Copy .ssh folder to your home folder!"
	exit 1
fi

# Ensure that openssh is installed
if pacman -Q "openssh" &>/dev/null; then
	echo "openssh is already installed. Cloning dotfiles..."
else
	echo "openssh is not installed. Installing..."
	doas pacman -S --noconfirm openssh
	echo "openssh is now installed. Cloning dotfiles..."
fi

# Clone dotfiles repo
git config --global init.defaultBranch main                                # Set default branch to "main" instead of "master"
alias dots='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'      # Set alias
echo "dotfiles" >>"$HOME"/.gitignore                                       # To avoid recursion problems
rm "$HOME"/.bashrc                                                         # Remove .bashrc, because it will be replaced
git clone --bare git@github.com:mscamp/dotfiles_artix.git "$HOME"/dotfiles # Clone dotfiles
dots checkout
dots config --local status.showUntrackedFiles no

# Pacman config
doas sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
doas sed -i "s/^#Color$/Color/" /etc/pacman.conf
doas sed -i "s/^#CheckSpace$/CheckSpace/" /etc/pacman.conf
doas sed -i "s/^#VerbosePkgList$/VerbosePkgList/" /etc/pacman.conf
doas sed -i "s/^#ILoveCandy$/ILoveCandy/" /etc/pacman.conf
doas sed -i "s/^#HookDir     = \/etc\/pacman\.d\/hooks\/$/HookDir = \/home\/scampo\/.config\/pacman\/pacman_hooks\//" /etc/pacman.conf
