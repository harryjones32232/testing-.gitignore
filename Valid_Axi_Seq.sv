`ifndef VALID_AXI_SEQ_SVH
`define VALID_AXI_SEQ_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "..//..//Packages//axi_packet.sv"
import axi_packet::*;

`include "Axi_item.sv"

class valid_axi_seq  extends uvm_sequence #(axi_item);
  
  `uvm_object_utils(valid_axi_seq)
    
  function new(string name = "valid_axi_seq");
    super.new(name);
	  `uvm_info("valid_axi_seq", "INSIDE NEW SEQUENCE CLASS ", UVM_LOW)
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
                wr dist {OFF :/ 5, READ :/ 45, WRITE :/ 45};

              //Valid addresses
                ((awaddr & 12'hFFF) + (awlen + 1 << 2)) < 12'hFFF;
                ((araddr & 12'hFFF) + (arlen + 1 << 2)) < 12'hFFF;
                (awaddr >> 2) < 1024;
                (araddr >> 2) < 1024;
                
              //50:50 handshake
                handshake dist {VALID_FIRST :/ 50, READY_FIRST :/ 50};
            };
      tr.randarr();  
      finish_item(tr);
    end
  endtask  
  
endclass  


`endif





