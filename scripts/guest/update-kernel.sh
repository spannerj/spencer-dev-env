# Install DKMS - prevents guest additions breaking when the kernel is updated
sudo yum -y -q install dkms
sudo yum -y -q update kernel*

LAST_INSTALLED_KERNEL=$(rpm -q --last kernel | perl -pe 's/^kernel-(\S+).*/$1/' | head -1)
CURRENT_RUNNING_KERNEL=$(uname -r)
if [ "$LAST_INSTALLED_KERNEL" == "$CURRENT_RUNNING_KERNEL" ]
then
exit 99
fi