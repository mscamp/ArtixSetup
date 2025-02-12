#!/bin/sh

# Variables
PLYMOUTH_THEME="https://github.com/adi1090x/plymouth-themes/releases/download/v1.0/connect.tar.gz"
PLYMOUTH_THEME_NAME="connect"

# Ensure that .ssh folder exists
if [ ! -d "$HOME/.ssh" ]; then
    echo "Copy .ssh folder over your home!"
    exit 1
fi

# Ensure that git is installed
if pacman -Q "git" &> /dev/null; then
    echo "Git is installed. Cloning dotfiles..."
else
    echo "Git is not installed. Installing..."
    sudo pacman -S --noconfirm git
    echo "Git is now installed. Cloning dotfiles..."
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

# Plymouth
sudo sed -i "s/block /block plymouth /g" /etc/mkinitcpio.conf
sudo mkinitcpio -p linux
wget $PLYMOUTH_THEME -O $HOME/Downloads/theme.tar.gz && cd $HOME/Downloads && tar -xpvf theme.tar.gz
rm -f theme.tar.gz
sudo cp -r $PLYMOUTH_THEME_NAME /usr/share/plymouth/themes && cd
sudo plymouth-set-default-theme -l
sudo plymouth-set-default-theme -R $PLYMOUTH_THEME_NAME
rm -rf $HOME/Downloads/$PLYMOUTH_THEME_NAME
echo "Remember to add 'splash' to kernel parameters in /etc/default/grub."
