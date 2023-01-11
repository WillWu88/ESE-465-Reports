`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/01/2022 03:27:39 PM
// Design Name: 
// Module Name: axi4literegs_tb
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


module axi4literegs_tb();
// Axi4Lite Manager instantiation    
parameter C_S_AXI_ADDR_WIDTH = 4, C_S_AXI_DATA_WIDTH = 32, CLK_PERIOD = 33.33 ;

// Axi4Lite signals
reg  S_AXI_ACLK ;
reg  S_AXI_ARESETN ;
wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR ;
wire  S_AXI_AWVALID ;
wire S_AXI_AWREADY ;
wire  [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA ;
wire  [3:0] S_AXI_WSTRB ;
wire  S_AXI_WVALID ;
wire S_AXI_WREADY ;
wire [1:0] S_AXI_BRESP ;
wire S_AXI_BVALID ;
wire  S_AXI_BREADY ;
wire  [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR ;
wire  S_AXI_ARVALID ;
wire S_AXI_ARREADY ;
wire [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA ;
wire [1:0] S_AXI_RRESP ;
wire S_AXI_RVALID ;
wire  S_AXI_RREADY ;
// Simple Bus signals
reg     [C_S_AXI_ADDR_WIDTH-1:0]    wrAddr ;
reg     [C_S_AXI_DATA_WIDTH-1:0]    wrData ;
reg                                 wr ;
wire                                wrDone ;
reg     [C_S_AXI_ADDR_WIDTH-1:0]    rdAddr ;
wire    [C_S_AXI_DATA_WIDTH-1:0]    rdData ;
reg                                 rd ;
wire                                rdDone ;

// spi connector signals
wire  SCK, SDI, CS_, SDO;

integer i;

// module instantiations
Axi4LiteManager #(.C_M_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH), .C_M_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) Axi4LiteManager1
        (
            // Simple Bus
            .wrAddr(wrAddr),                    // input    [C_M_AXI_ADDR_WIDTH-1:0]
            .wrData(wrData),                    // input    [C_M_AXI_DATA_WIDTH-1:0]
            .wr(wr),                            // input    
            .wrDone(wrDone),                    // output
            .rdAddr(rdAddr),                    // input    [C_M_AXI_ADDR_WIDTH-1:0]
            .rdData(rdData),                    // output   [C_M_AXI_DATA_WIDTH-1:0]
            .rd(rd),                            // input
            .rdDone(rdDone),                    // output
            // Axi4Lite Bus
            .M_AXI_ACLK(S_AXI_ACLK),            // input
            .M_AXI_ARESETN(S_AXI_ARESETN),      // input
            .M_AXI_AWADDR(S_AXI_AWADDR),        // output   [C_M_AXI_ADDR_WIDTH-1:0] 
            .M_AXI_AWVALID(S_AXI_AWVALID),      // output
            .M_AXI_AWREADY(S_AXI_AWREADY),      // input
            .M_AXI_WDATA(S_AXI_WDATA),          // output   [C_M_AXI_DATA_WIDTH-1:0]
            .M_AXI_WSTRB(S_AXI_WSTRB),          // output   [3:0]
            .M_AXI_WVALID(S_AXI_WVALID),        // output
            .M_AXI_WREADY(S_AXI_WREADY),        // input
            .M_AXI_BRESP(S_AXI_BRESP),          // input    [1:0]
            .M_AXI_BVALID(S_AXI_BVALID),        // input
            .M_AXI_BREADY(S_AXI_BREADY),        // output
            .M_AXI_ARADDR(S_AXI_ARADDR),        // output   [C_M_AXI_ADDR_WIDTH-1:0]
            .M_AXI_ARVALID(S_AXI_ARVALID),      // output
            .M_AXI_ARREADY(S_AXI_ARREADY),      // input
            .M_AXI_RDATA(S_AXI_RDATA),          // input    [C_M_AXI_DATA_WIDTH-1:0]
            .M_AXI_RRESP(S_AXI_RRESP),          // input    [1:0]
            .M_AXI_RVALID(S_AXI_RVALID),        // input
            .M_AXI_RREADY(S_AXI_RREADY)         // output
        );    
        
Axi4LiteSPI #(.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) Axi4LiteSPI1 (
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
    .S_AXI_RREADY(S_AXI_RREADY),         // input
    .SCK(SCK), 
    .SDI(SDI),
    .CONV_CS(CS_),
    .SDO(SDO)
    ) ;
    /*
AdcTester ADC1 (
    .SCK(SCK), 
    .SDI(SDI),
    .CS_(CS_),
    .SDO(SDO)
    ) ;
/*/
DacTester DAC1 (
    .SCK(SCK), 
    .SDI(SDI),
    .CS_(CS_),
    .SDO(SDO)
    ) ;
    
    parameter CLK_PERIOD_2 = (CLK_PERIOD/2);
    // generate clock
    always begin
        #(CLK_PERIOD_2) S_AXI_ACLK = ~S_AXI_ACLK;
    end
    
    initial begin
        S_AXI_ARESETN = 0 ;
        S_AXI_ACLK = 0 ;
        rdAddr = 0 ;
        rd = 0 ;
        wr = 0 ;
        wrAddr = 0 ;
        wrData = 0 ;
        #(CLK_PERIOD_2 + 2) S_AXI_ARESETN = 1 ;
        #(CLK_PERIOD*10) ;
        

        // adc spi test
        // write s/d, d/o words to spi peripheral
        /*
        #(CLK_PERIOD*10) ;
        wrAddr = 'b00000000 ;
        wr = 1 ;
        wrData = 'b00000001;
        #(CLK_PERIOD) ;
        wrAddr = 0 ;
        wr = 0 ;
        wrData = 0;
        
        // write to cycle max
        #(CLK_PERIOD*10) ;
        wrAddr = 'b00001000 ;
        wr = 1 ;
        wrData = 'b00011000;
        #(CLK_PERIOD) ;
        wrAddr = 0 ;
        wr = 0 ;
        wrData = 0;
        
        // write to sample per clock
        #(CLK_PERIOD*10) ;
        wrAddr = 'b00001100 ;
        wr = 1 ;
        wrData = 'h258;
        #(CLK_PERIOD) ;
        wrAddr = 0 ;
        wr = 0 ;
        wrData = 0;
        
        
        // read to chop off the data
        while ( rdData[31] == 0 ) begin
                rdAddr = 'b00000100;
                rd = 1;
                #(CLK_PERIOD) ;
                rd = 0;
                rdAddr = 0;
            end
            $display("Discard: %h",rdData[15:0]) ;
        for (i = 0; i < 1000; i = i+1) begin
            // write s/d, d/o words to spi peripheral
            #(CLK_PERIOD*10) ;
            wrAddr = 'b00000000 ;
            wr = 1 ;
            wrData = 'h800000;
            #(CLK_PERIOD) ;
            wrAddr = 0 ;
            wr = 0 ;
            wrData = 0;
            // reading adc data from channel 0
            while ( rdData[31] == 0 ) begin
                rdAddr = 'b00000100;
                rd = 1;
                #(CLK_PERIOD) ;
                rd = 0;
                rdAddr = 0;
            end
            $display("C1: %h",{!(rdData[15]), rdData[14:0]}) ;
            
            #(CLK_PERIOD) ;
            // channel switch
            // write s/d, d/o words to spi peripheral
            #(CLK_PERIOD*10) ;
            wrAddr = 'b00000000 ;
            wr = 1 ;
            wrData = 'hc00000;
            #(CLK_PERIOD) ;
            wrAddr = 0 ;
            wr = 0 ;
            wrData = 0;
            while ( rdData[31] == 0 ) begin
                rdAddr = 'b00000100;
                rd = 1;
                #(CLK_PERIOD) ;
                rd = 0;
               rdAddr = 0;
            end
            $display("C2: %h",{!(rdData[15]), rdData[14:0]}) ;
        end
        /*/
        //test DAC
        #(CLK_PERIOD*10) ;
        wrAddr = 'b00000000 ;
        wr = 1 ;
        wrData = 'b010100001000000000000000;
        #(CLK_PERIOD) ;
        wrAddr = 0 ;
        wr = 0 ;
        wrData = 0;
        
        // write to cycle max
        #(CLK_PERIOD*10) ;
        wrAddr = 'b00001000 ;
        wr = 1 ;
        wrData = 'b00011000;
        #(CLK_PERIOD) ;
        wrAddr = 0 ;
        wr = 0 ;
        wrData = 0;
        
        // write to sample per clock
        #(CLK_PERIOD*10) ;
        wrAddr = 'b00001100 ;
        wr = 1 ;
        wrData = 'h258;
        #(CLK_PERIOD) ;
        wrAddr = 0 ;
        wr = 0 ;
        wrData = 0;
        
        while (1) begin
        
            #(CLK_PERIOD*10) ;
            wrAddr = 'b00000000 ;
            wr = 1 ;
            wrData = 'b001100000000000000000000;
            #(CLK_PERIOD) ;
            wrAddr = 0 ;
            wr = 0 ;
            wrData = 0;
            while ( rdData[31] == 0 ) begin
                rdAddr = 'b00000100;
                rd = 1;
                #(CLK_PERIOD) ;
                rd = 0;
                rdAddr = 0;
            end
            
            #(CLK_PERIOD*10) ;
            wrAddr = 'b00000000 ;
            wr = 1 ;
            wrData = 'b001100010000000000000000;
            #(CLK_PERIOD) ;
            wrAddr = 0 ;
            wr = 0 ;
            wrData = 0;
            
            while ( rdData[31] == 0 ) begin
                rdAddr = 'b00000100;
                rd = 1;
                #(CLK_PERIOD) ;
                rd = 0;
                rdAddr = 0;
            end
            
            i = i+1;

        end
        
        $stop ;
    end
endmodule
