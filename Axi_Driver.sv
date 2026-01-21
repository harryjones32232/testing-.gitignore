`ifndef AXI_DRIVER_SVH
`define AXI_DRIVER_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "Axi_item.sv"
`include "..//common_cfg.sv"
`include"..//..//Packages//axi_assertions.sv"

class axi_driver extends uvm_driver #(axi_item);

  `uvm_component_utils(axi_driver)
  
  virtual If vif;
  
  common_cfg m_cfg;

  axi_item #() tr;
  
  function new(string name = "AXI_DRV" , uvm_component parent);
    super.new(name,parent);

    if (!uvm_config_db#(virtual If)::get(this, "*", "vif", vif))
      `uvm_fatal(get_type_name(), "Could not get vif")
    
    m_cfg = common_cfg::type_id::create("m_cfg");
    uvm_config_db#(common_cfg)::set(null, "*", "m_cfg", m_cfg);

    tr = axi_item #()::type_id::create("tr");
    
  endfunction  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "driver build phase", UVM_LOW)
  endfunction 
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info(get_type_name(),"inside Driver run phase",UVM_LOW)

    //Reset
    @(negedge vif.ACLK);
    vif.ARESETn = 0;
    @(negedge vif.ACLK);
    vif.ARESETn = 1;

    forever begin
      tr = axi_item #()::type_id::create("tr");
      tr.rout.delete();
      //get sequence item
      seq_item_port.get_next_item(tr);
      `uvm_info(get_type_name(),tr.in_conv2str(),UVM_LOW)

      //Add sequence item to the db for the monitor to read
      uvm_config_db#(axi_item)::set(null, "*", "tr", tr);

      //Clear all signals
      clear_all();

      //Drive
      drive_item();

      seq_item_port.item_done();
    end
  endtask

  //Clears all control signals
  extern task clear_all();

  //Drives the appropriate tasks for each sequence
  extern task drive_item();

  //Sends the appropriate signals for reading
  extern task drive_read();
  
  //Sends the appropriate signals for writing
  extern task drive_write();
  
  extern task drive_off();


endclass  

  task axi_driver::clear_all();
    @(negedge vif.ACLK);
    {vif.AWVALID,vif.WLAST, vif.WVALID, vif.BREADY,vif.ARVALID, vif.RREADY} = 6'd0;

  endtask

  task axi_driver::drive_item();
    //Drive cases 
    case (tr.wr)
      READ:
        drive_read();
      WRITE:
        drive_write();
      OFF:
        drive_off();
    endcase

    // uvm_config_db#(axi_item)::set(null, "*", "tr", tr);
    //trigger send event to monitor input
    ->m_cfg.stimulus_sent_e;

    //Drive reading for all cases
    if (tr.wr == WRITE) begin
      tr.araddr = tr.awaddr;
      tr.arlen = tr.awlen;
      tr.arsize = tr.awsize;
      drive_read();
    end
    
    //trigger receive event to monitor output
    ->m_cfg.out_receive_e;
      
  endtask

  task axi_driver::drive_read();
    begin
        int wait_valid;

        //========================== Address Reading =======================
        @(negedge vif.ACLK);
        vif.ARLEN   = tr.arlen;
        vif.ARSIZE  = tr.arsize;
        vif.ARADDR  = tr.araddr;

        //Set arvalid first
        if (tr.handshake == VALID_FIRST)
          vif.ARVALID = 1;
        
        //wait a few cycles for arready
        wait_valid = 10;
        while (~vif.ARREADY) begin
            @(negedge vif.ACLK);
            if (!(--wait_valid)) begin
                `uvm_error("AXI_DRV","ARREADY timeout")
                break;
            end
        end

        //Set arvalid after arready
        if (tr.handshake != VALID_FIRST)
          vif.ARVALID = 1;

        @(negedge vif.ACLK);
        vif.ARVALID = 0;
        //===================================================================     
        
        //========================== Reading Phase ==========================

        //Set ready before valid
        if (tr.handshake != VALID_FIRST) begin
          @(negedge vif.ACLK);
          vif.RREADY = 1;  
        end

        for (int i = 0; i < tr.arlen + 1; i++) begin
            if (tr.handshake != VALID_FIRST)
                vif.RREADY = 1;  

            //wait a few cycles for rvalid
            wait_valid = 10;
            while (~vif.RVALID) begin
              @(negedge vif.ACLK);
              if (!(--wait_valid)) begin
                  `uvm_error("AXI_DRV","RVALID timeout")
                  break;
              end
            end

            //set ready after valid
            if (tr.handshake == VALID_FIRST)
                vif.RREADY = 1;  

            @(negedge vif.ACLK);
            vif.RREADY = 0;   
            
            
            //collect output
            tr.rout.push_back('{rdata: vif.RDATA,
                                rresp: vif.RRESP,
                                rlast: vif.RLAST});   
            // 
            if (vif.RLAST == 1)
              break;

            @(negedge vif.ACLK);
        end

         `uvm_info(get_type_name(),tr.out_conv2str(),UVM_LOW)        
            
        //===================================================================
      end
  endtask

  
  task axi_driver::drive_write();
        int wait_valid;

        //========================== Address Reading =======================
        @(negedge vif.ACLK);
        vif.AWLEN   = tr.awlen;
        vif.AWSIZE  = tr.awsize;
        vif.AWADDR  = tr.awaddr;
        vif.WVALID = 0;

        //Control the order of the handshake according to tr.handshake enum value
        if (tr.handshake == VALID_FIRST)
          vif.AWVALID = 1;

        //Wait a few cycles for AWREADY
        wait_valid = 10;
        while (~vif.AWREADY) begin
            @(negedge vif.ACLK);
            if (!(--wait_valid)) begin
                `uvm_error("AXI_DRV","AWREADY timeout");
                break;
            end
        end
        
        //if the hanshake is not valid first, wait for AWREADY, then set valid
        if (tr.handshake != VALID_FIRST)
          vif.AWVALID = 1;

        
        @(negedge vif.ACLK);
        vif.AWVALID = 0;

        //===================================================================

        //========================== Writing phase =========================
        for (int i = 0; i < tr.awlen + 1; i++) begin
            @(negedge vif.ACLK);
            vif.WDATA  = tr.wdata[i];
            vif.WLAST  = (i == tr.awlen);
            
            if (tr.handshake == VALID_FIRST)
              vif.WVALID = 1;

            wait_valid = 10;
            while (~vif.WREADY) begin
                @(negedge vif.ACLK);
                if (!(--wait_valid)) begin
                    `uvm_error("AXI_DRV","WREADY timeout");
                    break;
                end
            end

            if (tr.handshake != VALID_FIRST)
              vif.WVALID = 1;
            
           @(negedge vif.ACLK);
           vif.WVALID = 0;
        end
        //===================================================================
    
        //=========================== Response Phase =========================
        
        if (tr.handshake == VALID_FIRST)
            vif.BREADY = 1;
            
        while (~vif.BVALID) begin
                @(negedge vif.ACLK);
                if (!(--wait_valid)) begin
                    `uvm_error("AXI_DRV","BVALID timeout");
                    break;
                end
        end

        tr.bresp = vif.BRESP;

        @(negedge vif.ACLK); 
         if (tr.handshake != VALID_FIRST) 
            vif.BREADY = 1;

        //===================================================================
  endtask

  
  task axi_driver::drive_off();
     @(negedge vif.ACLK)
      vif.ARESETn = 0;

      @(negedge vif.ACLK)
      tr.bresp = vif.BRESP;
      tr.rout.push_back('{rdata: vif.RDATA,
                                rresp: vif.RRESP,
                                rlast: vif.RLAST});  

      @(negedge vif.ACLK)
      vif.ARESETn = 1;
  endtask
  
`endif

