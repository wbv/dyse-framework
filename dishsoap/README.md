# DiSH SOAP

**Di**screte,
**S**tochastic,
**H**eterogeneous Model
**S**imulation
**O**n
**A**ctual
**P**rogrammable-Logic

This is a rewrite of the Fast-DiSH project (Gilboy et al., 2019.
[doi:10.1109/EMBC.2019.8857495](https://doi.org/10.1109/EMBC.2019.8857495))
using VHDL and targeting full FPGA-acceleration using Xilinx PYNQ as an
interface.


## `sim_ghdl.sh`

Use this script to analyze, synthesize, and simulate (run testbenches) VHDL
source code.
The script wraps `docker` so be sure you have it installed and your user has
been appropriate permissions to use the docker command line interface.

Under the hood, we use the `ghdl/ext:latest` container image and mount the src
directory into our container. The container is intended to be persistent so that
you can make changes and work interactively, but this behavior could change in
the future.

Try `./sim_ghdl.sh --help` for usage.

### Examples

```bash
# one-liner to run all testbenches
./sim_ghdl.sh test   # runs `make test` in the ./src directory

# interactive commands
./sim_ghdl.sh build  # builds a persistent ghdl container
./sim_ghdl.sh run    # runs a shell in the persistent container
./sim_ghdl.sh clean  # removes your persistent ghdl container
```

Note that most of these commands are just trivial shortcuts to common docker
operations:

```bash
# build:
docker create -it --name 'dishsoap-ghdl' --volume $(pwd)/src:/src \
	--workdir /src --entrypoint bash 'ghdl/ext'
# run:
docker start -it --attach 'dishsoap-ghdl'
# clean:
docker rm 'dishsoap-ghdl'
```

