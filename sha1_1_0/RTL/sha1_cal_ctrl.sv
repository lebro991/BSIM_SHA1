`timescale 1ps/1ps

module  sha1_cal_ctrl
        #(
           parameter    SHA160_H0                   = 32'h67452301                                          ,
           parameter    SHA160_H1                   = 32'hEFCDAB89                                          ,
           parameter    SHA160_H2                   = 32'h98BADCFE                                          ,
           parameter    SHA160_H3                   = 32'h10325476                                          ,
           parameter    SHA160_H4                   = 32'hC3D2E1F0                                          ,
           parameter    SHA160_RES_WIDTH            = 160                                                   ,
           parameter    CHANNEL_NUM_TOTAL           = 64                                                    ,
           parameter    CHANNEL_NUM_WIDTH           = $clog2(CHANNEL_NUM_TOTAL)                             ,
           parameter    TAG_DATA_WIDTH              = 14                                                    , 
           parameter    MSG_DATA_WIDTH              = 512                                                   , 
           parameter    MSG_LEN_WIDTH               = 6                                                     ,            
           parameter    MSG_INFO_WIDTH              = TAG_DATA_WIDTH + MSG_LEN_WIDTH                        ,
           parameter    BUF_FIFO_WRITE_DATA_WIDTH   = CHANNEL_NUM_WIDTH + MSG_LEN_WIDTH + SHA160_RES_WIDTH 
		   
        )
        (
        input                                        clk                        ,
        input                                        rst_n                      ,
                                                                                
        input        [MSG_DATA_WIDTH - 1:0]          msg_rd_data                ,
        input                                        msg_wr_ena                 ,
        input                                        msg_wr_sop                 ,
        input        [MSG_LEN_WIDTH - 1:0]           msg_wr_len                 , 
        input        [TAG_DATA_WIDTH - 1:0]          msg_wr_tag                 ,        
        input        [CHANNEL_NUM_WIDTH-1:0]         msg_wr_addr_h              ,
        output  reg                                  msg_rd_ena                 ,
        output  wire [11:0]                          msg_rd_addr                ,
        output  reg  [TAG_DATA_WIDTH - 1:0]          result_tag                 ,          
        output  reg  [CHANNEL_NUM_WIDTH-1:0]         result_sq                  ,
        output  reg  [SHA160_RES_WIDTH - 1:0]        result_data                ,
        output  reg                                  result_valid               ,         
        output  reg  [31:0]                          data_a                     ,
        output  reg  [31:0]                          data_b                     ,
        output  reg  [31:0]                          data_c                     ,
        output  reg  [31:0]                          data_d                     ,
        output  reg  [31:0]                          data_e                     ,
        input                                        data_new_valid             ,        
        input        [31:0]                          data_a_new                 ,
        input        [31:0]                          data_b_new                 ,
        input        [31:0]                          data_c_new                 ,
        input        [31:0]                          data_d_new                 ,
        input        [31:0]                          data_e_new                 ,        
        input        [CHANNEL_NUM_WIDTH-1:0]         msg_sq_new                 ,
        
        output  reg  [CHANNEL_NUM_WIDTH-1:0]         msg_sq                     ,
        output  reg  [MSG_DATA_WIDTH - 1:0]          sour_w                     ,
        output  reg                                  data_valid                         
        
        );
  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
                    reg     [CHANNEL_NUM_WIDTH-1:0]                                         msg_wr_addr_h_0d          ;
                    reg     [CHANNEL_NUM_WIDTH-1:0]                                         msg_wr_addr_h_1d          ;
                    reg                                                                     msg_rd_ena_0d             ;
                    reg                                                                     msg_rd_ena_1d             ;
                    reg                                                                     msg_rd_ena_2d             ; 
(*keep = "ture"*)   reg                                                                     msg_rd_ena_2d_tmp         ;   
                                                                                                                      
                    reg     [CHANNEL_NUM_WIDTH-1:0]                                         data_sq                   ;
                    reg     [CHANNEL_NUM_WIDTH-1:0]                                         data_sq_0d                ;
                    reg     [CHANNEL_NUM_WIDTH-1:0]                                         data_sq_1d                ;    
                    reg     [CHANNEL_NUM_WIDTH-1:0]                                         data_sq_cal_tmp0          ;
                    reg     [MSG_LEN_WIDTH - 1:0]                                           msg_addr_low              ;   
                                                                                            
                    reg     [MSG_LEN_WIDTH - 1:0]                                           len_cnt                   ;
                    reg     [0:CHANNEL_NUM_TOTAL -1][MSG_INFO_WIDTH - 1 : 0]                data_sq_info_buff         ;
                    reg     [0:CHANNEL_NUM_TOTAL -1][MSG_LEN_WIDTH - 1:0]                   len_cnt_buff              ; 
                    reg     [0:CHANNEL_NUM_TOTAL -1]                                        msg_cal_end               ;   
                    reg     [SHA160_RES_WIDTH - 1:0]                                        result_msg_tmp            ;
                    reg                                                                     sour_w_valid_tmp79_0d     ;
	                reg                                                                     sour_w_valid_tmp79_1d     ;
	                reg                                                                     sour_w_valid_tmp79_2d     ;	
                                                                                                       
                    reg     [CHANNEL_NUM_WIDTH-1:0]                                         data_sq_tmp79_0d          ;     
                    reg     [CHANNEL_NUM_WIDTH-1:0]                                         data_sq_tmp79_1d          ;
                    reg     [CHANNEL_NUM_WIDTH-1:0]                                         data_sq_tmp79_2d          ;
                    reg                                                                     data_sq_fifo_wr_ena       ;
                    reg     [CHANNEL_NUM_WIDTH + MSG_LEN_WIDTH + SHA160_RES_WIDTH -1 :0]    data_sq_fifo_din          ;  
                    wire                                                                    data_sq_fifo_empty        ; 
                    reg                                                                     data_sq_fifo_rd_ena       ;
	                wire                                                                    data_sq_fifo_rd_ena_lock  ;
                    reg                                                                     data_sq_fifo_rd_ena_0d    ;
                    reg                                                                     data_sq_fifo_rd_ena_1d    ;
                    reg                                                                     data_sq_fifo_rd_ena_2d    ;
                    wire    [CHANNEL_NUM_WIDTH + MSG_LEN_WIDTH + SHA160_RES_WIDTH -1 :0]    data_sq_fifo_dout         ; 
					
                    reg     [TAG_DATA_WIDTH - 1:0]                                          msg_wr_tag_tmp            ;
                    reg     [TAG_DATA_WIDTH - 1:0]                                          msg_wr_tag_tmp_0d         ;                              
                    reg     [SHA160_RES_WIDTH - 1:0]                                        sha160_h_next             ;
                    reg     [SHA160_RES_WIDTH - 1:0]                                        sha160_h_next_0d          ;
                    reg     [SHA160_RES_WIDTH - 1:0]                                        sha160_h_next_1d          ;    
	                reg     [0:CHANNEL_NUM_TOTAL -1][SHA160_RES_WIDTH - 1:0]                data_h_buff               ;   
                                                                                            
                    reg                                                                     data_h_ram_wr_ena         ;
                    reg     [5:0]                                                           data_h_ram_wr_addr        ;
                    reg     [SHA160_RES_WIDTH - 1:0]                                        data_h_ram_wr_data        ;
                    wire    [5:0]                                                           data_h_ram_rd_addr        ;
                    wire    [SHA160_RES_WIDTH - 1:0]                                        data_h_ram_rd_data        ;   
                                                                                            

/****************************************************************/                       
    always @ (posedge clk)begin 
        if(!rst_n)begin 
            msg_wr_addr_h_0d <=  'b0;
            msg_wr_addr_h_1d <=  'b0;
        end 
        else begin 
            msg_wr_addr_h_0d <=  msg_wr_addr_h   ;
            msg_wr_addr_h_1d <=  msg_wr_addr_h_0d;
        end 
    
    end        
/****************************************************************/
//buff the length of the packets
/****************************************************************/ 
    always @ (posedge clk) 
     begin: name
        integer  i;
        if(!rst_n)begin 
            for (i = 0 ; i < CHANNEL_NUM_TOTAL ; i = i + 1)begin 
                data_sq_info_buff[i] <=  14'b0;
            end 
        end 
        else begin 
            if(msg_wr_ena& msg_wr_sop)begin 
                data_sq_info_buff[msg_wr_addr_h] <=  {msg_wr_tag,msg_wr_len};
            end 
            // else begin 
                // data_msg_len <=  data_msg_len;
            // end 
        end 
    end 
/****************************************************************/
//make the fifo rd ena
/****************************************************************/ 
    always @ (posedge clk)begin 
        if(!rst_n)begin 
            data_sq_fifo_rd_ena <=  1'b0;
        end 
        else begin
            if(msg_wr_ena& msg_wr_sop)begin 
                data_sq_fifo_rd_ena <=   1'b0;
            end 
            else if(~data_sq_fifo_empty)begin 
                data_sq_fifo_rd_ena <=   1'b1;
            end            
            else begin 
                data_sq_fifo_rd_ena <=   1'b0;
            end             
        end 
    end
assign  data_sq_fifo_rd_ena_lock =  data_sq_fifo_rd_ena &(~data_sq_fifo_empty);
/************************************************************/
//make the rd en of the ram
/************************************************************/
    always @ (posedge clk)begin 
        if(!rst_n)begin 
            msg_rd_ena <=   1'b0;
        end 
        else begin
            if(msg_wr_ena& msg_wr_sop)begin  
                msg_rd_ena <=    1'b1;
            end
            // else if(~data_sq_fifo_empty)begin 
                // msg_rd_ena <=    1'b1;
            // end            
            else begin 
                msg_rd_ena <=    1'b0;
            end             
        end 
    end 
    
    
    always @ (posedge clk)begin 
        if(!rst_n)begin 
            data_sq_fifo_rd_ena_0d <=    1'b0;
            data_sq_fifo_rd_ena_1d <=    1'b0;
            data_sq_fifo_rd_ena_2d <=    1'b0;
        end 
        else begin
            data_sq_fifo_rd_ena_0d <=    data_sq_fifo_rd_ena_lock ; 
            data_sq_fifo_rd_ena_1d <=    data_sq_fifo_rd_ena_0d ;
            data_sq_fifo_rd_ena_2d <=    data_sq_fifo_rd_ena_1d ;
        end 
    end
    always @ (posedge clk)begin 
        if(!rst_n)begin 
            sha160_h_next    <=  'd0 ;
            sha160_h_next_0d <=  'd0 ;
            sha160_h_next_1d <=  'd0 ;
        end 
        else begin
            // if (data_sq_fifo_rd_ena)begin 
            sha160_h_next    <=  data_sq_fifo_dout[SHA160_RES_WIDTH - 1:0] ; 
            sha160_h_next_0d <=  sha160_h_next ;
            sha160_h_next_1d <=  sha160_h_next_0d ;
            // end 
            // else begin 
            
            // end 
        end 
    end    
    always @ (posedge clk)begin 
        if(!rst_n)begin 
            msg_rd_ena_0d <=  1'b0;
            msg_rd_ena_1d <=  1'b0;
            msg_rd_ena_2d <=  1'b0;
            msg_rd_ena_2d_tmp <=  1'b0;
        end 
        else begin
            msg_rd_ena_0d <=  (data_sq_fifo_rd_ena_lock)|| (msg_rd_ena); 
            msg_rd_ena_1d <=  msg_rd_ena_0d ;
            msg_rd_ena_2d <=  msg_rd_ena_1d ;
            msg_rd_ena_2d_tmp<=  msg_rd_ena_1d;
        end 
    end
    
    assign   msg_rd_addr = {data_sq,msg_addr_low};

    always @ (posedge clk)begin 
        if(!rst_n)begin 
            data_sq <=  'b0;
            msg_addr_low <=  'b0;
        end 
        else begin
 	        if(data_sq_fifo_rd_ena_lock)begin 
                data_sq <=  data_sq_fifo_dout[171:166];
                msg_addr_low <=  data_sq_fifo_dout[165:160];               
            end
            else if(msg_rd_ena)begin 
                data_sq <=  data_sq_cal_tmp0;
                msg_addr_low    <=   'b0 ;
            end 
            else begin 
                data_sq <=  data_sq;
                msg_addr_low    <=  msg_addr_low ;
            end             
        end 
    end 
    always @ (posedge clk)begin 
        if(!rst_n)begin 
            data_sq_cal_tmp0 <=  'b0;
        end 
        else begin
            if(msg_wr_ena& msg_wr_sop)begin  
                data_sq_cal_tmp0 <=  msg_wr_addr_h;
            end
            else begin 
                data_sq_cal_tmp0 <=  data_sq_cal_tmp0;
                 
            end             
        end 
    end   
    always @ (posedge clk)begin 
        if(!rst_n)begin 
            data_sq_0d <=  'b0;
            data_sq_1d <=  'b0;
        end 
        else begin 
            data_sq_0d <=  data_sq;
            data_sq_1d <=  data_sq_0d;             
        end 
    end 
/****************************************************************/
//initil  bunff  1
/****************************************************************/

    always @ (posedge clk)begin 
        if(!rst_n)begin 
         data_a <=  32'b0;
			data_b <=  32'b0;
			data_c <=  32'b0;
			data_d <=  32'b0;
			data_e <=  32'b0;
        end 
        else begin
                    
            if (data_sq_fifo_rd_ena_2d)begin 
                data_a <=  sha160_h_next_1d[SHA160_RES_WIDTH - 1:128];
                data_b <=  sha160_h_next_1d[127:96];
                data_c <=  sha160_h_next_1d[95:64];
                data_d <=  sha160_h_next_1d[63:32];
                data_e <=  sha160_h_next_1d[31:0];
                
            end 
            else if(msg_rd_ena_2d_tmp)begin 
             data_a <=  SHA160_H0;
			    data_b <=  SHA160_H1;
			    data_c <=  SHA160_H2;
			    data_d <=  SHA160_H3;
			    data_e <=  SHA160_H4;
            end 
            else begin 
                data_a <=  data_a;
			    data_b <=  data_b;
			    data_c <=  data_c;
			    data_d <=  data_d;
			    data_e <=  data_e;
            end 
        end 
    end  
/****************************************************************/
//buff the h
/****************************************************************/ 
    // integer  j;
    // always @ (posedge clk)begin 
        // if(!rst_n)begin 
			// for(j = 0;j < CHANNEL_NUM_TOTAL ;j = j + 1) begin
                // data_h_buff[j] <=  160'b0;
            // end 
        // end 
        // else begin        
            // if (data_sq_fifo_rd_ena_2d)begin 
                // data_h_buff[data_sq_1d] <=  sha160_h_next_1d;
            // end 
            // else if(msg_rd_ena_2d)begin 
                // data_h_buff[data_sq_1d] <=  {SHA160_H0,SHA160_H1,SHA160_H2,SHA160_H3,SHA160_H4};

            // end 
        // end
    // end
    always @ (posedge clk)begin 
        if(!rst_n)begin 
           data_h_ram_wr_ena  <= 1'b0; 
        end 
        else begin
            data_h_ram_wr_ena  <= data_sq_fifo_rd_ena_2d|msg_rd_ena_2d;         
        end
    end   
    always @ (posedge clk)begin 
        if(!rst_n)begin 
           data_h_ram_wr_addr  <= 'b0; 
        end 
        else begin
            data_h_ram_wr_addr  <= data_sq_1d;         
        end
    end  
    always @ (posedge clk)begin 
        if(!rst_n)begin 
           data_h_ram_wr_data  <= 'b0; 
        end 
        else begin
            if (data_sq_fifo_rd_ena_2d)begin 
                data_h_ram_wr_data <=  sha160_h_next_1d;
            end 
            else if(msg_rd_ena_2d_tmp)begin 
                data_h_ram_wr_data <=  {SHA160_H0,SHA160_H1,SHA160_H2,SHA160_H3,SHA160_H4};

            end        
        end
    end      
/****************************************************************/
//cal  function   0
/****************************************************************/ 
    always @ (posedge clk)begin 
        if(!rst_n)begin 
            msg_sq <=  'b0;
        end 
        else begin 
            if(msg_rd_ena_2d)begin 
                msg_sq <=  data_sq_1d;
            end 
            else begin 
                msg_sq <=  msg_sq ;
            end 
        end 
    end   
    always @ (posedge clk)begin 
        if(!rst_n)begin 
            sour_w <=  512'b0;
        end 
        else begin 
            if(msg_rd_ena_2d_tmp)begin 
                sour_w <=  msg_rd_data;
            end 
            else begin 
                sour_w <=  sour_w;
            end 
        end 
    end
    
    always @ (posedge clk)begin 
        if(!rst_n)begin 
            data_valid <=  1'b0;
        end 
        else begin
                    
            if(msg_rd_ena_2d)begin 
                data_valid <=  1'b1;
            end 
            else begin 
                data_valid <=  1'b0;
            end 
        end 
    end
///////num 79    
/************************************************************/
//计算当前数据包计算的个数?
/************************************************************/ 
    always @ (posedge clk)begin 
        if(!rst_n)begin 
            len_cnt <=  6'b0;
        end 
        else begin
            if(data_new_valid)begin 
                len_cnt <=  len_cnt_buff[msg_sq_new]  + 1'b1;
            end 
            else begin
                len_cnt <=   len_cnt;
            end     
        end 
    end 
	
    // always @ (posedge clk)begin 
        // if(!rst_n)begin 
            // data_msg_len_real_f0 <=  6'b0;
        // end 
        // else begin
            // data_msg_len_real_f0 <=   len_cnt;    
        // end 
    // end     
    
    always @ (posedge clk)begin : cal_msg_len_buff_m
        integer k;
        if(!rst_n)begin 
            for(k = 0;k < CHANNEL_NUM_TOTAL;k = k + 1) begin
                len_cnt_buff[k] <=  'b0;
            end 
        end 
        else begin
            if(sour_w_valid_tmp79_0d)begin
                if(len_cnt[5:0] == data_sq_info_buff[data_sq_tmp79_0d][5:0])begin 
                    len_cnt_buff[data_sq_tmp79_0d] <=  6'b0;
                end 
                else begin 
                    len_cnt_buff[data_sq_tmp79_0d] <=  len_cnt;
                end 
            end 
            // else begin
                // len_cnt <=   len_cnt;
            // end     
        end 
    end
    always @ (posedge clk)begin:msg_cal_end_m
       integer l; 
        if(!rst_n)begin  
            for(l = 0; l < CHANNEL_NUM_TOTAL; l = l + 1) begin
                msg_cal_end[l] <=  1'b0;
            end             
        end 
        else begin
            if(sour_w_valid_tmp79_0d&(len_cnt[5:0] == data_sq_info_buff[data_sq_tmp79_0d][5:0]))begin 
                msg_cal_end[data_sq_tmp79_0d] <=  1'b1;
            end 
            else if(sour_w_valid_tmp79_0d)begin
                msg_cal_end[data_sq_tmp79_0d] <=  1'b0; 
            end     
        end 
    end 
    
/************************************************************/
//延时信号，第79轮运箿
/************************************************************/   
    always @ (posedge clk)begin
        if(!rst_n)begin  
            msg_wr_tag_tmp <=  'b0;            
        end 
        else begin
            if(sour_w_valid_tmp79_0d)begin 
               msg_wr_tag_tmp <=  data_sq_info_buff[data_sq_tmp79_0d][19:6]; 
            end     
        end 
    end
     
    always @ (posedge clk)begin 
        if(!rst_n)begin 
            data_sq_tmp79_0d <=  2'b0; 
            data_sq_tmp79_1d <=  2'b0;
			data_sq_tmp79_2d <=  2'b0;
        end 
        else begin
            data_sq_tmp79_0d <=  msg_sq_new; 
            data_sq_tmp79_1d <=  data_sq_tmp79_0d;
            data_sq_tmp79_2d <=  data_sq_tmp79_1d;               			
        end 
    end 
    always @ (posedge clk)begin 
        if(!rst_n)begin 
            sour_w_valid_tmp79_0d <=  1'b0; 
            sour_w_valid_tmp79_1d <=  1'b0; 
			sour_w_valid_tmp79_2d <=  1'b0;
        end 
        else begin
            sour_w_valid_tmp79_0d <=  data_new_valid;
            sour_w_valid_tmp79_1d <=  sour_w_valid_tmp79_0d;
            sour_w_valid_tmp79_2d <=  sour_w_valid_tmp79_1d;			
        end 
    end 
/************************************************************/
//产生缓存中间计算结果数据的信叿
/************************************************************/
    always @ (posedge clk)begin 
        if(!rst_n)begin 
            data_sq_fifo_wr_ena <=  1'b0;
        end 
        else begin
            if((sour_w_valid_tmp79_2d)&(~msg_cal_end[data_sq_tmp79_2d]))begin 
                data_sq_fifo_wr_ena <=  1'b1;
            end 
            else begin
                data_sq_fifo_wr_ena <=  1'b0;
            end     
        end 
    end 
    always @ (posedge clk)begin 
        if(!rst_n)begin 
            data_sq_fifo_din <=  'd0 ;    
        end 
        else begin
		    //6 + 6 +160 
            data_sq_fifo_din <=  {data_sq_tmp79_2d,len_cnt_buff[data_sq_tmp79_2d],result_msg_tmp};                                                                                                                                                                                  
        end 
    end 

assign   data_h_ram_rd_addr  =  msg_sq_new;
    
    always @ (posedge clk)begin 
        if(!rst_n)begin 
            result_msg_tmp <=  160'b0;
        end 
        else begin
            if(sour_w_valid_tmp79_1d)begin 
                result_msg_tmp[SHA160_RES_WIDTH - 1:128] <=   data_a_new + data_h_ram_rd_data[SHA160_RES_WIDTH - 1:128];                     
                result_msg_tmp[127:96]                   <=   data_b_new + data_h_ram_rd_data[127:96] ;
                result_msg_tmp[95:64]                    <=   data_c_new + data_h_ram_rd_data[95:64]  ;
                result_msg_tmp[63:32]                    <=   data_d_new + data_h_ram_rd_data[63:32]  ;              
                result_msg_tmp[31:0]                     <=   data_e_new + data_h_ram_rd_data[31:0]   ;                
            end                                                                                               
            else begin                                                                                        
                result_msg_tmp <=  result_msg_tmp;                                                 
            end                                                                                               
        end 
    end     
/************************************************************/
//产生缓存朿终计算结果数据的信号
/************************************************************/
    always @ (posedge clk)begin 
        if(!rst_n)begin 
            result_valid <=  1'b0;
        end 
        else begin
            if((sour_w_valid_tmp79_2d)&(msg_cal_end[data_sq_tmp79_2d]))begin 
                result_valid <=  1'b1;
            end 
            else begin
                result_valid <=  1'b0;
            end     
        end 
    end
    always @ (posedge clk)begin
        if(!rst_n)begin  
            msg_wr_tag_tmp_0d <=  'b0;
            result_tag <=  'b0;           
        end 
        else begin
            msg_wr_tag_tmp_0d <=  msg_wr_tag_tmp ;
            result_tag    <=  msg_wr_tag_tmp_0d ;            
        end 
    end 
    
    always @ (posedge clk)begin 
        if(!rst_n)begin 
            result_sq <=  2'b0;
        end 
        else begin
            if(sour_w_valid_tmp79_2d)begin 
                result_sq <=  data_sq_tmp79_2d;
            end 
            else begin
                result_sq <=  2'b0;
            end     
        end 
    end    
    always @ (posedge clk)begin 
        if(!rst_n)begin 
            result_data <=  160'b0;
        end 
        else begin
		    result_data <=  result_msg_tmp;                                                                                      
        end 
    end 


sync_fifo #(
            .FIFO_MEMORY_TYPE     ("auto"                      ),  //"block" or "distributed"
	        .FIFO_READ_LATENCY    (0                           ),
            .FIFO_WRITE_DEPTH     (CHANNEL_NUM_TOTAL           ),
	        .WRITE_DATA_WIDTH     (BUF_FIFO_WRITE_DATA_WIDTH   ),	
	        .READ_MODE            ("fwft"                      )   //or "std"
        )
sha_channel_num_fifo_inst    
       (
            .wr_clk               (clk                      ),   // input                                             
            .rst                  (~rst_n                   ),   // input                                             
            .din                  (data_sq_fifo_din         ),   // input           [WRITE_DATA_WIDTH-1 : 0]          
            .rd_en                (data_sq_fifo_rd_ena_lock ),   // input                                             
            .wr_en                (data_sq_fifo_wr_ena      ),   // input                                                                   
            .dout                 (data_sq_fifo_dout        ),   // output  wire    [READ_DATA_WIDTH-1  : 0]          
            .empty                (data_sq_fifo_empty       ),   // output  wire                                      
            .full                 (                         ),   // output  wire                                      
            .prog_full            (                         ),   // output  reg  
            .overflow             (                         ),   // output  wire 					
            .underflow            (                         ),   // output  wire 					
            .wr_data_count        (                         )	 // output  wire    [RD_DATA_COUNT_WIDTH-1  : 0]   
	    ); 		
	           
xpm_sdpram_common_with_initial  #(
            .RAM_WIDTH        (SHA160_RES_WIDTH         )  , 
            .RAM_DEPTH        (CHANNEL_NUM_TOTAL        )  , 
            .RAM_STYLE        ("distribute"             )  ,  // "block" "distribute"	
			.INIT             (1                        )  , 
			.INIT_VALUE       ({SHA160_RES_WIDTH{1'b0}} )  , 
            .LAYTENCY         (3                        )    			
            
         )
sha1_result_buff_ram_inst
         (
		 .clk                 (clk                       ), //input                           
		 .rst                 (~rst_n                    ), //input                           
		 .dina                (data_h_ram_wr_data        ), //input    [RAM_WIDTH - 1  :0]    
		 .addra               (data_h_ram_wr_addr        ), //input    [ADDR_WIDTH - 1 :0]    
		 .wea                 (data_h_ram_wr_ena         ), //input                           
		 .doutb               (data_h_ram_rd_data        ), //input    [RAM_WIDTH - 1  :0]    
		 .addrb               (data_h_ram_rd_addr        ), //input    [ADDR_WIDTH - 1 :0]     
		 .initial_done        (                          )  //input    [ADDR_WIDTH - 1 :0]     
         );  
       
endmodule     