interface  tb_inf (input sys_clk  , input  sys_rst);

parameter    MSG_DATA_WIDTH       = 128                        ; 
parameter    MSG_INFO_WIDTH       = 16                         ; 
parameter    RES_DATA_WIDTH       = 32                         ;


logic [MSG_DATA_WIDTH - 1:0]   msg_data                  ;
logic                          msg_data_val              ;
logic [MSG_INFO_WIDTH - 1:0]   msg_info                  ;
logic                          msg_info_val              ;
logic                          msg_buff_ready            ;	

logic [RES_DATA_WIDTH - 1:0]   result_dout               ;
logic                          result_data_fifo_ren      ;
logic                          result_data_empty         ;
	                           
	
endinterface 
