`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/04 17:03:34
// Design Name: 
// Module Name: SIM_top_TB
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


module SIM_top_TB();

reg         gtclk_p     ;
reg         clk_p       ;

wire        gtclk_n     ;
wire        clk_n       ;
wire [1 :0]       w_gt_rx_p   ;
wire [1 :0]        w_gt_rx_n   ;

assign gtclk_n  = ~gtclk_p;
assign clk_n    = ~clk_p;

always begin
    gtclk_p = 0;
    #3.2;
    gtclk_p = 1;
    #3.2;
end

always begin
    clk_p = 0;
    #5;
    clk_p = 1;
    #5;
end

XC7Z100_top XC7Z100_top_U0(
    .i_gtrefclk_p           (gtclk_p            ),
    .i_gtrefclk_n           (gtclk_n            ),
    .i_sysclk_p             (clk_p              ),
    .i_sysclk_n             (clk_n              ),
    .i_gt_rx_p              (w_gt_rx_p          ),
    .i_gt_rx_n              (w_gt_rx_n          ),
    .o_gt_tx_p              (w_gt_rx_p          ),
    .o_gt_tx_n              (w_gt_rx_n          ),
    .o_sfp_disable          ()
);


endmodule
