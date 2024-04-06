`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/05 11:05:27
// Design Name: 
// Module Name: SIM_phy_TB
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


module SIM_phy_TB();

reg clk,rst;

initial begin
    rst = 1;
    #100;
    @(posedge clk)rst = 0;
end

always begin
    clk = 0;
    #10;
    clk = 1;
    #10;
end

wire [63:0] w_rx_data           ;
wire        w_rx_valid          ;
wire [1 :0] w_rx_header         ;
wire        w_rx_header_valid   ;
wire        w_rx_slipbit        ;
wire        m_axi_tx_tready     ;

reg  [63:0] m_axi_tx_tdata      ;
reg  [7 :0] m_axi_tx_tkeep      ;
reg         m_axi_tx_tlast      ;
reg         m_axi_tx_tvalid     ;
wire [6 :0] w_tx_sequence       ;

assign w_rx_valid  = w_tx_sequence != 32;
assign w_rx_header_valid = w_rx_valid;

PHY_Module PHY_Module_u1(
    .i_rx_clk                   (clk                ),
    .i_rx_rst                   (rst                ),
    .i_rx_data                  (w_rx_data          ),
    .i_rx_valid                 (w_rx_valid         ),
    .i_rx_header                (w_rx_header        ),
    .i_rx_header_valid          (w_rx_header_valid  ),
    .o_rx_slipbit               (w_rx_slipbit       ),
    .i_tx_clk                   (clk                ),
    .i_tx_rst                   (rst                ),
    .o_tx_data                  (w_rx_data          ),
    .o_tx_header                (w_rx_header        ),
    .o_tx_sequence              (w_tx_sequence      ),
    .o_data_valid               (         ),

    .s_axis_data                (m_axi_tx_tdata  ),
    .s_axis_keep                (m_axi_tx_tkeep  ),
    .s_axis_last                (m_axi_tx_tlast  ),
    .s_axis_valid               (m_axi_tx_tvalid ),
    .s_axis_ready               (m_axi_tx_tready ),
    .m_axis_data                (s_axi_rx_tdata  ),
    .m_axis_keep                (s_axi_rx_tkeep  ),
    .m_axis_last                (s_axi_rx_tlast  ),
    .m_axis_valid               (s_axi_rx_tvalid )
);

initial 
begin
    m_axi_tx_tdata  = 'd0;
    m_axi_tx_tkeep  = 'd0;
    m_axi_tx_tlast  = 'd0;
    m_axi_tx_tvalid = 'd0;
    wait(!rst);
    repeat(10)@(posedge clk);
    forever begin
        data_send(8'b1000_0000);
        repeat(20)@(posedge clk);
    end
    
end

task data_send(input [7 :0] keep);
begin:data_send_task
    integer  i;
    reg [7 :0] num;
    m_axi_tx_tdata  <= 'd0;
    m_axi_tx_tkeep  <= 'd0;
    m_axi_tx_tlast  <= 'd0;
    m_axi_tx_tvalid <= 'd0;
    num <= 8'd0;
    @(posedge clk);
    for(i = 0 ;i < 10;i = i + 1)
    begin
        m_axi_tx_tdata  <= {num+8'd0,num+8'd1,num+8'd2,num+8'd3,num+8'd4,num+8'd5,num+8'd6,num+8'd7};
        if(i == 10 - 1)m_axi_tx_tkeep  <= keep;
        else if(i == 10 - 1)m_axi_tx_tkeep  <= 8'b1111_1111;
        if(i == 10 - 1)m_axi_tx_tlast  <= 'd1;
        else m_axi_tx_tlast  <= 'd0;
        m_axi_tx_tvalid <= 'd1;
        num <= num + 8'd8;
        @(posedge clk);
    end
    m_axi_tx_tdata  <= 'd0;
    m_axi_tx_tkeep  <= 'd0;
    m_axi_tx_tlast  <= 'd0;
    m_axi_tx_tvalid <= 'd0;
    num <= 'd0;
    @(posedge clk);
end
endtask

endmodule
