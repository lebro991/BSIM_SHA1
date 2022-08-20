

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


class  case_vseq   extends uvm_sequence ;
    `uvm_object_utils(case_vseq); 
	`uvm_declare_p_sequencer(tb_vsqr);

	function  new (string name = "case_vseq" );
	    super.new(name);
    endfunction
	
    virtual task body();
	     tb_item              item        ;
		 drv0_seq             seq0           ;
		 
	    `uvm_info("case_vseq" , "get the start " , UVM_LOW);
        if(starting_phase != null)
    	    starting_phase.raise_objection(this);
		
		#1ms
		
		for(int i= 46; i<1400;i++)begin 
		    `uvm_do_on_with(item , p_sequencer.p_sqr0 , {item.pload.size() == i;})	
		    `uvm_info("case_vseq" , "send one longest  packet  on p_sequencer.sqr0 " , UVM_MEDIUM);
		end 		
		// fork  
		    // `uvm_do_on(seq0  , p_sequencer.p_sqr0 );
		    // `uvm_do_on(seq1  , p_sequencer.p_sqr1 );
		
		// join 
		
    	#50ms;
    	
        if(starting_phase != null)
    	    starting_phase.drop_objection(this);	
    endtask 	
endclass

	
class  tb_case1   extends tb_base_test ;
     

	function  new (string name = "tb_case1" , uvm_component  parent = null );
	    super.new(name , parent);
    endfunction
	extern virtual function void build_phase(uvm_phase phase) ;
	`uvm_component_utils(tb_case1)
	
endclass

	
	function void tb_case1:: build_phase(uvm_phase phase );
        super.build_phase(phase);
		
		
		uvm_config_db#(uvm_object_wrapper)::set( this ,  
		                                "v_sqr.main_phase" , 
										"default_sequence",
										case_vseq::type_id::get()
		                                );   
        // $display("step 1" ) ;										
    endfunction 	

	
	
 


