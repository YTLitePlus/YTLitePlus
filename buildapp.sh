#!/bin/bash

cd "$(dirname "$0")"

# Check Cercube
if	[ ! -f Tweaks/Cercube/me.alfhaily.cercube_5.3.11_iphoneos-arm.deb ]
then
	echo -e "==> \033[1mCercube v5.3.13 is not found. Downloading Cercube (v5.3.11)...\033[0m"
	curl https://dl.dropboxusercontent.com/s/b01erqbp3ajc5e2/me.alfhaily.cercube_5.3.11_iphoneos-arm.deb --output Tweaks/Cercube/me.alfhaily.cercube_5.3.11_iphoneos-arm.deb
else
   	echo -e "==> \033[1mFounded Cercube (v5.3.13)\033[0m"
fi

# Extract Cercube
	echo -e "==> \033[1mExtracting Cercube...\033[0m"
if 	(cd Tweaks/Cercube && tar -xf me.alfhaily.cercube_5.3.11_iphoneos-arm.deb && tar -xf data.tar.*)
then
	echo -e "\033[1m> Extracted Cercube!\033[0m"
else
	echo "> \033[1mCouldn't extract Cercube\033[0m"
fi

# Makefile
if 	[ -d ./tmp ]
then
	rm -rf ./tmp
fi
	read -e -p "==> Path to the decrypted YouTube.ipa or YouTube.app: " PATHTOYT
if 	[[ $PATHTOYT == *.ipa ]]
then 
	unzip -q "$PATHTOYT" -d tmp
	rm -rf tmp/Payload/YouTube.app/_CodeSignature/CodeResources
	rm -rf tmp/Payload/YouTube.app/PlugIns/*.appex
	cp -R Extensions/*.appex tmp/Payload/YouTube.app/PlugIns 
	make package FINALPACKAGE=1
	open packages

elif	[[ $PATHTOYT == *.app ]]
then
	mkdir -p ./tmp/Payload/
	cp -R "$PATHTOYT" tmp/Payload 2>/dev/null
	rm -rf tmp/Payload/YouTube.app/_CodeSignature/CodeResources
	rm -rf tmp/Payload/YouTube.app/PlugIns/*.appex
	cp -R Extensions/*.appex tmp/Payload/YouTube.app/PlugIns 
	make package FINALPACKAGE=1
	open packages
else
	echo "This is not an ipa/app!"
fi

# Clean up	
	tput setaf 1 && echo -e "==> \033[1mCleaning up...\033[0m"
	find Tweaks/Cercube -mindepth 1 ! -name "me.alfhaily.cercube_5.3.11_iphoneos-arm.deb" ! -name ".gitkeep" -exec rm -rf {} \; 2>/dev/null
	rm -rf tmp/ Resources .theos/_/Payload
	echo -e  "==> \033[1mSHASUM256: $(shasum -a 256 packages/*.ipa | cut -f1 -d' ')\033[0m"
