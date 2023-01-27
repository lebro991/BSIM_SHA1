class  tb_sequencer  extends uvm_sequencer #(tb_item) ;
	 
    function new(string name = "tb_sequencer"  , uvm_component parent = null ) ;
	    super.new(name , parent);
		
	endfunction
	
	`uvm_component_utils(tb_sequencer);

    
	virtual function void build_phase(uvm_phase  phase );
        super.build_phase(phase);
			
    endfunction : build_phase	
	
endclass : tb_sequencer