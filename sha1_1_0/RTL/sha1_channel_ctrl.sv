module  sha1_channel_ctrl
        #(
         parameter    CHANNEL_NUM_TOTAL        = 64,
         parameter    CHANNEL_NUM_WIDTH        = $clog2(CHANNEL_NUM_TOTAL)
        )
        (
        input                                           clk                     ,  
        input                                           rst_n                   ,
        input        [CHANNEL_NUM_WIDTH -1:0]           data_sq_tmp             ,
        input                                           result_valid            ,
        input                                           data_sq_fifo_rd_ena     ,
        output wire                                     data_sq_fifo_empty      ,
        output wire  [CHANNEL_NUM_WIDTH -1:0]           data_sq_fifo_dout 
        
        );
     
 
localparam             ST_IDLE                = 0, 
                       ST_INIT                = 1,   
                       ST_UPDATE              = 2 ;
           
reg [7:0]                           delay_cnt                    ;
reg                                 data_sq_fifo_wr_ena          ;
reg [CHANNEL_NUM_WIDTH -1:0]        data_sq_fifo_din             ;
reg [CHANNEL_NUM_WIDTH :0]          data_sq_fifo_din_update      ;           
reg [1:0]                           fsm_cs                       ;  
reg [1:0]                           fsm_ns                       ;
/****************************************************/
//inital the fifo
/****************************************************/
   always @ (posedge clk)begin 
       if(!rst_n)begin 
            data_sq_fifo_wr_ena <=  1'b0; 
       end 
       else begin 
            if ((fsm_cs == ST_INIT)&(~data_sq_fifo_din_update[CHANNEL_NUM_WIDTH]))begin
               data_sq_fifo_wr_ena <=  1'b1; 
            end 
            else if((fsm_cs == ST_UPDATE)& result_valid)begin 
               data_sq_fifo_wr_ena <=  1'b1;
            end 
            else begin 
               data_sq_fifo_wr_ena <=  1'b0; 
            end 
       end 
   end
   
   always @ (posedge clk)begin 
       if(!rst_n)begin 
            data_sq_fifo_din <=  6'h3F; 
       end 
       else begin 
            if (fsm_cs == ST_INIT)begin
               data_sq_fifo_din <=  data_sq_fifo_din_update; 
            end 
            else if((fsm_cs == ST_UPDATE)& result_valid)begin 
               data_sq_fifo_din <=  data_sq_tmp;
            end 
            else begin 
               data_sq_fifo_din <=  data_sq_fifo_din; 
            end 
       end 
   end
   always @ (posedge clk)begin 
       if(!rst_n)begin 
            data_sq_fifo_din_update <=  'b0; 
       end 
       else begin 
            if (fsm_cs == ST_INIT)begin
               data_sq_fifo_din_update <=  data_sq_fifo_din_update + 1'b1; 
            end 
            else begin 
               data_sq_fifo_din_update <=  data_sq_fifo_din_update; 
            end 
       end 
   end
    always @ (posedge clk)begin 
       if(!rst_n)begin 
            delay_cnt <=  'b0; 
       end 
       else if(delay_cnt < 'd8 )begin 
            delay_cnt <= delay_cnt + 1'b1;
       end 
   end
   
   
/****************************************************/   
//state machine 
/****************************************************/
   always @ (posedge clk)begin 
       if(!rst_n)begin 
           fsm_cs <=  ST_IDLE; 
       end 
       else begin 
           fsm_cs <= fsm_ns;
       end 
   end 

    always @ (*)begin 
   
        fsm_ns  = fsm_cs;
       
        case(fsm_cs)
      
            ST_IDLE :
                begin 
                    if (rst_n &(delay_cnt >= 8'd8))begin 
                        fsm_ns  =  ST_INIT;
                    end 
                    else begin 
                        fsm_ns  =  ST_IDLE;
                    end                
                end
            ST_INIT :
                begin 
                    if(data_sq_fifo_din_update[CHANNEL_NUM_WIDTH])begin 
                        fsm_ns  =  ST_UPDATE;
                    end
                    else begin 
                        fsm_ns  =  ST_INIT;
                    end                
                end             
            ST_UPDATE :
                begin 
                    fsm_ns  =  ST_UPDATE;
                end            
            default : fsm_ns  =  ST_IDLE;
   endcase 
 end  
	
sync_fifo #(
            .FIFO_MEMORY_TYPE     ("auto"                    ),  //"block" or "distributed"
	        .FIFO_READ_LATENCY    (0                         ),
            .FIFO_WRITE_DEPTH     (CHANNEL_NUM_TOTAL         ),
	        .WRITE_DATA_WIDTH     (CHANNEL_NUM_WIDTH         ),	
	        .READ_MODE            ("fwft"                    )   //or "std"
        )
sha_channel_num_buff_fifo_inst    
       (
            .wr_clk               (clk                                        ),   // input                                             
            .rst                  (~rst_n                                     ),   // input                                             
            .din                  (data_sq_fifo_din[CHANNEL_NUM_WIDTH - 1:0]  ),   // input           [WRITE_DATA_WIDTH-1 : 0]          
            .rd_en                (data_sq_fifo_rd_ena                        ),   // input                                             
            .wr_en                (data_sq_fifo_wr_ena                        ),   // input                                                                   
            .dout                 (data_sq_fifo_dout[CHANNEL_NUM_WIDTH - 1:0] ),   // output  wire    [READ_DATA_WIDTH-1  : 0]          
            .empty                (data_sq_fifo_empty                         ),   // output  wire                                      
            .full                 (                                           ),   // output  wire                                      
            .prog_full            (                                           ),   // output  reg  
            .overflow             (                                           ),   // output  wire 					
            .underflow            (                                           ),   // output  wire 					
            .wr_data_count        (                                           )	   // output  wire    [RD_DATA_COUNT_WIDTH-1  : 0]   
	    ); 	
endmodule     