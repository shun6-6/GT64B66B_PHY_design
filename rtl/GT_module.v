`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/23 11:55:29
// Design Name: 
// Module Name: GT_module
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


module GT_module#(
    parameter               QPLLREFCLKSEL_IN = 3'b001   
)(
    input                   i_sysclk                    ,
    input                   i_gtrefclk_p                ,
    input                   i_gtrefclk_n                ,

    input                   i_rx_rst                    ,
    input                   i_tx_rst                    ,
    output                  o_tx_done                   ,
    output                  o_rx_done                   ,
    input                   i_tx_polarity               ,
    input  [3 :0]           i_tx_diffctrl               ,
    input  [4 :0]           i_txpostcursor              ,
    input  [4 :0]           i_txpercursor               ,     
    input                   i_rx_polarity               ,
    input  [2 :0]           i_loopback                  ,
    input  [8 :0]           i_drpaddr                   , 
    input                   i_drpclk                    ,
    input  [15:0]           i_drpdi                     , 
    output [15:0]           o_drpdo                     , 
    input                   i_drpen                     ,
    output                  o_drprdy                    , 
    input                   i_drpwe                     ,
    input                   i_data_valid                ,
    output                  o_rx_clk                    ,
    output [63:0]           o_rx_data                   ,
    output                  o_rx_valid                  ,
    output [1 :0]           o_rx_header                 ,
    output                  o_rx_header_valid           ,
    input                   i_rx_slipbit                ,
    output                  o_tx_clk                    ,
    input  [63:0]           i_tx_data                   ,
    input  [1 :0]           i_tx_header                 ,
    input  [6 :0]           i_tx_sequence               ,      
    output                  o_gt_tx_p                   ,
    output                  o_gt_tx_n                   ,
    input                   i_gt_rx_p                   ,
    input                   i_gt_rx_n                   ,

    input                   i_rx_rst_2                  ,
    input                   i_tx_rst_2                  ,
    output                  o_tx_done_2                 ,
    output                  o_rx_done_2                 ,
    input                   i_tx_polarity_2             ,
    input  [3 :0]           i_tx_diffctrl_2             ,
    input  [4 :0]           i_txpostcursor_2            ,
    input  [4 :0]           i_txpercursor_2             ,     
    input                   i_rx_polarity_2             ,
    input  [2 :0]           i_loopback_2                ,
    input  [8 :0]           i_drpaddr_2                 , 
    input                   i_drpclk_2                  ,
    input  [15:0]           i_drpdi_2                   , 
    output [15:0]           o_drpdo_2                   , 
    input                   i_drpen_2                   ,
    output                  o_drprdy_2                  , 
    input                   i_drpwe_2                   ,
    input                   i_data_valid_2              ,
    output                  o_rx_clk_2                  ,
    output [63:0]           o_rx_data_2                 ,
    output                  o_rx_valid_2                ,
    output [1 :0]           o_rx_header_2               ,
    output                  o_rx_header_valid_2         ,
    input                   i_rx_slipbit_2              ,
    output                  o_tx_clk_2                  ,
    input  [63:0]           i_tx_data_2                 ,
    input  [1 :0]           i_tx_header_2               ,
    input  [6 :0]           i_tx_sequence_2             ,      
    output                  o_gt_tx_p_2                 ,
    output                  o_gt_tx_n_2                 ,
    input                   i_gt_rx_p_2                 ,
    input                   i_gt_rx_n_2                 
);

wire                        w_gtrefclk                  ;
wire                        w_qplllock                  ;
wire                        w_qpllrefclklost            ;
wire                        w_qpllreset                 ;
wire                        w_qplloutclk                ;
wire                        w_qplloutrefclk             ;
wire                        w_common_rst                ;

IBUFDS_GTE2 #(
    .CLKCM_CFG      ("TRUE"             ),
    .CLKRCV_TRST    ("TRUE"             ),
    .CLKSWING_CFG   (2'b11              ) 
)
IBUFDS_GTE2_inst (
    .O              (w_gtrefclk         ),
    .ODIV2          (                   ),
    .CEB            (0                  ),
    .I              (i_gtrefclk_p       ),
    .IB             (i_gtrefclk_n       ) 
   );

gtwizard_0_common #
(
    .WRAPPER_SIM_GTRESET_SPEEDUP        ("TRUE"                         ),
    .SIM_QPLLREFCLK_SEL                 (QPLLREFCLKSEL_IN               )
)
common0_i
(
    .QPLLREFCLKSEL_IN                   (QPLLREFCLKSEL_IN               ),
    .GTREFCLK0_IN                       (0                              ),
    .GTREFCLK1_IN                       (w_gtrefclk                     ),
    .QPLLLOCK_OUT                       (w_qplllock                     ),
    .QPLLLOCKDETCLK_IN                  (i_sysclk                       ),
    .QPLLOUTCLK_OUT                     (w_qplloutclk                   ),
    .QPLLOUTREFCLK_OUT                  (w_qplloutrefclk                ),
    .QPLLREFCLKLOST_OUT                 (w_qpllrefclklost               ),    
    .QPLLRESET_IN                       (w_qpllreset|w_common_rst       )

);

gtwizard_0_common_reset # 
(
    .STABLE_CLOCK_PERIOD                (50                             )    
)                       
common_reset_i                      
(                           
    .STABLE_CLOCK                       (i_sysclk                       ),   
    .SOFT_RESET                         (i_tx_rst                       ),   
    .COMMON_RESET                       (w_common_rst                   )    
);

GT_channel GT_channel_u0(
    .i_sysclk                           (i_sysclk                       ),
    .i_gtrefclk                         (w_gtrefclk                     ),
    .i_rx_rst                           (i_rx_rst                       ),
    .i_tx_rst                           (i_tx_rst                       ),
    .o_tx_done                          (o_tx_done                      ),
    .o_rx_done                          (o_rx_done                      ),
    .i_tx_polarity                      (i_tx_polarity                  ),
    .i_tx_diffctrl                      (i_tx_diffctrl                  ),
    .i_txpostcursor                     (i_txpostcursor                 ),
    .i_txpercursor                      (i_txpercursor                  ),     
    .i_rx_polarity                      (i_rx_polarity                  ),
    .i_loopback                         (i_loopback                     ),
    .i_drpaddr                          (i_drpaddr                      ), 
    .i_drpclk                           (i_drpclk                       ),
    .i_drpdi                            (i_drpdi                        ), 
    .o_drpdo                            (o_drpdo                        ), 
    .i_drpen                            (i_drpen                        ),
    .o_drprdy                           (o_drprdy                       ), 
    .i_drpwe                            (i_drpwe                        ),
    .i_qplllock                         (w_qplllock                     ), 
    .i_qpllrefclklost                   (w_qpllrefclklost               ), 
    .o_qpllreset                        (w_qpllreset                    ),
    .i_qplloutclk                       (w_qplloutclk                   ), 
    .i_qplloutrefclk                    (w_qplloutrefclk                ), 
    .i_data_valid                       (i_data_valid                   ),
    .o_rx_clk                           (o_rx_clk                       ),
    .o_rx_data                          (o_rx_data                      ),
    .o_rx_valid                         (o_rx_valid                     ),
    .o_rx_header                        (o_rx_header                    ),
    .o_rx_header_valid                  (o_rx_header_valid              ),
    .i_rx_slipbit                       (i_rx_slipbit                   ),

    .o_tx_clk                           (o_tx_clk                       ),
    .i_tx_data                          (i_tx_data                      ),
    .i_tx_header                        (i_tx_header                    ),
    .i_tx_sequence                      (i_tx_sequence                  ),      

    .o_gt_tx_p                          (o_gt_tx_p                      ),
    .o_gt_tx_n                          (o_gt_tx_n                      ),
    .i_gt_rx_p                          (i_gt_rx_p                      ),
    .i_gt_rx_n                          (i_gt_rx_n                      )
);

GT_channel GT_channel_u1(
    .i_sysclk                           (i_sysclk                       ),
    .i_gtrefclk                         (w_gtrefclk                     ),
    .i_rx_rst                           (i_rx_rst_2                     ),
    .i_tx_rst                           (i_tx_rst_2                     ),
    .o_tx_done                          (o_tx_done_2                    ),
    .o_rx_done                          (o_rx_done_2                    ),
    .i_tx_polarity                      (i_tx_polarity_2                ),
    .i_tx_diffctrl                      (i_tx_diffctrl_2                ),
    .i_txpostcursor                     (i_txpostcursor_2               ),
    .i_txpercursor                      (i_txpercursor_2                ),     
    .i_rx_polarity                      (i_rx_polarity_2                ),
    .i_loopback                         (i_loopback_2                   ),
    .i_drpaddr                          (i_drpaddr_2                    ), 
    .i_drpclk                           (i_drpclk_2                     ),
    .i_drpdi                            (i_drpdi_2                      ), 
    .o_drpdo                            (o_drpdo_2                      ), 
    .i_drpen                            (i_drpen_2                      ),
    .o_drprdy                           (o_drprdy_2                     ), 
    .i_drpwe                            (i_drpwe_2                      ),
    .i_qplllock                         (w_qplllock                     ), 
    .i_qpllrefclklost                   (w_qpllrefclklost               ), 
    .o_qpllreset                        (                               ),
    .i_qplloutclk                       (w_qplloutclk                   ), 
    .i_qplloutrefclk                    (w_qplloutrefclk                ), 
    .i_data_valid                       (i_data_valid_2                 ),
    .o_rx_clk                           (o_rx_clk_2                     ),
    .o_rx_data                          (o_rx_data_2                    ),
    .o_rx_valid                         (o_rx_valid_2                   ),
    .o_rx_header                        (o_rx_header_2                  ),
    .o_rx_header_valid                  (o_rx_header_valid_2            ),
    .i_rx_slipbit                       (i_rx_slipbit_2                 ),
                
    .o_tx_clk                           (o_tx_clk_2                     ),
    .i_tx_data                          (i_tx_data_2                    ),
    .i_tx_header                        (i_tx_header_2                  ),
    .i_tx_sequence                      (i_tx_sequence_2                ),      
                
    .o_gt_tx_p                          (o_gt_tx_p_2                    ),
    .o_gt_tx_n                          (o_gt_tx_n_2                    ),
    .i_gt_rx_p                          (i_gt_rx_p_2                    ),
    .i_gt_rx_n                          (i_gt_rx_n_2                    )
);

endmodule
