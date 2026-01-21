`ifndef  AXI_AGENT_SVH
`define  AXI_AGENT_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "Axi_Driver.sv"
`include "Axi_Monitor.sv"
`include "Axi_Sequencer.sv"

class axi_agent extends uvm_agent;
  
   axi_driver drv;
   axi_sequencer sqr;
   axi_monitor mon;
    
  `uvm_component_utils(axi_agent)

  axi_item tr;
  function new(string name = "agent" , uvm_component parent);
    super.new(name,parent);
  endfunction  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv =  axi_driver::type_id::create("drv", this);
    sqr =  axi_sequencer::type_id::create("sqr", this);
    mon =  axi_monitor::type_id::create("mon",this);     
    
    `uvm_info(get_type_name(), "agent build phase", UVM_LOW)
  endfunction 
      
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(sqr.seq_item_export);
	  `uvm_info("my_agent", "INSIDE CONNECT PHASE", UVM_LOW)
  endfunction  
endclass  

`endif



