`ifndef WRITE_AXI_SEQ_SVH
`define WRITE_AXI_SEQ_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "..//..//Packages//axi_packet.sv"
import axi_packet::*;

`include "Axi_item.sv"

class write_axi_seq  extends uvm_sequence #(axi_item);
  
  `uvm_object_utils(write_axi_seq)
    
  function new(string name = "write_axi_seq");
    super.new(name);
	  `uvm_info("write_axi_seq", "INSIDE NEW SEQUENCE CLASS ", UVM_LOW)
  endfunction
  
  axi_item #() tr ;
 
  int iter;
  task body();
    iter = $urandom_range(300,400);
    tr = axi_item#()::type_id::create("tr");
    repeat(iter)
    begin
      start_item(tr);
      tr.randomize() with  {
              //100% write
                wr dist {WRITE :/ 100};
            };
      tr.randarr();  
      finish_item(tr);
    end
  endtask  
  
endclass  


`endif





