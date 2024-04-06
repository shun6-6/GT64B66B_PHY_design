`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/23 11:55:10
// Design Name: 
// Module Name: PHY_rx
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


module PHY_rx(
    input                   i_rx_clk                    ,
    input                   i_rx_rst                    ,
    input  [63:0]           i_rx_data                   ,
    input                   i_rx_valid                  ,
    input  [1 :0]           i_rx_header                 ,
    input                   i_rx_header_valid           ,

    output [63:0]           m_axis_data                 ,
    output [7 :0]           m_axis_keep                 ,
    output                  m_axis_last                 ,
    output                  m_axis_valid                
);

reg  [63:0]                 rm_axis_data                ;
reg  [7 :0]                 rm_axis_keep                ;
reg                         rm_axis_last                ;
reg                         rm_axis_valid               ;
reg  [63:0]                 ri_rx_data                  ;
reg  [63:0]                 ri_rx_data_1d               ;
reg                         ri_rx_valid                 ;
reg                         ri_rx_valid_1d              ;
reg  [1 :0]                 ri_rx_header                ;
reg  [0 :0]                 ri_rx_header_valid          ;
reg                         r_receiving                 ;
reg                         r_eof                       ;
reg  [3 :0]                 r_eof_local                 ;
reg                         r_sof                       ;
reg                         r_revalid                   ;
reg                         r_invalid                   ;


wire [63:0]                 w_rx_data                   ;
wire                        w_sof                       ;
wire                        w_eof_s1                    ;
wire                        w_eof                       ;
wire [3 :0]                 w_eof_local                 ;             
wire [3 :0]                 w_eof_local_s1              ; 

assign m_axis_data  = rm_axis_data;

//输入数据先进行大小端转换，然后按照大端数据进行处理
assign w_rx_data    = { i_rx_data[7 : 0],i_rx_data[15: 8],i_rx_data[23:16],i_rx_data[31:24],
                        i_rx_data[39:32],i_rx_data[47:40],i_rx_data[55:48],i_rx_data[63:56]};


assign m_axis_keep   = rm_axis_keep                     ;
assign m_axis_last   = rm_axis_last                     ;
assign m_axis_valid  = rm_axis_valid                    ;
assign w_sof         = ri_rx_header_valid & ri_rx_header == 2'b10 & ri_rx_data[63:56] == 8'h71 & ri_rx_valid;

assign w_eof         = ri_rx_header_valid & ri_rx_header == 2'b10 & 
                       (ri_rx_data[63:56] == 8'h99 ||
                        ri_rx_data[63:56] == 8'h8e ||
                        ri_rx_data[63:56] == 8'hff ||
                        ri_rx_data[63:56] == 8'he8 ||
                        ri_rx_data[63:56] == 8'hd4 ||
                        ri_rx_data[63:56] == 8'hc3 ||
                        ri_rx_data[63:56] == 8'hb2 ||
                        ri_rx_data[63:56] == 8'ha5 
                       )& ri_rx_valid;

assign w_eof_s1     = i_rx_header_valid & i_rx_header == 2'b10 & 
                       (w_rx_data[63:56] == 8'h99 ||
                        w_rx_data[63:56] == 8'h8e ||
                        w_rx_data[63:56] == 8'hff ||
                        w_rx_data[63:56] == 8'he8 ||
                        w_rx_data[63:56] == 8'hd4 ||
                        w_rx_data[63:56] == 8'hc3 ||
                        w_rx_data[63:56] == 8'hb2 ||
                        w_rx_data[63:56] == 8'ha5 
                       )& i_rx_valid;

//指示最后一个byte位置，最高为7（因为第8byte位置是控制字节位），自左向右依次递减
assign w_eof_local =    ri_rx_data[63:56] == 8'h99 ? 7 : 
                        ri_rx_data[63:56] == 8'h8e ? 0 :
                        ri_rx_data[63:56] == 8'hff ? 1 :
                        ri_rx_data[63:56] == 8'he8 ? 2 :
                        ri_rx_data[63:56] == 8'hd4 ? 3 :
                        ri_rx_data[63:56] == 8'hc3 ? 4 :
                        ri_rx_data[63:56] == 8'hb2 ? 5 :
                        ri_rx_data[63:56] == 8'ha5 ? 6 :
                        'd0;
//w_eof_local的前一拍
assign w_eof_local_s1 = w_rx_data[63:56] == 8'h99 ? 7 : 
                        w_rx_data[63:56] == 8'h8e ? 0 :
                        w_rx_data[63:56] == 8'hff ? 1 :
                        w_rx_data[63:56] == 8'he8 ? 2 :
                        w_rx_data[63:56] == 8'hd4 ? 3 :
                        w_rx_data[63:56] == 8'hc3 ? 4 :
                        w_rx_data[63:56] == 8'hb2 ? 5 :
                        w_rx_data[63:56] == 8'ha5 ? 6 :
                        'd0;

always@(posedge i_rx_clk,posedge i_rx_rst)
begin
    if(i_rx_rst) begin
        ri_rx_data          <= 'd0;
        ri_rx_valid         <= 'd0;
        ri_rx_valid_1d      <= 'd0;
        ri_rx_header        <= 'd0;
        ri_rx_header_valid  <= 'd0;
        
    end else begin
        ri_rx_data          <= w_rx_data            ;
        ri_rx_valid         <= i_rx_valid           ;
        ri_rx_valid_1d      <= ri_rx_valid          ;
        ri_rx_header        <= i_rx_header          ;
        ri_rx_header_valid  <= i_rx_header_valid    ;
        
    end 
end

always@(posedge i_rx_clk,posedge i_rx_rst)
begin
    if(i_rx_rst)
        ri_rx_data_1d       <= 'd0;
    else if(ri_rx_valid)
        ri_rx_data_1d       <= ri_rx_data           ;
    else 
        ri_rx_data_1d       <= ri_rx_data_1d        ;
end
always@(posedge i_rx_clk,posedge i_rx_rst)
begin
    if(i_rx_rst) begin
        r_sof <= 'd0;
        r_eof <= 'd0;
        r_eof_local <= 'd0;
    end else begin
        r_sof <= w_sof;
        r_eof <= w_eof;
        r_eof_local <= w_eof_local;
    end
end

always@(posedge i_rx_clk,posedge i_rx_rst)
begin
    if(i_rx_rst)
        r_receiving <= 'd0;
    else if(r_eof)
        r_receiving <= 'd0;
    else if(w_sof)
        r_receiving <= 'd1;
    else 
        r_receiving <= r_receiving;
end

always@(posedge i_rx_clk,posedge i_rx_rst)
begin
    if(i_rx_rst)
        rm_axis_data <= 'd0;
    else if(r_eof && (r_eof_local < 7 && r_eof_local > 0))
        rm_axis_data <= {ri_rx_data_1d[47:0],16'd0};  
    else if(w_eof && (w_eof_local == 0))
        rm_axis_data <= {ri_rx_data_1d[55:0],8'd0};
    else if(w_eof && (w_eof_local <= 7))
        rm_axis_data <= {ri_rx_data_1d[55:0],ri_rx_data[55:48]};  
    else if(r_receiving && ri_rx_valid)
        rm_axis_data <= {ri_rx_data_1d[55:0],ri_rx_data[63:56]};
    else 
        rm_axis_data <= 'd0;
end


always@(posedge i_rx_clk,posedge i_rx_rst)
begin
    if(i_rx_rst)
        rm_axis_keep <= 8'b1111_1111;
    else if(r_eof && (r_eof_local < 7 && r_eof_local > 0))
        case(r_eof_local)
            1           :rm_axis_keep <= 8'b1111_1100;
            2           :rm_axis_keep <= 8'b1111_1000;
            3           :rm_axis_keep <= 8'b1111_0000;
            4           :rm_axis_keep <= 8'b1110_0000;
            5           :rm_axis_keep <= 8'b1100_0000;
            6           :rm_axis_keep <= 8'b1000_0000;           
            default     :rm_axis_keep <= 8'b1111_1111;
        endcase
    else if(w_eof && (w_eof_local == 0 || w_eof_local == 7))
        case(w_eof_local)
            0           :rm_axis_keep <= 8'b1111_1110;
            7           :rm_axis_keep <= 8'b1111_1111;            
            default     :rm_axis_keep <= 8'b1111_1111;
        endcase
    else 
        rm_axis_keep <= 8'b1111_1111;
end


always@(posedge i_rx_clk,posedge i_rx_rst)
begin
    if(i_rx_rst)
        rm_axis_last <= 'd0;
    else if(rm_axis_last && rm_axis_valid)
        rm_axis_last <= 'd0;
    else if(rm_axis_valid && r_eof && (r_eof_local < 7 && r_eof_local > 0))
        rm_axis_last <= 'd1;
    else if(rm_axis_valid && w_eof && (w_eof_local == 7 || w_eof_local == 0))
        rm_axis_last <= 'd1;
    else 
        rm_axis_last <= rm_axis_last;
end

always@(posedge i_rx_clk,posedge i_rx_rst)
begin
    if(i_rx_rst)
        rm_axis_valid <= 'd0;
    else if(r_sof)
        rm_axis_valid <= 'd1;
    else if(rm_axis_last && rm_axis_valid)
        rm_axis_valid <= 'd0;
    else if((!ri_rx_valid && ri_rx_header != 2'b10) || r_invalid)
        rm_axis_valid <= 'd0;
    else if(r_revalid)
        rm_axis_valid <= 'd1;
    else 
        rm_axis_valid <= rm_axis_valid;
end

always@(posedge i_rx_clk,posedge i_rx_rst)
begin
    if(i_rx_rst)
        r_revalid <= 'd0;
    else if(r_invalid)
        r_revalid <= 'd1;
    else if(!rm_axis_last && rm_axis_valid && !ri_rx_valid && ri_rx_valid_1d)
        r_revalid <= 'd1;
    else 
        r_revalid <= 'd0;
end

always@(posedge i_rx_clk,posedge i_rx_rst)
begin
    if(i_rx_rst)
        r_invalid <= 'd0;
    else if(r_sof & !ri_rx_valid)
        r_invalid <= 'd1;
    else 
        r_invalid <= 'd0;
end

endmodule
