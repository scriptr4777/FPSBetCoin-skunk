#!/bin/bash

set -e

date

#################################################################
# Update Ubuntu and install prerequisites for running fpsbetcoin   #
#################################################################
sudo apt-get update
#################################################################
# Build fpsbetcoin from source                                     #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building fpsbetcoin           #
#################################################################
sudo apt-get install -y qt4-qmake libqt4-dev libminiupnpc-dev libdb++-dev libdb-dev libcrypto++-dev libqrencode-dev libboost-all-dev build-essential libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libssl-dev ufw git
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

# By default, assume running within repo
repo=$(pwd)
file=$repo/src/fpsbetcoind
if [ ! -e "$file" ]; then
	# Now assume running outside and repo has been downloaded and named fpsbetcoin
	if [ ! -e "$repo/fpsbetcoin/build.sh" ]; then
		# if not, download the repo and name it fpsbetcoin
		git clone https://github.com/fpsbetcoind/source fpsbetcoin
	fi
	repo=$repo/fpsbetcoin
	file=$repo/src/fpsbetcoind
	cd $repo/src/
fi
make -j$NPROC -f makefile.unix

cp $repo/src/fpsbetcoind /usr/bin/fpsbetcoind

################################################################
# Configure to auto start at boot                                      #
################################################################
file=$HOME/.fpsbetcoin
if [ ! -e "$file" ]
then
        mkdir $HOME/.fpsbetcoin
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=u' 'rpcpassword=p' | tee $HOME/.fpsbetcoin/fpsbetcoin.conf
file=/etc/init.d/fpsbetcoin
if [ ! -e "$file" ]
then
        printf '%s\n%s\n' '#!/bin/sh' 'sudo fpsbetcoind' | sudo tee /etc/init.d/fpsbetcoin
        sudo chmod +x /etc/init.d/fpsbetcoin
        sudo update-rc.d fpsbetcoin defaults
fi

/usr/bin/fpsbetcoind
echo "fpsbetcoin has been setup successfully and is running..."

