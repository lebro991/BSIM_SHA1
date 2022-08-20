`timescale 1ns/1ps

module  sha1_pkt_oder
        #(       
         parameter    TAG_WIDTH                = 10                             ,
         parameter    SHA_RESULT_WIDTH         = 32                             ,
         parameter    SHA_RESULT_RAM_DEEP      = 1024                           ,
         parameter    SHA_RESULT_RAM_AWIDTH    = $clog2(SHA_RESULT_RAM_DEEP)    ,
         parameter    SHA_RESULT_RAM_DWIDTH    = SHA_RESULT_WIDTH   
        )
        (
        input                                           clk                     ,
        input                                           rst_n                   ,
        input        [SHA_RESULT_WIDTH - 1:0]           result_data             ,
        input        [TAG_WIDTH - 1:0]                  result_tag              ,        
        input                                           result_en               ,    

        output wire  [SHA_RESULT_WIDTH - 1:0]           result_dout             ,    
        output reg                                      result_data_empty       ,          
        output wire                                     init_done               ,          
        input                                           result_fifo_ren                  
        
        );
     
 
localparam             ST_IDLE                = 0 , 
                       ST_RD_DATA             = 1 ,
                       ST_WAIT_NOP0           = 2 ;
                       
                       
reg                                       result_ram_wr_ena         = 0   ;
reg  [SHA_RESULT_WIDTH - 1 : 0]           result_ram_wr_data        = 0   ;
reg  [SHA_RESULT_RAM_AWIDTH - 1 :0 ]      result_ram_wr_addr        = 0   ;
reg  [SHA_RESULT_RAM_AWIDTH - 1 :0 ]      result_ram_rd_addr        = 0   ;
wire [SHA_RESULT_WIDTH -1 :0]             result_ram_rd_data              ;
																	      
reg  [2:0]                                fsm_cs                          ;
reg  [2:0]                                fsm_ns                          ;   
	 																      
reg  [SHA_RESULT_RAM_DEEP - 1 : 0 ]       tag_en                          ;              
reg  [SHA_RESULT_RAM_AWIDTH - 1 : 0 ]     tag_addr                        ;              
reg                                       tag_rd_value                    ;              
                             
   
assign   result_dout =  result_ram_rd_data[SHA_RESULT_WIDTH - 1 :0];   

//***********************************************************************
    always @ (posedge clk)begin 
        if(!rst_n)begin 
             result_ram_wr_ena <=   1'b0; 
        end 
        else begin 
             result_ram_wr_ena <=   result_en;          
        end 
    end   

    always @ (posedge clk)begin
	    if(result_en) begin 
		    result_ram_wr_data <=  result_data ;
            result_ram_wr_addr <=  result_tag[SHA_RESULT_RAM_AWIDTH - 1:0];
		end 
    end 

    //for this always ,maybe  the  way is too long
    integer  k ;
    always@(posedge clk) begin 
        for(k = 0; k < SHA_RESULT_RAM_DEEP ; k = k + 1)begin
            tag_addr[k] = k ;
        end 
    end		
	genvar i;
    generate	
        for(i=0 ; i < SHA_RESULT_RAM_DEEP ; i = i + 1 ) begin    :  gen_tag_en                                                                                                                                        
            always@(posedge clk) begin 
                if(!rst_n)begin  
                    tag_en[i] = 1'b0   ;
                end 
				else if (result_fifo_ren & (result_ram_rd_addr[SHA_RESULT_RAM_AWIDTH - 1 :0 ] ==  tag_addr[i] )) begin 
				    tag_en[i] <=  1'b0 ;
				end 
	         	else if (result_en & (result_ram_rd_addr[SHA_RESULT_RAM_AWIDTH - 1 :0 ] ==  tag_addr[i] )) begin 
	         		tag_en[i] <=  1'b1 ;	
	         	end		
            end	
	    end 
	endgenerate	
   
   always @ (posedge clk)begin 
       if(!rst_n)begin 
            result_ram_rd_addr <=   {SHA_RESULT_RAM_AWIDTH{1'b0}}  ; 
       end 
       else begin
            if((result_fifo_ren)& (fsm_cs == ST_RD_DATA ))begin        
               result_ram_rd_addr <=   result_ram_rd_addr + 1'b1; 
            end 
            else begin 
               result_ram_rd_addr <=   result_ram_rd_addr;
            end             
      end 
   end  
//***********************************************************************
   always @ (posedge clk)begin 
      if(!rst_n)begin 
         fsm_cs <=  ST_IDLE ;
      end  
      else begin
         fsm_cs <=  fsm_ns  ;  
      end 
   end 
   always @ (*)begin 
   
      fsm_ns =  fsm_cs;
	  
      case(fsm_cs)
         ST_IDLE:
            begin 
			    if(~result_data_empty)begin 
                    fsm_ns =  ST_RD_DATA ; 
				end 
				else begin 
				    fsm_ns =  ST_IDLE    ; 
				end 
            end      
         ST_RD_DATA:
            begin 
                if (result_fifo_ren)begin 
                    fsm_ns =  ST_WAIT_NOP0  ;
                end 
                else begin
                    fsm_ns =  ST_RD_DATA    ;                   
                end 
            end 
         ST_WAIT_NOP0:
            begin 
               fsm_ns =  ST_IDLE  ; 
            end           
         default :
            begin 
               fsm_ns =  ST_IDLE; 
            end             
      endcase            
   end
   
    always @ (posedge clk)begin 
        if(!rst_n)begin 
            tag_rd_value <=   1'b0; 
        end 
        else begin
            tag_rd_value <=  tag_en[result_ram_rd_addr[SHA_RESULT_RAM_AWIDTH - 1:0]] ;         
        end 
    end 
   
   always @ (posedge clk)begin 
       if(!rst_n)begin 
            result_data_empty <=   1'b1; 
       end 
       else begin
            if (result_fifo_ren)begin 
                result_data_empty <=   1'b1;   
            end 
            else if(tag_rd_value  )begin        
                result_data_empty <=   1'b0;  
            end           
      end 
   end 
   

   
xpm_sdpram_common_with_initial  #(
            .RAM_WIDTH        (SHA_RESULT_WIDTH         )  , 
            .RAM_DEPTH        (SHA_RESULT_RAM_DEEP      )  , 
            .RAM_STYLE        ("block"                  )  ,  // "block" "distribute"	
			.INIT             (1                        )  , 
			.INIT_VALUE       ({SHA_RESULT_WIDTH{1'b0}} )  , 
            .LAYTENCY         (3                        )    			
            
         )
sha1_result_buff_ram_inst
         (
		 .clk                 (clk                       ), //input                           
		 .rst                 (~rst_n                    ), //input                           
		 .dina                (result_ram_wr_data        ), //input    [RAM_WIDTH - 1  :0]    
		 .addra               (result_ram_wr_addr        ), //input    [ADDR_WIDTH - 1 :0]    
		 .wea                 (result_ram_wr_ena         ), //input                           
		 .doutb               (result_ram_rd_data        ), //input    [RAM_WIDTH - 1  :0]    
		 .addrb               (result_ram_rd_addr        ), //input    [ADDR_WIDTH - 1 :0]     
		 .initial_done        (init_done                 )  //input    [ADDR_WIDTH - 1 :0]     
         );    
 
endmodule     