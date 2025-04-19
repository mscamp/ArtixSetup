#!/bin/sh

# Ensure that .ssh folder exists
if [ ! -d "$HOME/.ssh" ]; then
    echo "Copy .ssh folder to your home folder!"
    exit 1
fi

# Ensure that openssh is installed
if pacman -Q "openssh" &> /dev/null; then
    echo "openssh is already installed. Cloning dotfiles..."
else
    echo "openssh is not installed. Installing..."
    doas pacman -S --noconfirm openssh
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
doas sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
doas sed -i "s/^#Color$/Color/" /etc/pacman.conf
doas sed -i "s/^#CheckSpace$/CheckSpace/" /etc/pacman.conf
doas sed -i "s/^#VerbosePkgList$/VerbosePkgList/" /etc/pacman.conf
doas sed -i "s/^#ILoveCandy$/ILoveCandy/" /etc/pacman.conf

# Install zsh
if pacman -Q "zsh" &> /dev/null; then
    echo "zsh is installed."
else
    echo "zsh is not installed. Installing..."
    doas pacman -S --noconfirm zsh
    echo "zsh is now installed."
    chsh -s /usr/bin/zsh # Change shell to zsh
fi

# Install fontconfig
if pacman -Q "fontconfig" &> /dev/null; then
    echo "fontconfig is installed."
else
    echo "fontconfig is not installed. Installing..."
    doas pacman -S --noconfirm fontconfig
    echo "fontconfig is now installed."
fi

# Install custom font
if pacman -Q "ttf-jetbrains-mono-nerd" &> /dev/null; then
    echo "ttf-jetbrains-mono-nerd is installed."
else
    echo "ttf-jetbrains-mono-nerd is not installed. Installing..."
    doas pacman -S --noconfirm ttf-jetbrains-mono-nerd
    echo "ttf-jetbrains-mono-nerd is now installed."
    doas fc-cache -vf # Reload font cache
fi

# Prepare home folder
mkdir $HOME/Documents $HOME/Downloads $HOME/Software $HOME/Pictures $HOME/Videos
