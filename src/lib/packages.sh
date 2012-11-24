MANAGE_MAGIC=MAGIC
NEED_HOSTNAME=yes
NEED_CONFIG=yes
NEED_CONFIRM=yes

function manage()
{
	# Check if $1 is a regular file
	test -f $1

	# Get update
	remote apt-get update

	# Prevent services from running after installation
	remote "echo \\#!/bin/sh > /usr/sbin/policy-rc.d"
	remote "echo exit 101 >> /usr/sbin/policy-rc.d"

	remote chmod a+x /usr/sbin/policy-rc.d
	remote apt-get install --yes $(cat $1)
	remote rm /usr/sbin/policy-rc.d
}
