`ifndef MEM_DRIVER_SVH
`define MEM_DRIVER_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "Mem_item.sv"
`include "..//common_cfg.sv"

class mem_driver extends uvm_driver #(mem_item);

  `uvm_component_utils(mem_driver)
  
  virtual If vif;
  
  common_cfg m_cfg;

  function new(string name = "driver" , uvm_component parent);
    super.new(name,parent);

    if (!uvm_config_db#(virtual If)::get(this, "*", "vif", vif))
      `uvm_fatal("DRV", "Could not get vif")
    
    m_cfg = common_cfg::type_id::create("m_cfg");
    uvm_config_db#(common_cfg)::set(null, "*", "m_cfg", m_cfg);
  endfunction  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "driver build phase", UVM_LOW)
  endfunction 
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("Driver","inside Driver run phase",UVM_LOW)

    forever begin
      mem_item #() tr;
      seq_item_port.get_next_item(tr);
      drive_item(tr);
      seq_item_port.item_done();
    end
  endtask

  extern task drive_item(mem_item tr);
endclass  

  task mem_driver::drive_item(mem_item tr);
    //Drive cases 
    @(negedge vif.ACLK);
    case (tr.wr)
      READ:
      begin
        vif.ARESETn = 1;
        vif.mem_en = 1;
        vif.mem_we = 0;
      end
      WRITE:
      begin
        vif.ARESETn = 1;
        vif.mem_en = 1;
        vif.mem_we = 1;
      end
      DISABLE:
      begin
        vif.ARESETn = 1;
        vif.mem_en = 0;
        vif.mem_we = 1;
      end
      OFF:
      begin
        vif.ARESETn = 0;
        vif.mem_en = 1;
        vif.mem_we = 1;
      end
    endcase
    vif.mem_addr = tr.addr;
    vif.mem_wdata = tr.wdata;

    //trigger send event to monitor input
    ->m_cfg.stimulus_sent_e;

    //Drive reading for all cases
    if (tr.wr != READ) begin
     @(negedge vif.ACLK);
      vif.ARESETn = 1;
      vif.mem_en = 1;
      vif.mem_we = 0;
      vif.mem_addr = tr.addr;
      vif.mem_wdata = tr.wdata;
    end

    //Collect rdata
    @(negedge vif.ACLK);
      tr.rdata = vif.mem_rdata;

    //trigger receive event to monitor output
    ->m_cfg.out_receive_e;
  endtask
`endif

