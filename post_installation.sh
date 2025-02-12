#!/bin/sh

# Variables
HOST_NAME=$(cat /etc/hostname)

# Ensure that .ssh folder exists
if [ ! -d "$HOME/.ssh" ]; then
    echo "Copy .ssh folder over your home!"
    exit 1
fi

# Ensure that openssh is installed
if pacman -Q "openssh" &> /dev/null; then
    echo "openssh is installed. Cloning dotfiles..."
else
    echo "openssh is not installed. Installing..."
    sudo pacman -S --noconfirm openssh
    echo "openssh is now installed. Cloning dotfiles..."
fi

# Clone dotfiles repo
git config --global init.defaultBranch main # Set default branch to "main" instead of "master"
alias dots='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME' # Set alias
echo "dotfiles" >> $HOME/.gitignore # To avoid recursion problems
rm $HOME/.bashrc # Remove .bashrc, because it will be replaced
git clone --bare git@github.com:mscamp/dotfiles.git $HOME/dotfiles # Clone dotfiles
dots checkout 
dots config --local status.showUntrackedFiles no

# Pacman config
sudo sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
sudo sed -i "s/^#Color$/Color/" /etc/pacman.conf
sudo sed -i "s/^#CheckSpace$/CheckSpace/" /etc/pacman.conf
sudo sed -i "s/^#VerbosePkgList$/VerbosePkgList/" /etc/pacman.conf
sudo sed -i "s/^#ILoveCandy$/ILoveCandy/" /etc/pacman.conf

# Add Oglo's Arch Repo
echo "[oglo-arch-repo]" | sudo tee -a /etc/pacman.conf
echo "SigLevel = Optional DatabaseOptional" | sudo tee -a /etc/pacman.conf
echo 'Server = https://gitlab.com/Oglo12/$repo/-/raw/main/$arch' | sudo tee -a /etc/pacman.conf

# Install rebos
sudo pacman -Syy --noconfirm rebos

# Apply rebos configuration
ln -s $HOME/.config/rebos/machines/$HOST_NAME/gen.toml $HOME/.config/rebos/
rebos setup
rebos gen commit "First generation"
rebos gen current to-latest
rebos gen current build

# Change shell to zsh
chsh -s /usr/bin/zsh

# Font
sudo fc-cache -vf # Reload font cache

# Prepare home folder
mkdir $HOME/Documents $HOME/Downloads $HOME/Software $HOME/Pictures $HOME/Videos
