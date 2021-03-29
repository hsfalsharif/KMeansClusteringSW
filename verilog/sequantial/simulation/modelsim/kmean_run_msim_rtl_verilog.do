transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/oxygen/Documents/GitHub/KMeansClusteringSW/verilog/sequantial {C:/Users/oxygen/Documents/GitHub/KMeansClusteringSW/verilog/sequantial/kmean.v}
vlog -vlog01compat -work work +incdir+C:/Users/oxygen/Documents/GitHub/KMeansClusteringSW/verilog/sequantial {C:/Users/oxygen/Documents/GitHub/KMeansClusteringSW/verilog/sequantial/divder.v}
vlog -vlog01compat -work work +incdir+C:/Users/oxygen/Documents/GitHub/KMeansClusteringSW/verilog/sequantial/output_files {C:/Users/oxygen/Documents/GitHub/KMeansClusteringSW/verilog/sequantial/output_files/mb.v}
vlog -vlog01compat -work work +incdir+C:/Users/oxygen/Documents/GitHub/KMeansClusteringSW/verilog/sequantial {C:/Users/oxygen/Documents/GitHub/KMeansClusteringSW/verilog/sequantial/main_tb.v}

vlog -vlog01compat -work work +incdir+C:/Users/oxygen/Documents/GitHub/KMeansClusteringSW/verilog/sequantial {C:/Users/oxygen/Documents/GitHub/KMeansClusteringSW/verilog/sequantial/main_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  main_tb

add wave *
view structure
view signals
run -all
