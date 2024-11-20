#!/usr/bin/env bash
# These are the tools we'll need for the workshop.

export STUDENT="$(whoami)"
#install brew & git
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo >> /home/$STUDENT/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/$STUDENT/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
sudo apt-get install build-essential

#install docker
brew install docker 
sudo groupadd docker
sudo usermod -aG docker $STUDENT
newgrp docker

# if needed
#gpasswd docker

#install tools we'll use
brew install k3d k9s terraform tilt kubernetes-cli helm
brew install fluxcd/tap/flux

# /etc/resolv.conf in the workspace will need the following.
#nameserver 127.0.0.53
#nameserver 8.8.8.8
#options edns0 trust-ad
#search workshop.wesleyreisz.com




