
class  tb_vsqr  extends uvm_sequencer ;


    tb_sequencer       p_sqr0        ;
    // my_sequencer       p_sqr1        ;
	
 	function  new (string name = "tb_vsqr" , uvm_component  parent );
	    super.new(name , parent );
    endfunction
	
	`uvm_component_utils( tb_vsqr );

endclass


	
	

	
	
 


