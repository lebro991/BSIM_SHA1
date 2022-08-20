`ifndef  TB_ITEM_SV  
`define  TB_ITEM_SV


class  tb_item  extends uvm_sequence_item ;

    rand bit [47:0]     dmac       ;
    rand bit [47:0]     smac       ;
    rand bit [15:0]     ether_type ;
	rand byte           pload[]    ;
	rand bit [31:0]     crc        ;

	`uvm_object_utils_begin( tb_item )
	    `uvm_field_int       (dmac, UVM_ALL_ON      )
	    `uvm_field_int       (smac, UVM_ALL_ON      )
	    `uvm_field_int       (ether_type, UVM_ALL_ON)
	    `uvm_field_array_int (pload, UVM_ALL_ON     )
	    `uvm_field_int       (crc, UVM_ALL_ON       )
	`uvm_object_utils_end 
	
    constraint  pload_cons{
	    
		pload.size >= 46   ;
		pload.size <= 1500 ;
	  
	  
	  }	
    function  bit[31:0]  calc_crc();
        return  32'hFFFFFFFF ;
	endfunction 
    function  void post_randomize();
        crc = calc_crc ;
	endfunction 
	
	
    function  new(string name = "tb_item");
        super.new(name);
	endfunction 
	
	function void  my_print();
	    $display("dmac = %0h " , dmac) ;
	    $display("smac = %0h " , smac) ;
	    $display("ether_type = %0h " , ether_type) ;
		for (int i = 0 ; i < pload.size ; i++ )begin
            $display("pload[%0d] = %0h " , i , pload[i]) ;
        end  		
		$display("crc = %0h " , crc) ;
	endfunction	
endclass

`endif
