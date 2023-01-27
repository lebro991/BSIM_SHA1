`ifndef  TB_SCOREBOARD_SV  
`define  TB_SCOREBOARD_SV

class  tb_scoreboard  extends uvm_scoreboard  ;


   `uvm_component_utils( tb_scoreboard )  
   
    string                    fn_name         ;  
    extern  function new(string name , uvm_component parent = null);
    extern  virtual function void build_phase(uvm_phase phase );
    extern  virtual task main_phase(uvm_phase phase ); 

endclass :  tb_scoreboard

	function tb_scoreboard::new(string name  , uvm_component parent = null ) ;
	    super.new(name , parent) ;
		
	endfunction 
	
	function void tb_scoreboard::build_phase(uvm_phase phase );
        super.build_phase(phase);
	    `uvm_info("tb_scoreboard" , "build_phase is called" , UVM_LOW);
		
    endfunction 		
	
    task  tb_scoreboard :: main_phase(uvm_phase phase );
        int    tx_filled_pkt_wr_file ; 
        int    tx_result_wr_file     ; 
        int    rx_filled_pkt_wr_file ; 
        int    rx_result_wr_file     ; 
        bit[511:0]  tx_filled_pkt_data       ; 
        bit[511:0]  tx_filled_pkt_data_tmp   ; 
		bit[159:0]  tx_result_data_tmp       ; 
        bit[511:0]  rx_filled_pkt_data       ; 
        bit[159:0]  rx_final_result_data     ; 
        bit[511:0]  tx_filled_pkt_cmp[$]     ; 
		int         rcv_pkt_num              ;
		int         rcv_result_num           ;
		
		
       `uvm_info("tb_scoreboard" , "main_phase is called" , UVM_LOW);
        tx_filled_pkt_wr_file = $fopen("./tbout/tx_filled_pkt.txt","w");
        rx_filled_pkt_wr_file = $fopen("./tbout/rx_filled_pkt.txt","w");	   
        tx_result_wr_file     = $fopen("./tbout/tx_result_data.txt","w");	   
        rx_result_wr_file     = $fopen("./tbout/rx_result_data.txt","w");	   
    	fork
		    //print the tx_filled_pkt 
    	    while(1) begin 
                wait(tx_filled_pkt_q.size());
                tx_filled_pkt_data =  tx_filled_pkt_q.pop_front() ; 
				$fdisplay(tx_filled_pkt_wr_file,"%h" ,tx_filled_pkt_data);
                tx_filled_pkt_cmp.push_back(tx_filled_pkt_data);   				
    	    end 	
			
    	    while(1) begin 
                wait(rx_filled_pkt_q.size());
                rx_filled_pkt_data =  rx_filled_pkt_q.pop_front() ; 
				$fdisplay(rx_filled_pkt_wr_file,"%h" ,rx_filled_pkt_data);
                tx_filled_pkt_data_tmp = tx_filled_pkt_cmp.pop_front();  
                if(tx_filled_pkt_data_tmp == rx_filled_pkt_data)begin 
                    $display("[tb_scoreboard] rx pkt num %d success at %t " ,rcv_pkt_num , $time);
                end 
                else begin 
                    $display("[tb_scoreboard] rx pkt num %d ,the data is %h , failed at %t ns" , rcv_pkt_num , rx_filled_pkt_data,$time );   
                    $display("[tb_scoreboard]ERROR ****************** expect data is [0x%h]," , tx_filled_pkt_data_tmp);   
                    `uvm_error("*E", "[tb_scoreboard] rx pkt is error");  
                end 				
 				rcv_pkt_num ++ ;
    	    end 
			
    	    while(1) begin 
                wait(rx_result_final.size());
                rx_final_result_data =  rx_result_final.pop_front() ; 
				$fdisplay(rx_result_wr_file,"%h" ,rx_final_result_data);
                tx_result_data_tmp = ref_model_result_final.pop_front();  
                if(tx_result_data_tmp[31:0] == rx_final_result_data)begin 
                    $display("[tb_scoreboard] rx result num %d success at %t " ,rcv_result_num , $time);
                end 
                else begin 
                    $display("[tb_scoreboard] rx result num %d ,the data is %h , failed at %t ns" , rcv_result_num , rx_final_result_data,$time );   
                    $display("[tb_scoreboard] ERROR ****************** expect data is [0x%h]," , tx_result_data_tmp);
                    `uvm_error("*E", "[tb_scoreboard] rx result is error");					
                end 
				$fdisplay(tx_result_wr_file,"%h" ,tx_result_data_tmp);
 				rcv_result_num ++ ;
    	    end 			
        join			
    	$fclose(tx_filled_pkt_wr_file ); 
    	$fclose(rx_filled_pkt_wr_file ); 
    	$fclose(tx_result_wr_file     ); 
    	$fclose(rx_result_wr_file     ); 
		
    endtask



`endif
		



	
	
	
	
	
	
