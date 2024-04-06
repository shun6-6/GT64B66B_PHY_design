`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/23 11:55:10
// Design Name: 
// Module Name: PHY_Module
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


module PHY_Module(
    /*----gt port----*/
    input                   i_rx_clk                    ,
    input                   i_rx_rst                    ,
    input  [63:0]           i_rx_data                   ,
    input                   i_rx_valid                  ,
    input  [1 :0]           i_rx_header                 ,
    input                   i_rx_header_valid           ,
    output                  o_rx_slipbit                ,
    input                   i_tx_clk                    ,
    input                   i_tx_rst                    ,
    output [63:0]           o_tx_data                   ,
    output [1 :0]           o_tx_header                 ,
    output [6 :0]           o_tx_sequence               ,
    output                  o_data_valid                ,

    /*----user port----*/
    input  [63:0]           s_axis_data                 ,
    input  [7 :0]           s_axis_keep                 ,
    input                   s_axis_last                 ,
    input                   s_axis_valid                ,
    output                  s_axis_ready                ,
    output [63:0]           m_axis_data                 ,
    output [7 :0]           m_axis_keep                 ,
    output                  m_axis_last                 ,
    output                  m_axis_valid                
);


reg  [1 :0] ro_tx_header        ;
reg  [6 :0] ro_tx_sequence      ;

reg         r_rx_valid         ;
reg  [1 :0] r_rx_header        ;
reg         r_rx_header_valid  ;

wire        w_sync          ;
wire [63:0] w_tx_phy_data   ;
wire [1 :0] w_tx_header     ;
wire [6 :0] w_tx_sequence   ;
wire [63:0] w_rx_descrambler_data;

assign o_data_valid = w_sync        ;
assign o_tx_header  = ro_tx_header  ;
assign o_tx_sequence = ro_tx_sequence;

always @(posedge i_tx_clk or posedge i_tx_rst)begin
    if(i_tx_rst)begin
        ro_tx_header <= 'd0;
        ro_tx_sequence <= 'd0;
    end
    else begin
        ro_tx_header <= w_tx_header;
        ro_tx_sequence <= w_tx_sequence;
    end

end

always @(posedge i_rx_clk or posedge i_rx_rst)begin
    if(i_rx_rst)begin
        r_rx_valid        <= 'd0;
        r_rx_header       <= 'd0;
        r_rx_header_valid <= 'd0;
    end
    else begin
        r_rx_valid        <= i_rx_valid       ;
        r_rx_header       <= i_rx_header      ;
        r_rx_header_valid <= i_rx_header_valid;
    end
end


//ISERDER一样
PHY_rx_bitsync PHY_rx_bitsync_u0(
    .i_clk                  (i_rx_clk                   ),
    .i_rst                  (i_rx_rst                   ),
    .i_header               (i_rx_header                ),//64B66B 头只有2'b01与2'b10是有效头
    .i_headr_valid          (i_rx_header_valid          ),
    .o_slipbit              (o_rx_slipbit               ),
    .o_sync                 (w_sync                     )        
);

gtwizard_0_DESCRAMBLER #
(
    .RX_DATA_WIDTH ( 64 )    
)
descrambler_0_i
(
    // User Interface
    .SCRAMBLED_DATA_IN	    (i_rx_data              ),
    .UNSCRAMBLED_DATA_OUT	(w_rx_descrambler_data  ),
    .DATA_VALID_IN		    (i_rx_valid             ),

   // System Interface
    .USER_CLK		        (i_rx_clk               ),
    .SYSTEM_RESET		    (i_rx_rst               )
);

gtwizard_0_SCRAMBLER #
(
    .TX_DATA_WIDTH          ( 64 )    
)
scrambler_0_i
(
    // User Interface
    .UNSCRAMBLED_DATA_IN    (w_tx_phy_data          ),
    .SCRAMBLED_DATA_OUT	    (o_tx_data              ),
    .DATA_VALID_IN		    (w_tx_data_valid        ),
   // System Interface
    .USER_CLK		        (i_tx_clk               ),
    .SYSTEM_RESET		    (i_tx_rst               )

);

PHY_rx PHY_rx_u0(
    .i_rx_clk              (i_rx_clk                    ),
    .i_rx_rst              (~w_sync                     ),
    .i_rx_data             (w_rx_descrambler_data       ),
    .i_rx_valid            (r_rx_valid                  ),
    .i_rx_header           (r_rx_header                 ),
    .i_rx_header_valid     (r_rx_header_valid           ),
    .m_axis_data           (m_axis_data                 ),
    .m_axis_keep           (m_axis_keep                 ),
    .m_axis_last           (m_axis_last                 ),
    .m_axis_valid          (m_axis_valid                )
);

PHY_tx PHY_tx_u0(
    .i_tx_clk              (i_tx_clk                    ),
    .i_tx_rst              (i_tx_rst                    ),
    .o_tx_data             (w_tx_phy_data               ),
    .o_tx_header           (w_tx_header                 ),
    .o_tx_sequence         (w_tx_sequence               ),
    .o_tx_data_valid       (w_tx_data_valid             ),
    .s_axis_data           (s_axis_data                 ),
    .s_axis_keep           (s_axis_keep                 ),
    .s_axis_last           (s_axis_last                 ),
    .s_axis_valid          (s_axis_valid                ),
    .s_axis_ready          (s_axis_ready                )        
);

endmodule
