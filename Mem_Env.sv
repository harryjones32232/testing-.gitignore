`ifndef MEM_ENV_SVH
`define MEM_ENV_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "Mem_Agent.sv"
`include "Mem_Scoreboard.sv"
`include "Mem_Coverage.sv"


class mem_env extends uvm_env;

  `uvm_component_utils(mem_env)
  
  mem_agent      agt;
  mem_scoreboard            scb;
  mem_coverage              cov;

  function new(string name = "env" , uvm_component parent);
    super.new(name,parent);
  endfunction  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt   = mem_agent::type_id::create("agt", this);
    scb   = mem_scoreboard::type_id::create("scb", this);
    cov   = mem_coverage::type_id::create("cov", this); 
   `uvm_info(get_type_name(), "environment build phase", UVM_MEDIUM)
  endfunction    

  function void connect_phase(uvm_phase phase);
    agt.mon.ap.connect(scb.analysis_export);
    agt.mon.ap.connect(cov.analysis_export);
  endfunction
endclass  

`endif


