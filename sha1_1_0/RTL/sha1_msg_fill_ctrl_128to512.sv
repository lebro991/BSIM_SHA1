
module  sha1_msg_fill_ctrl_128to512
       #(  
           parameter    MSG_DATA_WIDTH       = 128                      ,
		   parameter    MSG_INFO_WIDTH       = 16                       ,		   
           parameter    TAG_DATA_WIDTH       = 14                       ,
           parameter    CNT_WIDTH            = 16                       ,
           parameter    CNT_512_WIDTH        =  CNT_WIDTH - 2           ,
           parameter    FILLED_DATA_WIDTH    = 'd512                    ,
           parameter    CHANNEL_NUM_TOTAL    = 64                       ,
		   parameter    CHANNEL_NUM_WIDTH    = $clog2(CHANNEL_NUM_TOTAL)		   

       )
       (                      
        input                                                   sys_clk                 ,
        input                                                   sys_rst                 ,
		
        input                                                   msg_cal_channel_ready   ,
		
        output reg                                              msg_data_rd_en          ,
        input             [MSG_DATA_WIDTH - 1 :0]               msg_data                ,
        output reg                                              msg_info_rd_en          ,
        input             [MSG_INFO_WIDTH - 1 :0]               msg_info                ,
        input                                                   msg_info_fifo_empty     ,
        input             [CHANNEL_NUM_WIDTH - 1 :0]            msg_channel_num_i       ,

        output reg                                              msg_filled_data_valid   ,
        output reg                                              msg_filled_data_sop     ,
        output reg                                              msg_filled_data_eop     ,
        output reg        [FILLED_DATA_WIDTH - 1 :0]            msg_filled_data         ,
        output reg                                              msg_filled_info_valid   ,
        output reg        [MSG_INFO_WIDTH - 1 :0]               msg_filled_info         ,       
        output reg        [TAG_DATA_WIDTH - 1 :0]               msg_filled_tag          ,
        output reg        [11 :0]                               msg_filled_addr         
   
        );
    
    reg  [MSG_INFO_WIDTH - 1 :0]          msg_info_1d                           =  'b0  ;
    reg  [MSG_INFO_WIDTH - 1 :0]          msg_info_2d                           =  'b0  ;
    reg  [MSG_INFO_WIDTH - 1 :0]          msg_info_3d                           =  'b0  ;
    reg  [MSG_INFO_WIDTH - 1 :0]          msg_info_loc                          =  'b0  ;
	
    reg  [63 :0]                          msg_info_bit                          =  'b0  ;
    reg  [CNT_WIDTH  - 1 :0]              msg_info_128_rd_cnt                   =  'b0  ;
    reg  [CNT_WIDTH  - 1 :0]              msg_info_128_rd_num                   =  'b0  ;
    reg  [CNT_WIDTH  - 1 :0]              msg_info_128_rd_num_1                 =  'b0  ;
    reg  [CNT_WIDTH  - 1 :0]              msg_info_128_first_filled_num         =  'b0  ;
    reg  [CNT_WIDTH  - 1 :0]              msg_info_128_first_filled_num_less1   =  'b0  ;
    reg  [CNT_512_WIDTH  - 1 :0]          msg_info_512b_cnt                     =  'b0  ;
    reg  [CNT_512_WIDTH  - 1 :0]          msg_info_512b_num                     =  'b0  ;
    reg  [CNT_512_WIDTH  - 1 :0]          msg_info_512b_num_1d                  =  'b0  ;
    reg  [CNT_512_WIDTH  - 1 :0]          msg_info_512b_num_2d                  =  'b0  ;
	
    reg  [CHANNEL_NUM_WIDTH  - 1 :0]      msg_channel_num                       =  'b0  ;	
    reg  [CHANNEL_NUM_WIDTH  - 1 :0]      msg_channel_num_1d                    =  'b0  ;	
    reg  [CHANNEL_NUM_WIDTH  - 1 :0]      msg_channel_num_2d                    =  'b0  ;	
    reg  [CHANNEL_NUM_WIDTH  - 1 :0]      msg_channel_num_3d                    =  'b0  ;	
    reg  [CHANNEL_NUM_WIDTH  - 1 :0]      msg_channel_num_4d                    =  'b0  ;	
	
    reg  [MSG_DATA_WIDTH  - 1 :0]         msg_data_1d                           =  'b0  ;
    reg  [MSG_DATA_WIDTH  - 1 :0]         msg_data_2d                           =  'b0  ;
	
    reg  [MSG_DATA_WIDTH  - 1 :0]         msg_data_firt_fill_tmp                =  'b0  ;
    reg  [MSG_DATA_WIDTH  - 1 :0]         msg_data_firt_fill                    =  'b0  ;	
    reg  [MSG_DATA_WIDTH  - 1 :0]         data_0                                =  'b0  ;
    reg  [MSG_DATA_WIDTH  - 1 :0]         data_1                                =  'b0  ;
    reg  [MSG_DATA_WIDTH  - 1 :0]         data_2                                =  'b0  ;
    reg  [MSG_DATA_WIDTH  - 1 :0]         data_3                                =  'b0  ;
	
    reg                                   msg_info_128_rd_eop                   =  'b0  ;
    reg                                   msg_info_128_rd_eop_1d                =  'b0  ;
    reg                                   msg_info_128_rd_eop_2d                =  'b0  ;
    reg                                   msg_info_128_rd_eop_3d                =  'b0  ;
    reg                                   msg_info_128_rd_eop_4d                =  'b0  ;
    reg                                   msg_data_rd_en_1d                     =  'b0  ;
	
    reg                                   msg_filled_flag                       =  'b0  ;
	
    reg                                   msg_info_rd_en_1d                     =  'b0  ;
    reg                                   msg_info_rd_en_2d                     =  'b0  ;
    reg                                   msg_info_rd_en_3d                     =  'b0  ;
	                                                                            
    reg                                   msg_filled_data_valid_tmp             =  'b0  ;
    reg                                   msg_filled_data_sop_tmp               =  'b0  ;
    reg                                   msg_filled_data_eop_tmp               =  'b0  ;
    reg  [5:0]                            msg_filled_addr_l                     =  'b0  ;
	
    reg [2:0]          fsm_cs ;
    reg [2:0]          fsm_ns ;
    localparam         IDLE    = 3'd0 ;
    localparam         ST_NUM1 = 3'd1 ;
    localparam         ST_NUM2 = 3'd2 ;
    localparam         ST_NUM3 = 3'd3 ;	


//*******************************************************************************************																		      

        always @ (posedge sys_clk)begin 
            msg_info_1d        <=  msg_info             ;
            msg_info_2d        <=  msg_info_1d          ;
            msg_info_3d        <=  msg_info_2d          ;
        end  
		
        always @ (posedge sys_clk)begin 
		    if(msg_info_rd_en) begin 
			    msg_info_loc <=  msg_info ;
			end 
        end  
        always @ (posedge sys_clk)begin 
		    if(msg_info_rd_en) begin 
			    msg_channel_num_1d <=  msg_channel_num_i ;
			end 
        end  		
        always @ (posedge sys_clk)begin 
		    msg_channel_num_2d <=  msg_channel_num_1d ;
		    msg_channel_num_3d <=  msg_channel_num_2d ;
		    msg_channel_num_4d <=  msg_channel_num_3d ;
		    msg_channel_num    <=  msg_channel_num_4d ; 
        end  
		
        always @ (posedge sys_clk)begin 
		    if(msg_info_rd_en_3d)begin 
		        msg_info_bit    <=  {45'd0,msg_info_3d,3'd0} ; 
			end 
        end 		
        always @ (posedge sys_clk)begin 
            if(sys_rst)begin 
                msg_info_rd_en   <= 1'b0;
            end
            else if(msg_info_rd_en | msg_info_rd_en_1d | msg_info_rd_en_2d)begin 
                msg_info_rd_en   <= 1'b0;
            end 			
            else if( (( msg_info_512b_cnt =='d0 )| ( msg_info_512b_cnt == 'd1))& ( ~ msg_info_fifo_empty) & ( msg_cal_channel_ready) ) begin 
                msg_info_rd_en   <= 1'b1;        
            end 
			else begin 
			    msg_info_rd_en   <= 1'b0;
			end
        end	
        always @ (posedge sys_clk)begin 
            if(sys_rst)begin 
                msg_info_rd_en_1d   <= 1'b0;
                msg_info_rd_en_2d   <= 1'b0;
                msg_info_rd_en_3d   <= 1'b0;
            end 

			else begin 
			    msg_info_rd_en_1d   <=  msg_info_rd_en    ;
			    msg_info_rd_en_2d   <=  msg_info_rd_en_1d ;
			    msg_info_rd_en_3d   <=  msg_info_rd_en_2d ;
			end
        end			
        always @ (posedge sys_clk)begin 
            if(sys_rst)begin 
                msg_data_rd_en   <= 1'b0;
            end 
            else if( msg_info_rd_en | ((msg_info_128_rd_cnt < msg_info_128_rd_num - 1'b1 )& msg_data_rd_en ))begin 
                msg_data_rd_en   <=  1'b1 ;          
            end 
			else begin 
			    msg_data_rd_en   <=  1'b0 ;
			end 
        end	
        always @ (posedge sys_clk)begin 
            if(sys_rst)begin 
                msg_data_rd_en_1d   <= 1'b0;
            end 
			else begin 
			    msg_data_rd_en_1d   <=  msg_data_rd_en ;
			end 
        end			
		
        always @ (posedge sys_clk)begin 
            if(sys_rst)begin 
                msg_info_128_rd_cnt   <= 'b0;
            end
            else if( msg_info_rd_en )begin 
                msg_info_128_rd_cnt   <= 'd0 ;          
            end 			
            else if( msg_data_rd_en )begin 
                msg_info_128_rd_cnt   <= msg_info_128_rd_cnt + 1'b1 ;          
            end 
        end	

        always @ (posedge sys_clk)begin 
            if(sys_rst)begin 
                msg_info_128_rd_num   <= 'b0;
            end 
            else if( msg_info_rd_en )begin 
                msg_info_128_rd_num   <=  msg_info_1d[MSG_INFO_WIDTH - 1:4] +  (| msg_info_1d[3:0]);          
            end 
        end	
		
        always @ (posedge sys_clk)begin 
            if(sys_rst)begin 
                msg_info_128_rd_num_1   <= 'b0;
            end 
            else if( msg_info_rd_en )begin 
                msg_info_128_rd_num_1   <=  msg_info_1d[MSG_INFO_WIDTH - 1:4] ;          
            end 
        end			
		
        always @ (posedge sys_clk)begin 
            if(( msg_info_1d[5:0] > 6'd55 ) & msg_info_rd_en )begin 
                msg_info_512b_num   <=  msg_info_1d[MSG_INFO_WIDTH - 1:6] + 2'd2 ;          
            end 
			else if(msg_info_rd_en)begin 
			    msg_info_512b_num   <=  msg_info_1d[MSG_INFO_WIDTH - 1:6] + 2'd1 ;
			end
        end		
		
        always @ (posedge sys_clk)begin 
            if(sys_rst)begin 
                msg_info_128_first_filled_num   <= 'b0;
            end 
            else if( msg_info_rd_en_3d )begin 
                msg_info_128_first_filled_num   <=  msg_info_3d[MSG_INFO_WIDTH - 1:4]  + |msg_info_3d[3:0];          
            end 
        end
        always @ (posedge sys_clk)begin 
            if(sys_rst)begin 
                msg_filled_flag   <= 1'b0;
            end 
            else if( msg_info_rd_en_3d &(msg_info_3d[5:0] >= 56 ) )begin 
                msg_filled_flag   <=  1'b1;          
            end
            else if(msg_info_rd_en_3d )begin 
                msg_filled_flag   <=  1'b0;  
            end 			
        end			
		
/*         always @ (posedge sys_clk)begin 
            if(sys_rst)begin 
                msg_info_128_first_filled_num_less1   <= 'b0;
            end 
            else if( msg_info_rd_en )begin 
                msg_info_128_first_filled_num_less1   <=  msg_info_1d[MSG_INFO_WIDTH - 1:4]  ;          
            end 
        end	 */		
/*         always @ (posedge sys_clk)begin 
            if(sys_rst)begin 
                msg_info_128_second_filled_num   <= 'b0;
            end 
            else if( msg_info_rd_en )begin 
                msg_info_128_second_filled_num   <=  msg_info_1d[MSG_INFO_WIDTH - 1:4] +  1'b1 ;          
            end 
        end	 */
        always @ (posedge sys_clk)begin 
            if(sys_rst)begin 
                msg_info_128_rd_eop   <= 1'b0;
            end 
            else if( (msg_info_128_rd_cnt == msg_info_128_rd_num_1 )& msg_data_rd_en_1d )begin 
                msg_info_128_rd_eop   <=  1'b1 ;          
            end 
            else  begin 
                msg_info_128_rd_eop   <=  1'b0 ;          
            end 			
        end
        always @ (posedge sys_clk)begin 
            if(sys_rst)begin 
                msg_info_128_rd_eop_1d   <= 1'b0;
                msg_info_128_rd_eop_2d   <= 1'b0;
                msg_info_128_rd_eop_3d   <= 1'b0;
                msg_info_128_rd_eop_4d   <= 1'b0;
            end 
            else  begin 
                msg_info_128_rd_eop_1d   <= msg_info_128_rd_eop    ;          
                msg_info_128_rd_eop_2d   <= msg_info_128_rd_eop_1d ;          
                msg_info_128_rd_eop_3d   <= msg_info_128_rd_eop_2d ;          
                msg_info_128_rd_eop_4d   <= msg_info_128_rd_eop_3d ;          
            end 			
        end		
		always @ (posedge sys_clk)begin 
            msg_data_1d   <=  msg_data      ; 
            msg_data_2d   <=  msg_data_1d   ; 
        end	
		
        always @ (posedge sys_clk)begin 
			case( msg_info_loc[3:0] )
				//big  end 
                4'h0 : msg_data_firt_fill_tmp  <=  128'h80000000_00000000_00000000_00000000                   ; 
                4'h1 : msg_data_firt_fill_tmp  <=  {msg_data[127:120]  ,120'h800000000000000000000000000000 }   ; 
                4'h2 : msg_data_firt_fill_tmp  <=  {msg_data[127:112]  ,112'h8000000000000000000000000000 }     ; 
                4'h3 : msg_data_firt_fill_tmp  <=  {msg_data[127:104]  ,104'h80000000000000000000000000 }       ; 
                4'h4 : msg_data_firt_fill_tmp  <=  {msg_data[127:96 ]  , 96'h800000000000000000000000 }         ; 
                4'h5 : msg_data_firt_fill_tmp  <=  {msg_data[127:88 ]  , 88'h8000000000000000000000 }           ; 
                4'h6 : msg_data_firt_fill_tmp  <=  {msg_data[127:80 ]  , 80'h80000000000000000000 }             ; 
                4'h7 : msg_data_firt_fill_tmp  <=  {msg_data[127:72 ]  , 72'h800000000000000000 }               ; 
                4'h8 : msg_data_firt_fill_tmp  <=  {msg_data[127:64 ]  , 64'h8000000000000000 }                 ; 
                4'h9 : msg_data_firt_fill_tmp  <=  {msg_data[127:56 ]  , 56'h80000000000000 }                   ; 
                4'hA : msg_data_firt_fill_tmp  <=  {msg_data[127:48 ]  , 48'h800000000000 }                     ; 
                4'hB : msg_data_firt_fill_tmp  <=  {msg_data[127:40 ]  , 40'h8000000000 }                       ; 
                4'hC : msg_data_firt_fill_tmp  <=  {msg_data[127:32 ]  , 32'h80000000 }                         ; 
                4'hD : msg_data_firt_fill_tmp  <=  {msg_data[127:24 ]  , 24'h800000 }                           ; 
                4'hE : msg_data_firt_fill_tmp  <=  {msg_data[127:16 ]  , 16'h8000 }                             ; 
                4'hF : msg_data_firt_fill_tmp  <=  {msg_data[127:8 ]   ,  8'h80 }                               ; 				
			endcase		
        end			
        always @ (posedge sys_clk)begin 
            if(msg_info_128_rd_eop)begin 
                msg_data_firt_fill   <=  msg_data_firt_fill_tmp;
            end 
            else  begin 
                msg_data_firt_fill   <=  msg_data_1d  ;          
            end 			
        end	
		
		always @ (posedge sys_clk)begin 
            msg_info_512b_num_1d   <=  msg_info_512b_num  ; 
        end	

        always @ (posedge sys_clk)begin 
            if(sys_rst)begin 
                msg_info_512b_cnt   <= 'b0;
            end 
            else if(msg_info_rd_en_2d )begin 
                msg_info_512b_cnt   <=  msg_info_512b_num_1d ;          
            end 
			else if(fsm_cs == ST_NUM3 )begin 
			    msg_info_512b_cnt   <=  msg_info_512b_cnt  - 1'b1 ;
			end
        end	
		
        always @ (posedge sys_clk)begin 
            if(msg_info_rd_en_3d )begin 
                msg_info_512b_num_2d   <=  msg_info_512b_num_1d ;          
            end 
        end			
		
//*******************************************************************************************/		
/****************************************************/   
//state machine 
/****************************************************/
    always @ (posedge sys_clk)begin 
        if(sys_rst)begin
            fsm_cs  <=  IDLE; 
        end 
        else begin 
            fsm_cs <= fsm_ns;
        end 
    end 

    always @(*)begin 
    
         fsm_ns  = fsm_cs;
    
       case(fsm_cs)
            IDLE :
               begin 
                  if ((|msg_info_512b_cnt))begin 
                     fsm_ns  =  ST_NUM1;
                  end                
               end
            ST_NUM1 :
               begin 
                   fsm_ns  =   ST_NUM2 ;              
               end             
            ST_NUM2 :
               begin 
                   fsm_ns   =  ST_NUM3 ;
               end 
            ST_NUM3 :
               begin 
                   fsm_ns   =    IDLE  ;
               end 		
            default : fsm_ns  =  IDLE;
        endcase 
   end  	
		
     always @ (posedge sys_clk)begin 
	    if((msg_info_128_rd_eop_1d)&(fsm_cs == IDLE ))begin 
		    data_0   <= msg_data_firt_fill  ;
		end 
        else if (msg_filled_flag & (fsm_cs == IDLE )& ( msg_info_512b_cnt ==  'd1 ) )begin
		    data_0   <= 128'd0  ;
		end 
		else if(fsm_cs == IDLE )begin 
		    data_0   <= msg_data_firt_fill  ;
		end
     end   		
     always @ (posedge sys_clk)begin 
	    if((msg_info_128_rd_eop_1d)&(fsm_cs == ST_NUM1 ))begin 
		    data_1   <= msg_data_firt_fill  ;
		end 	 
        // else if (((msg_info_128_first_filled_num[1:0]  <=  2'd1 )| msg_filled_flag) & (fsm_cs == ST_NUM1 )&( msg_info_512b_cnt ==  'd1 ) )begin
        else if ((msg_info_128_rd_eop_2d | msg_filled_flag) & (fsm_cs == ST_NUM1 )&( msg_info_512b_cnt ==  'd1 ) )begin
		
		    data_1   <= 128'd0  ;
		end 
		else if(fsm_cs == ST_NUM1 )begin  
		    data_1   <= msg_data_firt_fill  ;
		end
     end
     always @ (posedge sys_clk)begin 
	    if((msg_info_128_rd_eop_1d)&(fsm_cs == ST_NUM2 ))begin 
		    data_2   <= msg_data_firt_fill  ;
		end 	 
        // else if (((msg_info_128_first_filled_num[1:0]  <=  2'd2 )| msg_filled_flag) & (fsm_cs == ST_NUM2 )&( msg_info_512b_cnt ==  'd1 ) )begin
        else if ((msg_info_128_rd_eop_2d | msg_info_128_rd_eop_3d| msg_filled_flag) & (fsm_cs == ST_NUM2 )&( msg_info_512b_cnt ==  'd1 ) )begin
		    data_2   <= 128'd0  ;
		end 
		else if(fsm_cs == ST_NUM2 )begin   
		    data_2   <= msg_data_firt_fill  ;
		end
     end  	
     always @ (posedge sys_clk)begin 
	    if((msg_info_128_rd_eop_1d)&(fsm_cs == ST_NUM3 ))begin 
		    data_3   <= msg_data_firt_fill  ;
		end 	 
        // else if (((msg_info_128_first_filled_num[1:0]  <=  2'd3 )| msg_filled_flag) & (fsm_cs == ST_NUM3 )&( msg_info_512b_cnt ==  'd1 ) )begin
        else if ((msg_info_128_rd_eop_2d | msg_info_128_rd_eop_3d | msg_info_128_rd_eop_4d| msg_filled_flag) & (fsm_cs == ST_NUM3 )&( msg_info_512b_cnt ==  'd1 ) )begin
		    data_3   <= 128'd0  ;
		end 
		else if(fsm_cs == ST_NUM3 )begin   
		    data_3   <= msg_data_firt_fill  ;
		end
     end  		

    always @ (posedge sys_clk)begin 
       if(sys_rst)begin
           msg_filled_data_eop_tmp  <=  1'b0 ; 
       end 
       else if((fsm_cs == ST_NUM3 )&( msg_info_512b_cnt ==  'd1 ))begin 
           msg_filled_data_eop_tmp  <= 1'b1;
       end 
       else begin 
           msg_filled_data_eop_tmp  <= 1'b0;
       end 	   
   end 	
    always @ (posedge sys_clk)begin 
       if(sys_rst)begin
           msg_filled_data_sop_tmp  <=  1'b0 ; 
       end 
       else if((fsm_cs == ST_NUM3 )&( msg_info_512b_cnt ==  msg_info_512b_num_2d ))begin 
           msg_filled_data_sop_tmp  <= 1'b1;
       end 
       else begin 
           msg_filled_data_sop_tmp  <= 1'b0;
       end 	   
   end    

    always @ (posedge sys_clk)begin 
       if(sys_rst)begin
           msg_filled_data_valid_tmp  <=  1'b0 ; 
       end 
       else if((fsm_cs == ST_NUM3 ))begin 
           msg_filled_data_valid_tmp  <= 1'b1;
       end 
       else begin 
           msg_filled_data_valid_tmp  <= 1'b0;
       end 	   
    end 	
	
	
    always @ (posedge sys_clk)begin 
       if(sys_rst)begin
           msg_filled_data_sop  <=  1'b0 ; 
       end 
       else begin 
           msg_filled_data_sop  <= msg_filled_data_sop_tmp ;
       end 	   
    end 
	
    always @ (posedge sys_clk)begin 
       if(sys_rst)begin
           msg_filled_data_eop  <=  1'b0 ; 
       end 
       else begin 
           msg_filled_data_eop  <= msg_filled_data_eop_tmp ;
       end 	   
    end 	
    always @ (posedge sys_clk)begin 
       if(sys_rst)begin
           msg_filled_data_valid  <=  1'b0 ; 
       end 
       else begin 
           msg_filled_data_valid  <= msg_filled_data_valid_tmp ;
       end 	   
    end 	
	
	
    always @ (posedge sys_clk)begin 
	
        // msg_filled_data <= {data_3 , data_2 , data_1 ,data_0 } ;
		if(msg_filled_data_eop_tmp)begin 
            msg_filled_data <= {data_0 , data_1 , data_2 , data_3[127:64],msg_info_bit } ;
		end 
		else if( msg_filled_data_valid_tmp )begin 
		    msg_filled_data <= {data_0 , data_1 , data_2 , data_3 } ;
		end 
    end 
	
    always @ (posedge sys_clk)begin 
       if(sys_rst)begin
           msg_filled_info_valid  <=  1'b0 ; 
       end 
       else begin 
           msg_filled_info_valid  <= msg_filled_data_sop_tmp ;
       end 	   
    end  
	
    always @ (posedge sys_clk)begin 
       msg_filled_info <=  msg_info_512b_num_2d ;	   
    end  
	
    always @ (posedge sys_clk)begin 
       if(sys_rst)begin
           msg_filled_tag  <=  1'b0 ; 
       end 
       else if(msg_filled_data_sop_tmp ) begin 
           msg_filled_tag  <= msg_filled_tag + 1'b1  ;
       end 	   
    end 

    always @ (posedge sys_clk)begin 
       if(msg_filled_data_sop_tmp ) begin 
           msg_filled_addr_l  <= 'd0   ;
       end 	   	   
       else if(msg_filled_data_valid_tmp ) begin 
           msg_filled_addr_l  <= msg_filled_addr_l + 1'b1  ;
       end 	   
    end  	
assign   msg_filled_addr = {msg_channel_num , msg_filled_addr_l}; 	
//******************************************************************************/																		      
//debug   
    


    
endmodule 