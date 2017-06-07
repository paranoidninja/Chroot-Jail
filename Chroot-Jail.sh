#!/bin/bash

##Author : Paranoid Ninja
##Email  : paranoidninja@protonmail.com
##Desc   : A Shell script to create a group or user based Chroot Jail along with adding it to SSH Login.

uid=`id | cut -d '(' -f1 | cut -d '=' -f2`

if [[ $uid == '0' ]]; then

	printf "\n[+] Enter the Chroot directory [/home/Jail]:\n"
	read -p '>>> ' CHROOT_DIR
	if [[ $CHROOT_DIR == '' ]]; then
		CHROOT_DIR="/home/Jail"
	fi
	printf "\n[+] Enable Chrooted SSH? (y/n)\n"
	read -p '>>> ' ANSWER

		if [[ $ANSWER == 'y' ]]; then
			printf "\n[+] Create Chrooted SSH for? \n1. Single User\n2. Group\n"
			read -p '>>> ' ANSWER2

				if [[ $ANSWER2 == 1 ]]; then
					printf "\n[+] Enter the user's name\n"
					read -p '>>> ' userName
                                        printf "\nMatch User $userName\nChrootDirectory $CHROOT_DIR\n" >> /etc/ssh/sshd_config
                                        printf "\n[+] User $userName added to Chrooted SSH"

				else
					printf "\n[+] Enter the group name [restricted_group]\n"
					read -p '>>> ' groupName
					if [[ $groupName == '' ]]; then
						groupName="restricted_group"
					fi
					printf "\n[+] Creating group $groupName...\n"
					groupadd $groupName
                                        printf "\nMatch Group $groupName\nChrootDirectory $CHROOT_DIR\n" >> /etc/ssh/sshd_config
                                        printf "\n[+] Group $groupName added to Chrooted SSH\n[+] You can now add users to this group using the below command: \n\n$ usermod -g restricted_group username \n\n"
				fi
		fi

	printf "\n[+] Creating Chroot Jail in $CHROOT_DIR now...\n"

        mkdir -p $CHROOT_DIR/dev/
        mkdir -p $CHROOT_DIR/bin
        mkdir -p $CHROOT_DIR/lib64
        mkdir -p $CHROOT_DIR/lib

        cd $CHROOT_DIR/dev/
        mknod -m 666 null c 1 3
        mknod -m 666 tty c 5 0
        mknod -m 666 zero c 1 5
        mknod -m 666 random c 1 8
        chown root:root $CHROOT_DIR
        chmod 0755 $CHROOT_DIR
        cp -v /bin/bash $CHROOT_DIR/bin/
        cp -v /lib/x86_64-linux-gnu/libtinfo.so.5  $CHROOT_DIR/lib/
        cp -v /lib/x86_64-linux-gnu/libdl.so.2  $CHROOT_DIR/lib/
        cp -v /lib/x86_64-linux-gnu/libc.so.6  $CHROOT_DIR/lib/
        cp -v /lib64/ld-linux-x86-64.so.2  $CHROOT_DIR/lib64/

        ldd /bin/bash
	service sshd restart
	service ssh restart

        printf "\n[+] Do you want to test the Chroot Jail? (y/n)\n"
        read -p '>>> ' ANSWER3
        if [[ $ANSWER3 == 'y' ]]; then
	        cd $CHROOT_DIR/
	        chroot .
        fi

else
	printf '[!][!][!] You need to be root to execute this script\n'
fi
