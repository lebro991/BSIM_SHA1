module  sha1_msg_extend_function
       #(  
           parameter    DATA_WIDTH        =  512     

       )
       (
        input                                   clk               ,
        input                                   rst_n             ,
												       
        input        [DATA_WIDTH - 1:0]         sour_w            ,
        input                                   sour_w_en         ,
        output reg   [DATA_WIDTH - 1:0]         sour_w_new  
        
        );
		
    reg  [DATA_WIDTH - 1:0]       sour_w_tmp     = 'b0;
    reg                           sour_w_en_tmp  = 'b0;

    always @ (posedge clk)begin 
        if(!rst_n)begin 
            sour_w_en_tmp  <= 1'b0; 
        end 
        else begin 
            sour_w_en_tmp  <= sour_w_en;
        end 
    end     
    always @ (posedge clk)begin 
        if (sour_w_en)begin 
            sour_w_tmp[31:0] <= (sour_w[DATA_WIDTH - 1:480]^sour_w[447:416]^sour_w[255:224]^sour_w[95:64]);
        end 
        else begin 
            sour_w_tmp[31:0] <= sour_w_tmp[31:0];
        end 
    end  
    always @ (posedge clk)begin 
        sour_w_tmp[DATA_WIDTH - 1:32] <= sour_w[479:0];
    end 
    always @ (posedge clk)begin
        if (sour_w_en_tmp)begin     
            sour_w_new[31:0] <= {sour_w_tmp[30:0],sour_w_tmp[31]};
        end 
        else begin 
            sour_w_new[31:0] <= sour_w_new[31:0];
        end 
    end            

    always @ (posedge clk)begin
        sour_w_new[DATA_WIDTH - 1:32] <= sour_w_tmp[DATA_WIDTH - 1:32];
    end    
    
endmodule     