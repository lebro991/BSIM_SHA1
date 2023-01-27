vlib  work 
set UVM_HOME       E:/soft/modelsim/uvm-1.1d
set WORK_HOME      F:/mywork_file/sha1/BSIM/TB
set UVM_DPI_HOME   E:/soft/modelsim/uvm-1.1d/win64

#   cd  F:/mywork_file/sha1/BSIM/TB/case0 

#$UVM_HOME/src/uvm_pkg.sv

vlog +incdir +$UVM_HOME/src -L mtiOvm -L mtiUvm  -L mtiUPF   $WORK_HOME/tb_top.sv  
# vsim -c -sv_lib  $UVM_DPI_HOME/uvm_dpi   work.tb_top
vsim  -sv_lib  $UVM_DPI_HOME/uvm_dpi   -c tb_top  +UVM_TESTNAME=tb_case1

view wave *

run 30000ns
