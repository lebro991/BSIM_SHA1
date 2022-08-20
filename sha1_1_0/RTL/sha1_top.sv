module  sha1_top#(

        parameter    MSG_DATA_WIDTH       = 128                        ,  
        parameter    MSG_INFO_WIDTH       = 16                         , 
        parameter    MSG_FILL_DATA_WIDTH  = 512                        ,  
        parameter    TAG_DATA_WIDTH       = 14                         , 
        parameter    RES_DATA_WIDTH       = 32                         , 
        parameter    CHANNEL_NUM_TOTAL    = 64                         , 
		parameter    CHANNEL_NUM_WIDTH    = $clog2(CHANNEL_NUM_TOTAL)
      )
      
	  (
        input                               sys_clk                 ,
        input                               sys_rst                 ,
                                                      
        input      [MSG_DATA_WIDTH - 1:0]   msg_data                ,
        input                               msg_data_val            ,
        input      [MSG_INFO_WIDTH - 1:0]   msg_info                ,
        input                               msg_info_val            ,
		
        output reg                          msg_buff_ready          ,
		
        input                               result_data_fifo_ren    ,
        output wire [RES_DATA_WIDTH - 1:0]  result_dout             ,
        output wire                         result_data_empty      

        );
        wire   [MSG_DATA_WIDTH - 1:0]   msg_data_fifo_dout    ;
        wire                            msg_data_fifo_rd_en   ;
        wire                            msg_data_fifo_empty   ;
        wire                            msg_data_fifo_pfull   ;
        
        wire   [MSG_INFO_WIDTH - 1:0]   msg_info_fifo_dout    ;
        wire                            msg_info_fifo_rd_en   ;
        wire                            msg_info_fifo_empty   ;
        wire                            msg_info_fifo_pfull   ;        
         		
		wire [CHANNEL_NUM_WIDTH - 1 : 0 ]  msg_channel_num      ;
        wire                               data_sq_fifo_empty   ;
        wire                               data_sq_fifo_rd_ena  ;
        wire [TAG_DATA_WIDTH - 1:0 ]       msg_wr_tag           ;
        wire [MSG_FILL_DATA_WIDTH - 1:0 ]  msg_wr_data          ;
        wire                               msg_wr_ena           ;
        wire                               msg_wr_sop           ;
        wire                               msg_wr_eop           ;
        wire [MSG_INFO_WIDTH - 1 :0]       msg_wr_len           ;
        wire [11 :0]                       msg_wr_addr          ;		
		
/********************************************************************************************************/		   
sync_fifo #(
            .FIFO_MEMORY_TYPE     ("block"                   ),  //"block" or "distributed"
	        .FIFO_READ_LATENCY    (0                         ),
            .FIFO_WRITE_DEPTH     (2048                      ),
	        .WRITE_DATA_WIDTH     (MSG_DATA_WIDTH            ),	
	        .PROG_FULL_THRESH     (1500                      ),	
	        .READ_MODE            ("fwft"                    )   //or "std"
        )
sha1_msg_data_fifo_inst    
       (
            .wr_clk               (sys_clk                                    ),   // input                                             
            .rst                  (sys_rst                                    ),   // input                                             
            .din                  (msg_data                                   ),   // input           [WRITE_DATA_WIDTH-1 : 0]          
            .rd_en                (msg_data_fifo_rd_en                        ),   // input                                             
            .wr_en                (msg_data_val                               ),   // input                                                                   
            .dout                 (msg_data_fifo_dout                                   ),   // output  wire    [READ_DATA_WIDTH-1  : 0]          
            .empty                (msg_data_fifo_empty                        ),   // output  wire                                      
            .full                 (                                           ),   // output  wire                                      
            .prog_full            (msg_data_fifo_pfull                        ),   // output  reg  
            .overflow             (                                           ),   // output  wire 					
            .underflow            (                                           ),   // output  wire 					
            .wr_data_count        (                                           )	   // output  wire    [RD_DATA_COUNT_WIDTH-1  : 0]   
	    );  
sync_fifo #(
            .FIFO_MEMORY_TYPE     ("block"                   ),  //"block" or "distributed"
	        .FIFO_READ_LATENCY    (0                         ),
            .FIFO_WRITE_DEPTH     (512                       ),
	        .WRITE_DATA_WIDTH     (MSG_INFO_WIDTH            ),	
	        .PROG_FULL_THRESH     (500                       ),	
	        .READ_MODE            ("fwft"                    )   //or "std"
        )
sha1_msg_info_fifo_inst    
       (
            .wr_clk               (sys_clk                                    ),   // input                                             
            .rst                  (sys_rst                                    ),   // input                                             
            .din                  (msg_info                                   ),   // input           [WRITE_DATA_WIDTH-1 : 0]          
            .rd_en                (msg_info_fifo_rd_en                        ),   // input                                             
            .wr_en                (msg_info_val                               ),   // input                                                                   
            .dout                 (msg_info_fifo_dout                         ),   // output  wire    [READ_DATA_WIDTH-1  : 0]          
            .empty                (msg_info_fifo_empty                        ),   // output  wire                                      
            .full                 (                                           ),   // output  wire                                      
            .prog_full            (msg_info_fifo_pfull                        ),   // output  reg  
            .overflow             (                                           ),   // output  wire 					
            .underflow            (                                           ),   // output  wire 					
            .wr_data_count        (                                           )	   // output  wire    [RD_DATA_COUNT_WIDTH-1  : 0]   
	    );  		

    always @ (posedge sys_clk)begin 
        if(sys_rst)begin 
             msg_buff_ready <=   1'b0; 
        end 
        else begin 
             msg_buff_ready <=   (~msg_info_fifo_pfull)& (~msg_data_fifo_pfull) ;          
        end 
    end  

		
/********************************************************************************************************/	

assign  data_sq_fifo_rd_ena =  msg_info_fifo_rd_en ;
	
sha1_msg_fill_ctrl_128to512  
       #(  
            .MSG_DATA_WIDTH       (MSG_DATA_WIDTH        ),      //= 'd128              ,
            .MSG_INFO_WIDTH       (MSG_INFO_WIDTH        ),      //= 'd16               ,
            .TAG_DATA_WIDTH       (TAG_DATA_WIDTH        ),      //= 14                 ,
            .CNT_WIDTH            (16                    ),      //= 'd16               ,
            .FILLED_DATA_WIDTH    (MSG_FILL_DATA_WIDTH   ),      //= 'd512    
            .CHANNEL_NUM_TOTAL    (CHANNEL_NUM_TOTAL     )       //= 'd512    

       )
sha1_msg_fill_ctrl_128to512_inst
       (                      
            .sys_clk                 (sys_clk                                  ),  //input                                                   
            .sys_rst                 (sys_rst                                  ),  //input                                                                                                                                   
            .msg_cal_channel_ready   (~data_sq_fifo_empty                      ),  //input                                                    	                                                                                
            .msg_data_rd_en          (msg_data_fifo_rd_en                      ),  //input                                                   
            .msg_data                (msg_data_fifo_dout                                 ),  //input             [MSG_DATA_WIDTH - 1 :0]               
            .msg_info_rd_en          (msg_info_fifo_rd_en                      ),  //input                                                   
            .msg_info                (msg_info_fifo_dout                       ),  //input             [MSG_INFO_WIDTH - 1 :0]               
            .msg_info_fifo_empty     (data_sq_fifo_empty | msg_info_fifo_empty ),  //input             [MSG_INFO_WIDTH - 1 :0]                                                                                                 
            .msg_channel_num_i       (msg_channel_num                          ),  //input             [MSG_INFO_WIDTH - 1 :0]                                                                                                 
            .msg_filled_data_valid   (msg_wr_ena                               ),  //input             [CHANNEL_NUM_WIDTH - 1 :0]            
            .msg_filled_data_sop     (msg_wr_sop                               ),  //input                                                   
            .msg_filled_data_eop     (msg_wr_eop                               ),  //input                                                   
            .msg_filled_data         (msg_wr_data                              ),  //input             [FILLED_DATA_WIDTH - 1 :0]            
            .msg_filled_info_valid   (                                         ),  //input                                                   
            .msg_filled_info         (msg_wr_len                               ),  //input             [MSG_INFO_WIDTH - 1 :0]               
            .msg_filled_tag          (msg_wr_tag                               ),  //input             [TAG_DATA_WIDTH - 1 :0]                	
            .msg_filled_addr         (msg_wr_addr                              )   //input             [11 :0]                               
   
        );		
 
    sha1_cal_top  #(
            .CHANNEL_NUM_TOTAL        (CHANNEL_NUM_TOTAL              )   ,    //= 64                        ,
            .TAG_DATA_WIDTH           (TAG_DATA_WIDTH                 )   ,    //= 14                        ,
            .MSG_DATA_WIDTH           (MSG_FILL_DATA_WIDTH            )                       
       )
	sha1_cal_top_inst   
       (
            .sys_clk                (sys_clk             ),   //input                                       
            .sys_rst                (sys_rst             ),   //input                                                            
            .msg_wr_data            (msg_wr_data         ),   //input       [MSG_DATA_WIDTH - 1 :0]                                                 
            .msg_wr_ena             (msg_wr_ena          ),   //input                                       
            .msg_wr_sop             (msg_wr_sop          ),   //input                                       
            .msg_wr_addr            (msg_wr_addr         ),   //input       [11:0]                           
            .msg_wr_len             (msg_wr_len          ),   //input       [5:0]                            
            .msg_wr_tag             (msg_wr_tag          ),   //input       [TAG_DATA_WIDTH - 1 :0]          
            .data_sq_fifo_rd_ena    (data_sq_fifo_rd_ena ),   //input                                       
            .data_sq_fifo_empty     (data_sq_fifo_empty  ),   //output wire                                
            .data_sq_fifo_dout      (msg_channel_num     ),   //output wire [CHANNEL_NUM_WIDTH - 1:0]                                                 
            .data_result_fifo_ren   (result_data_fifo_ren),   //input                   
            .result_dout            (result_dout         ),   //output wire [31:0]                                            
            .result_data_empty      (result_data_empty   )    //output wire                               
                                                                                          
        ); 
	       
		
endmodule 