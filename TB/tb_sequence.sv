class  tb_sequence  extends uvm_sequence #(tb_item) ;
    tb_item            item ;

    `uvm_object_utils(tb_sequence);	
    function new(string name = "tb_sequence" ) ;
	    super.new(name );
	endfunction	
	
	virtual task body();
	    `uvm_info("tb_sequence" , "get the seq " , UVM_LOW);
        if(starting_phase != null)
		    starting_phase.raise_objection(this);	

		`uvm_info("tb_sequence" , "end  the seq " , UVM_LOW);
		if(starting_phase != null)
		    starting_phase.drop_objection(this);
			
	endtask

	


endclass