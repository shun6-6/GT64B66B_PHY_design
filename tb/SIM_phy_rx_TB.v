`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/05 14:45:24
// Design Name: 
// Module Name: SIM_phy_rx_TB
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


module SIM_phy_rx_TB();

reg clk,rst;

initial begin
    rst = 1;
    #100;
    @(posedge clk)rst = 0;
end

always begin
    clk = 1;
    #10;
    clk = 0;
    #10;
end

reg  [63:0]     r_rx_data               ;
reg             r_rx_valid              ;
reg  [1 :0]     r_rx_header             ;
wire            r_rx_header_valid       ;
wire [63:0]     m_axis_data             ;   
wire [7 :0]     m_axis_keep             ;   
wire            m_axis_last             ;   
wire            m_axis_valid            ;

assign r_rx_header_valid = r_rx_valid   ;

PHY_rx PHY_rx_u0(
    .i_rx_clk              (clk                         ),
    .i_rx_rst              (rst                         ),
    .i_rx_data             (r_rx_data                   ),
    .i_rx_valid            (r_rx_valid                  ),
    .i_rx_header           (r_rx_header                 ),
    .i_rx_header_valid     (r_rx_header_valid           ),
    .m_axis_data           (m_axis_data                 ),
    .m_axis_keep           (m_axis_keep                 ),
    .m_axis_last           (m_axis_last                 ),
    .m_axis_valid          (m_axis_valid                )
);



task send_data();
begin
    integer i;
    r_rx_data   <= 'd0;
    r_rx_header <= 'd0;
    @(posedge clk);
    for(i = 0 ;i < 10;i = i+ 1)
    begin

    end
end
endtask


endmodule
