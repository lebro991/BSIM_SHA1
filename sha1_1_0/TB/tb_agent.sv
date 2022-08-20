
class  tb_agent extends uvm_agent ;
    tb_sequencer  sqr   ;
    tb_driver     drv   ;
	// tb_model      
    tb_monitor    mon   ;
	
    uvm_analysis_port #(tb_item)  ap ;	
	
	function new(string name = "tb_agent" , uvm_component parent ) ;
	    super.new(name , parent) ;
		
	endfunction 

	extern  virtual  function void build_phase(uvm_phase phase);
	extern  virtual  function void connect_phase(uvm_phase phase);
	
	`uvm_component_utils(tb_agent)
	
endclass 


function  void tb_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
	if(is_active == UVM_ACTIVE )begin 
	   sqr = tb_sequencer::type_id::create("sqr" , this ) ;
	   drv = tb_driver::type_id::create("drv" , this ) ;
	
	end 
	   mon = tb_monitor::type_id::create("mon" , this );
	   
endfunction 

function void tb_agent::connect_phase(uvm_phase phase);
    super.connect_phase( phase ) ; 
	if(is_active == UVM_ACTIVE )begin 
	   drv.seq_item_port.connect(sqr.seq_item_export);
	   // drv.out_pkt_drv_port.connect(sqr.seq_item_export);
	end 
	ap = drv.out_pkt_drv_port ;
endfunction 	   