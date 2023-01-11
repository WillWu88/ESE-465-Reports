`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2022 03:00:23 PM
// Design Name: 
// Module Name: async_ram
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


module async_ram #
    (parameter RAM_HEIGHT = 279, RAM_WIDTH = 16)
    (
        input clk,
        input we,
        input [RAM_WIDTH-1:0] a,
        input [RAM_WIDTH-1:0] di,
        output [RAM_WIDTH-1:0] do
    );
    reg signed [RAM_WIDTH-1:0] ram [0:RAM_HEIGHT-1];
    always @(posedge clk) begin
        if (we) begin
            ram[a] <= di;
        end
    end
    assign do = ram[a];

endmodule
