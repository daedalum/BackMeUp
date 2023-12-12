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

    #Docs
    echo -e "$GREEN Copying '$SPREADSHEET' to '$DOCD'$NC"
    rclone copy -v $SPREADSHEET $DOCD &&

    echo -e "$GREEN Copying '$SPREADSHEET' to '$DOCM'$NC"
    rclone copy -v $SPREADSHEET $DOCM &&

    echo -e "$YELLOW Verifying '$SPREADSHEET' in '$DOCD'. Please, wait...$NC"
    echo ""
    echo "Verifying '$SPREADSHEET' in '$DOCD'" >> $RCLONELOG
    rclone cryptcheck --log-file=$RCLONELOG $SPREADSHEET $DOCD &&
    echo "" >> $RCLONELOG

    echo -e "$GREEN Copying '$OBSIDIAN' to '$OBSD'$NC"
    rclone sync -v $OBSIDIAN $OBSD &&

    echo -e "$YELLOW Verifying '$OBSIDIAN' in '$OBSD'. Please, wait...$NC"
    echo ""
    echo "Verifying '$OBSIDIAN' in '$OBSD'" >> $RCLONELOG
    rclone cryptcheck --log-file=$RCLONELOG $OBSIDIAN $OBSD &&
    echo "" >> $RCLONELOG

    echo -e "$GREEN Copying '$OBSIDIAN' to '$OBSM'$NC"
    rclone sync -v $OBSIDIAN $OBSM &&

    echo -e "$GREEN Copying '$VAULT' to '$VTD'$NC"
    rclone copy -v $VAULT $VTD &&

    echo "$YELLOW Verifying '$VAULT' in '$VTD'. Please, wait...$NC"
    echo ""
    echo "Verifying '$VAULT' in '$VTD'" >> $RCLONELOG
    rclone cryptcheck --log-file=$RCLONELOG $VAULT $VTD &&
    echo "" >> $RCLONELOG

    echo -e "$GREEN Copying '$V_CONFIG' to '$VTD'$NC"
    rclone copy -v $V_CONFIG $VTD &&

    echo "$YELLOW Verifying '$V_CONFIG' in '$VTD'. Please, wait...$NC"
    echo ""
    echo "Verifying '$V_CONFIG' in '$VTD'" >> $RCLONELOG
    rclone cryptcheck --log-file=$RCLONELOG $V_CONFIG $VTD &&
    echo "" >> $RCLONELOG


    #Pictures and Videos
    echo -e "$GREEN Copying '$PICTURES' to '$PICG'$NC"
    rclone copy -v $PICTURES $PICG &&

    echo -e "$GREEN Copying '$PICTURES' to '$PICM'$NC"
    rclone copy -v $PICTURES $PICM &&

    echo -e "$YELLOW Verifying '$PICTURES' in '$PICG'. Please, wait...$NC"
    echo ""
    echo "Verifying '$PICTURES' in '$PICG'" >> $RCLONELOG
    rclone cryptcheck --log-file=$RCLONELOG $PICTURES $PICG &&
    echo "" >> $RCLONELOG


    #Art
    echo -e "$GREEN Copying '$ART' to '$ARTG'$NC"
    rclone copy -v $ART $ARTG &&

    echo -e "$GREEN Copying '$ART' to '$ARTM'$NC"
    rclone copy -v $ART $ARTM &&

    echo -e "$YELLOW Verifying '$ART' in '$ARTG'. Please, wait...$NC"
    echo ""
    echo "Verifying '$ART' in '$ARTG'" >> $RCLONELOG
    rclone cryptcheck --log-file=$RCLONELOG $ART $ARTG &&
    echo "" >> $RCLONELOG


    #Design
    echo -e "$GREEN Copying '$DESIGN' to '$DSNG'$NC"
    rclone copy -v $DESIGN $DSNG &&

    echo -e "$GREEN Copying '$DESIGN' to '$DSNM'$NC"
    rclone copy -v $DESIGN $DSNM &&

    echo -e "$YELLOW Verifying '$DESIGN' in '$DSNG'. Please, wait...$NC"
    echo ""
    echo "Verifying '$DESIGN' in '$DSNG'" >> $RCLONELOG
    rclone cryptcheck --log-file=$RCLONELOG $DESIGN $DSNG &&
    echo "" >> $RCLONELOG


    #Android
    echo -e "$GREEN Copying '$ANDROID/contacts.vcf' to '$DOCM'$NC"
    rclone copy -v $ANDROID/contacts.vcf $DOCM &&

    echo -e "$GREEN Copying '$ANDROID/contacts.vcf' to '$DOCD'$NC"
    rclone copy -v $ANDROID/contacts.vcf $DOCD &&

    echo -e "$GREEN Copying '$ANDROID/NewPipe.zip' to '$ZIPM'$NC"
    rclone copy -v "$ANDROID/NewPipe.zip" $ZIPM &&

    echo -e "$GREEN Copying '$ANDROID/NewPipe.zip' to '$ZIPD'$NC"
    rclone copy -v "$ANDROID/NewPipe.zip" $ZIPD &&

    echo -e "$GREEN Copying '$ANDROID/WhatsApp.zip' to '$ZIPM'$NC"
    rclone copy -v "$ANDROID/WhatsApp.zip" $ZIPM
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
        rsync -a -v $SPREADSHEET $UDOC &&
        rsync -a -v $OBSIDIAN $UOBS &&
        rsync -a -v $VAULT $UVT &&
        rsync -a -v $V_CONFIG $UMINC &&

        #Pictures and Videos
        rsync -a -v $ART $UART &&
        rsync -a -v $PICTURES $UPIC &&
        rsync -a -v $DESIGN $UDSN &&

        #Music
        rsync -a -v $MUSIC $UMUS &&

        #Android
        rsync -a -v $ANDROID $UMINC &&

        #Save Files
        rsync -a -v $SAVESNDS $USNDS &&
        rsync -a -v $SM120 $USM120 &&

        #Unmount and close the LUKS Partition
        sudo umount /mnt/usb &&
        sudo cryptsetup close luks-data-traveler-64
    fi
}


Android(){
    #A function that verifies if the phone is properly connected to the computer.
    #If so, it pulls the selected files from it.

    adb start-server
    if [[ -z $(adb devices | grep "S46DU4FEPRWC4LQG") ]]; then
    echo "Device not detected. Enable the option 'USB Debugging' and try again."
    else
        adb pull "$SDCARD/NewPipe.zip" "$ANDROID" &&
        adb pull "$SDCARD/contacts.vcf" "$ANDROID" &&
        adb pull "$STORAGE/WhatsApp/Databases/" "$ANDROID" &&

        zip -r -q "$ANDROID/WhatsApp.zip" "$ANDROID/Databases/" &&
        rm -r "$ANDROID/Databases"
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
            echo "Error: Invalid option. Try one of the options [-h|a|p|c]"
            exit;;
    esac
done
