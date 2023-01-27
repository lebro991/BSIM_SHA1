
class  tb_model extends uvm_component ;


    uvm_blocking_get_port #(tb_item)  port ;
	// uvm_analysis_port #() ap ;
	extern  function new(string name , uvm_component parent);
	extern  function void build_phase(uvm_phase phase );
	extern  virtual task  main_phase(uvm_phase phase );
	extern  virtual task  cal_sha1_pkt(tb_item item );
	// extern  virtual task  pkt_filled(tb_item item );
	
	`uvm_component_utils(tb_model)
endclass

	function tb_model::new(string name  , uvm_component parent ) ;
	    super.new(name , parent) ;
	endfunction 

    function void tb_model::build_phase(uvm_phase phase );
        super.build_phase(phase);
        port = new("port" , this) ;
		// ap =new("ap" , this);
    endfunction 
    task  tb_model::main_phase(uvm_phase phase );
	    tb_item item ;
	    tb_item new_item ;
		super.main_phase( phase );
		
		while(1)begin 
		    port.get(item) ;
		    new_item = new("new_item") ;
			new_item.copy(item) ;
			`uvm_info("tb_model" ,"get one transaction ,copy and print it : " , UVM_LOW)
			// new_item.my_print();
			cal_sha1_pkt(new_item);
  
			// ap.write( );
		end
	endtask


    task  tb_model::cal_sha1_pkt(tb_item item );
	
	        bit[159:0]       sour_h_buf      ;
	        bit[159:0]       result_data_tmp ;
	        bit[511:0]       sour_data       ;
			
            pkt_filled(item);

			sour_h_buf = {32'h67452301,32'hEFCDAB89,32'h98BADCFE,32'h10325476,32'hC3D2E1F0};
			
			for(int i=0; i < pkt_filled.data_512b_size ; i++ )begin
			    sour_data = pkt_filled.data_512b[i] ; 
			    sha160_signal_block_test(sour_data , sour_h_buf , result_data_tmp );
				
				sour_h_buf  =  result_data_tmp ;
                // $display("[tb_model]  *******************************************" );    
                // $display("[tb_model]  result_data_tmp: %h" ,result_data_tmp);
                // $display("[tb_model]  sour_data: %h" ,sour_data);				
		    end 
			ref_model_result_final.push_back( result_data_tmp );
			// $display("[tb_model] *******************************************" );    
            // $display("[tb_model] ref_model_result_final: %h" ,result_data_tmp);
            
	endtask	
 
    task  pkt_filled(tb_item item );
            bit [511  :0]                        data_512b[$]   ;
	        bit [7:0]                            data_q[]       ;
	        bit [7:0]                            data_q_tmp[$]  ;
	        bit unsigned [31:0]                  data_size      ;
	        bit unsigned [63:0]                  data_bit_size  ;
	        bit unsigned [31:0]                  data_128b_size ;
	        bit unsigned [31:0]                  data_512b_size ;
	        bit unsigned [31:0]                  data_size_byte ; 
			int     k ;
			
	        item.pack_bytes(data_q);
	        data_size       =  data_q.size() ;
			$display("tb_model.data_size = %0d " , data_size ) ;
	        // data_128b_size  =  {4'd0 , (data_size[31:4] + (|data_size[3:0]))};
			if(data_size[5:0] == 6'd0)begin  
	            data_512b_size  =  {6'd0 , (data_size[31:6] + 1)};
			end 
			else if (data_size[5:0] > 6'd55 )begin  
			    data_512b_size  =  {6'd0 , (data_size[31:6] + (|data_size[5:0]) + 1 )};
			end 
			else begin 
			    data_512b_size  =  {6'd0 , (data_size[31:6] + (|data_size[5:0]) )};
			end 
			// $display("tb_model.data_512b_size = %0d " , data_512b_size ) ;
	        data_size_byte  =  data_512b_size * 64 ;
			
	        data_q_tmp.delete();
			
			for (int i = 0 ; i < data_size ; i++ ) begin 
	            data_q_tmp[i]  = data_q[i] ;
				// $display("tb_model.data_q_tmp[%0d] = %0h " , i , data_q_tmp[i]) ;
	        end
			// $display("****************************************************  "  ) ;
			data_q_tmp[data_size]  = 8'h80;
			// $display("tb_model.data_q_tmp[%0d] = %0h " , data_size , data_q_tmp[data_size]) ;
			
			// $display("****************************************************  "  ) ;
			for (int i = data_size + 1 ; i < data_size_byte - 8 ; i++ ) begin 
	            data_q_tmp[i]  = 8'd0 ;
				// $display("tb_model.data_q_tmp[%0d] = %0h " , i , data_q_tmp[i]) ;
	        end 	
			// $display("****************************************************  "  ) ;
			data_bit_size = data_size * 8 ;
			
			k = 0 ;
			
			for (int i = data_size_byte - 8 ; i < data_size_byte ; i++ ) begin 
	            data_q_tmp[i]  = data_bit_size[(63-8*k)-:8];
				
				k++;
				// $display("tb_model.data_q_tmp[%0d] = %0h " , i , data_q_tmp[i]) ;
	        end 			
	        
	        for (int i = 0 ; i < data_512b_size ; i++)begin 
	            for (int j = 0 ; j < 64 ; j++)begin 
	                data_512b[i][(511-8*j)-:8] = data_q_tmp[i * 64 +  j ] ;
				end 
	        	$display("tb_model.data_512b[%0d] = %h " , i , data_512b[i]) ;
				tx_filled_pkt_q.push_back(data_512b[i]);
	        end 
	        $display("***************************************************************"  ) ;
	        `uvm_info("tb_model" , " pack_512bit exchange the byte into 512bit " , UVM_LOW);
	        
	        `uvm_info("tb_model" , "begin to drive one pkt" , UVM_LOW);
            

	endtask	
	
  //----------------------------------------------------------------
  // single calculate the sha1
  //----------------------------------------------------------------
  task sha160_signal_block_test(
            input       [511 : 0]           block_data_tmp,
            input       [159 : 0]           init_buff_data,
            output  reg [159 : 0]           result_data    
                        );
                        
        // reg  [511 : 0]    block_data_tmp           ;
        reg  [0:15][31:0]       sour_w                   ;
        reg  [0:79][31:0]       extend_w                 ;
        reg  [0:4] [31:0]       sour_h                   ;
        reg  [0:3] [31:0]       sour_k                   ;
        reg  [31:0]             data_a                   ;
        reg  [31:0]             data_b                   ;
        reg  [31:0]             data_c                   ;
        reg  [31:0]             data_d                   ;
        reg  [31:0]             data_e                   ;
        reg  [31:0]             data_tmp                 ;  
        reg  [63:0]             cal_time                 ;           
        integer  i,j;        
    begin
        
        sour_h[0]  = init_buff_data[159:128];
        sour_h[1]  = init_buff_data[127:96 ];
        sour_h[2]  = init_buff_data[95:64  ];
        sour_h[3]  = init_buff_data[63:32  ];
        sour_h[4]  = init_buff_data[31:0   ];
        
        // $display("sour_h: %h" ,sour_h[0]); 
        // $display("init_buff_data : %h" ,init_buff_data); 
        // $display("block_data_tmp : %h" ,block_data_tmp);
        
        sour_k[0]  = 32'h5A827999;
        sour_k[1]  = 32'h6ED9EBA1;
        sour_k[2]  = 32'h8F1BBCDC;
        sour_k[3]  = 32'hCA62C1D6; 
           
        for(j=0; j<16; j=j+1)begin 
            i = (511-32*(j));
            sour_w[j] = block_data_tmp[i-:32 ];
        end
        
        for(j=0; j<16; j=j+1)begin 
            extend_w[j] = sour_w[j];
        end
        for(j=16; j<80; j=j+1)begin 
            extend_w[j] = (((extend_w[j-3])^(extend_w[j-8])^(extend_w[j-14])^(extend_w[j-16])));
			extend_w[j] = {extend_w[j][30:0],extend_w[j][31]};
        end
        
        data_a  =  sour_h[0] ;
        data_b  =  sour_h[1] ;
        data_c  =  sour_h[2] ;
        data_d  =  sour_h[3] ;
        data_e  =  sour_h[4] ;
        
        for(j=0; j<20; j=j+1)begin 
			
            data_tmp = {data_a[26:0],data_a[31:27]} + ((data_b & data_c)| ((~data_b )&data_d )) + data_e + extend_w[j] + sour_k[0] ;
            data_e = data_d;
            data_d = data_c;
            data_c = {data_b[1:0],data_b[31:2]};
            data_b = data_a  ;
            data_a = data_tmp;
        end            
        
        for(j=20; j<40; j=j+1)begin 
			data_tmp = {data_a[26:0],data_a[31:27]} + (data_b ^ data_c ^data_d) + extend_w[j]+ data_e + sour_k[1] ;
            data_e = data_d;
            data_d = data_c;
			data_c = {data_b[1:0],data_b[31:2]};
            data_b = data_a  ;
            data_a = data_tmp;
            
        end         
        
        for(j=40; j<60; j=j+1)begin 
            data_tmp = {data_a[26:0],data_a[31:27]} + ((data_b & data_c )| (data_c & data_d) | (data_b & data_d)) + data_e + extend_w[j] + sour_k[2] ;
            data_e = data_d;
            data_d = data_c;
			data_c = {data_b[1:0],data_b[31:2]};
            data_b = data_a  ;
            data_a = data_tmp;
            
        end  
        
        for(j=60; j<80; j=j+1)begin 
            // data_tmp = (data_a << 5) + (data_b ^ data_c ^data_d) + data_e + extend_w[j] + sour_k[3] ;
			data_tmp = {data_a[26:0],data_a[31:27]} + (data_b ^ data_c ^data_d) + data_e + extend_w[j] + sour_k[3] ;
            // #(`Clk_Period * 1);
            data_e = data_d;
            data_d = data_c;
            // data_c = data_b << 30;
			data_c = {data_b[1:0],data_b[31:2]};
            data_b = data_a  ;
            data_a = data_tmp;
            
            // #(`Clk_Period * 1);
        end               
        
        
        data_a = data_a  + sour_h[0] ;
        data_b = data_b  + sour_h[1] ;
        data_c = data_c  + sour_h[2] ;
        data_d = data_d  + sour_h[3] ;
        data_e = data_e  + sour_h[4] ;   
        
        result_data  = {data_a,data_b,data_c,data_d,data_e}; 
        // $display("result_data: %h" ,result_data);         
        
    end
  endtask // single_block_test
