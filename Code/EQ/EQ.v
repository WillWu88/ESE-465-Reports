`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2022 01:12:56 PM
// Design Name: 
// Module Name: EQ
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


module EQ #
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
        
        // ADC PMOD I/O
        output      ADC_SCK,
        output      ADC_SDI,
        output      ADC_CONV_CS,
        input           ADC_SDO,
        
        // ADC PMOD I/O
        output      DAC_SCK,
        output      DAC_SDI,
        output      DAC_CONV_CS,
        input           DAC_SDO
    );
    wire    [C_S_AXI_ADDR_WIDTH-1:0] wrAddrS;
    wire    [C_S_AXI_DATA_WIDTH-1:0] wrDataS;
    wire                             wrS;
    wire    [C_S_AXI_ADDR_WIDTH-1:0] rdAddrS;
    reg     [C_S_AXI_DATA_WIDTH-1:0] rdDataS;
    wire                             rdS;
    
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
    
    // FIR manager instantiation
    reg     [C_S_AXI_ADDR_WIDTH-1:0]    wrAddr_fir ;
    reg     [C_S_AXI_DATA_WIDTH-1:0]    wrData_fir ;
    reg                                 wr_fir ;
    wire                                wrDone_fir ;
    reg     [C_S_AXI_ADDR_WIDTH-1:0]    rdAddr_fir ;
    wire    [C_S_AXI_DATA_WIDTH-1:0]    rdData_fir ;
    reg                                 rd_fir ;
    wire                                rdDone_fir ;    
    wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR_fir ;
    wire  S_AXI_AWVALID_fir ;
    wire S_AXI_AWREADY_fir ;
    wire  [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA_fir ;
    wire  [3:0] S_AXI_WSTRB_fir ;
    wire  S_AXI_WVALID_fir ;
    wire S_AXI_WREADY_fir ;
    wire [1:0] S_AXI_BRESP_fir ;
    wire S_AXI_BVALID_fir ;
    wire  S_AXI_BREADY_fir ;
    wire  [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR_fir ;
    wire  S_AXI_ARVALID_fir ;
    wire S_AXI_ARREADY_fir ;
    wire [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA_fir ;
    wire [1:0] S_AXI_RRESP_fir ;
    wire S_AXI_RVALID_fir ;
    wire  S_AXI_RREADY_fir ;
    Axi4LiteManager #(.C_M_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH), .C_M_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) FIRMan
        (
            // Simple Bus
            .wrAddr(wrAddr_fir),                    // input    [C_M_AXI_ADDR_WIDTH-1:0]
            .wrData(wrData_fir),                    // input    [C_M_AXI_DATA_WIDTH-1:0]
            .wr(wr_fir),                            // input    
            .wrDone(wrDone_fir),                    // output
            .rdAddr(rdAddr_fir),                    // input    [C_M_AXI_ADDR_WIDTH-1:0]
            .rdData(rdData_fir),                    // output   [C_M_AXI_DATA_WIDTH-1:0]
            .rd(rd_fir),                            // input
            .rdDone(rdDone_fir),                    // output
            // Axi4Lite Bus
            .M_AXI_ACLK(S_AXI_ACLK),            // input
            .M_AXI_ARESETN(S_AXI_ARESETN),      // input
            .M_AXI_AWADDR(S_AXI_AWADDR_fir),        // output   [C_M_AXI_ADDR_WIDTH-1:0] 
            .M_AXI_AWVALID(S_AXI_AWVALID_fir),      // output
            .M_AXI_AWREADY(S_AXI_AWREADY_fir),      // input
            .M_AXI_WDATA(S_AXI_WDATA_fir),          // output   [C_M_AXI_DATA_WIDTH-1:0]
            .M_AXI_WSTRB(S_AXI_WSTRB_fir),          // output   [3:0]
            .M_AXI_WVALID(S_AXI_WVALID_fir),        // output
            .M_AXI_WREADY(S_AXI_WREADY_fir),        // input
            .M_AXI_BRESP(S_AXI_BRESP_fir),          // input    [1:0]
            .M_AXI_BVALID(S_AXI_BVALID_fir),        // input
            .M_AXI_BREADY(S_AXI_BREADY_fir),        // output
            .M_AXI_ARADDR(S_AXI_ARADDR_fir),        // output   [C_M_AXI_ADDR_WIDTH-1:0]
            .M_AXI_ARVALID(S_AXI_ARVALID_fir),      // output
            .M_AXI_ARREADY(S_AXI_ARREADY_fir),      // input
            .M_AXI_RDATA(S_AXI_RDATA_fir),          // input    [C_M_AXI_DATA_WIDTH-1:0]
            .M_AXI_RRESP(S_AXI_RRESP_fir),          // input    [1:0]
            .M_AXI_RVALID(S_AXI_RVALID_fir),        // input
            .M_AXI_RREADY(S_AXI_RREADY_fir)         // output
        );
    Axi4LiteFilter #(.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) FIR (
        // Axi4Lite Bus
        .S_AXI_ACLK(S_AXI_ACLK),            // input
        .S_AXI_ARESETN(S_AXI_ARESETN),      // input
        .S_AXI_AWADDR(S_AXI_AWADDR_fir),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
        .S_AXI_AWVALID(S_AXI_AWVALID_fir),      // input
        .S_AXI_AWREADY(S_AXI_AWREADY_fir),      // output
        .S_AXI_WDATA(S_AXI_WDATA_fir),          // input    [C_S_AXI_DATA_WIDTH-1:0]
        .S_AXI_WSTRB(S_AXI_WSTRB_fir),          // input    [3:0]
        .S_AXI_WVALID(S_AXI_WVALID_fir),        // input
        .S_AXI_WREADY(S_AXI_WREADY_fir),        // output        
        .S_AXI_BRESP(S_AXI_BRESP_fir),          // output   [1:0]
        .S_AXI_BVALID(S_AXI_BVALID_fir),        // output
        .S_AXI_BREADY(S_AXI_BREADY_fir),        // input
        .S_AXI_ARADDR(S_AXI_ARADDR_fir),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
        .S_AXI_ARVALID(S_AXI_ARVALID_fir),      // input
        .S_AXI_ARREADY(S_AXI_ARREADY_fir),      // output
        .S_AXI_RDATA(S_AXI_RDATA_fir),          // output   [C_S_AXI_DATA_WIDTH-1:0]
        .S_AXI_RRESP(S_AXI_RRESP_fir),          // output   [1:0]
        .S_AXI_RVALID(S_AXI_RVALID_fir),        // output    
        .S_AXI_RREADY(S_AXI_RREADY_fir)         // input
        ) ;  
         
    // ADC instantiation
    reg     [C_S_AXI_ADDR_WIDTH-1:0]    wrAddr_adc ;
    reg     [C_S_AXI_DATA_WIDTH-1:0]    wrData_adc ;
    reg                                 wr_adc ;
    wire                                wrDone_adc ;
    reg     [C_S_AXI_ADDR_WIDTH-1:0]    rdAddr_adc ;
    wire    [C_S_AXI_DATA_WIDTH-1:0]    rdData_adc ;
    reg                                 rd_adc ;
    wire                                rdDone_adc ;
    wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR_adc ;
    wire  S_AXI_AWVALID_adc ;
    wire S_AXI_AWREADY_adc ;
    wire  [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA_adc ;
    wire  [3:0] S_AXI_WSTRB_adc ;
    wire  S_AXI_WVALID_adc ;
    wire S_AXI_WREADY_adc ;
    wire [1:0] S_AXI_BRESP_adc ;
    wire S_AXI_BVALID_adc ;
    wire  S_AXI_BREADY_adc ;
    wire  [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR_adc ;
    wire  S_AXI_ARVALID_adc ;
    wire S_AXI_ARREADY_adc ;
    wire [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA_adc ;
    wire [1:0] S_AXI_RRESP_adc ;
    wire S_AXI_RVALID_adc ;
    wire  S_AXI_RREADY_adc ;    
    Axi4LiteManager #(.C_M_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH), .C_M_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) ADCMan
        (
            // Simple Bus
            .wrAddr(wrAddr_adc),                    // input    [C_M_AXI_ADDR_WIDTH-1:0]
            .wrData(wrData_adc),                    // input    [C_M_AXI_DATA_WIDTH-1:0]
            .wr(wr_adc),                            // input    
            .wrDone(wrDone_adc),                    // output
            .rdAddr(rdAddr_adc),                    // input    [C_M_AXI_ADDR_WIDTH-1:0]
            .rdData(rdData_adc),                    // output   [C_M_AXI_DATA_WIDTH-1:0]
            .rd(rd_adc),                            // input
            .rdDone(rdDone_adc),                    // output
            // Axi4Lite Bus
            .M_AXI_ACLK(S_AXI_ACLK),            // input
            .M_AXI_ARESETN(S_AXI_ARESETN),      // input
            .M_AXI_AWADDR(S_AXI_AWADDR_adc),        // output   [C_M_AXI_ADDR_WIDTH-1:0] 
            .M_AXI_AWVALID(S_AXI_AWVALID_adc),      // output
            .M_AXI_AWREADY(S_AXI_AWREADY_adc),      // input
            .M_AXI_WDATA(S_AXI_WDATA_adc),          // output   [C_M_AXI_DATA_WIDTH-1:0]
            .M_AXI_WSTRB(S_AXI_WSTRB_adc),          // output   [3:0]
            .M_AXI_WVALID(S_AXI_WVALID_adc),        // output
            .M_AXI_WREADY(S_AXI_WREADY_adc),        // input
            .M_AXI_BRESP(S_AXI_BRESP_adc),          // input    [1:0]
            .M_AXI_BVALID(S_AXI_BVALID_adc),        // input
            .M_AXI_BREADY(S_AXI_BREADY_adc),        // output
            .M_AXI_ARADDR(S_AXI_ARADDR_adc),        // output   [C_M_AXI_ADDR_WIDTH-1:0]
            .M_AXI_ARVALID(S_AXI_ARVALID_adc),      // output
            .M_AXI_ARREADY(S_AXI_ARREADY_adc),      // input
            .M_AXI_RDATA(S_AXI_RDATA_adc),          // input    [C_M_AXI_DATA_WIDTH-1:0]
            .M_AXI_RRESP(S_AXI_RRESP_adc),          // input    [1:0]
            .M_AXI_RVALID(S_AXI_RVALID_adc),        // input
            .M_AXI_RREADY(S_AXI_RREADY_adc)         // output
        );
    Axi4LiteSPI #(.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) ADCSPI (
        // Axi4Lite Bus
        .S_AXI_ACLK(S_AXI_ACLK),            // input
        .S_AXI_ARESETN(S_AXI_ARESETN),      // input
        .S_AXI_AWADDR(S_AXI_AWADDR_adc),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
        .S_AXI_AWVALID(S_AXI_AWVALID_adc),      // input
        .S_AXI_AWREADY(S_AXI_AWREADY_adc),      // output
        .S_AXI_WDATA(S_AXI_WDATA_adc),          // input    [C_S_AXI_DATA_WIDTH-1:0]
        .S_AXI_WSTRB(S_AXI_WSTRB_adc),          // input    [3:0]
        .S_AXI_WVALID(S_AXI_WVALID_adc),        // input
        .S_AXI_WREADY(S_AXI_WREADY_adc),        // output        
        .S_AXI_BRESP(S_AXI_BRESP_adc),          // output   [1:0]
        .S_AXI_BVALID(S_AXI_BVALID_adc),        // output
        .S_AXI_BREADY(S_AXI_BREADY_adc),        // input
        .S_AXI_ARADDR(S_AXI_ARADDR_adc),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
        .S_AXI_ARVALID(S_AXI_ARVALID_adc),      // input
        .S_AXI_ARREADY(S_AXI_ARREADY_adc),      // output
        .S_AXI_RDATA(S_AXI_RDATA_adc),          // output   [C_S_AXI_DATA_WIDTH-1:0]
        .S_AXI_RRESP(S_AXI_RRESP_adc),          // output   [1:0]
        .S_AXI_RVALID(S_AXI_RVALID_adc),        // output    
        .S_AXI_RREADY(S_AXI_RREADY_adc),         // input
        
        // SPI through PMOD
        .SCK(ADC_SCK), 
        .SDI(ADC_SDI),
        .CONV_CS(ADC_CONV_CS),
        .SDO(ADC_SDO)
        ) ;
    
    // DAC instantiation
    reg     [C_S_AXI_ADDR_WIDTH-1:0]    wrAddr_dac ;
    reg     [C_S_AXI_DATA_WIDTH-1:0]    wrData_dac ;
    reg                                 wr_dac ;
    wire                                wrDone_dac ;
    reg     [C_S_AXI_ADDR_WIDTH-1:0]    rdAddr_dac ;
    wire    [C_S_AXI_DATA_WIDTH-1:0]    rdData_dac ;
    reg                                 rd_dac ;
    wire                                rdDone_dac ;   
    wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR_dac ;
    wire  S_AXI_AWVALID_dac ;
    wire S_AXI_AWREADY_dac ;
    wire  [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA_dac ;
    wire  [3:0] S_AXI_WSTRB_dac ;
    wire  S_AXI_WVALID_dac ;
    wire S_AXI_WREADY_dac ;
    wire [1:0] S_AXI_BRESP_dac ;
    wire S_AXI_BVALID_dac ;
    wire  S_AXI_BREADY_dac ;
    wire  [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR_dac ;
    wire  S_AXI_ARVALID_dac ;
    wire S_AXI_ARREADY_dac ;
    wire [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA_dac ;
    wire [1:0] S_AXI_RRESP_dac ;
    wire S_AXI_RVALID_dac ;
    wire  S_AXI_RREADY_dac ; 
    Axi4LiteManager #(.C_M_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH), .C_M_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) DACMan
        (
            // Simple Bus
            .wrAddr(wrAddr_dac),                    // input    [C_M_AXI_ADDR_WIDTH-1:0]
            .wrData(wrData_dac),                    // input    [C_M_AXI_DATA_WIDTH-1:0]
            .wr(wr_dac),                            // input    
            .wrDone(wrDone_dac),                    // output
            .rdAddr(rdAddr_dac),                    // input    [C_M_AXI_ADDR_WIDTH-1:0]
            .rdData(rdData_dac),                    // output   [C_M_AXI_DATA_WIDTH-1:0]
            .rd(rd_dac),                            // input
            .rdDone(rdDone_dac),                    // output
            // Axi4Lite Bus
            .M_AXI_ACLK(S_AXI_ACLK),            // input
            .M_AXI_ARESETN(S_AXI_ARESETN),      // input
            .M_AXI_AWADDR(S_AXI_AWADDR_dac),        // output   [C_M_AXI_ADDR_WIDTH-1:0] 
            .M_AXI_AWVALID(S_AXI_AWVALID_dac),      // output
            .M_AXI_AWREADY(S_AXI_AWREADY_dac),      // input
            .M_AXI_WDATA(S_AXI_WDATA_dac),          // output   [C_M_AXI_DATA_WIDTH-1:0]
            .M_AXI_WSTRB(S_AXI_WSTRB_dac),          // output   [3:0]
            .M_AXI_WVALID(S_AXI_WVALID_dac),        // output
            .M_AXI_WREADY(S_AXI_WREADY_dac),        // input
            .M_AXI_BRESP(S_AXI_BRESP_dac),          // input    [1:0]
            .M_AXI_BVALID(S_AXI_BVALID_dac),        // input
            .M_AXI_BREADY(S_AXI_BREADY_dac),        // output
            .M_AXI_ARADDR(S_AXI_ARADDR_dac),        // output   [C_M_AXI_ADDR_WIDTH-1:0]
            .M_AXI_ARVALID(S_AXI_ARVALID_dac),      // output
            .M_AXI_ARREADY(S_AXI_ARREADY_dac),      // input
            .M_AXI_RDATA(S_AXI_RDATA_dac),          // input    [C_M_AXI_DATA_WIDTH-1:0]
            .M_AXI_RRESP(S_AXI_RRESP_dac),          // input    [1:0]
            .M_AXI_RVALID(S_AXI_RVALID_dac),        // input
            .M_AXI_RREADY(S_AXI_RREADY_dac)         // output
        );
    Axi4LiteSPI #(.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) DACSPI (
        // Axi4Lite Bus
        .S_AXI_ACLK(S_AXI_ACLK),            // input
        .S_AXI_ARESETN(S_AXI_ARESETN),      // input
        .S_AXI_AWADDR(S_AXI_AWADDR_dac),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
        .S_AXI_AWVALID(S_AXI_AWVALID_dac),      // input
        .S_AXI_AWREADY(S_AXI_AWREADY_dac),      // output
        .S_AXI_WDATA(S_AXI_WDATA_dac),          // input    [C_S_AXI_DATA_WIDTH-1:0]
        .S_AXI_WSTRB(S_AXI_WSTRB_dac),          // input    [3:0]
        .S_AXI_WVALID(S_AXI_WVALID_dac),        // input
        .S_AXI_WREADY(S_AXI_WREADY_dac),        // output        
        .S_AXI_BRESP(S_AXI_BRESP_dac),          // output   [1:0]
        .S_AXI_BVALID(S_AXI_BVALID_dac),        // output
        .S_AXI_BREADY(S_AXI_BREADY_dac),        // input
        .S_AXI_ARADDR(S_AXI_ARADDR_dac),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
        .S_AXI_ARVALID(S_AXI_ARVALID_dac),      // input
        .S_AXI_ARREADY(S_AXI_ARREADY_dac),      // output
        .S_AXI_RDATA(S_AXI_RDATA_dac),          // output   [C_S_AXI_DATA_WIDTH-1:0]
        .S_AXI_RRESP(S_AXI_RRESP_dac),          // output   [1:0]
        .S_AXI_RVALID(S_AXI_RVALID_dac),        // output    
        .S_AXI_RREADY(S_AXI_RREADY_dac),         // input
        
        //SPI through PMOD
        .SCK(DAC_SCK), 
        .SDI(DAC_SDI),
        .CONV_CS(DAC_CONV_CS),
        .SDO(DAC_SDO)
        ) ;
    
    
    //flip flops, states declaration
    parameter CONFIG_S = 0, ADC_S = 1, FIR_S = 2, DAC_S = 3;
    reg [3:0] nextState_s, currentState_s;
    
    //address
    parameter filterAddr = 'b0000, dacAddr = 'b0100, adcAddr = 'b1000, adBufAddr = 'b1100;
    parameter cycle_config = 300, adc = 16, dac = 24;
    
    // submodule-scope addresses
    parameter sdi_addr = 'b00000000, sdo_addr = 'b00000100, cycle_max_addr = 'b00001000, spc_addr = 'b00001100;
    parameter coeffAddr = 'b0000, sampleAddr = 'b0100, attenAddr = 'b1000;
    parameter c1_sdos = 'h800000, c2_sdos = 'hc00000; 
    parameter COEFF_LENGTH = 16, NUM_TAPS = 279, BAND_COUNT = 13, CHANNEL_COUNT = 2;
    integer i; // parallel loop counter

    // flip flops
    reg [C_S_AXI_DATA_WIDTH-1:0] fir_configQ, fir_configInt;
    reg [1:0] spi_configQ, spi_configInt;
    reg channel_countQ, channel_countInt;
    reg dacConfQ, dacConfInt;
    reg [2:0] fastCountQ, fastCountInt;
    parameter transmit = 3, fastMode = 5;
    reg signed [15:0] attenDQ [BAND_COUNT-1:0];
    reg signed [15:0] attenDInt [BAND_COUNT-1:0];
    reg signed [15:0] adBufQ [BAND_COUNT-1:0];
    reg signed [15:0] adBufInt[BAND_COUNT-1:0];
    reg [4:0] confCountQ, confCountInt;
    reg [3:0] attenCountQ, attenCountInt;
    reg attenSpacerQ, attenSpacerInt;
    
    always @* begin
        //flip flops
        fir_configInt = fir_configQ;
        spi_configInt = spi_configQ;
        channel_countInt = channel_countQ;
        fastCountInt = fastCountQ;
        dacConfInt = dacConfQ;
        confCountInt = confCountQ;
        attenSpacerInt = attenSpacerQ;
        attenCountInt = attenCountQ;
        
        // parallel flip flop
        for ( i = 0; i < BAND_COUNT; i = i+1) begin
            attenDInt[i] = attenDQ[i];
            adBufInt[i] = adBufQ[i];
        end
        
        // write to buffer, 2 bytes concatenated
        if ( wrS && (wrAddrS[3:0] == adBufAddr)) begin
            adBufInt[wrAddrS[7:4]] = wrDataS[15:0];
            //adBufInt[wrAddrS[7:4] + 1] = wrDataS[31:16];
        end
        
        //regs output
        nextState_s = currentState_s;
        wr_fir = 0;
        wr_adc = 0;
        wr_dac = 0;
        wrAddr_fir = 0;
        wrAddr_adc = 0;
        wrAddr_dac = 0;
        wrData_fir = 0;
        wrData_adc = 0;
        wrData_dac = 0;
        rdAddr_fir = 0;
        rdAddr_adc = 0;
        rdAddr_dac = 0;
        rd_fir = 0;
        rd_adc = 0;
        rd_dac = 0;

        case (currentState_s)
            CONFIG_S: begin
                if (wrDone_fir) begin
                    fir_configInt = fir_configQ + 1;
                end
                if (rdData_dac[31] && fastCountQ < 3) begin
                    fastCountInt = fastCountQ + 1;
                    dacConfInt = 0;
                end
                if ( wrS ) begin
                    if (spi_configQ == 0) begin
                        // configure spi bit stream transfer length
                        wrAddr_dac = cycle_max_addr;
                        wrData_dac = 24;
                        wr_dac = 1;
                        
                        wrAddr_adc = cycle_max_addr;
                        wrData_adc = 16;
                        wr_adc = 1;
                        
                        spi_configInt = spi_configQ + 1;
                    end else if (spi_configQ == 1) begin
                        // configure spi cycling count
                        wrAddr_dac = spc_addr;
                        wrData_dac = 300;
                        wr_dac = 1;
                        
                        wrAddr_adc = spc_addr;
                        wrData_adc = 300;
                        wr_adc = 1;
                        
                        spi_configInt = spi_configQ + 1;
                    end
                    if (wrAddrS == filterAddr) begin
                        if ( fir_configQ <= 3626 ) begin
                            wrAddr_fir = coeffAddr;
                            wrData_fir = wrDataS;
                            wr_fir = 1;
                        end else if ( fir_configQ > 3626 && fir_configQ <= 4184) begin
                            // zero out buffer
                            wrAddr_fir = sampleAddr;
                            wrData_fir = 0;
                            wr_fir = 1;
                        end
                    end
                    if ( fir_configQ == 4184) begin
                        // transition logic
                        // write channel info to adc
                        nextState_s = ADC_S;
                        wr_adc = 1;
                        wrAddr_adc = sdi_addr ;
                        if (!channel_countQ) begin
                            wrData_adc = c1_sdos; // channel 1
                        end else begin
                            wrData_adc = c2_sdos; // channel 2
                        end
                    end
                    // set device into fast mode
                    if (spi_configQ >1) begin
                        rd_dac = 1;
                        rdAddr_dac = sdo_addr;
                        
                        case (fastCountQ)
                            0: begin
                                if (!dacConfQ) begin
                                    wrAddr_dac = sdi_addr;
                                    wrData_dac[23:20] = fastMode;
                                    wrData_dac[19:16] = 0;
                                    wrData_dac[15:0] = 0;
                                    wr_dac = 1;
                                    dacConfInt = 1;
                                end
                            end
                            1: begin
                                if (!dacConfQ) begin
                                    wrAddr_dac = sdi_addr;
                                    wrData_dac[23:20] = transmit;
                                    wrData_dac[19:16] = 0;
                                    wrData_dac[15:0] = 0;
                                    wr_dac = 1;
                                    dacConfInt = 1;
                                end
                            end
                            2: begin
                                if (!dacConfQ) begin
                                    wrAddr_dac = sdi_addr;
                                    wrData_dac[23:20] = fastMode;
                                    wrData_dac[19:16] = 1;
                                    wrData_dac[15:0] = 0;
                                    wr_dac = 1;
                                    dacConfInt = 1;
                                end
                            end
                            3: begin
                                if (!dacConfQ) begin
                                    wrAddr_dac = sdi_addr;
                                    wrData_dac[23:20] = transmit;
                                    wrData_dac[19:16] = 1;
                                    wrData_dac[15:0] = 0;
                                    wr_dac = 1;
                                    dacConfInt = 1;
                                end
                            end
                            default: begin
                            end
                        endcase
                    end
                end
            end
            ADC_S: begin
                rd_adc = 1;
                rdAddr_adc = 'b0100;
                if ( rdDone_adc && rdData_adc[31] ) begin
                    nextState_s = FIR_S;
                    wrAddr_fir = sampleAddr;
                    wrData_fir[15] = !(rdData_adc[15]); // signed flip
                    wrData_fir[14:0] = rdData_adc[14:0];
                    wr_fir = 1;
                end
            end
            FIR_S: begin
                if ( confCountQ >= 4 && confCountQ < 26 + 4 ) begin
                    if (!attenSpacerQ) begin
                        rd_fir = 0;
                        wr_fir = 1;
                        wrAddr_fir[7:4] = attenCountQ;
                        wrAddr_fir[3:0] = attenAddr;
                        wrData_fir = adBufQ[attenCountQ];
                        confCountInt = confCountQ + 1;
                        attenSpacerInt = 1;
                        attenCountInt = attenCountQ + 1;
                    end else begin
                        wr_fir = 0;
                        attenSpacerInt = 0;
                        confCountInt = confCountQ + 1;
                    end
                end else if (confCountQ < 2) begin
                    rd_fir = 1;
                    rdAddr_fir = sampleAddr;
                    confCountInt = confCountQ + 1;
                end else if (confCountQ == 2 || confCountQ == 3) begin
                    rd_fir = 0; // empty state
                    wr_fir = 0;
                    confCountInt = confCountQ + 1;
                end else begin
                    rd_fir = 1;
                    rdAddr_fir = sampleAddr;
                end
                if ( rdDone_fir && rdData_fir[31] ) begin
                    nextState_s = DAC_S;
                    
                    // write to dac once
                    wrAddr_dac = sdi_addr;
                    wrData_dac[23:20] = transmit;
                    wrData_dac[19:16] = channel_countQ;
                    wrData_dac[15] = !(rdData_fir[15]); // unsigned flip
                    wrData_dac[14:0] = rdData_fir[14:0];
                    wr_dac = 1;
                    
                    // switch channel 1 adc
                    wr_adc = 1;
                    wrAddr_adc = sdi_addr;
                    if (channel_countQ) begin
                        wrData_adc = c1_sdos; // from channel 2 to channel 1
                    end else begin
                        wrData_adc = c2_sdos; // from channel 1 to channel 2
                    end
                end
            end
            DAC_S: begin
                confCountInt = 0;
                nextState_s = ADC_S;
                attenSpacerInt = 0;
                attenCountInt = 0;
                channel_countInt = !(channel_countQ);
                for ( i = 0; i < BAND_COUNT; i = i+1) begin
                    attenDInt[i] = adBufQ[i];
                end
            end
            default: begin
                nextState_s = CONFIG_S;
            end
        endcase
    end
    
    always @ (posedge S_AXI_ACLK) begin
        if ( !S_AXI_ARESETN ) begin
            currentState_s <= CONFIG_S;
            fir_configQ <= 0;
            spi_configQ <= 0;
            channel_countQ <= 0;
            fastCountQ <= 0;
            dacConfQ <= 0;
            confCountQ <= 0;
            attenSpacerQ <= 0;
            attenCountQ <= 0;
            for ( i = 0; i < BAND_COUNT; i=i+1) begin
                attenDQ[i] <= 'h4000;   //attenuation of 1
                adBufQ[i] <= 'h4000;
            end
        end else begin
            currentState_s = nextState_s;
            fir_configQ <= fir_configInt;
            spi_configQ <= spi_configInt;
            channel_countQ <= channel_countInt;
            fastCountQ <= fastCountInt;
            dacConfQ <= dacConfInt;
            confCountQ <= confCountInt;
            attenSpacerQ <= attenSpacerInt;
            attenCountQ <= attenCountInt;
            for ( i = 0; i < BAND_COUNT; i=i+1) begin
                attenDQ[i] <= attenDInt[i];
                adBufQ[i] <= adBufInt[i];
            end
        end
    end
endmodule
