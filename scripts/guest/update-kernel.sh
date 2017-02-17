# Install DKMS - prevents guest additions breaking when the kernel is updated
sudo yum -q -y install dkms

sudo yum -y update kernel* | grep 'No packages marked for update' &> /dev/null
if [ $? == 0 ]; then
    exit 1 # Nothing to update
else
    exit 0 # Update occurred
fi