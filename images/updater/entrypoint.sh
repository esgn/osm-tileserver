#!/bin/bash

echo "Updater container has been started"

# black magic for getting env vars in cron
declare -p | grep -Ev 'BASHOPTS|BASH_VERSINFO|EUID|PPID|SHELLOPTS|UID' > /container.env

# Create log dir if not exists
mkdir -p /var/log/updater/

# Setup a cron schedule for updating
echo "SHELL=/bin/bash
BASH_ENV=/container.env
*/15 * * * * /update.sh >> /var/log/updater/cron.log 2>&1
# This extra line makes it a valid cron" > scheduler.txt

crontab scheduler.txt

cron -f

echo  "Cron installed for updater"
