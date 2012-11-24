MANAGE_MAGIC=MAGIC
NEED_HOSTNAME=yes
NEED_CONFIG=yes
NEED_CONFIRM=yes

manage()
{
	while read FILE OWNER MODE; do
		remote "chown $OWNER $FILE && chmod $MODE $FILE"
	done < $1
}
