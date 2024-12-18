#!/bin/bash

# Color Variables
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' #No Color


##################################################################################
# Functions                                                                      #
##################################################################################

Help(){
    # Display informations about the script

    echo "A backup script that never lets you down! It backups files from your computer and Android phone to the cloud and encrypted external flash drive, via rsync and rclone."
    echo ""
    echo "Basic usage:  BackMeUp [OPTIONS]"
    echo ""
    echo "Options:"
    echo "-c    Copy and/or sync files to the cloud via rsync."
    echo "-p    Decrypt and mount an external flash drive, before copying files to it."
    echo "-a    Pull files from an Android Phone."
    echo "-h    Display informations about the script."
}


Version(){
    # Display the version of the program

    echo "'BackMeUp' 1.0 by Daedalum."
}

Cloud(){
    #A function that copy and/or sync files to the cloud via rsync.

    #Set the password to decrypt the configuration file, it is removed after the operation
    echo "Please, enter your password."
    source "$HOME/set-rclone-password"

    ## Docs

    echo -e "$GREEN Copying '$OBSIDIAN' to '$OBSG'$NC"
    rclone --ask-password=false sync -v $OBSIDIAN $OBSG &&

    echo -e "$YELLOW Verifying '$OBSIDIAN' in '$OBSG'. Please, wait...$NC"
    echo ""
    echo "Verifying '$OBSIDIAN' in '$OBSG'" >> $RCLONELOG
    rclone --ask-password=false cryptcheck --log-file=$RCLONELOG $OBSIDIAN $OBSG &&
    echo "" >> $RCLONELOG


    echo -e "$GREEN Copying '$VAULT' to '$VLTG'$NC"
    rclone --ask-password=false copy -v $VAULT $VLTG &&

    echo -e "$YELLOW Verifying '$VAULT' in '$VLTG'. Please, wait...$NC"
    echo ""
    echo "Verifying '$VAULT' in '$VLTG'" >> $RCLONELOG
    rclone --ask-password=false cryptcheck --log-file=$RCLONELOG $VAULT $VLTG &&
    echo "" >> $RCLONELOG

    
    echo -e "$GREEN Copying '$PDCL' to '$PDCG'$NC"
    rclone --ask-password=false sync -v $PDCL $PDCG &&

    echo -e "$YELLOW Verifying '$PDCL' in '$PDCG'. Please, wait...$NC"
    echo ""
    echo "Verifying '$PDCL' in '$PDCG'" >> $RCLONELOG
    rclone --ask-password=false cryptcheck --log-file=$RCLONELOG $PDCL $PDCG &&
    echo "" >> $RCLONELOG



    ## Pictures

    echo -e "$GREEN Copying '$PICTURES' to '$PICG'$NC"
    rclone --ask-password=false copy -v $PICTURES $PICG &&

    echo -e "$YELLOW Verifying '$PICTURES' in '$PICG'. Please, wait...$NC"
    echo ""
    echo "Verifying '$PICTURES' in '$PICG'" >> $RCLONELOG
    rclone --ask-password=false cryptcheck --log-file=$RCLONELOG $PICTURES $PICG &&
    echo "" >> $RCLONELOG



    ## Art and Design

    echo -e "$GREEN Copying '$ART' to '$ARTG'$NC"
    rclone --ask-password=false sync -v $ART $ARTG &&

    echo -e "$YELLOW Verifying '$ART' in '$ARTG'. Please, wait...$NC"
    echo ""
    echo "Verifying '$ART' in '$ARTG'" >> $RCLONELOG
    rclone --ask-password=false cryptcheck --log-file=$RCLONELOG $ART $ARTG &&
    echo "" >> $RCLONELOG


    echo -e "$GREEN Copying '$DESIGN' to '$DSNG'$NC"
    rclone --ask-password=false sync -v $DESIGN $DSNG &&

    echo -e "$YELLOW Verifying '$DESIGN' in '$DSNG'. Please, wait...$NC"
    echo ""
    echo "Verifying '$DESIGN' in '$DSNG'" >> $RCLONELOG
    rclone --ask-password=false cryptcheck --log-file=$RCLONELOG $DESIGN $DSNG &&
    echo "" >> $RCLONELOG



    ## Misc

    echo -e "$GREEN Copying '$ANDROID' to '$GMISC'$NC"
    rclone --ask-password=false copy -v $ANDROID $GMISC &&

    echo -e "$YELLOW Verifying '$ANDROID' in '$GMISC'. Please, wait...$NC"
    echo ""
    echo "Verifying '$ANDROID' in '$GMISC'" >> $RCLONELOG
    rclone --ask-password=false cryptcheck --log-file=$RCLONELOG $ANDROID $GMISC &&
    echo "" >> $RCLONELOG


    echo -e "$GREEN Copying '$FRTB' to '$GMISC'$NC"
    rclone --ask-password=false copy -v $FRTB $GMISC &&

    echo -e "$YELLOW Verifying '$FRTB' in '$GMISC'. Please, wait...$NC"
    echo ""
    echo "Verifying '$FRTB' in '$GMISC'" >> $RCLONELOG
    rclone --ask-password=false cryptcheck --log-file=$RCLONELOG $FRTB $GMISC &&
    echo "" >> $RCLONELOG
}


USB(){
    #A function that detects the external flash drive, decrypts it and mounts it
    #before copying files to it.

        if [[ -z $(lsusb | grep "Kingston Technology DataTraveler") ]]; then
        echo "USB Device not detected."
    else
        sudo cryptsetup open /dev/sdc1 luks-data-traveler-64 &&
        sudo mount -t ext4 /dev/mapper/luks-data-traveler-64 /mnt/usb &&

        #Docs
        rsync -a --delete -v $OBSIDIAN $UOBS &&
        rsync -a -v $VAULT $UVT &&
        rsync -a -v $V_CONFIG $UMISC &&
        rsync -a -v $PDCL $UDOC &&

        #Pictures and Videos
        rsync -a -l -v $ART $UART &&
        rsync -a -v $PICTURES $UPIC &&
        rsync -a --delete -v $DESIGN $UDSN &&

        #Code
        rsync -a --delete -v  $CODE $UCODE &&

        #Android
        rsync -a -v $ANDROID $UMISC &&

        #Save Files
        rsync -a -v $SAVES $USAV &&

        #Misc
        rsync -a -v $FRTB $UMISC &&

        #Unmount and close the LUKS Partition
        sudo umount /mnt/usb &&
        sudo cryptsetup close luks-data-traveler-64
    fi
}


Android(){
    #A function that verifies if the phone is properly connected to the computer.
    #If so, it pulls the selected files from it.

    adb start-server
    if [[ -z $(adb devices | grep "ZF524PFT7N") ]]; then
    echo "Device not detected. Enable the option 'USB Debugging' and try again."
    else
        adb pull "sdcard/NewPipeData-moto-g04s.zip" "$ANDROID" &&
        adb pull "sdcard/NewPipeData-xiaomi.zip" "$ANDROID" 
    fi

    adb kill-server
}


###################################################################################
###################################################################################
# Main Program                                                                    #
###################################################################################
###################################################################################

# Get options
while getopts ":haucV" OPTION; do
    
    case "$OPTION" in
        h) #Display Help
            Help
            exit;;

        a) #Android Backup
            Android
            exit;;
        
        u) #USB Drive Backup
            USB
            exit;;
        
        c) #Cloud Backup
            Cloud
            exit;;
        
        V) #Display the version
            Version
            exit;;
        
        \?) #Invalid Option
            echo "Error: Invalid option. Try one of the options [-h|a|u|c|V]"
            exit;;
    esac
done
