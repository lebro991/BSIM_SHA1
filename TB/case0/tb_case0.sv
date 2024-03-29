

class  drv0_seq  extends uvm_sequence #(tb_item);


    tb_item       item        ;
	
 	function  new (string name = "drv0_seq");
	    super.new(name);
    endfunction
	
    virtual task body();
	    `uvm_info("drv0_seq" , "get the start " , UVM_LOW);
        if(starting_phase != null)
    	    starting_phase.raise_objection(this);
			
    	repeat (2) begin
    	    `uvm_do(item )
    	    // `uvm_do_with(m_trans , {m_trans.pload.size() == 100;})
			`uvm_info("drv0_seq" , "send one transaction " , UVM_MEDIUM);
    	end 
    	#1000ms;
    	
        if(starting_phase != null)
    	    starting_phase.drop_objection(this);	
    endtask 
	
	`uvm_object_utils(drv0_seq);

endclass


class  case0_vseq   extends uvm_sequence ;
    `uvm_object_utils(case0_vseq); 
	`uvm_declare_p_sequencer(tb_vsqr);

	function  new (string name = "case0_vseq" );
	    super.new(name);
    endfunction
	
    virtual task body();
	     tb_item              item        ;
		 drv0_seq             seq0           ;
		 
	    `uvm_info("case0_vseq" , "get the start " , UVM_LOW);
        if(starting_phase != null)
    	    starting_phase.raise_objection(this);
			
		`uvm_do_on_with(item , p_sequencer.p_sqr0 , {item.pload.size() == 65;})	
		`uvm_info("case0_vseq" , "send one longest  packet  on p_sequencer.sqr0 " , UVM_MEDIUM);
		// fork  
		    // `uvm_do_on(seq0  , p_sequencer.p_sqr0 );
		    // `uvm_do_on(seq1  , p_sequencer.p_sqr1 );
		
		// join 
		
    	#50ms;
    	
        if(starting_phase != null)
    	    starting_phase.drop_objection(this);	
    endtask 	
endclass

	
class  tb_case0   extends tb_base_test ;
     

	function  new (string name = "tb_case0" , uvm_component  parent = null );
	    super.new(name , parent);
    endfunction
	extern virtual function void build_phase(uvm_phase phase) ;
	`uvm_component_utils(tb_case0)
	
endclass

	
	function void tb_case0:: build_phase(uvm_phase phase );
        super.build_phase(phase);
		
		
		uvm_config_db#(uvm_object_wrapper)::set( this ,  
		                                "v_sqr.main_phase" , 
										"default_sequence",
										case0_vseq::type_id::get()
		                                );   
        $display("step 1" ) ;										
    endfunction 	

	
	
 


