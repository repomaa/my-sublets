#!/bin/bash

# Run as root
# Requires community/expac
user="your username"

# Download packages needing an update
nice -n 50 pacman -Syuwq --noconfirm > /dev/null

# Write the packages needing an update to file
pacman -Quq | tr "\\n" " " | xargs expac -S '%r/%n [%v]' > /home/$user/.pacmanupdates

# Update sublet
subtler -su pacman > /dev/null