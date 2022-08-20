
class  tb_env extends uvm_env ;
	
    tb_agent       i_agt        ;
    // my_agent       o_agt        ;
    tb_model       mdl          ;
	tb_scoreboard  scoreboard   ;
	uvm_tlm_analysis_fifo #(tb_item) agt_mdl_fifo;
	// uvm_tlm_analysis_fifo #(my_transaction) agt_scb_fifo;	
	uvm_tlm_analysis_fifo #(msg_filled_512) mdl_scb_fifo;	
    
	
	function new(string name = "tb_env" , uvm_component parent ) ;
	    super.new(name , parent) ;
	endfunction   

	virtual function void build_phase(uvm_phase phase );
        super.build_phase(phase);
       
		// drv   = my_driver::type_id::create("drv" , this);
        i_agt = tb_agent::type_id::create("i_agt" , this);
        // o_agt = my_agent::type_id::create("o_agt" , this);
		mdl   = tb_model::type_id::create("mdl"   , this);
        scoreboard = tb_scoreboard::type_id::create("scoreboard" , this);
		
		i_agt.is_active  = UVM_ACTIVE ;
		// o_agt.is_active  = UVM_PASSIVE ;
		
		uvm_config_db#(uvm_object_wrapper)::set( this, 
		                                "i_agt.sqr.main_phase" , 
										"default_sequence",
										tb_sequence::type_id::get()
		                                );
										
        agt_mdl_fifo = new("agt_mdl_fifo" , this);		
        // agt_scb_fifo = new("agt_scb_fifo" , this);		
        mdl_scb_fifo = new("mdl_scb_fifo" , this);		
    endfunction

	
	`uvm_component_utils(tb_env)
	    extern  virtual function void connect_phase(uvm_phase phase );
	    // extern  task main_phase(uvm_phase phase );
endclass 

	function void tb_env::connect_phase(uvm_phase phase);
	    super.connect_phase(phase) ;
		
		i_agt.ap.connect(agt_mdl_fifo.analysis_export) ;
		mdl.port.connect(agt_mdl_fifo.blocking_get_export) ;

		mdl.ap.connect(mdl_scb_fifo.analysis_export) ;
		scoreboard.exp_port.connect(mdl_scb_fifo.blocking_get_export) ;	

		// o_agt.ap.connect(agt_scb_fifo.analysis_export) ;
		// scoreboard.act_port.connect(agt_scb_fifo.blocking_get_export) ;			
    endfunction 
	