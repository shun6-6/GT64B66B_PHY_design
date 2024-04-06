`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/23 11:55:10
// Design Name: 
// Module Name: PHY_tx
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


module PHY_tx(
    input                   i_tx_clk                    ,
    input                   i_tx_rst                    ,
    output [63:0]           o_tx_data                   ,
    output [1 :0]           o_tx_header                 ,
    output [6 :0]           o_tx_sequence               ,
    output                  o_tx_data_valid             ,

    input  [63:0]           s_axis_data                 ,
    input  [7 :0]           s_axis_keep                 ,
    input                   s_axis_last                 ,
    input                   s_axis_valid                ,
    output                  s_axis_ready                        
);



reg             r_fifo_rden         ;
reg             r_fifo_rden_1d      ;
reg             r_fifo_rden_2d      ;
reg             r_fifo_rden_3d      ;
reg  [15:0]     r_cnt               ;
reg  [15:0]     r_len               ;
reg             r_axis_last         ;
reg  [5 :0]     ro_tx_sequence      ;
reg  [63:0]     ro_tx_data          ;
reg  [1 :0]     ro_tx_header        ;
reg  [15:0]     r_send_cnt          ;
reg             r_input_end         ;
reg  [63:0]     r_fifo_dout         ;
reg  [7 :0]     r_axis_keep         ;
reg  [1 :0]     r_fifo_empty        ;
reg             rs_axis_ready       ;
reg             r_invalid           ;

wire            w_gt_send_valid     ;
wire            w_axis_active       ;
wire [63:0]     w_fifo_dout         ;
wire            w_fifo_full         ;
wire            w_fifo_empty        ;

assign          s_axis_ready    = rs_axis_ready                 ;
assign          o_tx_sequence   = {1'b0,ro_tx_sequence}         ;
assign          w_axis_active   = s_axis_valid & s_axis_ready   ;
assign          w_gt_send_valid = ro_tx_sequence == 30 ? 0 : 1  ;

assign          o_tx_data       = { ro_tx_data[7 : 0],ro_tx_data[15: 8],ro_tx_data[23:16],ro_tx_data[31:24],
                                    ro_tx_data[39:32],ro_tx_data[47:40],ro_tx_data[55:48],ro_tx_data[63:56]};

assign          o_tx_header     = ro_tx_header                  ;

assign o_tx_data_valid = ro_tx_sequence != 32;

FIFO_64X512 FIFO_64X512_U0 (
  .clk                      (i_tx_clk               ),
  .din                      (s_axis_data            ),
  .wr_en                    (w_axis_active          ),
  .rd_en                    (r_fifo_rden            ),
  .dout                     (w_fifo_dout            ),
  .full                     (w_fifo_full            ),
  .empty                    (w_fifo_empty           ) 
);

always@(posedge i_tx_clk,posedge i_tx_rst)
begin
    if(i_tx_rst)
        r_axis_last <= 'd0;
    else 
        r_axis_last <= s_axis_last;
end

always@(posedge i_tx_clk,posedge i_tx_rst)
begin
    if(i_tx_rst)   
        r_cnt <= 'd0;
    else if(w_axis_active)
        r_cnt <= r_cnt + 1;
    else    
        r_cnt <= 'd0;
end

always@(posedge i_tx_clk,posedge i_tx_rst)
begin
    if(i_tx_rst)    
        r_len <= 'd0;
    else if(r_axis_last)
        r_len <= r_cnt;
    else 
        r_len <= r_len;
end

always@(posedge i_tx_clk,posedge i_tx_rst)
begin
    if(i_tx_rst)
        ro_tx_sequence <= 'd0;
    else if(ro_tx_sequence == 32)
        ro_tx_sequence <= 'd0;
    else 
        ro_tx_sequence <= ro_tx_sequence + 1;
end

always@(posedge i_tx_clk,posedge i_tx_rst)
begin
    if(i_tx_rst)
        r_input_end <= 'd0;
    else if(s_axis_last)
        r_input_end <= 'd1;
    else if(s_axis_valid)
        r_input_end <= 'd0;
    else 
        r_input_end <= r_input_end;
end

always@(posedge i_tx_clk,posedge i_tx_rst)
begin
    if(i_tx_rst)
        r_send_cnt <= 'd0;
    else if(r_input_end && r_send_cnt == r_len - 0)
        r_send_cnt <= 'd0;
    else if(r_invalid && r_send_cnt)
        r_send_cnt <= r_send_cnt;
    else if(r_invalid && r_fifo_rden_2d && !r_fifo_rden_3d)
        r_send_cnt <= r_send_cnt + 1;
    else if((!r_invalid && r_fifo_rden_1d && !r_fifo_rden_2d) || (r_send_cnt && w_gt_send_valid))
        r_send_cnt <= r_send_cnt + 1;
    else 
        r_send_cnt <= r_send_cnt;
end


always@(posedge i_tx_clk,posedge i_tx_rst)
begin
    if(i_tx_rst)
        r_fifo_dout <= 'd0;
    else if(r_fifo_rden)
        r_fifo_dout <= w_fifo_dout;
    else 
        r_fifo_dout <= r_fifo_dout;
end

always@(posedge i_tx_clk,posedge i_tx_rst)
begin
    if(i_tx_rst)
        r_axis_keep <= 'd0;
    else if(s_axis_last)
        r_axis_keep <= s_axis_keep;
    else 
        r_axis_keep <= r_axis_keep;
end

always@(posedge i_tx_clk,posedge i_tx_rst)
begin
    if(i_tx_rst)
        ro_tx_data <= 'd0;
    else if(r_send_cnt && r_input_end && ((r_axis_keep > 8'b1111_1100 && r_send_cnt == r_len - 0) 
            || (r_axis_keep <= 8'b1111_1100 && r_send_cnt == r_len - 1)))
        case(r_axis_keep)
            8'b1111_1111:ro_tx_data <= {8'h99,r_fifo_dout[7 :0],6'd0,7'h16,7'h16,7'h16,7'h16,7'h16,7'h16};
            8'b1111_1110:ro_tx_data <= {8'h8e,7'd0,7'h16,7'h16,7'h16,7'h16,7'h16,7'h16,7'h16};
            8'b1111_1100:ro_tx_data <= {8'hff,r_fifo_dout[7 :0],w_fifo_dout[63:16]};
            8'b1111_1000:ro_tx_data <= {8'he8,r_fifo_dout[7 :0],w_fifo_dout[63:24],1'd0,7'h16};
            8'b1111_0000:ro_tx_data <= {8'hd4,r_fifo_dout[7 :0],w_fifo_dout[63:32],2'd0,7'h16,7'h16};
            8'b1110_0000:ro_tx_data <= {8'hc3,r_fifo_dout[7 :0],w_fifo_dout[63:40],3'd0,7'h16,7'h16,7'h16};
            8'b1100_0000:ro_tx_data <= {8'hb2,r_fifo_dout[7 :0],w_fifo_dout[63:48],4'd0,7'h16,7'h16,7'h16,7'h16};
            8'b1000_0000:ro_tx_data <= {8'ha5,r_fifo_dout[7 :0],w_fifo_dout[63:56],5'd0,7'h16,7'h16,7'h16,7'h16,7'h16};
        endcase
    else case(r_send_cnt)
        0       :ro_tx_data <= {8'h71,w_fifo_dout[63:8]};
        default :ro_tx_data <= {r_fifo_dout[7 :0],w_fifo_dout[63:8]};
    endcase
end

always@(posedge i_tx_clk,posedge i_tx_rst)
begin
    if(i_tx_rst)
        ro_tx_header <= 'd0;
    else if(r_send_cnt && r_input_end && ((r_axis_keep > 8'b1111_1100 && r_send_cnt == r_len - 0) 
            || (r_axis_keep <= 8'b1111_1100 && r_send_cnt == r_len - 1)))
        ro_tx_header <= 2'b10;
        
    else if(r_send_cnt == 0 && r_fifo_rden_2d && r_invalid)
        ro_tx_header <= 2'b10;
    else if(r_send_cnt == 0 && r_fifo_rden_1d)
        ro_tx_header <= 2'b10;
    else
        ro_tx_header <= 2'b01;
end

always@(posedge i_tx_clk,posedge i_tx_rst)
begin
    if(i_tx_rst)
        r_fifo_rden <= 'd0;
    else if(w_fifo_empty || !w_gt_send_valid)   
        r_fifo_rden <= 'd0;
    else if(!w_fifo_empty)
        r_fifo_rden <= 'd1;
    else 
        r_fifo_rden <= r_fifo_rden;
end

always@(posedge i_tx_clk,posedge i_tx_rst)
begin
    if(i_tx_rst)
        r_fifo_rden_1d <= 'd0;
    else 
        r_fifo_rden_1d <= r_fifo_rden;
end

always@(posedge i_tx_clk,posedge i_tx_rst)
begin
    if(i_tx_rst)
        r_fifo_rden_2d <= 'd0;
    else 
        r_fifo_rden_2d <= r_fifo_rden_1d;
end

always@(posedge i_tx_clk,posedge i_tx_rst)
begin
    if(i_tx_rst)
        r_fifo_rden_3d <= 'd0;
    else 
        r_fifo_rden_3d <= r_fifo_rden_2d;
end

always@(posedge i_tx_clk,posedge i_tx_rst)
begin
    if(i_tx_rst)
        r_fifo_empty <= 'd0;
    else 
        r_fifo_empty <= {r_fifo_empty[0],w_fifo_empty};
end

always@(posedge i_tx_clk,posedge i_tx_rst)
begin
    if(i_tx_rst)
        rs_axis_ready <= 'd1;
    else if(s_axis_last)
        rs_axis_ready <= 'd0;
    else if(r_input_end && r_send_cnt == r_len - 0)
        rs_axis_ready <= 'd1;
    else 
        rs_axis_ready <= rs_axis_ready;
end


always@(posedge i_tx_clk,posedge i_tx_rst)
begin
    if(i_tx_rst)
        r_invalid <= 'd0;
    else if(r_invalid && r_send_cnt)
        r_invalid <= 'd0;
    else if(r_fifo_rden && !w_gt_send_valid && r_send_cnt == 0)
        r_invalid <= 'd1;
    else 
        r_invalid <= r_invalid;
end
endmodule
