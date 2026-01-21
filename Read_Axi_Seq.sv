`ifndef READ_AXI_SEQ_SVH
`define READ_AXI_SEQ_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "..//..//Packages//axi_packet.sv"
import axi_packet::*;

`include "Axi_item.sv"

class read_axi_seq  extends uvm_sequence #(axi_item);
  
  `uvm_object_utils(read_axi_seq)
    
  function new(string name = "read_axi_seq");
    super.new(name);
	  `uvm_info("read_axi_seq", "INSIDE NEW SEQUENCE CLASS ", UVM_LOW)
  endfunction
  
  axi_item #() tr ;
 
  int iter;
  task body();
    iter = $urandom_range(200,300);
    tr = axi_item#()::type_id::create("tr");
    repeat(iter)
    begin
      start_item(tr);
      tr.randomize() with  {
              //100% read
                wr dist {READ :/ 100};
            };
      tr.randarr();  
      finish_item(tr);
    end
  endtask  
  
endclass  


`endif





