MANAGE_MAGIC=MAGIC
NEED_HOSTNAME=yes
NEED_CONFIG=yes
NEED_CONFIRM=yes

function manage()
{
	test -d $1
	TEMP=$(remote_tempdir)

	sync_dirs $1 $TEMP
	remote "cd $TEMP; for SCRIPT in *.sh; do sh -e \$SCRIPT; done"
	remote_rmtempdir
}
