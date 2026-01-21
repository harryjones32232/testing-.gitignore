`ifndef MEM_SCOREBOARD_SVH
`define MEM_SCOREBOARD_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "Mem_Scoreboard.sv"

`include "Mem_item.sv"
class mem_scoreboard extends uvm_scoreboard;
  //Factory Registeration
  `uvm_component_utils(mem_scoreboard)
  
//TLM components
  uvm_analysis_export #(mem_item) analysis_export;
  uvm_tlm_analysis_fifo #(mem_item) fifo;

  //File pointer
  integer scb_mon;

  function new(string name = "mem scoreboard" , uvm_component parent);
    super.new(name,parent);
    //Create TLM components
    analysis_export = new("analysis_export",this);
    fifo = new("fifo",this);

    //Open file
    scb_mon = $fopen("memory_scoreboard.txt","w");
  endfunction  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "mem scoreboard build phase", UVM_LOW)
  endfunction  

  function void connect_phase(uvm_phase phase);
    //Connect export to fifo
    analysis_export.connect(fifo.analysis_export);
  endfunction
  
  //array of expected values in the memory with the address as key
  logic [31:0] expected_mem [logic [9:0]];

  task run_phase(uvm_phase phase);
    mem_item #()tr;
    forever begin
      fifo.get(tr);
      compare(tr.wr, tr.wdata, tr.rdata, tr.addr,  tr.addr);
    end
    
  endtask

  function void compare(memory_en_e op, logic [31:0] wdata, logic [31:0] rdata, logic [9:0] raddr , logic [9:0] waddr);
    //If the operation is write, write the data to our assoc array
      if (op == WRITE)
        expected_mem[waddr] = wdata;
        //If the address was previously written to
        if (expected_mem.exists(waddr))
        begin
          if (rdata == expected_mem[raddr])  //check if rdata matches that value in the assoc array
          begin
            $fwrite(scb_mon, $sformatf("[Pass], expected: %h, actual: %h\n",expected_mem[raddr], rdata));
            `uvm_info("SCB","[Pass]",UVM_LOW)
          end
          else
          begin 
            $fwrite(scb_mon, $sformatf("[Fail], expected: %h, actual: %h\n",expected_mem[raddr], rdata));
            `uvm_error("SCB","[Fail], address has different value than expected")
          end
        end 
        //otherwise, we expect the value in the given address to be zero
        else if (rdata == 0)
        begin
            $fwrite(scb_mon, $sformatf("[Pass], expected: %h, actual: %h\n", 32'd0, rdata));
            `uvm_info("SCB","[Pass]",UVM_LOW)
        end
        else
        begin   
            $fwrite(scb_mon, $sformatf("[Fail], expected: %h, actual: %h", 32'd0, rdata));
            `uvm_error("SCB",$sformatf("[Fail], read value should be zero, read value: %h", rdata))
        end
  endfunction
endclass  

`endif



