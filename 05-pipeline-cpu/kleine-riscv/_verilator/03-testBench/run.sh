verilator --binary -j 0 -Wall --timing testbench.v and_gate.v
./obj_dir/Vtestbench

# verilator --binary -j 0 -Wall our.v