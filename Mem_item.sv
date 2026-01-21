`ifndef MEM_ITEM_SVH
`define MEM_ITEM_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "..//..//Packages//axi_packet.sv"
import axi_packet::*;

class mem_item #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 10,   
    parameter DEPTH = 1024
 ) extends uvm_sequence_item;
  
  rand logic [ADDR_WIDTH - 1:0] addr;
  rand logic [DATA_WIDTH - 1:0] wdata;
  rand memory_en_e wr;
  logic [DATA_WIDTH - 1:0] rdata;

  `uvm_object_utils_begin(mem_item)
  `uvm_field_int(addr, UVM_DEFAULT)
  `uvm_field_int(wdata, UVM_DEFAULT)
  `uvm_field_enum(memory_en_e, wr, UVM_DEFAULT)
  `uvm_field_int(rdata, UVM_DEFAULT)
  `uvm_object_utils_end
  
  //Simultanous read/write is not supported in memory
  constraint wr_c
  {
    wr inside {OFF,DISABLE,READ,WRITE};
  }
  
  function new(string name = "transaction");
    super.new(name);
  endfunction  

  function string conv2str();
    return $sformatf("Operation: %s, address: %h, wdata: %h",  wr.name(), addr, wdata);
  endfunction
  
endclass  

`endif



