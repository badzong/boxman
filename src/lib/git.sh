MANAGE_MAGIC=MAGIC
NEED_HOSTNAME=yes
NEED_CONFIG=yes
NEED_CONFIRM=yes

function manage()
{
	while read FOLDER REPO BRANCH; do
		if test -z "$BRANCH"; then
			BRANCH=master
		fi

		TEMP=$(remote_tempdir)
		remote git clone -b $BRANCH $REPO $TEMP
		remote rm -rf $TEMP/.git*
		remote "test -e $FOLDER && rm -rf $FOLDER" || echo $FOLDER does not exist
		remote mv $TEMP $FOLDER
	done < $1
}
