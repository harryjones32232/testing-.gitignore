`ifndef MEM_COVERAGE_SVH
`define MEM_COVERAGE_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "Mem_item.sv"

class mem_coverage extends uvm_component;
  `uvm_component_utils(mem_coverage)

  uvm_analysis_export #(mem_item) analysis_export;
  uvm_tlm_analysis_fifo #(mem_item) fifo;

  covergroup cg with function sample(mem_item stim);
    mode_cp:         coverpoint stim.wr;
    addr_cp:        coverpoint stim.addr;
    wdata_cp:       coverpoint stim.wdata;
    corner_adresses: coverpoint stim.addr
    {
        bins addr_zeros = {10'h000};
        bins addr_ones = {10'h3ff};
        bins addr_zeros_to_ones = (10'h000 => 10'h3ff);
        bins addr_ones_to_zeros = (10'h3ff => 10'h000);
    }
    corner_write: coverpoint stim.wdata
    {
        bins wdata_zeros = {32'h000_0000};
        bins wdata_ones = {32'hffff_ffff};
        bins wdata_zeros_to_ones = (32'h000_0000 => 32'hffff_ffff);
        bins wdata_ones_to_zeros = (32'hffff_ffff => 132'h000_0000);
    }
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
      mem_item tr;
      forever begin
        fifo.get(tr);
        cg.sample(tr);
      end
    endtask

endclass

`endif



