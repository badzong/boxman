MANAGE_MAGIC=MAGIC
NEED_HOSTNAME=yes
NEED_CONFIG=yes
NEED_CONFIRM=yes

function manage()
{
	REMOTE=$(remote_tempdir)/$1

	remote_copy $1 $REMOTE
	remote sh -e $REMOTE
	remote_rmtempdir
}
