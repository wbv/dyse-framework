#!/bin/sh

cp ../vivado/test_dma_stream/test_dma_stream_wrapper.xsa .
unzip -o test_dma_stream_wrapper.xsa test_dma_stream_wrapper.bit test_dma_stream.hwh
mv test_dma_stream_wrapper.bit test_dma_stream.bit
scp test_dma_stream.hwh xilinx@136.142.180.169:~/jupyter_notebooks/dishsoap/
scp test_dma_stream.bit xilinx@136.142.180.169:~/jupyter_notebooks/dishsoap/
