`ifndef AXI_ENV_SVH
`define AXI_ENV_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "Axi_Agent.sv"
`include "Axi_Scoreboard.sv"
`include "Axi_Coverage.sv"


class axi_env extends uvm_env;

  `uvm_component_utils(axi_env)
  
  axi_agent      agt;
  axi_scoreboard            scb;
  axi_coverage              cov;

  function new(string name = "env" , uvm_component parent);
    super.new(name,parent);
  endfunction  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt   = axi_agent::type_id::create("agt", this);
    scb   = axi_scoreboard::type_id::create("scb", this);
    cov   = axi_coverage::type_id::create("cov", this); 
   `uvm_info(get_type_name(), "environment build phase", UVM_MEDIUM)
  endfunction    

  function void connect_phase(uvm_phase phase);
    agt.mon.ap.connect(scb.analysis_export);
    agt.mon.ap.connect(cov.analysis_export);
  endfunction
endclass  

`endif


