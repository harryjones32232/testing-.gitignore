`ifndef  MEM_SEQUENCER_SVH
`define MEM_SEQUENCER_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "Mem_item.sv"

class mem_sequencer extends uvm_sequencer #(mem_item);
  
  `uvm_component_utils(mem_sequencer)
  
  function new(string name = "mem_sequencer" , uvm_component parent);
    super.new(name,parent);
  endfunction  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "mem_sequencer build phase", UVM_LOW)
  endfunction  

endclass  

`endif

