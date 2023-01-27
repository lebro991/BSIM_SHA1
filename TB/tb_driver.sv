`ifndef  TB_DRIVER_SV  
`define  TB_DRIVER_SV


class  tb_driver  extends uvm_driver#( tb_item ) ;

  virtual   tb_inf      tb_inf ;
  
  parameter    MSG_DATA_WIDTH       = 128                        ; 
  parameter    MSG_INFO_WIDTH       = 16                         ; 
  
   uvm_analysis_port #(tb_item)   out_pkt_drv_port;
  
    `uvm_component_utils( tb_driver )
	
	function new(string name = "tb_driver" , uvm_component parent = null ) ;
	    super.new(name , parent) ;
		`uvm_info("tb_driver", "new is called" , UVM_LOW);
		 out_pkt_drv_port = new("out_pkt_drv_port", this);
	endfunction   
  
 	extern  virtual task main_phase(uvm_phase phase); 
    extern    task drive_one_pkt(tb_item  item) ;
    extern    task rd_result_task               ;
	
	virtual function void build_phase(uvm_phase phase );
        super.build_phase(phase);
	    `uvm_info("tb_driver" , "build_phase is called" , UVM_LOW);
	    
	    if(!uvm_config_db#(virtual tb_inf)::get(this , "" , "tb_inf" , tb_inf))
	        `uvm_fatal("tb_driver" , "virtual interface must be set for tb_inf!!!")

    endfunction 
	
endclass :  tb_driver

task  tb_driver :: main_phase(uvm_phase phase );

	tb_inf.msg_data                  <= 'd0      ;
	tb_inf.msg_data_val              <= 'd0      ;
	tb_inf.msg_info                  <= 'd0      ;
	tb_inf.msg_info_val              <= 'd0      ;
	
	tb_inf.result_data_fifo_ren      <= 'd0      ;
	
   `uvm_info("tb_driver" , "main_phase is called" , UVM_LOW);
   
	while((tb_inf.sys_rst)|(~tb_inf.msg_buff_ready))begin
	    `uvm_info("tb_driver" , "tb_inf.sys_rst is called" , UVM_LOW);
        @(posedge tb_inf.sys_clk);
    end 
	fork
        while(1)begin 
	         `uvm_info("tb_driver" , "pkt  is  need  tx" , UVM_LOW);
	        // uvm_wait_for_nba_region();
            seq_item_port.get_next_item(req);
            // seq_item_port.try_next_item(req);
	    	`uvm_info("tb_driver" , "if req  is no  null " , UVM_LOW);
	    	if(req != null)begin
	    	   `uvm_info("tb_driver" , "req  is no  null " , UVM_LOW);
	    	    drive_one_pkt(req);
	    	    seq_item_port.item_done();
	    		out_pkt_drv_port.write(req);
	    	end 
	    	else begin 
	    	    @(posedge tb_inf.sys_clk);
	    		`uvm_info("tb_driver" , "req  is  null " , UVM_LOW);
	    	end 
        end 	
        while(1)begin 
	        // `uvm_info("tb_driver" , "read the sha1 result " , UVM_LOW);
	    	rd_result_task( ); 
        end 
    join		
endtask

task  tb_driver::drive_one_pkt(tb_item  item );

    bit [MSG_DATA_WIDTH - 1 :0]          data_128b[$]   ;
	bit [7:0]                            data_q[]       ;
	bit unsigned [31:0]                  data_size      ;
	bit unsigned [31:0]                  data_128b_size ;
	bit unsigned [31:0]                  data_size_byte ;
	
	item.pack_bytes(data_q);
	data_size       =  data_q.size() ;
	data_128b_size  =  {4'd0 , (data_size[31:4] + (|data_size[3:0]))};
	data_size_byte  =  data_128b_size * 16 ;
	
	if  (data_size ==  data_size_byte)begin 
        for (int i = 0 ; i < data_size ; i++ ) begin 
	        data_q[i]  = data_q[i] ;
	    end 
	end 
	else begin 
        for (int i = 0 ; i < data_size ; i++ ) begin 
	        data_q[i]  = data_q[i] ;
	    end 
        for (int i = data_size ; i < data_size_byte ; i++ ) begin 
	        data_q[i]  = 8'd0 ;
	    end 		
	end 
	
	for (int i = 0 ; i < data_128b_size ; i++)begin 
	
	    data_128b[i][127:120] = data_q[i*16     ] ;
	    data_128b[i][119:112] = data_q[i*16 + 1 ] ;
	    data_128b[i][111:104] = data_q[i*16 + 2 ] ;
	    data_128b[i][103:96 ] = data_q[i*16 + 3 ] ;
	    data_128b[i][95 :88 ] = data_q[i*16 + 4 ] ;
	    data_128b[i][87 :80 ] = data_q[i*16 + 5 ] ;
	    data_128b[i][79 :72 ] = data_q[i*16 + 6 ] ;
	    data_128b[i][71 :64 ] = data_q[i*16 + 7 ] ;
	    data_128b[i][63 :56 ] = data_q[i*16 + 8 ] ;
	    data_128b[i][55 :48 ] = data_q[i*16 + 9 ] ;
	    data_128b[i][47 :40 ] = data_q[i*16 + 10] ;
	    data_128b[i][39 :32 ] = data_q[i*16 + 11] ;
	    data_128b[i][31 :24 ] = data_q[i*16 + 12] ;
	    data_128b[i][23 :16 ] = data_q[i*16 + 13] ;
	    data_128b[i][15 :8  ] = data_q[i*16 + 14] ;
	    data_128b[i][7  :0  ] = data_q[i*16 + 15] ;
		// $display("data_128b[%0d] = %0h " , i , data_128b[i]) ;
	end 
	
	// `uvm_info("tb_driver" , " pack_128bit exchange the byte into 128bit " , UVM_LOW);
	
	// `uvm_info("tb_driver" , "begin to drive one pkt" , UVM_LOW);
	
	repeat(1) @(posedge tb_inf.sys_clk);	
	
	for (int i = 0 ; i < data_128b_size - 1 ; i++ ) begin 
	    @(posedge tb_inf.sys_clk);
		tb_inf.msg_data_val <= 1'b1 ;
		// tb_inf.data  <= pack_128bit.data_128b[i];
		tb_inf.msg_data  <= data_128b[i];
	
	end 
	@(posedge tb_inf.sys_clk);
	tb_inf.msg_data_val    <= 1'b1 ;
    tb_inf.msg_data     <= data_128b[data_128b_size - 1];	
	tb_inf.msg_info_val <= 1'b1 ;
	tb_inf.msg_info     <= data_size;	
	@(posedge tb_inf.sys_clk);
	tb_inf.msg_data_val <= 1'b0 ;
	tb_inf.msg_info_val <= 1'b0 ;
	`uvm_info("tb_driver" , "end to drive one pkt" , UVM_LOW);	
	
endtask : drive_one_pkt


task  tb_driver::rd_result_task;
	
	@(posedge tb_inf.sys_clk);
    #10ps;
	if(~tb_inf.result_data_empty)begin 
	    @(posedge tb_inf.sys_clk);
		@(posedge tb_inf.sys_clk);
	    tb_inf.result_data_fifo_ren <= 1'b1 ;
		`uvm_info("tb_driver" , "end to read the sha1 result " , UVM_LOW);	
	end 
	@(posedge tb_inf.sys_clk);
	tb_inf.result_data_fifo_ren <= 1'b0 ;
	@(posedge tb_inf.sys_clk);
	@(posedge tb_inf.sys_clk);
	
endtask : rd_result_task
`endif
		



	
	
	
	
	
	
