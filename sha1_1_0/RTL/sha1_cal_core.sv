`timescale 1ps/1ps

module  sha1_cal_core
       #(
           parameter    SHA160_RES_WIDTH  = 160                              ,
           parameter    CHANNEL_NUM_TOTAL = 64                               ,
           parameter    CHANNEL_NUM_WIDTH = $clog2(CHANNEL_NUM_TOTAL)        ,
           parameter    TAG_DATA_WIDTH    = 14                               ,
           parameter    MSG_DATA_WIDTH    = 512                              , 		   
           parameter    MSG_LEN_WIDTH     = 6                                               

       )
      (
        input                                        clk               ,
        input                                        rst_n             ,                                                                 
        input       [MSG_DATA_WIDTH - 1:0]           msg_rd_data       ,
        input                                        msg_wr_ena        ,
        input                                        msg_wr_sop        ,
        input       [MSG_LEN_WIDTH - 1   :0]         msg_wr_len        , 
        input       [TAG_DATA_WIDTH - 1  :0]         msg_wr_tag        ,        
        input       [CHANNEL_NUM_WIDTH-1 :0]         msg_wr_addr_h     ,
        
        output wire                                  msg_rd_ena        ,
        output wire [11:0]                           msg_rd_addr       ,
        output wire [TAG_DATA_WIDTH - 1:0]           result_tag        ,          
        output wire [CHANNEL_NUM_WIDTH-1:0]          result_sq         ,
        output wire [SHA160_RES_WIDTH - 1:0]         result_data       ,
        output wire                                  result_valid

        );
  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------

    // reg  [3:0][31:0]                    sha160_k                 ;  
    wire [31:0]                         data_a                        ;
    wire [31:0]                         data_b                        ;
    wire [31:0]                         data_c                        ;
    wire [31:0]                         data_d                        ;
    wire [31:0]                         data_e                        ;
    wire [79:0][31:0]                   data_a_tmp                    ;
    wire [79:0][31:0]                   data_b_tmp                    ;
    wire [79:0][31:0]                   data_c_tmp                    ;
    wire [79:0][31:0]                   data_d_tmp                    ;
    wire [79:0][31:0]                   data_e_tmp                    ;
    
    wire [CHANNEL_NUM_WIDTH-1:0]        msg_sq                        ;
    wire                                data_valid                    ;
    wire [79:0]                         data_new_valid                ;
    wire [79:0][CHANNEL_NUM_WIDTH-1:0]  msg_sq_new                    ;
    wire [79:0][MSG_DATA_WIDTH - 1:0]   sour_w_new                    ;
    wire [MSG_DATA_WIDTH - 1:0]         sour_w                        ;
//***********************************************************************	
 sha1_cal_ctrl
        #(                  

           .SHA160_RES_WIDTH   (SHA160_RES_WIDTH      ),
           .CHANNEL_NUM_TOTAL  (CHANNEL_NUM_TOTAL     ),
           .TAG_DATA_WIDTH     (TAG_DATA_WIDTH        ),
           .MSG_DATA_WIDTH     (MSG_DATA_WIDTH        ),
           .MSG_LEN_WIDTH      (MSG_LEN_WIDTH         )   
        )
 sha1_cal_ctrl_inst       
        (
            .clk                        (clk                    ),  
            .rst_n                      (rst_n                  ),                
            .msg_rd_data                (msg_rd_data            ),  
            .msg_wr_ena                 (msg_wr_ena             ),  
            .msg_wr_sop                 (msg_wr_sop             ),  
            .msg_wr_len                 (msg_wr_len             ),  
            .msg_wr_tag                 (msg_wr_tag             ),  
            .msg_wr_addr_h              (msg_wr_addr_h          ),  
            .msg_rd_ena                 (msg_rd_ena             ),  
            .msg_rd_addr                (msg_rd_addr            ),  
            .result_tag                 (result_tag             ),  
            .result_sq                  (result_sq              ),  
            .result_data                (result_data            ),  
            .result_valid               (result_valid           ),   
            .data_a                     (data_a                 ),  
            .data_b                     (data_b                 ),  
            .data_c                     (data_c                 ),  
            .data_d                     (data_d                 ),  
            .data_e                     (data_e                 ), 
            .data_new_valid             (data_new_valid[78]     ),            
            .data_a_new                 (data_a_tmp[79]         ),  
            .data_b_new                 (data_b_tmp[79]         ),  
            .data_c_new                 (data_c_tmp[79]         ),  
            .data_d_new                 (data_d_tmp[79]         ),  
            .data_e_new                 (data_e_tmp[79]         ),
            .msg_sq_new                 (msg_sq_new[78]         ),            
            .msg_sq                     (msg_sq                 ),  
            .sour_w                     (sour_w                 ),  
            .data_valid                 (data_valid             )   
        
        );
/************************************************************/  
// the first step 
/************************************************************/   
        sha1_cal_function  #(
               .DATA_WIDTH       (32            ),
               .FUNCTION_SEL     (0             ),
               .CHANNEL_NUM_TOTAL(64            )
       
            )
        sha1_cal_function_inst_0    
            (
                .clk                 (clk                           ),    //input               
                .rst_n               (rst_n                         ),    //input                     
                .data_valid          (data_valid                    ),    //input                    
				// .sour_k              (sha160_k[0]                   ),    //input        [DATA_WIDTH - 1 :0]      
                .sour_w              (sour_w[511:480]               ),    //input        [DATA_WIDTH - 1 :0]       
                .channel_num         (msg_sq                        ),    //input        [CHANNEL_NUM_WIDTH-1:0]                          
                .data_a              (data_a                        ),    //input        [DATA_WIDTH - 1 :0]       
                .data_b              (data_b                        ),    //input        [DATA_WIDTH - 1 :0]       
                .data_c              (data_c                        ),    //input        [DATA_WIDTH - 1 :0]       
                .data_d              (data_d                        ),    //input        [DATA_WIDTH - 1 :0]       
                .data_e              (data_e                        ),    //input        [DATA_WIDTH - 1 :0]       
                .data_a_new          (data_a_tmp[0]                 ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_b_new          (data_b_tmp[0]                 ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_c_new          (data_c_tmp[0]                 ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_d_new          (data_d_tmp[0]                 ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_e_new          (data_e_tmp[0]                 ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_new_valid      (data_new_valid[0]             ),    //output reg          
                .channel_num_new     (msg_sq_new[0]                 )     //output reg   [1:0]     
                );			
        sha1_msg_extend_function #(
		
                .DATA_WIDTH( MSG_DATA_WIDTH        )
				
                ) 
		sha1_msg_extend_function_inst_c
		        (
                .clk                 (clk                     ),   //input                 
                .rst_n               (rst_n                   ),   //input                 
                .sour_w              (sour_w                  ),   //input      [DATA_WIDTH - 1:0]         
                .sour_w_en           (data_valid              ),   //input                 
                .sour_w_new          (sour_w_new[0]           )    //output reg [DATA_WIDTH - 1:0] 
                );			
generate
    genvar a; 
    for(a=1;a < 20;a=a+1) begin 
        sha1_cal_function  #(
               .DATA_WIDTH       (32            ),
               .FUNCTION_SEL     (0             ),
               .CHANNEL_NUM_TOTAL(64            )
       
            )
        sha1_cal_function_inst_a    
            (
                .clk                 (clk                           ),    //input               
                .rst_n               (rst_n                         ),    //input                     
                .data_valid          (data_new_valid[a-1]           ),    //input                    
				// .sour_k              (sha160_k[0]                   ),    //input        [DATA_WIDTH - 1 :0]      
                .sour_w              (sour_w_new[a-1][511:480]      ),    //input        [DATA_WIDTH - 1 :0]       
                .channel_num         (msg_sq_new[a-1]               ),    //input        [CHANNEL_NUM_WIDTH-1:0]                          
                .data_a              (data_a_tmp[a-1]               ),    //input        [DATA_WIDTH - 1 :0]       
                .data_b              (data_b_tmp[a-1]               ),    //input        [DATA_WIDTH - 1 :0]       
                .data_c              (data_c_tmp[a-1]               ),    //input        [DATA_WIDTH - 1 :0]       
                .data_d              (data_d_tmp[a-1]               ),    //input        [DATA_WIDTH - 1 :0]       
                .data_e              (data_e_tmp[a-1]               ),    //input        [DATA_WIDTH - 1 :0]       
                .data_a_new          (data_a_tmp[a]                 ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_b_new          (data_b_tmp[a]                 ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_c_new          (data_c_tmp[a]                 ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_d_new          (data_d_tmp[a]                 ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_e_new          (data_e_tmp[a]                 ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_new_valid      (data_new_valid[a]             ),    //output reg          
                .channel_num_new     (msg_sq_new[a]                 )     //output reg   [1:0]     
                );				
        sha1_msg_extend_function #(
		
                .DATA_WIDTH( MSG_DATA_WIDTH        )
				
                ) 
		sha1_msg_extend_function_inst_c
		        (
                .clk                 (clk                     ),   //input                 
                .rst_n               (rst_n                   ),   //input                 
                .sour_w              (sour_w_new[a-1]         ),   //input      [DATA_WIDTH - 1:0]         
                .sour_w_en           (data_new_valid[a-1]     ),   //input                 
                .sour_w_new          (sour_w_new[a]           )    //output reg [DATA_WIDTH - 1:0] 
                ); 
    end     
endgenerate
generate
    genvar b; 
    for(b=20;b < 40;b=b+1) begin  
        sha1_cal_function  #(
               .DATA_WIDTH       (32            ),
               .FUNCTION_SEL     (1             ),
               .CHANNEL_NUM_TOTAL(64            )
       
            )
        sha1_cal_function_inst_b    
            (
                .clk                 (clk                           ),    //input               
                .rst_n               (rst_n                         ),    //input                     
                .data_valid          (data_new_valid[b-1]           ),    //input                    
				// .sour_k              (sha160_k[1]                   ),    //input        [DATA_WIDTH - 1 :0]      
                .sour_w              (sour_w_new[b-1][511:480]      ),    //input        [DATA_WIDTH - 1 :0]       
                .channel_num         (msg_sq_new[b-1]               ),    //input        [CHANNEL_NUM_WIDTH-1:0]                          
                .data_a              (data_a_tmp[b-1]               ),    //input        [DATA_WIDTH - 1 :0]       
                .data_b              (data_b_tmp[b-1]               ),    //input        [DATA_WIDTH - 1 :0]       
                .data_c              (data_c_tmp[b-1]               ),    //input        [DATA_WIDTH - 1 :0]       
                .data_d              (data_d_tmp[b-1]               ),    //input        [DATA_WIDTH - 1 :0]       
                .data_e              (data_e_tmp[b-1]               ),    //input        [DATA_WIDTH - 1 :0]       
                .data_a_new          (data_a_tmp[b]                 ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_b_new          (data_b_tmp[b]                 ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_c_new          (data_c_tmp[b]                 ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_d_new          (data_d_tmp[b]                 ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_e_new          (data_e_tmp[b]                 ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_new_valid      (data_new_valid[b]             ),    //output reg          
                .channel_num_new     (msg_sq_new[b]                 )     //output reg   [1:0]     
                );				
        sha1_msg_extend_function #(
		
                .DATA_WIDTH( MSG_DATA_WIDTH        )
				
                ) 
		sha1_msg_extend_function_inst_c
		        (
                .clk                 (clk                     ),   //input                 
                .rst_n               (rst_n                   ),   //input                 
                .sour_w              (sour_w_new[b-1]         ),   //input      [DATA_WIDTH - 1:0]         
                .sour_w_en           (data_new_valid[b-1]     ),   //input                 
                .sour_w_new          (sour_w_new[b]           )    //output reg [DATA_WIDTH - 1:0] 
                );         
    end     
endgenerate
generate
    genvar c; 
    for(c=40;c < 60;c=c+1) begin  
        sha1_cal_function  #(
               .DATA_WIDTH       (32            ),
               .FUNCTION_SEL     (2             ),
               .CHANNEL_NUM_TOTAL(64            )
       
            )
        sha1_cal_function_inst_c    
            (
                .clk                 (clk                           ),    //input               
                .rst_n               (rst_n                         ),    //input                     
                .data_valid          (data_new_valid[c-1]           ),    //input                    
				// .sour_k              (sha160_k[2]                   ),    //input        [DATA_WIDTH - 1 :0]      
                .sour_w              (sour_w_new[c-1][511:480]      ),    //input        [DATA_WIDTH - 1 :0]       
                .channel_num         (msg_sq_new[c-1]               ),    //input        [CHANNEL_NUM_WIDTH-1:0]                          
                .data_a              (data_a_tmp[c-1]               ),    //input        [DATA_WIDTH - 1 :0]       
                .data_b              (data_b_tmp[c-1]               ),    //input        [DATA_WIDTH - 1 :0]       
                .data_c              (data_c_tmp[c-1]               ),    //input        [DATA_WIDTH - 1 :0]       
                .data_d              (data_d_tmp[c-1]               ),    //input        [DATA_WIDTH - 1 :0]       
                .data_e              (data_e_tmp[c-1]               ),    //input        [DATA_WIDTH - 1 :0]       
                .data_a_new          (data_a_tmp[c]                 ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_b_new          (data_b_tmp[c]                 ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_c_new          (data_c_tmp[c]                 ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_d_new          (data_d_tmp[c]                 ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_e_new          (data_e_tmp[c]                 ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_new_valid      (data_new_valid[c]             ),    //output reg          
                .channel_num_new     (msg_sq_new[c]                 )     //output reg   [1:0]     
                );				
        sha1_msg_extend_function #(
		
                .DATA_WIDTH( MSG_DATA_WIDTH        )
				
                ) 
		sha1_msg_extend_function_inst_c
		        (
                .clk                 (clk                     ),   //input                 
                .rst_n               (rst_n                   ),   //input                 
                .sour_w              (sour_w_new[c-1]         ),   //input      [DATA_WIDTH - 1:0]         
                .sour_w_en           (data_new_valid[c-1]     ),   //input                 
                .sour_w_new          (sour_w_new[c]           )    //output reg [DATA_WIDTH - 1:0] 
                );  	        
    end 
endgenerate
generate   
    genvar d; 
    for(d=60;d < 79;d=d+1) begin  
        sha1_cal_function  #(
               .DATA_WIDTH       (32            ),
               .FUNCTION_SEL     (3             ),
               .CHANNEL_NUM_TOTAL(64            )
       
            )
        sha1_cal_function_inst_d    
            (
                .clk                 (clk                           ),    //input               
                .rst_n               (rst_n                         ),    //input                     
                .data_valid          (data_new_valid[d-1]           ),    //input                    
				// .sour_k              (sha160_k[3]                   ),    //input        [DATA_WIDTH - 1 :0]      
                .sour_w              (sour_w_new[d-1][511:480]      ),    //input        [DATA_WIDTH - 1 :0]       
                .channel_num         (msg_sq_new[d-1]               ),    //input        [CHANNEL_NUM_WIDTH-1:0]                          
                .data_a              (data_a_tmp[d-1]               ),    //input        [DATA_WIDTH - 1 :0]       
                .data_b              (data_b_tmp[d-1]               ),    //input        [DATA_WIDTH - 1 :0]       
                .data_c              (data_c_tmp[d-1]               ),    //input        [DATA_WIDTH - 1 :0]       
                .data_d              (data_d_tmp[d-1]               ),    //input        [DATA_WIDTH - 1 :0]       
                .data_e              (data_e_tmp[d-1]               ),    //input        [DATA_WIDTH - 1 :0]       
                .data_a_new          (data_a_tmp[d]                 ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_b_new          (data_b_tmp[d]                 ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_c_new          (data_c_tmp[d]                 ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_d_new          (data_d_tmp[d]                 ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_e_new          (data_e_tmp[d]                 ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_new_valid      (data_new_valid[d]             ),    //output reg          
                .channel_num_new     (msg_sq_new[d]                 )     //output reg    [1:0]     
                );   
        sha1_msg_extend_function #(
		
                .DATA_WIDTH( MSG_DATA_WIDTH        )
				
                ) 
		sha1_msg_extend_function_inst
		        (
                .clk                 (clk                     ),   //input                 
                .rst_n               (rst_n                   ),   //input                 
                .sour_w              (sour_w_new[d-1]         ),   //input      [DATA_WIDTH - 1:0]         
                .sour_w_en           (data_new_valid[d-1]     ),   //input                 
                .sour_w_new          (sour_w_new[d]           )    //output reg [DATA_WIDTH - 1:0] 
                );  				
    end 
endgenerate		
        sha1_cal_function  #(
               .DATA_WIDTH       (32            ),
               .FUNCTION_SEL     (3             ),
               .CHANNEL_NUM_TOTAL(64            )
       
            )
        sha1_cal_function_inst_79    
            (
                .clk                 (clk                          ),    //input               
                .rst_n               (rst_n                        ),    //input                     
                .data_valid          (data_new_valid[78]           ),    //input                    
				// .sour_k              (sha160_k[3]                  ),    //input        [DATA_WIDTH - 1 :0]      
                .sour_w              (sour_w_new[78][511:480]      ),    //input        [DATA_WIDTH - 1 :0]       
                .channel_num         (msg_sq_new[78]               ),    //input        [CHANNEL_NUM_WIDTH-1:0]                          
                .data_a              (data_a_tmp[78]               ),    //input        [DATA_WIDTH - 1 :0]       
                .data_b              (data_b_tmp[78]               ),    //input        [DATA_WIDTH - 1 :0]       
                .data_c              (data_c_tmp[78]               ),    //input        [DATA_WIDTH - 1 :0]       
                .data_d              (data_d_tmp[78]               ),    //input        [DATA_WIDTH - 1 :0]       
                .data_e              (data_e_tmp[78]               ),    //input        [DATA_WIDTH - 1 :0]       
                .data_a_new          (data_a_tmp[79]               ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_b_new          (data_b_tmp[79]               ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_c_new          (data_c_tmp[79]               ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_d_new          (data_d_tmp[79]               ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_e_new          (data_e_tmp[79]               ),    //output reg   [DATA_WIDTH - 1 :0]  
                .data_new_valid      (data_new_valid[79]           ),    //output reg          
                .channel_num_new     (msg_sq_new[79]               )     //output reg    [1:0]     
                );
        sha1_msg_extend_function #(
		
                .DATA_WIDTH( MSG_DATA_WIDTH        )
				
                ) 
		sha1_msg_extend_function_inst
		        (
                .clk                 (clk                     ),   //input                 
                .rst_n               (rst_n                   ),   //input                 
                .sour_w              (sour_w_new[78]          ),   //input      [DATA_WIDTH - 1:0]         
                .sour_w_en           (data_new_valid[78]      ),   //input                 
                .sour_w_new          (sour_w_new[79]          )    //output reg [DATA_WIDTH - 1:0] 
                );  				
   				
				
        
endmodule 