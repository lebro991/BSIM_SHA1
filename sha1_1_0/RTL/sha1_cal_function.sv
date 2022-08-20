(* use_dsp  =  "yes" *)


module  sha1_cal_function
       #(  
           parameter    DATA_WIDTH        = 32     ,
           parameter    FUNCTION_SEL      = 2'b00  ,
           parameter    CHANNEL_NUM_TOTAL = 64     ,
           parameter    CHANNEL_NUM_WIDTH = $clog2(CHANNEL_NUM_TOTAL)

       )
       (                      
        input                                               clk              ,
        input                                               rst_n            ,
        input                                               data_valid       ,
        // input             [DATA_WIDTH - 1 :0]               sour_k           ,
        input             [DATA_WIDTH - 1 :0]               sour_w           ,
        input             [CHANNEL_NUM_WIDTH-1:0]           channel_num      ,
        input             [DATA_WIDTH - 1 :0]               data_a           ,
        input             [DATA_WIDTH - 1 :0]               data_b           ,
        input             [DATA_WIDTH - 1 :0]               data_c           ,
        input             [DATA_WIDTH - 1 :0]               data_d           ,
        input             [DATA_WIDTH - 1 :0]               data_e           ,
        output   reg      [DATA_WIDTH - 1 :0]               data_a_new       ,
        output   reg      [DATA_WIDTH - 1 :0]               data_b_new       ,
        output   reg      [DATA_WIDTH - 1 :0]               data_c_new       ,
        output   reg      [DATA_WIDTH - 1 :0]               data_d_new       ,
        output   reg      [DATA_WIDTH - 1 :0]               data_e_new       ,
        output   reg                                        data_new_valid   ,
        output   reg      [CHANNEL_NUM_WIDTH-1:0]           channel_num_new      

   
        );
                     reg  [DATA_WIDTH - 1 :0]          sour_k            =  'b0       ;                                            
                     reg  [DATA_WIDTH - 1 :0]          data_a_1d         =  'b0       ;
                     reg  [DATA_WIDTH - 1 :0]          data_b_1d         =  'b0       ;
                     reg  [DATA_WIDTH - 1 :0]          data_c_1d         =  'b0       ;
                     reg  [DATA_WIDTH - 1 :0]          data_d_1d         =  'b0       ;
                     reg  [DATA_WIDTH - 1 :0]          data_e_1d         =  'b0       ;
																		              
                     reg  [DATA_WIDTH - 1 :0]          data_cal_temp     =  'b0       ;
                     reg  [DATA_WIDTH - 1 :0]          data_cal_temp1    =  'b0       ; 
																		 	          
                     reg  [CHANNEL_NUM_WIDTH-1:0]      channel_num_1d    = 'b0        ;
                     reg                               data_valid_1d     = 'b0        ;
(*keep = "ture"*)    reg                               data_valid_1d_tmp = 'b0        ;

//*******************************************************************************************																		      
//*******************************************************************************************																		      
//*******************************************************************************************																		      
        always @ (posedge clk)begin 
            if (data_valid) begin 
                data_a_1d <=  {data_a[26:0],data_a[31:27]} ;
            end 
        end     
        always @ (posedge clk)begin 
            data_b_1d <=  data_b ;
            data_c_1d <=  data_c ;
            data_d_1d <=  data_d ;
            data_e_1d <=  data_e ;
        end     
        generate 
           case(FUNCTION_SEL)
              0:begin 
                 always @ (posedge clk)begin                   
                    data_cal_temp <=((data_b & data_c)| ((~data_b )& data_d )) +  sour_w;                                                                           
                 end
              end 
              1:begin 
                 always @ (posedge clk)begin                   
                    data_cal_temp <=(data_b ^ data_c ^data_d) +  sour_w;                                                                          
                 end         
              end 
              2:begin 
                 always @ (posedge clk)begin                             
                    data_cal_temp <= ((data_b & data_c )| (data_c & data_d) | (data_b & data_d)) +  sour_w;                                                                          
                 end         
              end
              3:begin 
                 always @ (posedge clk)begin                   
                    data_cal_temp <= (data_b ^ data_c ^data_d) +  sour_w;  
                 end             
              end
              default:begin 
                 always @ (posedge clk)begin                   
                    data_cal_temp <= (data_b ^ data_c ^data_d) +  sour_w;                                                                        
                 end         
              end       
           endcase
        endgenerate   
        generate 
           case(FUNCTION_SEL)
              0:begin 
                 always @ (posedge clk)begin                   
                    sour_k <=  32'h5A827999  ;                                                                           
                 end
              end 
              1:begin 
                 always @ (posedge clk)begin                   
                    sour_k <=  32'h6ED9EBA1  ;                                                                       
                 end         
              end 
              2:begin 
                 always @ (posedge clk)begin                             
                    sour_k <=  32'h8F1BBCDC  ;         
                 end         
              end
              3:begin 
                 always @ (posedge clk)begin                   
                    sour_k <=  32'hCA62C1D6  ;
                 end             
              end
              default:begin 
                 always @ (posedge clk)begin                   
                    sour_k <=  32'h5A827999  ;                                                                       
                 end         
              end       
           endcase
        endgenerate       
//*******************************************************************************************
        always @ (posedge clk)begin                
            data_cal_temp1  <=  {data_a[26:0],data_a[31:27]} + data_e + sour_k;
        end     
        always @ (posedge clk)begin                
            data_a_new  <=  data_cal_temp + data_cal_temp1;
        end     
    
        always @ (posedge clk)begin                
            if(data_valid_1d)begin         
               data_b_new  <=  {data_a_1d[4:0],data_a_1d[31:5]};  
               data_c_new  <=  {data_b_1d[1:0],data_b_1d[31:2]};
            end     
        end      
        always @ (posedge clk)begin                
            if(data_valid_1d)begin         
               data_d_new  <=  data_c_1d;
               data_e_new  <=  data_d_1d;  
            end     
        end  
        always @ (posedge clk)begin 
            channel_num_1d  <= channel_num;
            channel_num_new <= channel_num_1d;             
        end    
      
        always @ (posedge clk)begin 
            if(!rst_n)begin 
                data_valid_1d   <= 1'b0;
                data_new_valid  <= 1'b0;
            end 
            else begin 
                data_valid_1d   <= data_valid;
                data_new_valid  <= data_valid_1d;             
            end 
        end
    
endmodule 