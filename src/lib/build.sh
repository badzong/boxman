MANAGE_MAGIC=MAGIC
NEED_HOSTNAME=yes
NEED_CONFIG=yes
NEED_CONFIRM=yes

function manage()
{
	BUILD_DIR=/usr/local/src

	test -d $1
	for SCRIPT in $1/*.sh; do
		test -f $SCRIPT || return # If directory is empty

		SCRIPT_NAME=$(basename $SCRIPT)
		remote_copy $SCRIPT $BUILD_DIR/$SCRIPT_NAME
		remote "cd $BUILD_DIR; sh -e $SCRIPT_NAME"
	done
}
