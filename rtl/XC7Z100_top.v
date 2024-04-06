`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/03 10:26:27
// Design Name: 
// Module Name: XC7Z100_top
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


module XC7Z100_top(
    input           i_gtrefclk_p        ,
    input           i_gtrefclk_n        ,
    input           i_sysclk_p          ,
    input           i_sysclk_n          ,

    input  [1 :0]   i_gt_rx_p           ,
    input  [1 :0]   i_gt_rx_n           ,
    output [1 :0]   o_gt_tx_p           ,
    output [1 :0]   o_gt_tx_n           ,
    output [1 :0]   o_sfp_disable       
);

assign o_sfp_disable = 2'b00            ;
wire                w_clk_100Mhz        ;
wire                w_clk_100Mhz_rst    ;
wire                w_clk_locked        ;
wire                w_rx_clk            ;
wire                w_rx_rst            ;
(*MARK_DEBUG = "TRUE"*)wire                w_rx_done           ;
(*MARK_DEBUG = "TRUE"*)wire [63:0]         w_rx_data           ;
(*MARK_DEBUG = "TRUE"*)wire                w_rx_valid          ;
(*MARK_DEBUG = "TRUE"*)wire [1 :0]         w_rx_header         ;
(*MARK_DEBUG = "TRUE"*)wire                w_rx_header_valid   ;
wire                w_rx_slipbit        ;
wire                w_tx_clk            ;
wire                w_tx_rst            ;
(*MARK_DEBUG = "TRUE"*)wire                w_tx_done           ;
(*MARK_DEBUG = "TRUE"*)wire [63:0]         w_tx_data           ;
(*MARK_DEBUG = "TRUE"*)wire [1 :0]         w_tx_header         ;
wire [6 :0]         w_tx_sequence       ;
(*MARK_DEBUG = "TRUE"*)wire                w_data_valid        ;
wire                w_rx_clk_2          ;
wire                w_rx_rst_2          ;
(*MARK_DEBUG = "TRUE"*)wire                w_rx_done_2         ;
(*MARK_DEBUG = "TRUE"*)wire [63:0]         w_rx_data_2         ;
(*MARK_DEBUG = "TRUE"*)wire                w_rx_valid_2        ;
(*MARK_DEBUG = "TRUE"*)wire [1 :0]         w_rx_header_2       ;
(*MARK_DEBUG = "TRUE"*)wire                w_rx_header_valid_2 ;
wire                w_rx_slipbit_2      ;
wire                w_tx_clk_2          ;
wire                w_tx_rst_2          ;
(*MARK_DEBUG = "TRUE"*)wire                w_tx_done_2         ;
(*MARK_DEBUG = "TRUE"*)wire [63:0]         w_tx_data_2         ;
(*MARK_DEBUG = "TRUE"*)wire [1 :0]         w_tx_header_2       ;
wire [6 :0]         w_tx_sequence_2     ;
(*MARK_DEBUG = "TRUE"*)wire                w_data_valid_2      ;
wire [63:0]         m_axi_c1_tx_tdata   ;
wire [7 :0]         m_axi_c1_tx_tkeep   ;
wire                m_axi_c1_tx_tlast   ;
wire                m_axi_c1_tx_tvalid  ;
wire                m_axi_c1_tx_tready  ;
(*MARK_DEBUG = "TRUE"*)wire [63:0]         s_axi_c1_rx_tdata   ;
(*MARK_DEBUG = "TRUE"*)wire [7 :0]         s_axi_c1_rx_tkeep   ;
(*MARK_DEBUG = "TRUE"*)wire                s_axi_c1_rx_tlast   ;
(*MARK_DEBUG = "TRUE"*)wire                s_axi_c1_rx_tvalid  ;
wire [63:0]         m_axi_c2_tx_tdata   ;
wire [7 :0]         m_axi_c2_tx_tkeep   ;
wire                m_axi_c2_tx_tlast   ;
wire                m_axi_c2_tx_tvalid  ;
wire                m_axi_c2_tx_tready  ;
(*MARK_DEBUG = "TRUE"*)wire [63:0]         s_axi_c2_rx_tdata   ;
(*MARK_DEBUG = "TRUE"*)wire [7 :0]         s_axi_c2_rx_tkeep   ;
(*MARK_DEBUG = "TRUE"*)wire                s_axi_c2_rx_tlast   ;
(*MARK_DEBUG = "TRUE"*)wire                s_axi_c2_rx_tvalid  ;

clk_wiz_0 clk_wiz_0_100Mhz
(
    .clk_in1_p                  (i_sysclk_p         ),
    .clk_in1_n                  (i_sysclk_n         ),
    .clk_out1                   (w_clk_100Mhz       ),     
    .locked                     (w_clk_locked       )    
);

rst_gen_module#(
    .P_RST_CYCLE                (20               )   
)
rst_gen_module_u0
(
    .i_rst                      (0                  ),
    .i_clk                      (w_clk_100Mhz       ),
    .o_rst                      (w_clk_100Mhz_rst   )
);

rst_gen_module#(
    .P_RST_CYCLE                (1000           )   
)
rst_gen_module_u1
(
    .i_rst                      (w_clk_100Mhz_rst   ),
    .i_clk                      (w_tx_clk       ),
    .o_rst                      (w_tx_rst       )
);

rst_gen_module#(
    .P_RST_CYCLE                (1000           )   
)
rst_gen_module_u2
(
    .i_rst                      (w_clk_100Mhz_rst   ),
    .i_clk                      (w_rx_clk       ),
    .o_rst                      (w_rx_rst       )
);

rst_gen_module#(
    .P_RST_CYCLE                (1000           )   
)
rst_gen_module_u3
(
    .i_rst                      (w_clk_100Mhz_rst   ),
    .i_clk                      (w_rx_clk_2     ),
    .o_rst                      (w_rx_rst_2     )
);

rst_gen_module#(
    .P_RST_CYCLE                (1000           )   
)
rst_gen_module_u4
(
    .i_rst                      (w_clk_100Mhz_rst   ),
    .i_clk                      (w_tx_clk_2     ),
    .o_rst                      (w_tx_rst_2     )
);

user_data_gen user_data_gen_u0(
    .i_clk                      (w_tx_clk           ),
    .i_rst                      (w_tx_rst           ),
    .m_axi_tx_tdata             (m_axi_c1_tx_tdata  ),
    .m_axi_tx_tkeep             (m_axi_c1_tx_tkeep  ),
    .m_axi_tx_tlast             (m_axi_c1_tx_tlast  ),
    .m_axi_tx_tvalid            (m_axi_c1_tx_tvalid ),
    .m_axi_tx_tready            (m_axi_c1_tx_tready ),
    .s_axi_rx_tdata             (s_axi_c1_rx_tdata  ),
    .s_axi_rx_tkeep             (s_axi_c1_rx_tkeep  ),
    .s_axi_rx_tlast             (s_axi_c1_rx_tlast  ),
    .s_axi_rx_tvalid            (s_axi_c1_rx_tvalid )
);

PHY_Module PHY_Module_u0(
    .i_rx_clk                   (w_rx_clk           ),
    .i_rx_rst                   (w_rx_rst           ),
    .i_rx_data                  (w_rx_data          ),
    .i_rx_valid                 (w_rx_valid         ),
    .i_rx_header                (w_rx_header        ),
    .i_rx_header_valid          (w_rx_header_valid  ),
    .o_rx_slipbit               (w_rx_slipbit       ),
    .i_tx_clk                   (w_tx_clk           ),
    .i_tx_rst                   (w_tx_rst           ),
    .o_tx_data                  (w_tx_data          ),
    .o_tx_header                (w_tx_header        ),
    .o_tx_sequence              (w_tx_sequence      ),
    .o_data_valid               (w_data_valid       ),

    .s_axis_data                (m_axi_c1_tx_tdata  ),
    .s_axis_keep                (m_axi_c1_tx_tkeep  ),
    .s_axis_last                (m_axi_c1_tx_tlast  ),
    .s_axis_valid               (m_axi_c1_tx_tvalid ),
    .s_axis_ready               (m_axi_c1_tx_tready ),
    .m_axis_data                (s_axi_c1_rx_tdata  ),
    .m_axis_keep                (s_axi_c1_rx_tkeep  ),
    .m_axis_last                (s_axi_c1_rx_tlast  ),
    .m_axis_valid               (s_axi_c1_rx_tvalid )
);

user_data_gen user_data_gen_u1(
    .i_clk                      (w_tx_clk_2         ),
    .i_rst                      (w_tx_rst_2         ),
    .m_axi_tx_tdata             (m_axi_c2_tx_tdata  ),
    .m_axi_tx_tkeep             (m_axi_c2_tx_tkeep  ),
    .m_axi_tx_tlast             (m_axi_c2_tx_tlast  ),
    .m_axi_tx_tvalid            (m_axi_c2_tx_tvalid ),
    .m_axi_tx_tready            (m_axi_c2_tx_tready ),
    .s_axi_rx_tdata             (s_axi_c2_rx_tdata  ),
    .s_axi_rx_tkeep             (s_axi_c2_rx_tkeep  ),
    .s_axi_rx_tlast             (s_axi_c2_rx_tlast  ),
    .s_axi_rx_tvalid            (s_axi_c2_rx_tvalid )
);

PHY_Module PHY_Module_u1(
    .i_rx_clk                   (w_rx_clk_2         ),
    .i_rx_rst                   (w_rx_rst_2         ),
    .i_rx_data                  (w_rx_data_2        ),
    .i_rx_valid                 (w_rx_valid_2       ),
    .i_rx_header                (w_rx_header_2      ),
    .i_rx_header_valid          (w_rx_header_valid_2),
    .o_rx_slipbit               (w_rx_slipbit_2     ),
    .i_tx_clk                   (w_tx_clk_2         ),
    .i_tx_rst                   (w_tx_rst_2         ),
    .o_tx_data                  (w_tx_data_2        ),
    .o_tx_header                (w_tx_header_2      ),
    .o_tx_sequence              (w_tx_sequence_2    ),
    .o_data_valid               (w_data_valid_2     ),

    .s_axis_data                (m_axi_c2_tx_tdata  ),
    .s_axis_keep                (m_axi_c2_tx_tkeep  ),
    .s_axis_last                (m_axi_c2_tx_tlast  ),
    .s_axis_valid               (m_axi_c2_tx_tvalid ),
    .s_axis_ready               (m_axi_c2_tx_tready ),
    .m_axis_data                (s_axi_c2_rx_tdata  ),
    .m_axis_keep                (s_axi_c2_rx_tkeep  ),
    .m_axis_last                (s_axi_c2_rx_tlast  ),
    .m_axis_valid               (s_axi_c2_rx_tvalid )
);      

GT_module#(
    .QPLLREFCLKSEL_IN           (3'b010             )   
)
GT_module_u0
(
    .i_sysclk                   (w_clk_100Mhz       ),
    .i_gtrefclk_p               (i_gtrefclk_p       ),
    .i_gtrefclk_n               (i_gtrefclk_n       ),
    .i_rx_rst                   (0                  ),
    .i_tx_rst                   (0                  ),
    .o_tx_done                  (w_tx_done          ),
    .o_rx_done                  (w_rx_done          ),
    .i_tx_polarity              (0                  ),
    .i_tx_diffctrl              (4'b1100            ),
    .i_txpostcursor             (5'b00011           ),
    .i_txpercursor              (5'b00111           ),     
    .i_rx_polarity              (0                  ),
    .i_loopback                 (3'b000             ),
    .i_drpaddr                  (0                  ), 
    .i_drpclk                   (0                  ),
    .i_drpdi                    (0                  ), 
    .o_drpdo                    (                   ), 
    .i_drpen                    (0                  ),
    .o_drprdy                   (                   ),     
    .i_drpwe                    (0                  ),
    .i_data_valid               (w_data_valid       ),
    .o_rx_clk                   (w_rx_clk           ),
    .o_rx_data                  (w_rx_data          ),
    .o_rx_valid                 (w_rx_valid         ),
    .o_rx_header                (w_rx_header        ),
    .o_rx_header_valid          (w_rx_header_valid  ),
    .i_rx_slipbit               (w_rx_slipbit       ),
    .o_tx_clk                   (w_tx_clk           ),
    .i_tx_data                  (w_tx_data          ),
    .i_tx_header                (w_tx_header        ),
    .i_tx_sequence              (w_tx_sequence      ),      
    .o_gt_tx_p                  (o_gt_tx_p[0]       ),
    .o_gt_tx_n                  (o_gt_tx_n[0]       ),
    .i_gt_rx_p                  (i_gt_rx_p[0]       ),
    .i_gt_rx_n                  (i_gt_rx_n[0]       ),

    .i_rx_rst_2                 (0                  ),
    .i_tx_rst_2                 (0                  ),
    .o_tx_done_2                (),
    .o_rx_done_2                (),
    .i_tx_polarity_2            (0                  ),
    .i_tx_diffctrl_2            (4'b1100            ),
    .i_txpostcursor_2           (5'b00011           ),
    .i_txpercursor_2            (5'b00111           ),     
    .i_rx_polarity_2            (0                  ),
    .i_loopback_2               (3'b000             ),
    .i_drpaddr_2                (0                  ), 
    .i_drpclk_2                 (0                  ),
    .i_drpdi_2                  (0                  ), 
    .o_drpdo_2                  (                   ), 
    .i_drpen_2                  (0                  ),
    .o_drprdy_2                 (                   ), 
    .i_drpwe_2                  (0                  ),
    .i_data_valid_2             (w_data_valid_2     ),
    .o_rx_clk_2                 (w_rx_clk_2         ),
    .o_rx_data_2                (w_rx_data_2        ),
    .o_rx_valid_2               (w_rx_valid_2       ),
    .o_rx_header_2              (w_rx_header_2      ),
    .o_rx_header_valid_2        (w_rx_header_valid_2),
    .i_rx_slipbit_2             (w_rx_slipbit_2     ),
    .o_tx_clk_2                 (w_tx_clk_2         ),
    .i_tx_data_2                (w_tx_data_2        ),
    .i_tx_header_2              (w_tx_header_2      ),
    .i_tx_sequence_2            (w_tx_sequence_2    ),      
    .o_gt_tx_p_2                (o_gt_tx_p[1]       ),
    .o_gt_tx_n_2                (o_gt_tx_n[1]       ),
    .i_gt_rx_p_2                (i_gt_rx_p[1]       ),
    .i_gt_rx_n_2                (i_gt_rx_n[1]       )
);
endmodule

