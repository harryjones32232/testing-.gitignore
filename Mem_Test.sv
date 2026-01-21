`ifndef MEM_TEST_SVH
`define MEM_TEST_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "Mem_Env.sv"
`include "Rand_Mem_Seq.sv"
`include "Corner_Mem_Seq.sv"

`include "..//common_cfg.sv"

class mem_test extends uvm_test;
  
  `uvm_component_utils(mem_test)

  //Environment
  mem_env             mem_envt;

  //Sequences
  rand_mem_seq        rand_seq;
  corner_mem_seq      corner_seq;

  common_cfg m_cfg;
  
  function new(string name = "mem_test" , uvm_component parent);
    super.new(name,parent);
    uvm_config_db#(common_cfg)::set(null, "*", "m_cfg", m_cfg);
  endfunction  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //Create environment and sequences
    mem_envt = mem_env::type_id::create("mem_envt", this);
	  rand_seq = rand_mem_seq::type_id::create("rand_seq");
    corner_seq = corner_mem_seq::type_id::create("corner_seq");

    `uvm_info(get_type_name(), "test build phase", UVM_LOW)
  endfunction     

  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    //Raise objection
    phase.raise_objection(this);

    //Start sequences
    rand_seq.start(mem_envt.agt.sqr);
    corner_seq.start(mem_envt.agt.sqr);

    //Drop objection
    phase.drop_objection(this);
  endtask
endclass  


`endif

