`ifndef ERROR_AXI_SEQ_SVH
`define ERROR_AXI_SEQ_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "..//..//Packages//axi_packet.sv"
import axi_packet::*;

`include "Axi_item.sv"

class error_axi_seq  extends uvm_sequence #(axi_item);
  
  `uvm_object_utils(error_axi_seq)
    
  function new(string name = "error_axi_seq");
    super.new(name);
	  `uvm_info("error_axi_seq", "INSIDE NEW SEQUENCE CLASS ", UVM_LOW)
  endfunction
  
  axi_item #() tr ;
 
  int iter;
  task body();
    iter = $urandom_range(200,300);
    tr = axi_item#()::type_id::create("tr");
    repeat(iter)
    begin
      start_item(tr);
      /*
        To cover different invalid addresses senarios:
        valid address, boundary cross
        invalid address, no boundary cross
        invalid address and boundary cross

        we will randomly choose from these case according to the iteration number
      */
      if (iter % 3 == 0) begin
        tr.randomize() with  {
                //50:50 Read/Write
                  wr dist {OFF :/ 5, READ :/ 45, WRITE :/ 45};

                //Invalid boundary
                  ((awaddr & 12'hFFF) + (awlen + 1 << 2)) >= 12'hFFF;
                  ((araddr & 12'hFFF) + (arlen + 1 << 2)) >= 12'hFFF;

                //Valid address
                  (awaddr >> 2) < 1024;
                  (araddr >> 2) < 1024;
                  
                //50:50 handshake
                  handshake dist {VALID_FIRST :/ 50, READY_FIRST :/ 50};
              };
        end
        else if (iter % 3 == 1) begin
           tr.randomize() with {
                //50:50 Read/Write
                  wr dist {OFF :/ 5, READ :/ 45, WRITE :/ 45};

                //Valid boundary
                  ((awaddr & 12'hFFF) + (awlen + 1 << 2)) < 12'hFFF;
                  ((araddr & 12'hFFF) + (arlen + 1 << 2)) < 12'hFFF;
                
                  //invalid address
                  (awaddr >> 2) >= 1024;
                  (araddr >> 2) >= 1024;
                  
                //50:50 handshake
                  handshake dist {VALID_FIRST :/ 50, READY_FIRST :/ 50};
            };
        end
        else begin
           tr.randomize() with {
                //50:50 Read/Write
                  wr dist {OFF :/ 5, READ :/ 45, WRITE :/ 45};

                //Invalid boundary 
                  ((awaddr & 12'hFFF) + (awlen + 1 << 2)) >= 12'hFFF;
                  ((araddr & 12'hFFF) + (arlen + 1 << 2)) >= 12'hFFF;

                //Invalid address
                  (awaddr >> 2) >= 1024;
                  (araddr >> 2) >= 1024;
                  
                //50:50 handshake
                  handshake dist {VALID_FIRST :/ 50, READY_FIRST :/ 50};
            };
        end

      tr.randarr();  
      finish_item(tr);
    end
  endtask  
  
endclass  


`endif





