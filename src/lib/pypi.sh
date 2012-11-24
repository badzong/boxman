MANAGE_MAGIC=MAGIC
NEED_HOSTNAME=yes
NEED_CONFIG=yes
NEED_CONFIRM=yes

function manage()
{
	while read EGG; do
		remote easy_install-2.7 $EGG
	done < $1
}
