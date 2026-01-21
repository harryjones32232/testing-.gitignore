`include "Interface.sv"

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "Memory_Test//Mem_Test.sv"
`include "Axi_Test//Axi_Test.sv"

module top;
  
  If vif();

  axi4_memory DUT
  (
        .clk(vif.ACLK),
        .rst_n(vif.ARESETn),
        .mem_en(vif.mem_en),
        .mem_we(vif.mem_we),
        .mem_addr(vif.mem_addr),
        .mem_wdata(vif.mem_wdata),
        .mem_rdata(vif.mem_rdata)
  );

  axi4 axi_DUT (vif.axi);
  
  axi_assertions_module assertions(vif.axi);

  initial begin
    vif.ACLK = 0;
    forever begin
      #2ns vif.ACLK = ~vif.ACLK; 
    end  
  end
  
  initial begin
    vif.ARESETn = 1;
    #2ns;
    vif.ARESETn = 0;
  end  
  
  initial begin
    uvm_config_db#(virtual If)::set(null, "*", "vif", vif);
    run_test("axi_test");
  end
  
endmodule  




