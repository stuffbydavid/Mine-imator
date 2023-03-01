#!/bin/bash
# Copy executable
cp Build/Mine-imator Mine-imator/usr/local/bin/Mine-imator/Mine-imator

# Set version
sed -i "s/Version: .*/Version: $1/" Mine-imator/DEBIAN/control
sed -i "s/Version=.*/Version=$1/" Mine-imator/usr/share/applications/mine-imator.desktop

# Create Debian package
dpkg-deb --build Mine-imator

# Create archive
tar cvf Mine-imator.tar.gz -C Mine-imator/usr/local/bin Mine-imator