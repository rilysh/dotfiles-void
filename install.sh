#!/bin/bash

# DO NOT RUN THIS SCRIPT WITHOUT READING THE README.md FILE
# This script doesn't do what you might expect, but install a bunch of dependencies which you can mess up so easily

# Check if the script run as a root or not
if [[ $(id -u) != 0 ]]; then
    echo "You need to run the script as root"
    exit 1
fi

# Update XBPS
xbps-install -Su xbps
xbps-install -Su

# Install essential packages
xbps-install -S alsa-utils xfce4-pulseaudio-plugin xfce4-screenshooter xfce4-whiskermenu-plugin lightdm lightdm-gtk3-greeter lightdm-gtk-greeter-settings wget curl nano vim zsh unzip xz

# Create .themes,.icons and .fonts directory
mkdir ~/.themes && mkdir ~/.icons && mkdir ~/.fonts

# Install fonts and configure
xbps-install -S noto-fonts-emoji noto-fonts-ttf noto-fonts-ttf-extra noto-fonts-cjk ttf-ubuntu-font-family
curl https://github.com/ryanoasis/nerd-fonts/releases/latest/download/SourceCodePro.zip --output SourceCodePro.zip
mv SourceCodePro.zip ~/.fonts
curl https://fonts.google.com/download?family=Fira%20Sans --output FiraSans.zip
mv FiraSans.zip ~/.fonts
unzip ~/.fonts/SourceCodePro.zip && rm ~/.fonts/SourceCodePro.zip
unzip ~/.fonts/FiraSans.zip && rm ~/.fonts/FiraSans.zip
unzip Fura_Mono.tar.gz && mv Fura_Mono/* ~/.fonts
rm -rf Fura_Mono
rm ~/.fonts/*.txt && rm ~/.fonts/*.md
ln -s /usr/share/fontconfig/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d/
xbps-reconfigure -f fontconfig
fc-cache -f

# Install neofetch
mkdir /opt/neofetch
curl https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch --output neofetch
mv neofetch /opt/neofetch
chmod +x /opt/neofetch/neofetch
ln -s /opt/neofetch /usr/sbin/neofetch

# Setup lightdm
xbps-remove -R lxdm
rm -rf /var/service/lxdm
yes | cp lightdm/*.conf /etc/lightdm/
ln -s /etc/lightdm/ /var/lib/lightdm # Note: if anything fails here, you may need to make changes to lightdm config according you needs

# Setup oh-my-zsh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
yes | cp zshconf/.zshrc ~/.zshrc
source ~/.zshrc

# Setup other tools
read -p "Do you want to install and import nvm? (If you don't want nodejs, then select no. [Y]es, [N]o: " yesno
if [[ $yesno == "Y" ]]; then
    cp ~/.bashrc ~/.bashrc.bck && cp ~/.zshrc ~/.zshrc.bck
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

    ## As we're right now using bash shell, we need to append it to .zshrc
cat <<EOF >> ~/.zshrc
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
EOF
    source ~/.bashrc && source ~/.zshrc

    if [ ! nvm ]; then
        echo "nvm failed to load, might not be exported correctly, skipping..."
    else
        nvm install node
        if [ ! npm ]; then
            echo "Node failed to load, might not be exported correctly by nvm, skipping..."
        else
            npm i --location=global yarn pnpm typescript eslint
        fi
    fi
else
    echo "Skipping the export of nvm directory"
    source ~/.bashrc && source ~/.zshrc
fi

# Install VSCode and Tor browser
curl https://code.visualstudio.com/sha/download?build=stable&os=linux-x64 --output code.tar.gz
tar xf code.tar.gz
mv VSCode-linux-x64 /opt
export PATH=/opt/VSCode-linux-x64/bin:$PATH
source ~/.zshrc

# Install protonvpn
xbps-install -S protonvpn-cli
protonvpn init

# Development tools
xbps-install -S git gcc ruby base-devel ruby-build ruby-devel
