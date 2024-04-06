module GT_channel(
    input                   i_sysclk                    ,
    input                   i_gtrefclk                  ,
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
    input                   i_qplllock                  , 
    input                   i_qpllrefclklost            , 
    output                  o_qpllreset                 ,
    input                   i_qplloutclk                , 
    input                   i_qplloutrefclk             , 
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
    input                   i_gt_rx_n                   
);



wire                        gt0_txusrclk_i              ;
wire                        gt0_txusrclk2_i             ;
wire                        gt0_txoutclk_i              ;
wire                        gt0_txmmcm_lock_i           ;
wire                        gt0_txmmcm_reset_i          ;
wire                        gt0_rxusrclk_i              ;
wire                        gt0_rxusrclk2_i             ;
wire                        gt0_rxmmcm_lock_i           ;
wire                        gt0_rxmmcm_reset_i          ;

assign o_tx_clk = gt0_txusrclk2_i;
assign o_rx_clk = gt0_txusrclk2_i;


//根据gt0_txoutclk_i产生用户发送和接收时钟信号
gtwizard_0_GT_USRCLK_SOURCE gt_usrclk_source
(
    .GT0_TXUSRCLK_OUT           (gt0_txusrclk_i         ),
    .GT0_TXUSRCLK2_OUT          (gt0_txusrclk2_i        ),
    .GT0_TXOUTCLK_IN            (gt0_txoutclk_i         ),
    .GT0_TXCLK_LOCK_OUT         (gt0_txmmcm_lock_i      ),
    .GT0_TX_MMCM_RESET_IN       (gt0_txmmcm_reset_i     ),
    .GT0_RXUSRCLK_OUT           (gt0_rxusrclk_i         ),
    .GT0_RXUSRCLK2_OUT          (gt0_rxusrclk2_i        ),
    .GT0_RXCLK_LOCK_OUT         (gt0_rxmmcm_lock_i      ),
    .GT0_RX_MMCM_RESET_IN       (gt0_rxmmcm_reset_i     )
);

gtwizard_0  gtwizard_0_i
(
    .sysclk_in                      (i_sysclk               ),
    .soft_reset_tx_in               (i_tx_rst               ),
    .soft_reset_rx_in               (i_rx_rst               ),
    .dont_reset_on_data_error_in    (0                      ),
    .gt0_tx_fsm_reset_done_out      (                       ),
    .gt0_rx_fsm_reset_done_out      (o_rx_done              ),
    .gt0_data_valid_in              (i_data_valid           ),
    .gt0_tx_mmcm_lock_in            (gt0_txmmcm_lock_i      ),
    .gt0_tx_mmcm_reset_out          (gt0_txmmcm_reset_i     ),
    .gt0_rx_mmcm_lock_in            (gt0_rxmmcm_lock_i      ),
    .gt0_rx_mmcm_reset_out          (gt0_rxmmcm_reset_i     ),

    .gt0_drpaddr_in                 (i_drpaddr              ),
    .gt0_drpclk_in                  (i_drpclk               ),
    .gt0_drpdi_in                   (i_drpdi                ),
    .gt0_drpdo_out                  (o_drpdo                ),
    .gt0_drpen_in                   (i_drpen                ),
    .gt0_drprdy_out                 (o_drprdy               ),
    .gt0_drpwe_in                   (i_drpwe                ),

    .gt0_dmonitorout_out            (                       ),
    .gt0_loopback_in                (i_loopback             ),
    .gt0_eyescanreset_in            (0                      ),
    .gt0_rxuserrdy_in               (1                      ),
    .gt0_eyescandataerror_out       (                       ),
    .gt0_eyescantrigger_in          (0                      ),
    .gt0_rxclkcorcnt_out            (                       ),
    .gt0_rxusrclk_in                (gt0_rxusrclk_i         ),
    .gt0_rxusrclk2_in               (gt0_rxusrclk2_i        ),
    .gt0_rxdata_out                 (o_rx_data              ),
    .gt0_gtxrxp_in                  (i_gt_rx_p              ),
    .gt0_gtxrxn_in                  (i_gt_rx_n              ),
    
    .gt0_rxdfelpmreset_in           (0                      ),
    .gt0_rxmonitorout_out           (                       ),
    .gt0_rxmonitorsel_in            (0                      ),
    .gt0_rxoutclkfabric_out         (                       ),
    .gt0_rxdatavalid_out            (o_rx_valid             ),
    .gt0_rxheader_out               (o_rx_header            ),
    .gt0_rxheadervalid_out          (o_rx_header_valid      ),
    .gt0_rxgearboxslip_in           (i_rx_slipbit           ),
    .gt0_gtrxreset_in               (i_rx_rst               ),
    .gt0_rxpmareset_in              (0                      ),
    .gt0_rxpolarity_in              (i_rx_polarity          ),
    .gt0_rxresetdone_out            (                       ),
    
    .gt0_txpostcursor_in            (i_txpostcursor         ),
    .gt0_txprecursor_in             (i_txpercursor          ),
    .gt0_gttxreset_in               (i_tx_rst               ),
    .gt0_txuserrdy_in               (1                      ),
    .gt0_txusrclk_in                (gt0_txusrclk_i         ),
    .gt0_txusrclk2_in               (gt0_txusrclk2_i        ),
    .gt0_txdiffctrl_in              (i_tx_diffctrl          ),
    .gt0_txdata_in                  (i_tx_data              ),
    .gt0_gtxtxn_out                 (o_gt_tx_n              ),
    .gt0_gtxtxp_out                 (o_gt_tx_p              ),
    .gt0_txoutclk_out               (gt0_txoutclk_i         ),
    .gt0_txoutclkfabric_out         (                       ),
    .gt0_txoutclkpcs_out            (                       ),
    .gt0_txheader_in                (i_tx_header            ),
    .gt0_txsequence_in              (i_tx_sequence          ),
    .gt0_txresetdone_out            (o_tx_done              ),
    .gt0_txpolarity_in              (i_tx_polarity          ),
    
    .gt0_qplllock_in                (i_qplllock             ),
    .gt0_qpllrefclklost_in          (i_qpllrefclklost       ),
    .gt0_qpllreset_out              (o_qpllreset            ),
    .gt0_qplloutclk_in              (i_qplloutclk           ),
    .gt0_qplloutrefclk_in           (i_qplloutrefclk        ) 
);






endmodule
