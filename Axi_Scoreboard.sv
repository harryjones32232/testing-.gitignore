`ifndef AXI_SCOREBOARD_SVH
`define AXI_SCOREBOARD_SVH

`include "..//..//Packages//axi_packet.sv"
import axi_packet::*;

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "Axi_item.sv"
class axi_scoreboard extends uvm_scoreboard;
  //Factory Registeration
  `uvm_component_utils(axi_scoreboard)
  
   //TLM components
  uvm_analysis_export #(axi_item) analysis_export;
  uvm_tlm_analysis_fifo #(axi_item) fifo;

  //File pointer
  integer scb_mon;

  function new(string name = "scoreboard" , uvm_component parent);
    super.new(name,parent);
    //Create TLM components
    analysis_export = new("analysis_export",this);
    fifo = new("fifo",this);

    scb_mon = $fopen("axi_scoreboard.txt","w");
  endfunction  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "my scoreboard build phase", UVM_LOW)
  endfunction  

  function void connect_phase(uvm_phase phase);
    //Connect export to fifo
    analysis_export.connect(fifo.analysis_export);
  endfunction

  //array of expected values in the memory with the address as key
  logic [31:0] expected_mem [logic [9:0]];

  task run_phase(uvm_phase phase);
    axi_item in;
    forever begin
      //Get next item from fifo
      fifo.get(in);
      //Make the appropriate comparison
      if (in.wr == WRITE)
        write_compare(in.wdata,in.rout,in.bresp,in.awaddr, in.awlen);
      else if (in.wr == READ)
        read_compare(in.rout, in.araddr, in.arlen);
      else
        off_compare(in.rout,in.bresp,in.araddr);

      //clear rout array for next iteration
      if (in)
        in.rout.delete();
    end
  endtask

  extern function void read_compare(r_out rdata[$], logic [15:0] raddr, logic [7:0] len);

  extern function void write_compare(logic [31:0] wdata[], r_out rdata[$], logic [1:0] bresp ,logic [15:0] waddr, logic [7:0] len);

  extern function void off_compare(r_out rdata[$], logic[1:0] bresp, logic [15:0] addr);

  extern function bit check_addr_valid(logic [15:0] addr, logic [7:0] len);
  
endclass  
  
  function bit axi_scoreboard::check_addr_valid(logic [15:0] addr, logic [7:0] len);
    return (((addr & 12'hFFF) + (len + 1 << 2)) < 12'hFFF) && ((addr >> 2) < 1024);
  endfunction

 function void axi_scoreboard::off_compare(r_out rdata[$], logic[1:0] bresp, logic [15:0] addr);
    r_out expected = {0,0,0};

    //check if all outputs are 0
    if (rdata[0].rresp == 0 && rdata[0].rdata == 0 && rdata[0].rlast == 0 && bresp == 0)
      $fwrite(scb_mon, $sformatf("[OFF PASS] expected: %p, actual: %p\n", expected,rdata[0]));
    else
      $fwrite(scb_mon, $sformatf("[OFF FAIL] expected: %p, actual: %p\n", expected,rdata[0]));
      
  endfunction

  
  function void axi_scoreboard::read_compare(r_out rdata[$], logic [15:0] raddr, logic [7:0] len);
    r_out expected;
    foreach(rdata[i]) begin
      //Predicted response
      if (check_addr_valid(raddr + i*4, len)) begin
        expected.rresp = 2'b00;
        expected.rlast = i == len;

         //Expected read data
        if (expected_mem.exists((raddr + i*4)>>2))
          expected.rdata = expected_mem[(raddr + i*4)>>2];
        else
          expected.rdata = 0;
      end
      else begin
        expected.rresp = 2'b10;
        expected.rlast = 1;
        expected.rdata = 0;
      end

      if (rdata[i] == expected)
        $fwrite(scb_mon, $sformatf("[READ PASS] expected: %p, actual: %p\n", expected,rdata[i]));
      else
        $fwrite(scb_mon, $sformatf("[READ FAIL] expected: %p, actual: %p\n", expected,rdata[i]));
    end
  endfunction

  function void axi_scoreboard::write_compare(logic [31:0] wdata[], r_out rdata[$], logic [1:0] bresp ,logic [15:0] waddr, logic [7:0] len);
    r_out expected;
    logic [1:0] expected_bresp;

    foreach(wdata[i]) begin
      
      if (check_addr_valid(waddr + i*4, len)) begin
        //Predicted response
        expected_bresp = 2'b00;

        //predicted read values
        expected.rresp = 2'b00;
        expected.rlast = i == len;

        //writing to scb memory
        expected_mem[(waddr + i*4)>>2] = wdata[i];
        expected.rdata = expected_mem[(waddr + i*4)>>2];
      end
      else begin
        expected_bresp = 2'b10;
        expected.rresp = 2'b10;
        expected.rlast = 1;
        expected.rdata = 0;
      end

      if (rdata[i] == expected)
        $fwrite(scb_mon, $sformatf("[WRITE DATA PASS] expected: %p, actual: %p\n", expected,rdata[i]));
      else
        $fwrite(scb_mon, $sformatf("[WRITE DATA FAIL] expected: %p, actual: %p\n", expected,rdata[i]));
      
        if (rdata[i].rlast)
          break;
    end

    if (expected_bresp == bresp)
        $fwrite(scb_mon, $sformatf("[WRITE RESP PASS] expected: %2b, actual: %2b\n", expected_bresp, bresp));
    else
        $fwrite(scb_mon, $sformatf("[WRITE RESP FAIL] expected: %2b, actual: %2b\n", expected_bresp, bresp));
  endfunction

  
`endif



