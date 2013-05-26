# Each command needs to set manage magic or the command will not execute.
MANAGE_MAGIC=

# List of all classes applied so far
GLOBAL_CLASSES=

# Run commands in orders
MANAGE_CHAIN=

# Run remote commands as
USER=root

CLASS_FILE=classes
CLASS_BASE=class
CLASS_STACK=
HOST_BASE=host
BINDIR=bin

GREEN="\E[1;32m"
MAGENTA="\E[1;35m"
BLUE="\E[1;34m"
WHITE="\E[1;37m"
NORM="\E[0m"

set -e

die()
{
	echo ERROR: $*
	exit 255
}

warn()
{
	echo -e "$MAGENTA>>>$NORM" $*
}

msg()
{
	if test -n "$QUIET"; then
		return
	fi

	echo -e "$GREEN>>>$NORM" $*
}

debug()
{
	if test -n "$QUIET"; then
		return
	fi

	echo -e "$BLUE>>>$NORM" $*
}

ask()
{
	echo -n $* "[yes/no]"?\ 
	read YES

	test "yes" = "$YES"
}

get_hosts()
{
	cd $HOST_BASE
	ls
}

cmd_path()
{
	for DIR in $BOXMAN_PATH; do
		XCMD=$DIR/$1.sh
		if test -e $XCMD; then
			echo $XCMD
		fi
	done
}

remote_copy()
{
	if test -z "$DRY"; then
		scp $1 $USER@$HOST:$2
	else
		debug scp $1 $USER@$HOST:$2
	fi
}

remote()
{
	if test -z "$DRY"; then
		ssh $USER@$HOST "$*" < /dev/null
	else
		debug ssh $USER@$HOST "$*" < /dev/null
	fi
}

remote_rmtempdir()
{
	remote rm -rf /tmp/cc2.??????????
}

remote_tempdir()
{
	TEMPLATE=/tmp/cc2.XXXXXXXXXX

	if test -z "$DRY"; then
		remote mktemp -d $TEMPLATE
	else
		echo $TEMPLATE
	fi
}

remote_script()
{
	test -n "$1" || die Usage: remote_script script

	REMOTE=$(remote_tempdir)/$1

	remote_copy $1 $REMOTE
	remote sh -e $REMOTE
	remote_rmtempdir
}

sync_dirs()
{
	SRC=$1
	DST=$2

	test -n "$SRC" || die Usage: sync_dirs source destination
	test -n "$DST" || die Usage: sync_dirs source destination

	# Make sure whe have trailing slashes
	LAST=$(echo $SRC | grep -o ".$")
	if test ! "$LAST" = "/"; then
		SRC=$SRC/
	fi

	LAST=$(echo $DST | grep -o ".$")
	if test ! "$LAST" = "/"; then
		DST=$DST/
	fi

	if test -z "$DRY"; then
		rsync -rlptDvz -e ssh --copy-links $SRC $USER@$HOST:$DST
	else
		debug rsync -rlptDvz -e ssh --copy-links $SRC $USER@$HOST:$DST
	fi
}

manage_exec()
{
	# No config for command
	if test -n "$NEED_CONFIG" -a -n "$BASE" -a ! -e "$BASE/$1"; then
		warn $BASE/$1 does not exist: skipping
		return
	fi

	if test -n "$BASE" -a -n "$DRY"; then
		debug $1: workdir: $BASE
	fi

	COMMAND=$(cmd_path $1)
	(
		if test -z "$BASE"; then
			msg $1
		else
			cd $BASE
			msg $1: $BASE
		fi

		# CMD_ARGS is set in manage
		manage $1 $CMD_ARGS
	)
}

manage_host()
{
	# $1 = command
	# $2 = host
	test -n "$1" || die Usage: manage_host command host
	test -n "$2" || die Usage: manage_host command host

	HOST=$2
	BASE=$HOST_BASE/$HOST

	manage_exec $1
}

# helper function that makes sure each class can be applied only once. Needed
# to prevent endless recursion
check_class()
{
	for C in $GLOBAL_CLASSES; do
		if test "$C" = "$1"; then
			warn class $1 already applied
			return 255
		fi
	done

	GLOBAL_CLASSES="$GLOBAL_CLASSES $1"
	return 0
}


manage_classes()
{
	# $1 = command
	# $2 = class file

	test -n "$1" || die Usage: manage_classes command file
	test -n "$2" || die Usage: manage_classes command file

	for CLASS in $(cat $2); do
		# Apply each class only once
		check_class $CLASS || continue

		CLASS_PATH=$CLASS_BASE/$CLASS

		# Check if class exists
		test -d $CLASS_PATH || die $2: class $CLASS does not exist

		# Handle subclasses
		if test -e "$CLASS_PATH/$CLASS_FILE"; then
			CLASS_STACK="$CLASS $CLASS_STACK"
			manage_classes $1 "$CLASS_PATH/$CLASS_FILE"
			CLASS=$(echo $CLASS_STACK | cut -d\  -f 1)
			CLASS_STACK=$(echo $CLASS_STACK | cut -d\  -f 2-)
			CLASS_PATH=$CLASS_BASE/$CLASS
		fi

		BASE=$CLASS_PATH

		manage_exec $1
	done
}

function manage_command()
{
	test -n "$1" || die Usage: manage_command command

	COMMAND=$(cmd_path $1)
	. $COMMAND

	# Variables set by $COMMAND:
	#
	# MANAGE_MAGIC		needs to be non empty
	# NEED_HOSTNAME		command is executed for a particular host
	# NEED_CONFIG		command has configuration
	# NEED_CONFIRM		user needs to approve command execution

	# Check if command sets magic
	test -n "$MANAGE_MAGIC" || die command $COMMAND does not set MAGIC

	# Check hostname
	if test -n "$NEED_HOSTNAME"; then
		test -n "$HOST" || die command $1 needs hostname
	fi

	# Confirm action if neccessary
	if test -n "$NEED_CONFIRM"; then
		if test ! "$YES" = "yes"; then
			if test -n "$HOST"; then
				ask Execute $1 on $HOST || exit
			else
				ask Execute $1 || exit
			fi
		fi
	fi

	# Commands with config are executed for all classes
	if test -n "$NEED_CONFIG" -a -e "$HOST_BASE/$HOST/$CLASS_FILE"; then
		manage_classes $1 $HOST_BASE/$HOST/$CLASS_FILE
	fi

	# Hostless commands
	if test -z "$NEED_HOSTNAME"; then
		manage_exec $1
	else
		manage_host $1 $HOST
	fi
}
