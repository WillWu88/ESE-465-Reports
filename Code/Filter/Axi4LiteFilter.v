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


module Axi4LiteFilter #
    (parameter C_S_AXI_ADDR_WIDTH = 6, C_S_AXI_DATA_WIDTH = 32)
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
        output      bit_reg0_0,
        output      bit_reg0_1
    );
    wire    [C_S_AXI_ADDR_WIDTH-1:0] wrAddrS;
    wire    [C_S_AXI_DATA_WIDTH-1:0] wrDataS;
    wire                             wrS;
    wire    [C_S_AXI_ADDR_WIDTH-1:0] rdAddrS;
    reg     [C_S_AXI_DATA_WIDTH-1:0] rdDataS;
    wire                             rdS;
    
    // flip flops for write, s_write, f_read and s_read counter
    reg [C_S_AXI_DATA_WIDTH-1:0] filterQ;
    reg [C_S_AXI_DATA_WIDTH-1:0] s_writeQ;
    reg [C_S_AXI_DATA_WIDTH-1:0] s_readQ;
    reg signed [C_S_AXI_DATA_WIDTH-1:0] result_int, resultQ;
    
    //flip flop to hold result for the supporter to read
    
    reg [C_S_AXI_DATA_WIDTH-1:0] filter_int, s_write_int, s_read_int;
    
    //memory initialization
    reg signed [15:0] filter_ram[60:0];
    reg signed [15:0] sample_ram[60:0];
    
    // marker register flip flop (for hardware timing)
    reg [C_S_AXI_DATA_WIDTH-1:0] marker_regQ, marker_regInt;
    // reg address
    parameter filterAddr = 'b00000000, sampleAddr = 'b00000100, markerRegAddr = 'b0001100;
    parameter IDLE_S = 0, ACCU_S = 1, ROUND_S = 2;
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
        s_read_int = s_readQ;
        filter_int = filterQ;
        s_write_int = s_writeQ;
        nextState_s = currentState_s;
        result_int = resultQ;
        rdDataS = 0;
        marker_regInt = marker_regQ;
        
        
        if ( wrS ) begin
            if ( wrAddrS == markerRegAddr ) begin
                marker_regInt = wrDataS;
            end
        end
        
        
        case (currentState_s)
            IDLE_S: begin
                if ( rdS ) begin
                    if (rdAddrS == sampleAddr) begin
                        nextState_s = ACCU_S;
                        s_read_int = s_writeQ - 1; //come back if initialization wasn't right
                        if (s_writeQ == 0) begin
                            s_read_int = 60;
                        end
                    end
                end
            end
            ACCU_S: begin
                result_int = filter_ram[filterQ] * sample_ram[s_readQ] + resultQ;
                filter_int = filterQ + 1;
                if (s_readQ == 0) begin
                    s_read_int = 60;
                end else begin
                    s_read_int = s_readQ -1;
                end
                if (filterQ == 60) begin
                    filter_int = 0;
                    nextState_s = ROUND_S;
                end
            end
            ROUND_S: begin
                rdDataS[30:0] = ((resultQ + 16384) & 'b01111111111111111000000000000000) >> 15;
                rdDataS[31] = 1;
                // truncate top bit with an bitwise and, round by half of bit 14, shift right by 15 bits, and set bit 31 to 1
                if ( rdS ) begin
                    nextState_s = IDLE_S;
                    result_int = 0;
                end
            end
            default: begin
                nextState_s = IDLE_S;
            end
        endcase
    end
    // sequential logic
    always @ (posedge S_AXI_ACLK) begin
        if ( !S_AXI_ARESETN ) begin
        // reset 3 registers to 0
            filterQ <= 0 ;
            s_writeQ <= 0 ;
            s_readQ <= 0 ;
            resultQ <= 0 ;
            currentState_s = IDLE_S;
            marker_regQ <= 0;
        end else begin
            filterQ <= filter_int ;
            s_writeQ <= s_write_int ;
            s_readQ <= s_read_int ;
            resultQ <= result_int ;
            currentState_s = nextState_s;
            marker_regQ <= marker_regInt;
        end
        if (wrS) begin
            if (wrAddrS == filterAddr) begin
                filter_ram[filter_int] <= wrDataS;
                filterQ <= filter_int + 1;
                if (filter_int == 60) begin
                    filterQ <= 0;
                end
            end
            if (wrAddrS == sampleAddr) begin
                sample_ram[s_write_int] <= wrDataS;
                s_writeQ <= s_write_int + 1;
                if (s_write_int == 60) begin
                    s_writeQ <= 0;
                end
            end
        end
    end
    assign bit_reg0_0 = marker_regQ[0];
    assign bit_reg0_1 = marker_regQ[1];
    //assign bit_reg0_0 = filterQ[0];
    //assign bit_reg0_1 = filterQ[1];

endmodule
