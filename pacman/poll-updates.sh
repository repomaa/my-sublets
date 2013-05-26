#!/bin/bash

# Run as root
# Requires community/expac
user="your username"

# Download packages needing an update
nice -n 50 pacman -Syuwq --noconfirm > /dev/null

# Comment out/remove the line above and uncomment the one
# below to only poll updates without downloading them

# pacman -Sy > /dev/null

# Write the packages needing an update to file
packages=$(pacman -Quq | tr "\\n" " ")
if [ -n "$packages" ]; then
  expac -S '%r/%n [%v]' $packages > /home/$user/.pacmanupdates
fi

# Update sublet
subtler -su pacman > /dev/null
