`ifndef MEM_MONITOR_SVH
`define MEM_MONITOR_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "..//Interface.sv"
`include "Mem_item.sv"

`include "..//..//Packages//axi_packet.sv"
import axi_packet::*;

`include "..//common_cfg.sv"

class mem_monitor extends uvm_monitor;  
  `uvm_component_utils(mem_monitor)

  uvm_analysis_port #(mem_item) ap;
  virtual If vif;
  common_cfg m_cfg;
  integer mon;
  
  function new(string name = "mem_monitor" , uvm_component parent);
    super.new(name,parent);

    ap = new("ap",this);

    if (!uvm_config_db#(virtual If)::get(this, "*", "vif", vif))
      `uvm_fatal("DRV", "Could not get vif")

    if (!uvm_config_db#(common_cfg)::get(this, "*", "m_cfg", m_cfg))
      `uvm_fatal("DRV", "Could not get m_cfg")

     mon = $fopen("memory_input_log.txt","w");
  endfunction  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "monitor build phase", UVM_LOW)
  endfunction  

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      mem_item tr = mem_item#()::type_id::create("mem_item");
      tr.rdata = -1;

      //wait for input to be driven
      @(m_cfg.stimulus_sent_e);
      if (vif.ARESETn) //Collect tr operation
        tr.wr = {vif.mem_en,vif.mem_we};
      else 
        tr.wr = OFF;
      
      //collect inputs
      tr.wdata = vif.mem_wdata;
      tr.addr = vif.mem_addr;

      //wait for output to be collected
      @(m_cfg.out_receive_e);
      tr.rdata = vif.mem_rdata; //collect output

      //Write drived inputs and output
      $fwrite(mon,{tr.conv2str(),"\n"});
      $fwrite(mon,$sformatf("Output: %h\n",tr.rdata));

      //Send transaction to coverage and scoreboard
      ap.write(tr);
    end
  endtask
  
endclass  

`endif
