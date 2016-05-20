# This is a script to update virtualbox guest additions to a 5.0 version.
# You must run this if if you've updated your kernel and have started to suffer the shared-folder-hang-on-boot problem because of the additions failing.
# (How to get this script into your VM without shared folder access is down to you, but sudo vi and sudo chmod are big hints!)

# If you're still running the original kernel that shipped with the image, this script is optional.

# Installation might immediately kill your shared folders so remember to halt/up afterwards.

USING_ORIGINAL_KERNEL=false
# Original kernel files are not available via normal yum repos
if uname -r | grep -q 3.10.0-229; then
	USING_ORIGINAL_KERNEL=true
fi

if modprobe vboxguest; then
    printf "%s\n" "VB Guest Additions working" >&2
	if VBoxControl -v | grep -q 5.0; then
		printf "%s\n" "VB Guest Additions at level 5.0" >&2
		additions_need_installing=false
	else
		printf "%s\n" "VB Guest Additions not at level 5.0!" >&2
		additions_need_installing=true
	fi
else
	printf "%s\n" "VB Guest Additions not working!" >&2
	additions_need_installing=true
fi

if [ "$additions_need_installing" = true ] ; then
    echo "Installing VB Guest Additions 5.0.10"
	cd /opt
	# Download the ISO and mount it
	sudo wget -c -q http://download.virtualbox.org/virtualbox/5.0.10/VBoxGuestAdditions_5.0.10.iso -O VBoxGuestAdditions_5.0.10.iso
	sudo mount VBoxGuestAdditions_5.0.10.iso -o loop /mnt
	if [ "$USING_ORIGINAL_KERNEL" = true ] ; then
		printf '%s\n' 'Using original kernel!' >&2
		# Download the kernel files for the default kernel
		sudo wget -c -q http://vault.centos.org/7.1.1503/updates/x86_64/Packages/kernel-devel-3.10.0-229.11.1.el7.x86_64.rpm -O kernel-devel-3.10.0-229.11.1.el7.x86_64.rpm
		sudo wget -c -q http://vault.centos.org/7.1.1503/updates/x86_64/Packages/kernel-headers-3.10.0-229.11.1.el7.x86_64.rpm -O kernel-headers-3.10.0-229.11.1.el7.x86_64.rpm
		# Remove the existing kernel files and install the new ones
		sudo yum -q -y remove kernel-devel kernel-headers
		sudo yum -q -y --disablerepo \* --disableplugin \* install kernel-devel-3.10.0-229.11.1.el7.x86_64.rpm
		sudo yum -q -y --disablerepo \* --disableplugin \* install kernel-headers-3.10.0-229.11.1.el7.x86_64.rpm
	fi
	
	# Install everything the compiler needs
	sudo yum -q -y install -y -q kernel-devel kernel-headers dkms gcc gcc-c++ gcc-gfortran libquadmath-devel libtool systemtap
	sudo rpm -Uvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-6.noarch.rpm
	
	cd /mnt
	# This is needed in case the using DKMS didn't work so the installer needs to manually compile
	export KERN_DIR=/usr/src/kernels/`uname -r`
	#export KERN_DIR=/usr/src/kernels/`rpm -q --last kernel | perl -pe "s/^kernel-(\S+).*/$1/" | head -1`
	
	# Off we go!
	sudo ./VBoxLinuxAdditions.run --nox11
	printf "%s\n" "Now reboot please!" >&2
fi