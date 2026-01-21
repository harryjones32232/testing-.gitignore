`ifndef RAND_MEM_SEQ_SVH
`define RAND_MEM_SEQ_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "..//..//Packages//axi_packet.sv"
import axi_packet::*;

`include "Mem_item.sv"

class rand_mem_seq  extends uvm_sequence #(mem_item);
  
  `uvm_object_utils(rand_mem_seq)
    
  function new(string name = "rand_mem_seq");
    super.new(name);
	  `uvm_info("rand_mem_seq", "INSIDE NEW SEQUENCE CLASS ", UVM_LOW)
  endfunction
  
  mem_item #() tr ;
 
  int iter;
  task body();
    iter = $urandom_range(500,700);
    repeat(iter)
    begin
      `uvm_do_with(
        tr, {wr dist {OFF :/ 5, DISABLE :/ 5,READ :/ 45, WRITE :/ 45};}
      )
    end
  endtask  
  
endclass  


`endif





