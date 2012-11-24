DEFAULT_LIB=/usr/local/lib/boxman
DEFAULT_BIN=/usr/local/bin

if test -z "$BOXMAN_LIB"; then
	BOXMAN_LIB=$DEFAULT_LIB
fi

if test -z "$BOXMAN_BIN"; then
	BOXMAN_BIN=$DEFAULT_BIN
fi

case "$1" in
install)
	sed -e "s#LIB=INSTALL_LIB#LIB=$BOXMAN_LIB#" < src/boxman > boxman

	install boxman $BOXMAN_BIN
	install -d $BOXMAN_LIB
	install src/lib/* $BOXMAN_LIB
	;;
uninstall)
	echo rm $BOXMAN_BIN/boxman $BOXMAN_LIB
	rm -Ir $BOXMAN_BIN/boxman $BOXMAN_LIB
	;;
*)
	cat << EOF
USAGE: $0 install

$0 installs boxman to your system. To customize the installation
directories you can use the following environment variables:

  BOXMAN_LIB       Location where the builtin boxman scripts will be
                   installed (DEFAULT=$DEFAULT_LIB).

  BOXMAN_BIN       Location where the main boxman script will be
                   installed (DEFAULT=$DEFAULT_BIN).


Example Usage:

  BOXMAN_LIB=/usr/lib/boxman BOXMAN_BIN=/usr/bin sh $0

EOF
	exit 255
	;;
esac
exit 0
