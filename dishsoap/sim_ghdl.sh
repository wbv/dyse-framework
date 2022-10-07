#!/bin/sh

NAME='dishsoap-ghdl'
BASE_IMAGE='docker.io/ghdl/ext:latest'
#NEW_IMAGE='ghdl-for-dishsoap'

usage() {
	cat <<-EOF
Usage:
  $0 ACTION

Description:
  Manages a container named '$NAME' based off the
  image tag '$BASE_IMAGE' using docker tools.

  Intended to help test and verify VHDL for the 'dishsoap' project.

Actions:
  build   build the container (docker create)
  run     run the container   (docker start --attach)
  clean   delete the continer (docker rm)
  test    build and run a temporary container to run the test suite

	EOF
}

container_built() {
	return docker container inspect "$NAME" &>/dev/null ;
}

if ! command -v docker &>/dev/null \
&& ! which docker      &>/dev/null ; then
	echo "E: Comand 'docker' not found." >&2
	echo "E: Docker is needed to run tests on src. Exiting." >&2
	exit 1
fi

if [ $# -eq 0 ]; then
	usage
	exit 1
fi

while [ $# -gt 0 ]; do
	case "$1" in
		test )
			docker run \
			  --rm \
			  --interactive \
			  --tty \
			  --volume $(pwd)/src:/src \
			  --workdir /src \
			  "$BASE_IMAGE" \
			  sh -c './run-tb.sh \
			    nw_reg.vhdl \
			    network_toy.vhdl \
			  '
			shift
			;;
		build )
			# warn nicely if clean hasn't been done
			if container_built; then
				echo "E: container already built." >&2
				echo "   Hint: To destory current container, run '$0 clean' first." >&2
				exit 1
			fi
			docker create \
			  --interactive \
			  --tty \
			  --name "$NAME" \
			  --volume $(pwd)/src:/src \
			  --workdir /src \
			  --entrypoint bash \
			  "$BASE_IMAGE"
			shift
			;;
		run )
			# warn nicely if build hasn't been done
			if ! container_built; then
				echo "E: container not built." >&2
				echo "   Hint: run '$0 build' first." >&2
				exit 1
			fi

			docker start -ia "$NAME"
			shift
			;;
		stop )
			docker stop -t 0 "$NAME"
			shift
			;;
		clean )
			# remove the container, offering advice on failure
			if ! docker rm "$NAME" ; then
				echo "Hint: run '$0 stop' first." >&2
			fi

			shift
			;;
		help | -h | --help | -? )
			usage
			exit
			;;
		* )
			echo "E: Unknown action '$1'. Exiting." >&2
			usage
			exit 2
			;;
	esac
done
