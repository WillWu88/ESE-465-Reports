`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2022 01:20:21 PM
// Design Name: 
// Module Name: Axi4LiteFilter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Axi4LiteSPI #
    (parameter C_S_AXI_ADDR_WIDTH = 9, C_S_AXI_DATA_WIDTH = 32)
    (
        // Axi4Lite Bus
        input       S_AXI_ACLK,
        input       S_AXI_ARESETN,
        input       [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
        input       S_AXI_AWVALID,
        output      S_AXI_AWREADY,
        input       [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
        input       [3:0] S_AXI_WSTRB,
        input       S_AXI_WVALID,
        output      S_AXI_WREADY,
        output      [1:0] S_AXI_BRESP,
        output      S_AXI_BVALID,
        input       S_AXI_BREADY,
        input       [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
        input       S_AXI_ARVALID,
        output      S_AXI_ARREADY,
        output      [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
        output      [1:0] S_AXI_RRESP,
        output      S_AXI_RVALID,
        input       S_AXI_RREADY,
        
        // PMOD I/O
        output reg      SCK,
        output reg      SDI,
        output reg      CONV_CS,
        input           SDO
    );
    wire    [C_S_AXI_ADDR_WIDTH-1:0] wrAddrS;
    wire    [C_S_AXI_DATA_WIDTH-1:0] wrDataS;
    wire                             wrS;
    wire    [C_S_AXI_ADDR_WIDTH-1:0] rdAddrS;
    reg     [C_S_AXI_DATA_WIDTH-1:0] rdDataS;
    wire                             rdS;
    
    // ADC/DAC pmod output
    
    // SDO, SDI and Buffer Storage
    reg [15:0] sdo_ramQ,sdo_bufferQ, sdo_ramInt, sdo_bufferInt;
    reg [C_S_AXI_DATA_WIDTH-1:0] sdi_ramQ, sdi_bufferQ, sdi_ramInt, sdi_bufferInt;
    
    // SPI configuration storage: 
    reg [14:0] clock_per_sampleQ, clock_per_sampleInt;
    reg [4:0]  cycle_maxQ, cycle_maxInt; 
    
    // timing counters
    reg [14:0] time_countQ, time_countInt; // overall timer
    reg [1:0]  sck_countQ, sck_countInt; // shift clock counter
    reg [4:0]  cycle_countQ, cycle_countInt; // cycle count timer, for bit transfer and capture
    
    // valid bit flip flop
    // keep the valid bit low when we just write to SDI
    reg vbit_switchInt, vbit_switchQ;
    // only write channel & data during conversion
    //reg wbit_switchInt, wbit_switchQ;
   
    
    // reg address
    parameter sdi_addr = 'b00000000, sdo_addr = 'b00000100, cycle_max_addr = 'b00001000, spc_addr = 'b00001100;
    parameter IDLE_S = 0, TRANS_S = 1, CAP_S = 2;
    reg [3:0] nextState_s, currentState_s;
    
    // Axi4Lite Supporter instantiation
    Axi4LiteSupporter #(.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) Axi4LiteSupporter1 (
        // Simple Bus
        .wrAddr(wrAddrS),                    // output   [C_S_AXI_ADDR_WIDTH-1:0]
        .wrData(wrDataS),                    // output   [C_S_AXI_DATA_WIDTH-1:0]
        .wr(wrS),                            // output
        .rdAddr(rdAddrS),                    // output   [C_S_AXI_ADDR_WIDTH-1:0]
        .rdData(rdDataS),                    // input    [C_S_AXI_ADDR_WIDTH-1:0]
        .rd(rdS),                            // output   
        // Axi4Lite Bus
        .S_AXI_ACLK(S_AXI_ACLK),            // input
        .S_AXI_ARESETN(S_AXI_ARESETN),      // input
        .S_AXI_AWADDR(S_AXI_AWADDR),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
        .S_AXI_AWVALID(S_AXI_AWVALID),      // input
        .S_AXI_AWREADY(S_AXI_AWREADY),      // output
        .S_AXI_WDATA(S_AXI_WDATA),          // input    [C_S_AXI_DATA_WIDTH-1:0]
        .S_AXI_WSTRB(S_AXI_WSTRB),          // input    [3:0]
        .S_AXI_WVALID(S_AXI_WVALID),        // input
        .S_AXI_WREADY(S_AXI_WREADY),        // output        
        .S_AXI_BRESP(S_AXI_BRESP),          // output   [1:0]
        .S_AXI_BVALID(S_AXI_BVALID),        // output
        .S_AXI_BREADY(S_AXI_BREADY),        // input
        .S_AXI_ARADDR(S_AXI_ARADDR),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
        .S_AXI_ARVALID(S_AXI_ARVALID),      // input
        .S_AXI_ARREADY(S_AXI_ARREADY),      // output
        .S_AXI_RDATA(S_AXI_RDATA),          // output   [C_S_AXI_DATA_WIDTH-1:0]
        .S_AXI_RRESP(S_AXI_RRESP),          // output   [1:0]
        .S_AXI_RVALID(S_AXI_RVALID),        // output    
        .S_AXI_RREADY(S_AXI_RREADY)         // input
    ) ;
    
    //combinational logic
    always @ * begin
        sdo_ramInt = sdo_ramQ;
        sdo_bufferInt = sdo_bufferQ;
        sdi_ramInt = sdi_ramQ;
        sdi_bufferInt = sdi_bufferQ;
        clock_per_sampleInt = clock_per_sampleQ;
        cycle_maxInt = cycle_maxQ;
        time_countInt = time_countQ;
        sck_countInt = sck_countQ;
        cycle_countInt = cycle_countQ;
        vbit_switchInt = vbit_switchQ;
        
        
        nextState_s = currentState_s;
        SCK = 0;
        SDI = 0;
        CONV_CS = 0;
        rdDataS[31] = 0;
        
        /*
        if ( rdS ) begin
            if (rdAddrS == sdo_addr) begin
                rdDataS[30:0] = sdo_ramQ;
            end
        end*/
        
        if ( wrS ) begin
            if (wrAddrS == sdi_addr) begin
                sdi_ramInt = wrDataS;
            end else if (wrAddrS == cycle_max_addr) begin
                cycle_maxInt = wrDataS;
            end else if (wrAddrS == spc_addr) begin
                clock_per_sampleInt = wrDataS;
            end
        end
        
        case ( currentState_s )
            IDLE_S: begin
                CONV_CS = 1;
                
                time_countInt = time_countQ + 1;
                
                
                if ( rdS && vbit_switchQ ) begin
                    rdDataS[31] = 1;
                    rdDataS[30:0] = sdo_ramQ;
                    vbit_switchInt = 0;
                end
                /*
                if ( wrS ) begin
                    vbit_switchInt = 0;
                    rdDataS[31] = 0;
                end*/
                
                if ( time_countQ == clock_per_sampleQ -1 ) begin // careful when writing the C program
                    nextState_s = TRANS_S;
                    time_countInt = 0;
                    cycle_countInt = 0;
                end
            end
            TRANS_S: begin
                rdDataS[31] = 0;
                //outputs
                CONV_CS = 0;
                SCK = 0;
                
                // write to SDI
                if (cycle_countQ <= 23) begin
                    SDI = sdi_bufferQ[23 - cycle_countQ]; // first bit out is the msb, remember in c code!
                end else begin
                    SDI = 0; // counter out-of-bound issue
                end
                // branch logic
                sck_countInt = sck_countQ + 1;
                time_countInt = time_countQ + 1;
                
                if (cycle_countQ >= cycle_maxQ) begin
                    nextState_s = IDLE_S;
                    // update buffers
                    sdo_ramInt = sdo_bufferQ;
                    sdi_bufferInt = sdi_ramQ;
                end
                if (sck_countQ == 2) begin
                    nextState_s = CAP_S;
                    sck_countInt = 0;
                    vbit_switchInt = 1;
                end
            end
            CAP_S: begin
                // output
                SCK = 1;
                SDI = sdi_bufferQ[23 - cycle_countQ]; // first bit out is the msb, remember in c code!
                // timing
                sck_countInt = sck_countQ + 1;
                time_countInt = time_countQ + 1;
                
                // read & branch logic
                if ( sck_countQ == 2 ) begin
                    sdo_bufferInt[cycle_maxQ - cycle_countQ - 1] = SDO;
                    nextState_s = TRANS_S;
                    sck_countInt = 0;
                    cycle_countInt = cycle_countQ + 1;
                    
                end
            end
            default:
                nextState_s = IDLE_S;
        endcase
    end
    // sequential logic
    always @ (posedge S_AXI_ACLK) begin
        if ( !S_AXI_ARESETN ) begin
            sdo_ramQ <= 0;
            sdo_bufferQ <= 0;
            sdi_ramQ <= 0;
            sdi_bufferQ <= 0;
            clock_per_sampleQ <= 0;
            cycle_maxQ <= 0;
            time_countQ <= 0;
            sck_countQ <= 0;
            cycle_countQ <= 0;
            vbit_switchQ <= 0;
            
            currentState_s <= IDLE_S;
        end else begin
            sdo_ramQ <= sdo_ramInt;
            sdo_bufferQ <= sdo_bufferInt;
            sdi_ramQ <= sdi_ramInt;
            sdi_bufferQ <= sdi_bufferInt;
            clock_per_sampleQ <= clock_per_sampleInt;
            cycle_maxQ <= cycle_maxInt;
            time_countQ <= time_countInt;
            sck_countQ <= sck_countInt;
            cycle_countQ <= cycle_countInt;
            vbit_switchQ <= vbit_switchInt;
            
            currentState_s <= nextState_s;
        end
    end
    
    //assign bit_reg0_0 = filterQ[0];
    //assign bit_reg0_1 = filterQ[1];

endmodule
