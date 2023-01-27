`ifndef  TB_MONITOR_SV  
`define  TB_MONITOR_SV


class  tb_monitor  extends uvm_monitor;

  virtual   tb_inf   tb_inf ;
   tb_item           item   ;
  
  // uvm_analysis_port #(tb_item) out_tlp_mon_port  ;
  

    `uvm_component_utils( tb_monitor )
	
	function new(string name = "tb_monitor" , uvm_component parent = null ) ;
	    super.new(name , parent) ;
		`uvm_info("tb_monitor", "new is called" , UVM_LOW);
	endfunction   
  
 	extern  virtual task main_phase(uvm_phase phase); 
    extern    task recv_filled_pkt  ;
    extern    task recv_rtl_result  ;
	
	virtual function void build_phase(uvm_phase phase );
        super.build_phase(phase);
	    `uvm_info("tb_monitor" , "build_phase is called" , UVM_LOW);
	
		
	    if(!uvm_config_db#(virtual tb_inf)::get(this , "" , "tb_inf" , tb_inf))
	        `uvm_fatal("tb_monitor" , "virtual interface must be set for vif!!!")
			
	    // out_tlp_mon_port = new("out_tlp_mon_port" , this);
		item = tb_item::type_id::create("item"); 
    endfunction 
	
endclass :  tb_monitor

task  tb_monitor::main_phase(uvm_phase phase );

   `uvm_info("tb_monitor" , "main_phase is called" , UVM_LOW);	
    fork
	    while(1) begin 
	       recv_filled_pkt ;
	    end 
		
	    while(1) begin 
	       recv_rtl_result ;
	    end 		
    join 		
		
endtask



task  tb_monitor::recv_filled_pkt ;
        bit           rx_filled_data_valid ;
		bit[511:0]    rx_filled_data       ;
		
 
        
		@(posedge tb_inf.sys_clk);
        	
		#1ns ;
        uvm_hdl_read("tb_top.sha1_top_inst.sha1_msg_fill_ctrl_128to512_inst.msg_filled_data_valid", rx_filled_data_valid);  
        uvm_hdl_read("tb_top.sha1_top_inst.sha1_msg_fill_ctrl_128to512_inst.msg_filled_data", rx_filled_data); 			
		if(rx_filled_data_valid)begin 
		    rx_filled_pkt_q.push_back(rx_filled_data) ; 
			// $display("[tb_monitor]   rx_rtl_filled_data: %h" ,rx_filled_data);  
		end 
	
	
endtask : recv_filled_pkt

task  tb_monitor::recv_rtl_result ;
        bit           rx_rtl_result_valid      ;
		bit[159:0]    rx_rtl_result_data       ;
		
		@(posedge tb_inf.sys_clk);
        	
		#1ns ;
        uvm_hdl_read("tb_top.sha1_top_inst.result_data_fifo_ren", rx_rtl_result_valid);  
        uvm_hdl_read("tb_top.sha1_top_inst.result_dout", rx_rtl_result_data); 			
		if(rx_rtl_result_valid)begin 
		    rtl_result_final.push_back(rx_rtl_result_data) ; 
			$display("[tb_monitor]   rx_rtl_result_data: %h" ,rx_rtl_result_data);  
		end 
	
	
endtask : recv_rtl_result
`endif
		



	
	
	
	
	
	
