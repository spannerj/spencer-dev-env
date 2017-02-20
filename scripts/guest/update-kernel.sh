# Install DKMS - prevents guest additions breaking when the kernel is updated
echo "Installing DKMS and updating Linux kernel"
yum -y -q install dkms
yum -y -q update kernel*