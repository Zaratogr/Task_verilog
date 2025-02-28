`timescale 1 ns / 1 ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.09.2023 20:48:19
// Design Name: 
// Module Name: TB_divident_mod17
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


module TB_divident_mod17();
    
    parameter PERIOD = 10;
    reg         clk;
    reg         start=1;
    reg [31:0]  mod17 [0:13];
    reg         mark_mod17 [0:13];
    integer     index;
    
    
    always begin
        clk = 1'b0;
        #(PERIOD/2)
        clk = 1'b1;
        #(PERIOD/2);
    end
    
    wire        mark_out;
    wire [4:0]  reminder;
    
    reg         mark_in = 0;
    reg [31:0]  divident = 0;
    
    divident_mod17
    divident_mod17_inst(
        .clk(clk),
        .mark_in(mark_in),
        .divident(divident),
        .mark_out(mark_out),
        .reminder(reminder)
    );
    
    always begin
    if (start==1)  //для ручного ввода значений
    begin
        #(PERIOD*5);
        mark_in  <= 1;
        divident <= 17; //                        = 0
        #(PERIOD);
        divident <= 32'hFFFFFFFF; //4 294 967 295 mod 17 = 0
        #(PERIOD);
        divident <= 294967295; //                       =6
        #(PERIOD);
        divident <= 32'hFFFFFFFE; //4 294 967 294 mod 17 = 16
        #(PERIOD);
        divident <= 0; //                               = 0
        #(PERIOD);
        divident <= 45642458; //                        = 8
        #(PERIOD);
        divident <= 3; //                               = 3
        #(PERIOD);
        mark_in  <= 0;
        #(PERIOD);
        mark_in  <= 1;
        divident <= 687452345; //                       = 4
        #(PERIOD);
        mark_in  <= 0;
        #(PERIOD);
        mark_in  <= 1;
        divident <= 18; //                              = 1
        #(PERIOD);
        mark_in  <= 0;
        #(PERIOD*5);
        start=0;
    end
    else
        begin
            mark_in  <= 1;
            divident <= $urandom%4294967295;    //тестирование на случайных числах
            #(PERIOD);
        end
    end
    
// автоматическая проверка -------------------------
    always @(posedge clk) begin
        if (mark_in==1)
        begin
            mark_mod17[0] <= 1;
            mod17[0] <= divident % 17;
        end
        else
            mark_mod17[0] <= 0;
        for (index = 1; index < 14; index = index + 1) 
        begin
            mod17[index] <= mod17[index-1];
            mark_mod17[index] <= mark_mod17[index-1];
        end
        if (mark_mod17[13]==1 | mark_out==1)
        begin
            if (mod17[13]!=reminder | mark_mod17[13]!=mark_out)
                $display("Error!!! Reference: %2d, Result: %2d. Time: %0t",mod17[13],mark_out,$time);
        end
    end
    
    
    
endmodule
