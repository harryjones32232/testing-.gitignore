`ifndef AXI_COVERAGE_SVH
`define AXI_COVERAGE_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "Axi_item.sv"

class axi_coverage extends uvm_component;
  `uvm_component_utils(axi_coverage)

  uvm_analysis_export #(axi_item) analysis_export;
  uvm_tlm_analysis_fifo #(axi_item) fifo;

  covergroup cg with function sample(axi_item stim);
  //---------------write coverage----------------
    awaddr: coverpoint stim.awaddr {option.weight = 0;}

    awlen: coverpoint stim.awlen {
      bins burst_len[] = {[0:15]};
      option.weight = 0;
    }
    //-----------read coverage-----------------
    araddr: coverpoint stim.araddr {option.weight = 0;}
    
    arlen: coverpoint stim.arlen {
        bins burst_len[] = {[0:15]};
        option.weight = 0;
    }
    //--------------common part-----------------
    Read: coverpoint stim.wr {
      bins read = {READ};
    }

    Write: coverpoint stim.wr {
      bins write = {WRITE};
    }

    Off: coverpoint stim.wr {
      bins Off = {OFF};
    }
    Handshake: coverpoint stim.handshake {
      bins valid_first = {VALID_FIRST};
      bins read_first = {READY_FIRST};
    }
   
    //---------------crossing----------------
    read_addr: cross Read, araddr;
    write_addr: cross Write, awaddr;
    
    read_len: cross Read, arlen;
    write_len: cross Write, awlen;

    handshake_read: cross Read, Handshake;
    handshake_write: cross Write, Handshake;
  endgroup
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
    analysis_export = new("analysis_export",this);
    fifo = new("fifo",this);
    cg = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    analysis_export.connect(fifo.analysis_export);
  endfunction

    task run_phase(uvm_phase phase);
      axi_item tr;
      forever begin
        fifo.get(tr);
        cg.sample(tr);
      end
    endtask

endclass

`endif



