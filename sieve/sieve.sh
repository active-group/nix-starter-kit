#!/usr/bin/env sh

set -e
cd "$(dirname "$0")"

username_file=./username
if [ ! -e "$username_file" ]; then
    echo "Username on the server: "
    read -r username
    echo "$username" > "$username_file"
fi

username=$(cat "$username_file")

case "$1" in
    "activate")
        sieve-connect -s imap.active-group.de -u "$username" --exec ./upload_and_activate
        echo
        echo "------------------------------------------------------------"
        echo "    The following out-of-office message is now *active*:"
        echo "------------------------------------------------------------"
        echo
        cat ./message
        ;;
    "deactivate")
        sieve-connect -s imap.active-group.de -u "$username" --deactivate
        echo "----------------------------------------------------"
        echo "    Out-of-office message has been *deactivated*"
        echo "----------------------------------------------------"
        ;;
    *)
        echo "Usage: $0 activate|deactivate"
esac
