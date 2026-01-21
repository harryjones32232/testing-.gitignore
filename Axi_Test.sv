`ifndef AXI_TEST_SVH
`define AXI_TEST_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "Axi_Env.sv"
`include "Axi_item.sv"

`include "..//common_cfg.sv"

`include "Read_Axi_Seq.sv"
`include "Write_Axi_Seq.sv"
`include "Rand_Axi_Seq.sv"
`include "Valid_Axi_Seq.sv"
`include "Error_Axi_Seq.sv"

class axi_test extends uvm_test;
  
  `uvm_component_utils(axi_test)

  axi_env             env;
  rand_axi_seq  rand_seq;
  read_axi_seq  read_seq;
  write_axi_seq  write_seq;
  error_axi_seq  error_seq;
  valid_axi_seq  valid_seq;
  function new(string name = "axi_test" , uvm_component parent);
    super.new(name,parent);
  endfunction  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi_env::type_id::create("env", this);
    read_seq = read_axi_seq::type_id::create("read_seq");
    write_seq = write_axi_seq::type_id::create("write_seq");

    valid_seq = valid_axi_seq::type_id::create("valid_seq");
    error_seq = error_axi_seq::type_id::create("error_seq");

    rand_seq = rand_axi_seq::type_id::create("rand_seq");
    `uvm_info(get_type_name(), "test build phase", UVM_LOW)
  endfunction     

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);

    write_seq.start(env.agt.sqr);
    read_seq.start(env.agt.sqr);

    valid_seq.start(env.agt.sqr);
    error_seq.start(env.agt.sqr);

    rand_seq.start(env.agt.sqr);
    phase.drop_objection(this);
  endtask
endclass  

`endif

