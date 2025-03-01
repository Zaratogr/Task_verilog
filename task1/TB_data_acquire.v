`timescale 1 ns / 1 ns

module TB_data_acquire();
  
  parameter PERIOD = 10;
  reg clk;
  
  always begin
    clk = 1'b0;
    #(PERIOD/2)
    clk = 1'b1;
    #(PERIOD/2);
  end
  
  wire        adc_data_req_o;
  wire [11:0] data_o;
  wire        data_rdy_o;
  
  reg         reset_n_i = 1;
  reg         adc_data_rdy_i = 1;
  reg [11:0]  adc_data_i = 0;
  reg         syncro_i = 0;
  
  data_acquire
  data_acquire_inst(
    .clk_i(clk),
    .reset_n_i(reset_n_i),
      
  //ADC interface
    .adc_data_req_o(adc_data_req_o),
    .adc_data_rdy_i(adc_data_rdy_i),
    .adc_data_i(adc_data_i),
    
  //Module output interface
    .syncro_i(syncro_i),
    .data_o(data_o),
    .data_rdy_o(data_rdy_o)
  );
  
  always begin
    #(PERIOD*4.3); 
    reset_n_i <= 0;
    #(PERIOD*0.2);
    reset_n_i <= 1;
    #(PERIOD*5.5);
    syncro_i <= 1;
    #(PERIOD*2);
    syncro_i <= 0;
    @(posedge adc_data_req_o);
    #(PERIOD*5);
    adc_data_rdy_i <= 0;
    #(PERIOD*15);
    adc_data_rdy_i <= 1;
    adc_data_i <= 12'h014;   //20
    #(PERIOD);
    @(posedge adc_data_req_o);
    #(PERIOD*1);
    adc_data_rdy_i <= 0;
    #(PERIOD*1);
    adc_data_rdy_i <= 1;
    adc_data_i <= 12'hFF1;   //-15
    #(PERIOD);
    @(posedge adc_data_req_o);
    #(PERIOD*5);
    adc_data_rdy_i <= 0;
    #(PERIOD*15);
    adc_data_rdy_i <= 1;
    adc_data_i <= 12'h020;   //32
    #(PERIOD);
    @(posedge adc_data_req_o);
    #(PERIOD*5);
    adc_data_rdy_i <= 0;
    #(PERIOD*15);
    adc_data_rdy_i <= 1;
    adc_data_i <= 12'h002;   //2
    #(PERIOD);
    @(posedge adc_data_req_o);
    #(PERIOD*5);
    adc_data_rdy_i <= 0;
    #(PERIOD*15);
    adc_data_rdy_i <= 1;
    adc_data_i <= 12'hFDC;   //-36
    #(PERIOD);
    @(posedge adc_data_req_o);
    #(PERIOD*5);
    adc_data_rdy_i <= 0;
    #(PERIOD*15);
    
//    #(PERIOD*4.3); 
//    reset_n_i <= 0;
//    #(PERIOD*0.2);
//    reset_n_i <= 1;
//    #(PERIOD*5.5);
    
    adc_data_rdy_i <= 1;
    adc_data_i <= 12'h034;   //52
    #(PERIOD);
    @(posedge adc_data_req_o);
    #(PERIOD*5);
    adc_data_rdy_i <= 0;
    #(PERIOD*15);
    adc_data_rdy_i <= 1;
    adc_data_i <= 12'h005;   //5
    #(PERIOD);
    @(posedge adc_data_req_o);
    #(PERIOD*5);
    adc_data_rdy_i <= 0;
    #(PERIOD*15);
    adc_data_rdy_i <= 1;
    adc_data_i <= 12'h002;   //2
    #(PERIOD);
    //20-15+32+2-36+52+5+2=62 (3E)
    //62/8 = 7.75 (8)
    
    @(posedge data_rdy_o);
    #(PERIOD*10);
  end
  
dmodule
