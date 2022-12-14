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
        int    rx_filled_pkt_wr_file ; 
        bit[511:0]  tx_filled_pkt_data       ; 
        bit[511:0]  tx_filled_pkt_data_tmp   ; 
        bit[511:0]  rx_filled_pkt_data   ; 
        bit[511:0]  tx_filled_pkt_cmp[$] ; 
		int         rcv_pkt_num          ;
		
		
       `uvm_info("tb_scoreboard" , "main_phase is called" , UVM_LOW);
        tx_filled_pkt_wr_file = $fopen("./tbout/tx_filled_pkt.txt","w");
        rx_filled_pkt_wr_file = $fopen("./tbout/rx_filled_pkt.txt","w");	   
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
                end 				
 				rcv_pkt_num ++ ;
    	    end 			
        join			
    	$fclose(tx_filled_pkt_wr_file ); 
    	$fclose(rx_filled_pkt_wr_file ); 
		
    endtask



`endif
		



	
	
	
	
	
	
