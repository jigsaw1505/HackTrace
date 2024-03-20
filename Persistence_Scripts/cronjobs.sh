#!/bin/bash
# List all user crontabs
for user in $(cut -f1 -d: /etc/passwd); do
    crontab -u $user -l 2>/dev/null | {
        while IFS= read -r line; do
            echo "User: $user - $line"
        done
    }
done
# List system cron jobs
echo "System cron jobs:"
ls -l /etc/cron.d/
ls -l /etc/cron.daily/
ls -l /etc/cron.hourly/
ls -l /etc/cron.monthly/
ls -l /etc/cron.weekly/
ls -l /etc/crontab
