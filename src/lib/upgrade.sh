MANAGE_MAGIC=MAGIC
NEED_HOSTNAME=yes
NEED_CONFIG=
NEED_CONFIRM=yes

function manage()
{
	remote apt-get update
	remote apt-get upgrade --yes
}
