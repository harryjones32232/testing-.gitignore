`ifndef CORNER_MEM_SEQ_SVH
`define CORNER_MEM_SEQ_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "..//..//Packages//axi_packet.sv"
import axi_packet::*;

`include "Mem_item.sv"

class corner_mem_seq extends uvm_sequence #(mem_item);
  
  `uvm_object_utils(corner_mem_seq)
    
  function new(string name = "corner_mem_seq");
    super.new(name);
	  `uvm_info("corner_mem_seq", "INSIDE NEW SEQUENCE CLASS ", UVM_LOW)
  endfunction
  
  mem_item #() tr ;
 
  int iter;
  
  task body();
    iter = $urandom_range(50,100);
    repeat(iter)
    begin
      `uvm_do_with(
        tr, { 
                wr dist {OFF :/ 5, DISABLE :/ 5,READ :/ 45, WRITE :/ 45};
                addr inside {10'h000, 10'h3ff};
                wdata inside {32'h0000_0000, 32'hffff_ffff};
            }
      )
    end
  endtask  
  
endclass  


`endif





