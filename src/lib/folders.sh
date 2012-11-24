MANAGE_MAGIC=MAGIC
NEED_HOSTNAME=yes
NEED_CONFIG=yes
NEED_CONFIRM=yes

function manage()
{
	while read FOLDER OWNER MODE; do
		remote mkdir -p $FOLDER

		if test -n "$OWNER"; then
			remote chown -R $OWNER $FOLDER
		fi

		if test -n "$MODE"; then
			remote chmod -R $MODE $FOLDER
		fi
	done < $1
}
