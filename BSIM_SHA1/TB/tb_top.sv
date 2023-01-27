`ifndef  TOP
`define  TOP 

`timescale  1ns/1ns
`include "uvm_macros.svh"

import uvm_pkg ::*;
`include "./tb_inf.sv"
`include "./tb_pkg.sv"
import tb_pkg ::*;

module  tb_top;

parameter    MSG_DATA_WIDTH       = 128    ;  
parameter    MSG_INFO_WIDTH       = 16     ; 
parameter    RES_DATA_WIDTH       = 32     ;

logic                          sys_clk               ;
logic                          sys_rst               ;

logic  [MSG_DATA_WIDTH - 1:0]  msg_data              ;
logic                          msg_data_val          ;
logic  [MSG_INFO_WIDTH - 1:0]  msg_info              ;
logic                          msg_info_val          ;
                                                     
logic  [RES_DATA_WIDTH - 1:0]  result_dout	         ;
logic                          result_data_fifo_ren  ;
logic                          result_data_empty     ;




tb_inf  input_if (sys_clk , sys_rst) ;


assign   msg_data               =  input_if.msg_data      ;    
assign   msg_data_val           =  input_if.msg_data_val  ;
assign   msg_info               =  input_if.msg_info      ;
assign   msg_info_val           =  input_if.msg_info_val  ;

assign   result_data_fifo_ren         =  input_if.result_data_fifo_ren  ;
assign   input_if.result_data_empty   =  result_data_empty              ;
assign   input_if.result_dout         =  result_dout                    ;


sha1_top  sha1_top_inst(

    .sys_clk               (sys_clk              ),
	.sys_rst               (sys_rst              ),
	.msg_data              (msg_data             ),
	.msg_data_val          (msg_data_val         ),
	.msg_info              (msg_info             ),
	.msg_info_val          (msg_info_val         ),
	.msg_buff_ready        (msg_buff_ready       ),
	.result_data_fifo_ren  (result_data_fifo_ren ),	
	.result_dout	       (result_dout	         ),
	.result_data_empty     (result_data_empty    )
 
);

initial begin 
    uvm_config_db#(virtual tb_inf)::set(null , "uvm_test_top.env0.i_agt.drv" , "tb_inf" , input_if ) ;
    uvm_config_db#(virtual tb_inf)::set(null , "uvm_test_top.env0.i_agt.mon" , "tb_inf" , input_if ) ;

end 

initial begin 
    sys_clk = 0 ;
	forever begin 
	    #2.5ns sys_clk = ~ sys_clk ;
    end 
end 

initial begin 
    sys_rst  = 1'b1  ;
	#10000;
	sys_rst = 1'b0  ;
end 

initial begin 

  // run_test() ;
  run_test(" ") ;
  // run_test("my_env") ;
  // $finish ;
end 



endmodule 
	
`endif 