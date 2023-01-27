package tb_pkg;

`include "uvm_macros.svh"
import uvm_pkg ::*;

bit[511:0]   tx_filled_pkt_q[$];
bit[159:0]   ref_model_result_final[$];
bit[511:0]   rx_filled_pkt_q[$];
bit[159:0]   rtl_result_final[$];

// `include "tb_agent_config.sv"
`include "tb_item.sv"
`include "tb_sequencer.sv"
`include "tb_driver.sv"
`include "tb_sequence.sv"
`include "tb_monitor.sv"
`include "tb_agent.sv"
`include "tb_model.sv"
`include "tb_scoreboard.sv"
`include "tb_env.sv"
`include "tb_vsqr.sv"
`include "tb_base_test.sv"
`include "./case0/tb_case0.sv"
`include "./case1/tb_case1.sv"
endpackage
