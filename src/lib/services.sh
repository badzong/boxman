MANAGE_MAGIC=MAGIC
NEED_HOSTNAME=yes
NEED_CONFIG=yes
NEED_CONFIRM=yes

function manage()
{
	while read SERVICE; do
		remote "/etc/init.d/$SERVICE restart"
	done < $1
}
