#!/bin/bash

source etc/dev_utils.conf

# define the dialog exit status codes
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ESC=255}

function exit_util {
    clear
    echo "exit"
    exit
}

function action_ssh {
    exec 3>&1
    declare -a servers

    let i=0
    while read -r data
    do
        IFS=','
        for val in $data
        do
            servers[i]=$val
            ((i++))
        done

    done < "etc/dev_utils_ssh.conf"

    target=$(dialog --backtitle "ssh access" --cancel-label Back --clear --menu "ssh server list" 25 90 10 \
        "${servers[@]}" \
        2>&1 1>&3 \
    )

    ret=$?
    exec 3>&-
    case $ret in
        $DIALOG_OK)
            clear
            echo "Accessig to the ssh server. $target"
            ssh -o StrictHostKeyChecking=no $target
            ;;
        $DIALOG_CANCEL)
            main
            ;;
    esac
}

function action_sshfs {
    exec 3>&1
    declare -a servers

    let i=0
    while read -r data
    do
        IFS=','
        for val in $data
        do
            servers[i]=$val
            ((i++))
        done

    done < "etc/dev_utils_sshfs.conf"

    target=$(dialog --backtitle "ssh filesystem" --cancel-label Back --clear --menu "sshfs server list" 25 90 10 \
        "${servers[@]}" \
        2>&1 1>&3 \
    )

    ret=$?
    exec 3>&-
    case $ret in
        $DIALOG_OK)
            clear
            echo "Mounting the ssh filesystem. $target"
            sshfs $target:/ ~/remote/$target
            ;;
        $DIALOG_CANCEL)
            main
            ;;
    esac
}

function main {
    exec 3>&1
    target=$(dialog --backtitle "Select menu" --clear --nocancel --menu "Choose utils" 20 50 10 \
        "1" "ssh connect" \
        "2" "ssh filesystem" \
    2>&1 1>&3)

    ret=$?
    exec 3>&-
    if [ $ret != $DIALOG_OK ]; then
        exit
    fi

    case $target in
        1)
            action_ssh
            ;;
        2)
            action_sshfs
            ;;
    esac
}

while true
do
    main
done