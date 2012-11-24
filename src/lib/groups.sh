MANAGE_MAGIC=MAGIC
NEED_HOSTNAME=yes
NEED_CONFIG=yes
NEED_CONFIRM=yes

function manage()
{
	while read NAME ARGS; do
		remote "getent group $NAME || groupadd $ARGS $NAME"
	done < $1
}
