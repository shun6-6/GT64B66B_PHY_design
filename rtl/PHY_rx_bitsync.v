`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/23 11:55:10
// Design Name: 
// Module Name: PHY_rx_bitsync
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


module PHY_rx_bitsync#(
    parameter       P_HEARER_VALID_NUMNER = 64  ,
    parameter       P_SLIPBIT_GAP         = 40  
)(
    input           i_clk                       ,
    input           i_rst                       ,
    input  [1:0]    i_header                    ,
    input           i_headr_valid               ,
    output          o_slipbit                   ,
    output          o_sync                  
);

reg                 ro_slipbit                  ;
reg                 ro_sync                     ;
reg  [15:0]         r_header_valid_cnt          ;
reg  [15:0]         r_header_invalid_cnt        ;
reg  [7 :0]         r_slipbit_gap_cnt           ;

wire                w_header_valid              ;
wire                w_header_invalid            ;
wire                w_valid_cnt_max             ;
wire                w_invalid_cnt_max           ;
wire                w_invalid_cnt_zero          ;

assign o_slipbit            = ro_slipbit                  ;
assign o_sync               = ro_sync                     ;
assign w_header_valid       = i_headr_valid && (i_header==2'b01 || i_header == 2'b10) & !r_slipbit_gap_cnt;
assign w_valid_cnt_max      = r_header_valid_cnt == P_HEARER_VALID_NUMNER - 1;
assign w_header_invalid     = i_headr_valid && !(i_header==2'b01 || i_header == 2'b10) & !r_slipbit_gap_cnt;
assign w_invalid_cnt_max    = r_header_invalid_cnt == P_HEARER_VALID_NUMNER - 1;
assign w_invalid_cnt_zero   = r_header_invalid_cnt == 0;

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_header_valid_cnt <= 'd0;
    else if(w_valid_cnt_max || ro_slipbit)
        r_header_valid_cnt <= 'd0;
    else if(w_header_valid)
        r_header_valid_cnt <= r_header_valid_cnt + 1;
    else   
        r_header_valid_cnt <= r_header_valid_cnt;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_header_invalid_cnt <= 'd0;
    else if(w_invalid_cnt_max || ro_slipbit)
        r_header_invalid_cnt <= 'd0;
    else if(w_header_invalid)
        r_header_invalid_cnt <= r_header_invalid_cnt + 1;
    else   
        r_header_invalid_cnt <= r_header_invalid_cnt;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_slipbit <= 'd0;
    else if(ro_slipbit)
        ro_slipbit <= 'd0;
    else if(!r_slipbit_gap_cnt && (w_header_invalid || !w_invalid_cnt_zero))       
        ro_slipbit <= 'd1;
    else 
        ro_slipbit <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_slipbit_gap_cnt <= 'd0;
    else if(r_slipbit_gap_cnt  == P_SLIPBIT_GAP - 1)       
        r_slipbit_gap_cnt <= 'd0;
    else if(ro_slipbit || r_slipbit_gap_cnt)
        r_slipbit_gap_cnt <= r_slipbit_gap_cnt + 1;
    else 
        r_slipbit_gap_cnt <= r_slipbit_gap_cnt;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_sync <= 'd0;
    else if(!w_invalid_cnt_zero || w_header_invalid)
        ro_sync <= 'd0;
    else if(w_valid_cnt_max && w_invalid_cnt_zero)       
        ro_sync <= 'd1;
    else 
        ro_sync <= ro_sync;
end

endmodule
