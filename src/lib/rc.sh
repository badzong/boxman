MANAGE_MAGIC=MAGIC
NEED_HOSTNAME=yes
NEED_CONFIG=yes
NEED_CONFIRM=yes

function manage()
{
	while read INIT ACTION PRIO RUNLEVEL; do
		remote update-rc.d $INIT $ACTION $PRIO $RUNLEVEL
	done < $1
}
