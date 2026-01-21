`ifndef  AXI_SEQUENCER_SVH
`define AXI_SEQUENCER_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "Axi_item.sv"

class axi_sequencer extends uvm_sequencer #(axi_item);
  
  `uvm_component_utils(axi_sequencer)
  
  function new(string name = "sequencer" , uvm_component parent);
    super.new(name,parent);
  endfunction  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "sequencer build phase", UVM_LOW)
  endfunction  

endclass  

`endif

