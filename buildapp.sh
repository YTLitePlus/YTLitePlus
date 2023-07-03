#!/bin/bash

cleanup() {
  echo "==> Cleaning up..."
  rm -f YouTube.ipa
  rm -rf tmp
  rm -f packages/ipa/YTLitePlus_$youtube_version.ipa
}

revert_makefile_changes() {
  echo "==> Reverting Makefile changes..."
  if [ "$app_name" != "YouTube" ]; then
    sed -i '' "11s#.*#DISPLAY_NAME = YouTube#g" Makefile
  fi
}

trap cleanup EXIT

# Set your inputs here
decrypted_youtube_url="https://cdn-141.anonfiles.com/J4GdS7zez9/59a30fb9-1688414260/com.google.ios.youtube-18.25.1-Decrypted.ipa"
youtube_version="18.25.1"
ytliteplus_version="2.1"
bundle_id="com.google.ios.youtube"
app_name="YouTube"

if [ -z "$decrypted_youtube_url" ]; then
  echo "Please enter a decrypted YouTube URL"
  exit 1
fi

if [ -z "$youtube_version" ]; then
  echo "Please enter the YouTube version"
  exit 1
fi

# Install Dependencies
brew install ldid dpkg make

# Setup Theos
if [ ! -d "theos" ]; then
  git clone --recursive https://github.com/theos/theos.git
else
  echo "==> Theos already cached"
fi

# Download iOS 15.5 SDK
if [ ! -d "theos/sdks/iPhoneOS15.5.sdk" ]; then
  if command -v svn > /dev/null; then
    svn checkout -q https://github.com/chrisharper22/sdks/trunk/iPhoneOS15.5.sdk
    mv iPhoneOS15.5.sdk theos/sdks/
  else
    echo "==> svn command not found, please install svn"
    exit 1
  fi
else
  echo "==> iPhoneOS15.5.sdk already cached"
fi

# Setup Theos Jailed
if [ ! -d "theos-jailed" ]; then
  git clone --recursive https://github.com/qnblackcat/theos-jailed.git
else
  echo "==> theos-jailed already cached"
fi

# Install Theos Jailed
./theos-jailed/install

# Prepare YouTube iPA
wget "$decrypted_youtube_url" --no-verbose -O YouTube.ipa
echo "==> YouTube v$youtube_version downloaded!"
unzip -q YouTube.ipa -d tmp
rm -rf tmp/Payload/YouTube.app/_CodeSignature/CodeResources
rm -rf tmp/Payload/YouTube.app/PlugIns/*
cp -R Extensions/*.appex tmp/Payload/YouTube.app/PlugIns
echo "==> YouTube v$youtube_version unpacked!"

# Fix Compiling & Build Package
echo "PATH=\"$(brew --prefix make)/libexec/gnubin:\$PATH\"" >> ~/.zprofile
sed -i '' "12s#.*#BUNDLE_ID = $bundle_id#g" Makefile
if [ "$app_name" != "YouTube" ]; then
  sed -i '' "11s#.*#DISPLAY_NAME = $app_name#g" Makefile
fi
make package FINALPACKAGE=1
mkdir -p packages/ipa
mv "packages/$(ls -t packages | head -n1)" "packages/ipa/YTLitePlus_$youtube_version.ipa"
echo "==> SHASUM256: $(shasum -a 256 packages/ipa/*.ipa | cut -f1 -d' ')"
echo "==> Bundle ID: $bundle_id"

revert_makefile_changes

# Disable the cleanup function when the script exits successfully
trap - EXIT