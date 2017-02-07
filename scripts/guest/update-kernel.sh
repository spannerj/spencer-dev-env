sudo yum -y update kernel* | grep 'No packages marked for update' &> /dev/null
if [ $? == 0 ]; then
    exit 1 # Nothing to update
else
    exit 0 # Update occurred
fi