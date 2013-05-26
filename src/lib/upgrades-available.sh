MANAGE_MAGIC=MAGIC
NEED_HOSTNAME=yes
NEED_CONFIG=
NEED_CONFIRM=

function manage()
{
	remote apt-get update >& /dev/null
	UPGRADES=$(remote apt-get upgrade --dry-run | grep -o '^[0-9]*')

	# Print if upgrase available or quiet is not set.
	if test "$UPGRADES" -gt 0 -o -n "$QUIT"; then
		echo $UPGRADES upgrades for $HOST available.
	fi
}
