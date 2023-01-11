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
        input       S_AXI_RREADY
    );
    wire    [C_S_AXI_ADDR_WIDTH-1:0] wrAddrS;
    wire    [C_S_AXI_DATA_WIDTH-1:0] wrDataS;
    wire                             wrS;
    wire    [C_S_AXI_ADDR_WIDTH-1:0] rdAddrS;
    reg     [C_S_AXI_DATA_WIDTH-1:0] rdDataS;
    wire                             rdS;
    
    // flip flops for write, s_write, and s_read counter
    reg [C_S_AXI_DATA_WIDTH-1:0] filterQ;
    reg [C_S_AXI_DATA_WIDTH-1:0] s_writeQ;
    reg [C_S_AXI_DATA_WIDTH-1:0] s_readQ;
    reg [C_S_AXI_DATA_WIDTH-1:0] filter_int, s_write_int, s_read_int;
    
    //flip flop to hold result for the supporter to read
    reg signed [C_S_AXI_DATA_WIDTH-1:0] result_c1Int[12:0];
    reg signed [C_S_AXI_DATA_WIDTH-1:0] result_c1Q[12:0];
    
    reg signed [C_S_AXI_DATA_WIDTH-1:0] result_c2Int[12:0];
    reg signed [C_S_AXI_DATA_WIDTH-1:0] result_c2Q[12:0];
    integer i; // index for parallel flip flop
    
    reg [C_S_AXI_DATA_WIDTH-1:0] sample_addr;
    reg [1:0] samplewr;
    wire signed [15:0] sample_out[1:0];
    genvar j;
    //sample memory initialization
    parameter COEFF_LENGTH = 16, NUM_TAPS = 279, BAND_COUNT = 13, CHANNEL_COUNT = 2;
    generate
        for ( j = 0; j < CHANNEL_COUNT; j = j+1) begin
            async_ram #(.RAM_HEIGHT(NUM_TAPS), .RAM_WIDTH(COEFF_LENGTH)) sampleRAM (
                .clk(S_AXI_ACLK),
                .we(samplewr[j]),
                .a(sample_addr),
                .di(wrDataS), // better way for this? 
                .do(sample_out[j])
            );
        end
    endgenerate
    
    // 13 rams for coefficients

    wire signed [15:0] coeff [12:0];
    reg [12:0] coeffwr;
    
    generate
        for (j = 0; j < BAND_COUNT; j = j + 1 ) begin
            async_ram #(.RAM_HEIGHT(NUM_TAPS), .RAM_WIDTH(COEFF_LENGTH)) coeffRAM (
                .clk(S_AXI_ACLK),
                .we(coeffwr[j]),
                .a(filterQ),
                .di(wrDataS), // better way for this? 
                .do(coeff[j])
            );
        end
    endgenerate
    
    //attenuation factor ram
    reg signed [15:0] attenDQ[0:12];
    reg signed [15:0] attenDInt[0:12];
    
    reg signed [15:0] adBufQ[0:12]; // be careful
    reg signed [15:0] adBufInt[0:12];
    
    // summed results from each channel
    reg signed [15:0] result_sumC1Q, result_sumC1Int;
    reg signed [15:0] result_sumC2Q, result_sumC2Int;
    
    // band and channel counter for write operations
    reg [3:0] band_countQ, band_countInt;
    reg [1:0] channel_countQ, channel_countInt;
    
    // reg address
    parameter filterAddr = 'b0000, sampleAddr = 'b0100, attenAddr = 'b1000;
    parameter IDLE_S = 0, ACCU_S = 1, ROUND_S = 2;
    reg [3:0] nextState_s, currentState_s;
    
    // summing temps
    reg signed [15:0] temp;
    reg signed [31:0] temp2;
    reg signed [15:0] temp3;
    reg signed [31:0] temp4;
    reg signed [15:0] temp5;
    reg signed [31:0] temp6;
    reg signed [15:0] temp7;
    reg signed [31:0] temp8;
    reg signed [15:0] temp9;
    reg signed [31:0] temp10;
    reg signed [15:0] temp11;
    reg signed [31:0] temp12;
    reg signed [15:0] temp13;
    reg signed [31:0] temp14;
    reg signed [15:0] temp15;
    reg signed [31:0] temp16;
    reg signed [15:0] temp17;
    reg signed [31:0] temp18;
    reg signed [15:0] temp19;
    reg signed [31:0] temp20;
    reg signed [15:0] temp21;
    reg signed [31:0] temp22;
    reg signed [15:0] temp23;
    reg signed [31:0] temp24;
    reg signed [15:0] temp25;
    reg signed [31:0] temp26;
    reg signed [31:0] ConfConf;


    

    
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
        // flip flops
        s_read_int = s_readQ;
        filter_int = filterQ;
        s_write_int = s_writeQ;
        band_countInt = band_countQ;
        channel_countInt = channel_countQ;
        result_sumC1Int = result_sumC1Q;
        result_sumC2Int = result_sumC2Q;
        temp = 0;
        temp2 = 0;
        
        
        // parallel flip flops
        for (i = 0; i < BAND_COUNT; i = i+1) begin
            result_c1Int[i] = result_c1Q[i];
            result_c2Int[i] = result_c2Q[i];
            attenDInt[i] = attenDQ[i];
            adBufInt[i] = adBufQ[i];
        end
                
        // regs
        nextState_s = currentState_s;
        rdDataS = 0;
        coeffwr = 0;
        samplewr = 0;

        // write logic
        if (wrS) begin
            if (wrAddrS[3:0] == filterAddr) begin
                coeffwr[band_countQ] = 1;
                band_countInt = band_countQ + 1;
                if (band_countQ == BAND_COUNT-1) begin
                    band_countInt = 0;
                    filter_int = filterQ + 1;
                    if (filterQ == NUM_TAPS-1) begin
                        filter_int = 0;
                    end
                end
            end
            if (wrAddrS[3:0] == sampleAddr) begin
                sample_addr = s_writeQ;
                samplewr[channel_countQ] = 1;
                channel_countInt = channel_countQ + 1;
                if (channel_countQ == CHANNEL_COUNT-1) begin
                    s_write_int = s_writeQ + 1;
                    channel_countInt = 0;                  
                    if (s_writeQ == NUM_TAPS-1) begin
                        s_write_int = 0;
                    end
                end
            end
            if (wrAddrS[3:0] == attenAddr) begin
                adBufInt[wrAddrS[7:4]] = wrDataS[15:0];
            end
        end
        
        
        // MAC FSM
        case (currentState_s)
            IDLE_S: begin
                if ( rdS ) begin
                    if (rdAddrS[3:0] == sampleAddr) begin
                        nextState_s = ACCU_S;
                        if ( channel_countQ == 1) begin
                            // channel 0
                            s_read_int = s_writeQ; //come back if initialization wasn't right
                        end else begin
                            s_read_int = s_writeQ - 1;
                            if (s_writeQ == 0) begin
                                s_read_int = NUM_TAPS-1;
                            end
                        end
                        
                    end
                end
            end
            ACCU_S: begin

                if (channel_countQ == 1) begin // channel 0
                    for (i = 0; i < BAND_COUNT; i = i+1) begin
                        sample_addr = s_readQ;
                        result_c1Int[i] = coeff[i] * sample_out[0] + result_c1Q[i];
                    end
                end else begin // channel 1
                    for (i = 0; i < BAND_COUNT; i = i+1) begin
                        sample_addr = s_readQ;
                        result_c2Int[i] = coeff[i] * sample_out[1] + result_c2Q[i];
                    end
                end
                filter_int = filterQ + 1;
                if (s_readQ == 0) begin
                    s_read_int = NUM_TAPS-1;
                end else begin
                    s_read_int = s_readQ -1;
                end
                if (filterQ == NUM_TAPS-1) begin
                    filter_int = 0;
                    nextState_s = ROUND_S;
                    band_countInt = 0; // watch out for incorrect write later
                    for (i = 0; i < BAND_COUNT; i=i+1) begin
                        attenDInt[i] = adBufQ[i];
                    end
                end
            end
            ROUND_S: begin
                //summing
                if (channel_countQ == 1) begin
                    // rounding each band
                
                    temp = ((result_c1Q[0] + 16384) & 'b01111111111111111100000000000000) >> 15;
                    temp2 = temp * attenDQ[0];
                    
                    temp3 = ((result_c1Q[1] + 16384) & 'b01111111111111111100000000000000) >> 15;
                    temp4 = temp3 * attenDQ[1];
                    
                    temp5 = ((result_c1Q[2] + 16384) & 'b01111111111111111100000000000000) >> 15;
                    temp6 = temp5 * attenDQ[2];
                    //temp6 = ((temp5 * attenDQ[2] + 8192) & 'b00111111111111111110000000000000) >> 14;
                    
                    temp7 = ((result_c1Q[3] + 16384) & 'b01111111111111111100000000000000) >> 15;
                    temp8 = temp7 * attenDQ[3];
                    
                    temp9 = ((result_c1Q[4] + 16384) & 'b01111111111111111100000000000000) >> 15;
                    temp10 = temp9 * attenDQ[4];
                    
                    temp11 = ((result_c1Q[5] + 16384) & 'b01111111111111111100000000000000) >> 15;
                    temp12 = temp11 * attenDQ[5];
                    
                    temp13 = ((result_c1Q[6] + 16384) & 'b01111111111111111100000000000000) >> 15;
                    temp14 = temp13 * attenDQ[6];
                    
                    temp15 = ((result_c1Q[7] + 16384) & 'b01111111111111111100000000000000) >> 15;
                    temp16 = temp15 * attenDQ[7];
                    
                    temp17 = ((result_c1Q[8] + 16384) & 'b01111111111111111100000000000000) >> 15;
                    temp18 = temp17 * attenDQ[8];
                    
                    temp19 = ((result_c1Q[9] + 16384) & 'b01111111111111111100000000000000) >> 15;
                    temp20 = temp19 * attenDQ[9];
                    
                    temp21 = ((result_c1Q[10] + 16384) & 'b01111111111111111100000000000000) >> 15;
                    temp22 = temp21 * attenDQ[10];
                    
                    temp23 = ((result_c1Q[11] + 16384) & 'b01111111111111111100000000000000) >> 15;
                    temp24 = temp23 * attenDQ[11];
                    
                    temp25 = ((result_c1Q[12] + 16384) & 'b01111111111111111100000000000000) >> 15;
                    temp26 = temp25 * attenDQ[12];

                     ConfConf = temp2 + temp4 + temp6 + temp8 + temp10 + temp12 + temp14 + temp16 + temp18 + temp20 + temp22 + temp24 + temp26;
                     result_sumC1Int = ((ConfConf + 8192) & 'b00111111111111111110000000000000) >> 14;
                end else begin
                    temp = ((result_c2Q[0] + 16384) & 'b01111111111111111100000000000000) >> 15;
                    temp2 = temp * attenDQ[0];
                    
                    temp3 = ((result_c2Q[1] + 16384) & 'b01111111111111111100000000000000) >> 15;
                    temp4 = temp3 * attenDQ[1];
                    
                    temp5 = ((result_c2Q[2] + 16384) & 'b01111111111111111100000000000000) >> 15;
                    temp6 = temp5 * attenDQ[2];
                    //temp6 = ((temp5 * attenDQ[2] + 8192) & 'b00111111111111111110000000000000) >> 14;
                    
                    temp7 = ((result_c2Q[3] + 16384) & 'b01111111111111111100000000000000) >> 15;
                    temp8 = temp7 * attenDQ[3];
                    
                    temp9 = ((result_c2Q[4] + 16384) & 'b01111111111111111100000000000000) >> 15;
                    temp10 = temp9 * attenDQ[4];
                    
                    temp11 = ((result_c2Q[5] + 16384) & 'b01111111111111111100000000000000) >> 15;
                    temp12 = temp11 * attenDQ[5];
                    
                    temp13 = ((result_c2Q[6] + 16384) & 'b01111111111111111100000000000000) >> 15;
                    temp14 = temp13 * attenDQ[6];
                    
                    temp15 = ((result_c2Q[7] + 16384) & 'b01111111111111111100000000000000) >> 15;
                    temp16 = temp15 * attenDQ[7];
                    
                    temp17 = ((result_c2Q[8] + 16384) & 'b01111111111111111100000000000000) >> 15;
                    temp18 = temp17 * attenDQ[8];
                    
                    temp19 = ((result_c2Q[9] + 16384) & 'b01111111111111111100000000000000) >> 15;
                    temp20 = temp19 * attenDQ[9];
                    
                    temp21 = ((result_c2Q[10] + 16384) & 'b01111111111111111100000000000000) >> 15;
                    temp22 = temp21 * attenDQ[10];
                    
                    temp23 = ((result_c2Q[11] + 16384) & 'b01111111111111111100000000000000) >> 15;
                    temp24 = temp23 * attenDQ[11];
                    
                    temp25 = ((result_c2Q[12] + 16384) & 'b01111111111111111100000000000000) >> 15;
                    temp26 = temp25 * attenDQ[12];

                     ConfConf = temp2 + temp4 + temp6 + temp8 + temp10 + temp12 + temp14 + temp16 + temp18 + temp20 + temp22 + temp24 + temp26;
                     result_sumC2Int = ((ConfConf + 8192) & 'b00111111111111111110000000000000) >> 14;
                end
                
                if (channel_countQ == 1) begin
                    rdDataS[15:0] = result_sumC1Q;
                    rdDataS[31] = 1;
                end else begin
                    rdDataS[15:0] = result_sumC2Q;
                    rdDataS[31] = 1;
                end
                // truncate top bit with an bitwise and, round by half of bit 14, shift right by 15 bits, and set bit 31 to 1
                if ( rdS ) begin
                    nextState_s = IDLE_S;
                    result_sumC1Int = 0;
                    result_sumC2Int = 0;
                    for (i = 0; i < BAND_COUNT; i = i+1) begin
                        result_c1Int[i] = 0;
                        result_c2Int[i] = 0;
                    end
                    temp = 0;
                    temp2 = 0;
                    temp3 = 0;
                    temp4 = 0;
                    temp5 = 0;
                    temp6 = 0;
                    temp7 = 0;
                    temp8 = 0;
                    temp9 = 0;
                    temp10 = 0;
                    temp11 = 0;
                    temp12 = 0;
                    temp13 = 0;
                    temp14 = 0;
                    temp15 = 0;
                    temp16 = 0;
                    temp17 = 0;
                    temp18 = 0;
                    temp19 = 0;
                    temp20 = 0;
                    temp21 = 0;
                    temp22 = 0;
                    temp23 = 0;
                    temp24 = 0;
                    temp25 = 0;
                    temp26 = 0;
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
            // reset registers to 0, FSM to IDLE
            filterQ <= 0 ;
            s_writeQ <= 0 ;
            s_readQ <= 0 ;
            result_sumC1Q <= 0;
            result_sumC2Q <= 0;
            band_countQ <= 0;
            channel_countQ <= 0;

            for ( i = 0; i < BAND_COUNT; i = i+1) begin
                result_c1Q[i] <= 0 ;
                result_c2Q[i] <= 0 ;
                attenDQ[i] <= 'h4000;
                adBufQ[i] <= 'h4000;
            end
            currentState_s = IDLE_S;
        end else begin
            filterQ <= filter_int ;
            s_writeQ <= s_write_int ;
            s_readQ <= s_read_int ;
            result_sumC1Q <= result_sumC1Int;
            result_sumC2Q <= result_sumC2Int;
            band_countQ <= band_countInt;
            channel_countQ <= channel_countInt;

            for ( i = 0; i < BAND_COUNT; i = i+1) begin
                result_c1Q[i] <= result_c1Int[i] ;
                result_c2Q[i] <= result_c2Int[i] ;
                attenDQ[i] <= attenDInt[i];
                adBufQ[i] <= adBufInt[i];
            end
            currentState_s = nextState_s;
        end
    end

endmodule
