    `timescale 1ns / 1ps
    //////////////////////////////////////////////////////////////////////////////////
    // Company: 
    // Engineer: 
    // 
    // Create Date: 2023/12/10 13:21:44
    // Design Name: 
    // Module Name: Data_Descrambler
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


    module Data_Descrambler#(
        parameter           P_INIT_VALID = 16'h76d8     
    )(
        input               i_clk                       ,
        input               i_rst                       ,
        input               i_en                        ,
        input  [31:0]       i_scr_data                  ,
        input  [3 :0]       i_scr_char                  ,
        output [31:0]       o_data                      ,
        output [3 :0]       o_char                      
    );

    reg  [31:0]             ro_data                     ;
    reg  [3 :0]             ro_char                     ;
    reg  [15:0]             r_seed                      ;
     
    wire [47:0]             w_seed_next                 ;    
    wire [31:0]             w_seed_xor                  ;
    wire [15:0]             w_lfsr                      ;



    assign o_data               = ro_data               ;
    assign o_char               = ro_char               ;


    assign w_seed_next[15:0] = r_seed;
    genvar i;
    generate 
        for(i = 0;i < 32 ;i = i + 1)
        begin
            assign w_seed_next[16 + i]           = w_seed_next[i + (16 - 16)] ^ w_seed_next[i + (16 - 12)] ^ w_seed_next[i + (16 - 3)] ^ w_seed_next[i + (16 - 1)];  
        end
    endgenerate
    assign w_seed_xor   = w_seed_next[31:0];
    assign w_lfsr       = w_seed_next[47:32];

        
    
    always@(posedge i_clk,posedge i_rst)
    begin
        if(i_rst)
            r_seed <= P_INIT_VALID;
        else if(i_en)
            r_seed <= w_lfsr[15:0];
        else 
            r_seed <= P_INIT_VALID;
    end

    always@(posedge i_clk,posedge i_rst)
    begin
        if(i_rst)
            ro_data <= 'd0;
        else if(i_en)
            ro_data <= i_scr_data^w_seed_xor;
        else 
            ro_data <= i_scr_data;
    end

    always@(posedge i_clk,posedge i_rst)
    begin
        if(i_rst)
            ro_char <= 'd0;
        else if(i_en)
            ro_char <= i_scr_char;
        else 
            ro_char <= i_scr_char;
    end

    endmodule
