
class  tb_base_test extends uvm_test ;


    tb_env       env0        ;
    tb_vsqr      v_sqr       ;
 
	function new(string name = "tb_base_test" , uvm_component parent = null ) ;
	    super.new(name , parent) ;
	endfunction 
	
	
	extern  virtual function void build_phase(uvm_phase phase);
	extern  virtual function void report_phase(uvm_phase phase);
	extern  virtual function void connect_phase(uvm_phase phase);
    `uvm_component_utils(tb_base_test)
	
endclass

	function void tb_base_test:: build_phase(uvm_phase phase );
        super.build_phase(phase);
        env0 = tb_env::type_id::create("env0" , this);
        // env1 = my_env::type_id::create("env1" , this);
		v_sqr = tb_vsqr::type_id::create("v_sqr" , this);
		 										
    endfunction 
	function void tb_base_test::report_phase(uvm_phase phase);
	    uvm_report_server  server ;
		int  err_num ;
		super.report_phase(phase);
		server = get_report_server();
		err_num = server.get_severity_count(UVM_ERROR);
		
		if(err_num != 0)begin 
		    $display("TEST CASE FAILED");
		end 
		else begin 
		    $display("TEST CASE PASSED");
		end 
    endfunction 	
	
	function void tb_base_test:: connect_phase(uvm_phase phase );
        super.build_phase(phase);
        v_sqr.p_sqr0  = env0.i_agt.sqr ;
        // v_sqr.p_sqr1  = env1.i_agt.sqr ;
		 										
    endfunction 	

	
	
 


