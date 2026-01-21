`ifndef AXI_MONITOR_SVH
`define AXI_MONITOR_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "..//Interface.sv"
`include "Axi_item.sv"

`include "..//..//Packages//axi_packet.sv"
import axi_packet::*;

`include "..//common_cfg.sv"

class axi_monitor extends uvm_monitor;  
  `uvm_component_utils(axi_monitor)

  uvm_analysis_port #(axi_item) ap;

  virtual If vif;

  common_cfg m_cfg;

  integer mon;
  
  axi_item#() tr;
  function new(string name = "axi_monitor" , uvm_component parent);
    super.new(name,parent);

    ap = new("ap",this);

    if (!uvm_config_db#(virtual If)::get(this, "*", "vif", vif))
      `uvm_fatal("AXI_MON", "Could not get vif")

    if (!uvm_config_db#(common_cfg)::get(this, "*", "m_cfg", m_cfg))
      `uvm_fatal("AXI_MON", "Could not get m_cfg")

    mon = $fopen("axi_input_log.txt","w");
  endfunction  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "monitor build phase", UVM_LOW)
  endfunction  

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      @(m_cfg.stimulus_sent_e);
      if (!uvm_config_db#(axi_item)::get(this, "*", "tr", tr))
        `uvm_fatal("AXI_MON", "Could not get tr")

      $fwrite(mon,{tr.in_conv2str(), "\n\n"});
      `uvm_info(get_type_name(),tr.in_conv2str(),UVM_LOW)  
      
      if (tr.wr != READ)
        @(m_cfg.out_receive_e);
      
      $fwrite(mon,{tr.out_conv2str(), "\n\n"});
      `uvm_info(get_type_name(),tr.out_conv2str(),UVM_LOW)  

      ap.write(tr);
    end
  endtask
  
endclass  

`endif
