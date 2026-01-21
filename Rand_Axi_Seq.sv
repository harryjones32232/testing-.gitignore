`ifndef RAND_AXI_SEQ_SVH
`define RAND_AXI_SEQ_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "..//..//Packages//axi_packet.sv"
import axi_packet::*;

`include "Axi_item.sv"

class rand_axi_seq  extends uvm_sequence #(axi_item);
  
  `uvm_object_utils(rand_axi_seq)
    
  function new(string name = "rand_axi_seq");
    super.new(name);
	  `uvm_info("rand_axi_seq", "INSIDE NEW SEQUENCE CLASS ", UVM_LOW)
  endfunction
  
  axi_item #() tr ;
 
  int iter;
  task body();
    iter = $urandom_range(50,100);
    tr = axi_item#()::type_id::create("tr");
    repeat(iter)
    begin
      start_item(tr);
      tr.randomize() with  {
              //50:50 Read/Write
                wr dist {OFF:/ 5, READ :/ 45, WRITE :/ 45};

              //50:50 handshake
                handshake dist {VALID_FIRST :/ 50, READY_FIRST :/ 50};
            };
      tr.randarr();  
      finish_item(tr);
    end
  endtask  
  
endclass  


`endif





