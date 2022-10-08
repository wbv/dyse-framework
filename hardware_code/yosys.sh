#!/bin/sh

# vim: tw=100

docker --help 2>/dev/null >/dev/null || echo "E: 'docker' not found." >&2 | exit 1

UID=$(id -u)
GID=$(id -g)
PWD=$(pwd)

if [ "$UID" = "" ]; then
	echo 'E: $UID not found' >&2
	exit 1
elif [ "$GID" = "" ]; then
	echo 'E: $GID not found' >&2
	exit 1
elif
	[ ! -w "$PWD" ]; then
	echo "E: unable to write to current directory:" >&2
	echo " -> $PWD" >&2
fi

cmd="docker run --rm -it -u $UID:$GID -v $PWD:/work -w /work gcr.io/hdl-containers/yosys yosys $@"
echo $cmd
eval $cmd
