sed -i 's/\r$//' scripts/slack-notify.sh

chmod +x scripts/slack-notify.sh

file scripts/slack-notify.sh

bash -n scripts/slack-notify.sh
