`ifndef  MEM_AGENT_SVH
`define  MEM_AGENT_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "Mem_Driver.sv"
`include "Mem_Sequencer.sv"
`include "Mem_Monitor.sv"

class mem_agent extends uvm_agent;
  
   mem_driver drv;
   mem_sequencer sqr;
   mem_monitor mon;
    
  `uvm_component_utils(mem_agent)

  function new(string name = "agent" , uvm_component parent);
    super.new(name,parent);
  endfunction  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv =  mem_driver::type_id::create("drv", this);
    sqr =  mem_sequencer::type_id::create("sqr", this);
    mon =  mem_monitor::type_id::create("mon",this);     
    
    `uvm_info(get_type_name(), "agent build phase", UVM_LOW)
  endfunction 
      
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(sqr.seq_item_export);
	  `uvm_info("my_agent", "INSIDE CONNECT PHASE", UVM_LOW)
  endfunction  
endclass  

`endif



