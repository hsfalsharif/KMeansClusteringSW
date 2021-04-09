transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Hamza/PycharmProjects/KMeansClustering/verilog/kd_tree {C:/Users/Hamza/PycharmProjects/KMeansClustering/verilog/kd_tree/node.v}
vlog -vlog01compat -work work +incdir+C:/Users/Hamza/PycharmProjects/KMeansClustering/verilog/kd_tree {C:/Users/Hamza/PycharmProjects/KMeansClustering/verilog/kd_tree/cluster_PE.v}
vlog -vlog01compat -work work +incdir+C:/Users/Hamza/PycharmProjects/KMeansClustering/verilog/kd_tree {C:/Users/Hamza/PycharmProjects/KMeansClustering/verilog/kd_tree/manhattan.v}
vlog -vlog01compat -work work +incdir+C:/Users/Hamza/PycharmProjects/KMeansClustering/verilog/kd_tree {C:/Users/Hamza/PycharmProjects/KMeansClustering/verilog/kd_tree/cluster_CE.v}
vlog -vlog01compat -work work +incdir+C:/Users/Hamza/PycharmProjects/KMeansClustering/verilog/kd_tree {C:/Users/Hamza/PycharmProjects/KMeansClustering/verilog/kd_tree/kd_tree.v}

vlog -vlog01compat -work work +incdir+C:/Users/Hamza/PycharmProjects/KMeansClustering/verilog/kd_tree {C:/Users/Hamza/PycharmProjects/KMeansClustering/verilog/kd_tree/kd_tree.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  kd_tree

add wave *
view structure
view signals
run -all