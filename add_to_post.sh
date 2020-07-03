#!/bin/bash
[ -z "$1" ] && echo "[Usage]: $0 FILE" && exit 1

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

case "$1" in
	clean)
		find "$DIR"/_posts/ -xtype l -delete
		;;
	all)
		echo "TODO: add all"
		;;
	*)
		FILE="$DIR"/"$1"
		[ ! -f "$FILE" ] && echo "'$FILE' Not found!" && exit 1
		ln -s -f "$FILE" "$DIR"/_posts/
		;;
esac
