//Предложите алгоритм вычисления остатка от деления 32-битного числа на 17.
// reminder = divident mod 17
//На вход модуля поступает 32-битный сигнал divident
//На выходе 5-битный остаток reminder от 0 до 16.

module divident_mod17(
  input  wire        clk,
  input  wire        mark_in,
  input  wire [31:0] divident,
  output reg  [4:0]  reminder,
  output reg         mark_out
);

  reg [5:0]   p = 17;  //constant
  
  reg [4:0]   w [0:31];
  reg [8:0]   c [0:15];
  reg [7:0]   d [0:16];
  
  //signals
  integer     index;
  reg [31:0]  divident_q1 = 0;
  reg [4:0]   w_mask [0:31];
  reg [4:0]   w_sum_L1 [0:15];
  reg [5:0]   w_sum_L2 [0:7];
  reg [6:0]   w_sum_L3 [0:3];
  reg [7:0]   w_sum_L4 [0:1];
  reg [8:0]   sum = 0;
  (* dont_touch = "yes" *) reg [8:0]   sum_q1   [0:1]; // уменьшаем fanout
  reg [8:0]   sum_q2 = 0;
  reg [8:0]   sum_q3 = 0;
  reg [8:0]   sum_q4 = 0;
  reg [8:0]   sum_q5 = 0;
  reg [8:0]   sum_q6 = 0;
  reg [0:16]  comp = 0;
  reg [0:16]  comp_mask = 0;
  reg         comp_mask16_d = 0;
  reg [7:0]   d_mask  [0:16];
  reg [7:0]   or_d_L1 [0:3];
  reg [7:0]   deduction = 0;
  reg [0:12]  mark_d = 0;
  
  initial begin
    for (index = 0; index < 32; index = index + 1) begin
      w[index] = (2**index) % p;
    end
    for (index = 0; index < 16; index = index + 1) begin
      c[index] = (index+1)*p;
    end
    for (index = 0; index < 17; index = index + 1) begin
      d[index] = index*p;
    end
  end
  
  always @(posedge clk) begin
  
    divident_q1 <= divident;
    
    for (index = 0; index < 32; index = index + 1) begin
      w_mask[index] <= w[index] & {5{divident_q1[index]}};        //маскируем коэффициенты w
    end
    
    //begin: дерево сумматоров
    for (index = 0; index < 16; index = index + 1) begin
      w_sum_L1[index] <= w_mask[index*2] + w_mask[index*2+1];     //первый уровень дерева сумматоров
    end
    for (index = 0; index < 8; index = index + 1) begin
      w_sum_L2[index] <= w_sum_L1[index*2] + w_sum_L1[index*2+1]; //второй уровень дерева сумматоров
    end
    for (index = 0; index < 4; index = index + 1) begin
      w_sum_L3[index] <= w_sum_L2[index*2] + w_sum_L2[index*2+1]; //третий уровень дерева сумматоров
    end
    for (index = 0; index < 2; index = index + 1) begin
      w_sum_L4[index] <= w_sum_L3[index*2] + w_sum_L3[index*2+1]; //четвертый уровень дерева сумматоров
    end
    sum <= w_sum_L4[0] + w_sum_L4[1];
    //end: дерево сумматоров
	
    sum_q1[0] <= sum;
    sum_q1[1] <= sum;
    for (index = 0; index < 16; index = index + 1) begin
      if (index < 8)  comp[index] <= (c[index] > sum_q1[0]);      //находим интервал суммы
      else            comp[index] <= (c[index] > sum_q1[1]);
      
      if (index == 0)  comp_mask[index] <= comp[index];
      else             comp_mask[index] <= comp[index] & ~comp[index-1];   //маскируем до одного интервала
      
      d_mask[index] <= d[index] & {8{comp_mask[index]}};         //блокируем все d кроме одного
    end
    comp[16] <= (c[15] == sum_q1[1]);
    comp_mask[16] <= comp[16];
    comp_mask16_d <= comp_mask[16];
    d_mask[16] <= d[16] & {8{comp_mask16_d}};
    
    for (index = 0; index < 4; index = index + 1) begin
      or_d_L1[index] <= d_mask[index*4] | d_mask[index*4+1] | d_mask[index*4+2] | d_mask[index*4+3]; //через or выделяем незаблакированное d
    end
    deduction <= or_d_L1[0] | or_d_L1[1] | or_d_L1[2] | or_d_L1[3] | d_mask[16]; //через or выделяем незаблакированное d
    
    sum_q2 <= sum_q1[0];
    sum_q3 <= sum_q2;
    sum_q4 <= sum_q3;
    sum_q5 <= sum_q4;
    sum_q6 <= sum_q5;
    reminder <= sum_q6 - deduction; //финальный вычет
    
    mark_d[0] <= mark_in;
    for (index = 1; index < 13; index = index + 1) begin
      mark_d [index] <= mark_d [index-1];  //задерживаем маркер
    end
    mark_out <= mark_d[12];
    
  end
  
endmodule