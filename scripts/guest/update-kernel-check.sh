LAST_INSTALLED_KERNEL=$(rpm -q --last kernel | perl -pe 's/^kernel-(\S+).*/$1/' | head -1)
CURRENT_RUNNING_KERNEL=$(uname -r)
if [ "$LAST_INSTALLED_KERNEL" != "$CURRENT_RUNNING_KERNEL" ]
then
echo "UPDATED"
fi