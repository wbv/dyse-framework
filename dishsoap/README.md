# DiSH SOAP

**Di**screte,
**S**tochastic,
**H**eterogeneous Model
**S**imulation
**O**n
**A**ctual
**P**rogrammable-Logic

This is a rewrite of the Fast-DiSH project (Gilboy et al., 2017.
[doi:10.1109/EMBC.2019.8857495](https://doi.org/10.1109/EMBC.2019.8857495))
using VHDL and targeting full FPGA-acceleration using Xilinx PYNQ as an
interface.


## `sim_ghdl.sh`

Use this script to analyze, synthesize, and simulate (run testbenches) files.
The script wraps `docker` so be sure you have it installed and your user has
been appropriate permissions to use the docker command line interface. 

Under the hood, we use the `ghdl/ext:latest` container image and mount the src
directory into our container. The container is intended to be persistent so that
you can make changes and work interactively, but this behavior could change in
the future.

Try `./sim_ghdl.sh --help` for usage.

### Examples

```bash
./sim_ghdl.sh build  # builds the ghdl container image
./sim_ghdl.sh test   # runs ./src/run-tb.sh in a temporary container
```
