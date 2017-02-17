# This is a script to update virtualbox guest additions to a 5.0 version.
# You must run this if if you've updated your kernel and have started to suffer the shared-folder-hang-on-boot problem because of the additions failing.
# (How to get this script into your VM without shared folder access is down to you, but sudo vi and sudo chmod are big hints!)

# Installation might immediately kill your shared folders so remember to halt/up afterwards.

# Exit code will be 0 if successful update else 99 if not needed

if modprobe vboxguest; then
    printf "%s\n" "VirtualBox Guest Additions working" >&2
	if VBoxControl -v | grep -q 5.1.14; then
		printf "%s\n" "VirtualBox Guest Additions at level 5.1.14. Nothing to do." >&2
		exit 99
	else
		printf "%s\n" "VirtualBox Guest Additions not at level 5.1.14!" >&2
	fi
else
	printf "%s\n" "VirtualBox Guest Additions not working!" >&2
fi

echo "Installing VirtualBox Guest Additions 5.1.14"
cd /opt
# Download the ISO and mount it
sudo wget -c -q http://download.virtualbox.org/virtualbox/5.1.14/VBoxGuestAdditions_5.1.14.iso -O VBoxGuestAdditions_5.1.14.iso
sudo mount VBoxGuestAdditions_5.1.14.iso -o loop /mnt

# Install everything the compiler needs
sudo yum -q -y install kernel-devel kexec-tools kernel-headers gcc gcc-c++ gcc-gfortran libquadmath-devel libtool systemtap

cd /mnt
# This is needed in case the using DKMS didn't work so the installer needs to manually compile
export KERN_DIR=/usr/src/kernels/`uname -r`
#export KERN_DIR=/usr/src/kernels/`rpm -q --last kernel | perl -pe "s/^kernel-(\S+).*/$1/" | head -1`

# Off we go!
sudo ./VBoxLinuxAdditions.run --nox11