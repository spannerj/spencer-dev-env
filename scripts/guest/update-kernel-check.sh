LAST_INSTALLED_KERNEL=$(ls -t /boot/vmlinuz-* | sed "s/\/boot\/vmlinuz-//g" | head -n1)
CURRENT_RUNNING_KERNEL=$(uname -r)
if [ "$LAST_INSTALLED_KERNEL" != "$CURRENT_RUNNING_KERNEL" ]
then
echo "UPDATED"
fi