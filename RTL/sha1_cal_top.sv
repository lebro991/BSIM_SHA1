module  sha1_cal_top#(
            parameter    CHANNEL_NUM_TOTAL        = 64                        ,
            parameter    CHANNEL_NUM_WIDTH        = $clog2(CHANNEL_NUM_TOTAL) ,
            parameter    TAG_DATA_WIDTH           = 14                        ,
            parameter    MSG_DATA_WIDTH           = 512                       ,
            parameter    MSG_LEN_WIDTH            = 6                         
       )
       (
            input                                       sys_clk               ,
            input                                       sys_rst               ,
                                                         
            input      [MSG_DATA_WIDTH - 1 :0]          msg_wr_data           ,
            input                                       msg_wr_ena            ,
            input                                       msg_wr_sop            ,
            input      [11:0]                           msg_wr_addr           ,
            input      [5:0]                            msg_wr_len            ,
            input      [TAG_DATA_WIDTH - 1 :0]          msg_wr_tag            ,
            input                                       data_sq_fifo_rd_ena   ,
            output wire                                 data_sq_fifo_empty    ,
            output wire[CHANNEL_NUM_WIDTH - 1:0]        data_sq_fifo_dout     ,
            
            input                                       data_result_fifo_ren   ,
            output wire [31:0]                          result_dout            ,
            output wire                                 result_data_empty

        );

		localparam    SHA160_RES_WIDTH         = 160  ;
         
         		
		wire   [11:0]                                msg_rd_addr    ;
		wire   [MSG_DATA_WIDTH - 1:0]                msg_rd_data    ;
        wire                                         msg_rd_ena     ;
		wire   [MSG_DATA_WIDTH - 1:0]                data_msg_wr_tmp;
        wire   [TAG_DATA_WIDTH - 1:0]                result_tag     ;
        wire   [SHA160_RES_WIDTH - 1:0]              result_data    ;
        wire                                         result_valid   ;
        wire   [CHANNEL_NUM_WIDTH - 1:0]             data_sq_tmp    ;        
		
sha1_cal_core #(
            .SHA160_RES_WIDTH          (SHA160_RES_WIDTH  ),
            .CHANNEL_NUM_TOTAL         (CHANNEL_NUM_TOTAL ),
            .TAG_DATA_WIDTH            (TAG_DATA_WIDTH    ),
            .MSG_DATA_WIDTH            (MSG_DATA_WIDTH    ),
            .MSG_LEN_WIDTH             (MSG_LEN_WIDTH     )    
	
        ) 
sha1_cal_core_inst( 
            .clk                (sys_clk                ),     
            .rst_n              (~sys_rst               ),     
            .msg_rd_data        (msg_rd_data            ),     
            .msg_wr_ena         (msg_wr_ena             ),     
            .msg_wr_sop         (msg_wr_sop             ),
            .msg_wr_len         (msg_wr_len             ),
            .msg_wr_tag         (msg_wr_tag             ),
            .msg_wr_addr_h      (msg_wr_addr[11:6]      ),
            .msg_rd_ena         (msg_rd_ena             ),
            .msg_rd_addr        (msg_rd_addr            ),
			.result_tag         (result_tag             ),
            .result_sq          (data_sq_tmp            ),
            .result_data        (result_data[159:0]     ),
            .result_valid       (result_valid           )
         );	
		 
xpm_sdpram_common_with_initial  #(
            .RAM_WIDTH        (MSG_DATA_WIDTH           )  , 
            .RAM_DEPTH        (4096                     )  , 
            .RAM_STYLE        ("block"                  )  ,  // "block" "distribute"	
			.INIT             (1                        )  , 
			.INIT_VALUE       ({MSG_DATA_WIDTH{1'b0}}   )  , 
            .LAYTENCY         (2                        )    			
            
         )
sha1_block_data_ram_inst
         (
		 .clk                 (sys_clk                   ), //input                           
		 .rst                 (sys_rst                   ), //input                           
		 .dina                (msg_wr_data               ), //input    [RAM_WIDTH - 1  :0]    
		 .addra               (msg_wr_addr               ), //input    [ADDR_WIDTH - 1 :0]    
		 .wea                 (msg_wr_ena                ), //input                           
		 .doutb               (msg_rd_data               ), //input    [RAM_WIDTH - 1  :0]    
		 .addrb               (msg_rd_addr               ), //input    [ADDR_WIDTH - 1 :0]     
		 .initial_done        (                          )  //input    [ADDR_WIDTH - 1 :0]     
         ); 	   
	   
sha1_channel_ctrl   
        #(
        .CHANNEL_NUM_TOTAL          (CHANNEL_NUM_TOTAL  )
        )
sha1_channel_ctrl_inst        
        (
        .clk                    (sys_clk                ),   //input                                  
        .rst_n                  (~sys_rst               ),   //input                                  
        .data_sq_tmp            (data_sq_tmp            ),   //input        [CHANNEL_NUM_WIDTH -1:0]  
        .result_valid           (result_valid           ),   //input                                  
        .data_sq_fifo_rd_ena    (data_sq_fifo_rd_ena    ),   //input                                  
        .data_sq_fifo_empty     (data_sq_fifo_empty     ),   //output wire                            
        .data_sq_fifo_dout      (data_sq_fifo_dout      )    //output wire  [CHANNEL_NUM_WIDTH -1:0]  
        
        );      
        
sha1_pkt_oder  
        #(       
            .TAG_WIDTH                (TAG_DATA_WIDTH      )   ,    
            .SHA_RESULT_WIDTH         (32                  )     
        )
sha1_pkt_oder_inst
        (
            .clk                     (sys_clk              ),  //input                                           
            .rst_n                   (~sys_rst             ),  //input                                           
            .result_data             (result_data[31:0]    ),  //input        [SHA_RESULT_WIDTH - 1:0]           
            .result_tag              (result_tag           ),  //input        [TAG_WIDTH - 1:0]                       
            .result_en               (result_valid         ),  //input                                           
            .result_dout             (result_dout          ),  //output wire  [SHA_RESULT_WIDTH - 1:0]           
            .result_data_empty       (result_data_empty    ),  //output reg                                             
            .init_done               (init_done            ),  //output wire                                            
            .result_fifo_ren         (data_result_fifo_ren )   //input                                                     
        
        );        
		
endmodule 