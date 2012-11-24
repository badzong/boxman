MANAGE_MAGIC=MAGIC
NEED_HOSTNAME=yes
NEED_CONFIG=yes
NEED_CONFIRM=yes

function remote_diff()
{
	FILE=$1
	if ssh $USER@$HOST "cd /; diff "$FILE" - " < $FILE; then
		return 0
	fi

	return 255
}

function manage()
{
	ROOT=$1
	MODE=$2
	
	# $ROOT exists but is not a directory
	test -d "$ROOT"


	if test "$MODE" = "diff"; then
		cd $ROOT
		for FILE in $(find . -type f); do
			if ! remote_diff $FILE > /dev/null; then
				msg $FILE
				remote_diff $FILE || true
				echo
			fi
		done
	else
		sync_dirs $ROOT /
	fi
}
