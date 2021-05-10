# KMeansClusteringSW

This is a repository storing all of the files and related works for the FPGA Cluster Computing Machine project. This is the senior design project of Hamza Alsharif (hsfalsharif), and Ahmad Alharbi (nitrogar). There are two main sets of files within this repo. The first set is the files that are relevant to the software version or the golden model, and the second set is relevant to the hardware version which was the focus of work of the project.

The first set of files includes the directories:
* `pictures`: Input pictures in a format that can be accepted and tested by the software version.
* `outputs`: Some outputs that were the results of the images tested from within the pictures directory.

And the files:
* `ComparatorTree.py`: An early version of a modular single-dimension tree class.
* `KMeansClusteringModular.py`: An early version of a clustering program for testing. This was the first working prototype of the dimension separation approach.
* `tree.py`: The primary final software version program. This program was changed extensively throughout the algorithmic development phase.

The second set of files are all included in the `verilog` directory. Inside of it, the following Quartus prime project directories are included:
* `sequantial`: "Sequential with Divider" design version. The divider was configured and tested with and without pipelining from the megafunction config menu.
* `sequential_manhattan`: "Pipelined Sequential without Divider" design version.
* `kd_tree`: "Pipelined Kd Tree with Pipelined Divider" and "Kd Tree with Pipelined Divider" design versions. Pipelining was done within the comparison element. Switching baterrn the pipelined and non-pipelined iterations was a matter of switching between reg and wire types accordingly.
* `kd_tree_no_div`: "Pipelined Kd Tree with Pipelined Divider" design version.

For each of the directories, the `.qpf` can be run with the Quartus Prime design software. For the `sequantial` and `sequential_manhattan` projects, `kmean.v` is the main verilog module file and `main_tb.v` is the testbench for it. For the `kd_tree` and `kd_tree_no_div` projects, the top level verilog module is `container.v` which is a container for `node.v`. `node.v` uses the `cluster_CE.v` module which contains the `manhattan.v` module. Originally it was planned that `cluster_PE.v` would be its own independent module but later it made more sense to put its contents within `node.v` so that the node module can have direct access to it. The testbenches for `cluster_CE.v` and `cluster_PE.v` are `cluster_ce_tb.v` and `cluster_pe_tb.v` respectively. The testbench for testing a tree which is made up of multiple nodes is `kd_tree.v`. A python program is also included for generating the text required to instantiate node modules for the testbench. This program takes the number of nodes required and generates their instanstiation text - it is `tree_generator.py`.

To run the `kd_tree.v` testbench, simply open the .qpf file and run the ModelSim simulator, but make sure to specify the correct relative path to the input test image hex file - `mm.hex`.
