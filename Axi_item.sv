`ifndef AXI_ITEM_SVH
`define AXI_ITEM_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "..//..//Packages//axi_packet.sv"
import axi_packet::*;

class axi_item #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 10,   
    parameter DEPTH = 1024
) extends uvm_sequence_item;
  
  //Axi inputs
  rand logic [15:0] awaddr;
  rand logic [15:0] araddr;
  rand logic [7:0] awlen;
  rand logic [2:0] awsize;
  rand logic [7:0] arlen;
  rand logic [2:0] arsize;

  //Modes (READ,WRITE,OFF)
  rand memory_en_e wr;

  //Handshake (Valid first, Ready first)
  rand handshake_e handshake;

  //Data to be sent to DUT
  logic [DATA_WIDTH - 1:0] wdata [];

  //Write output
  logic [1:0] bresp;

  //Array of read outputs
  r_out rout[$];
  
  //Factory Registration
  `uvm_object_utils_begin(axi_item)
    `uvm_field_int(awaddr, UVM_DEFAULT)
    `uvm_field_int(araddr, UVM_DEFAULT)
    `uvm_field_int(awlen, UVM_DEFAULT)
    `uvm_field_int(awsize, UVM_DEFAULT)
    `uvm_field_int(arlen, UVM_DEFAULT)
    `uvm_field_int(arsize, UVM_DEFAULT)
    `uvm_field_int(bresp, UVM_DEFAULT)
    `uvm_field_enum(memory_en_e, wr, UVM_DEFAULT)
    `uvm_field_enum(handshake_e, handshake, UVM_DEFAULT)
  `uvm_object_utils_end
  
  //Memory enable is not controlled by the slave (DISABLE does not apply)
  constraint no_dis 
  {
    wr inside {OFF,READ,WRITE};
  }

  constraint align_addr {
    awaddr % 4 == 0;
    araddr % 4 == 0;
  }
  
  //fixed size
  constraint size_c
  {
    arsize == 2;
    awsize == 2;
  }

  //burst length within range
  constraint burst_len_c
  {
    awlen inside {[0:15]};
    arlen inside {[0:15]};
  }

  function new(string name = "Axi_item");
    super.new(name);
  endfunction  

  function string in_conv2str();
    return $sformatf("Operation: %s,handshake: %s, araddr: %h, awaddr: %h, wdata: %p, awlen: %d, arlen: %d",  wr.name(), handshake.name(),araddr, awaddr,wdata,awlen, arlen);
  endfunction

  function string out_conv2str();
    return $sformatf("BRESP: %2b, Rout: %p", bresp, rout);
  endfunction
  
  function void randarr();
    wdata = new[awlen + 1];
    foreach (wdata[i])
      wdata[i] = $urandom_range(0, 2**DATA_WIDTH - 1);
  endfunction

endclass  

`endif



