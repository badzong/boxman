MANAGE_MAGIC=MAGIC
NEED_HOSTNAME=yes
NEED_CONFIG=yes
NEED_CONFIRM=yes

VIRTUALENV_BASE=/usr/local/virtualenv

function manage()
{
	cd $1

	for FILE in *; do
		test -f $FILE || return # Incase folder is empty

		VENV=$VIRTUALENV_BASE/$FILE
		VREQ=$VENV/requirements.txt
		PIP=$VENV/bin/pip

		remote "test -d $VIRTUALENV_BASE || mkdir $VIRTUALENV_BASE"
		remote "test ! -d $VENV || rm -rf $VENV" # CAVEAT ! and ||
		remote "virtualenv $VENV"
		remote_copy $FILE $VREQ
		remote "$PIP install -M -r $VREQ"
	done
}
