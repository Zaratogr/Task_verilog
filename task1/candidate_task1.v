//�� ���� ������ ��������� �������� �������� clk_i c �������� N, ����������� ������ ������ reset_n_i (����� �� ������ 0).
//� ������������ ������ ������� ����� ��������� ����������� �������� syncro_i ������������� �� ����� ������ ����� ������� clk_i.
//�� ��������� ������ ����� �������� ���������� ��������� 11 ������ clk_i � �������� 8 ��������� � ������� ���.
//��� ������� ������ �� ��� ���������� ������ ������ ������� adc_data_req_o ������������� �� ����� 2 ������ clk_i. �� ��������� ������
//����� ������� ������� ��� �������� ������� � ��������� ������. ��� �������� �� ������ �������, � �� �� ������. ���������� ����� ������ ������� � ��������� ���������� ������ ��� �� ������� adc_data_rdy_i.
//�� ��� ����������� ��������� ������ clk_i. ������ � ��� ����� ������ �� ��������� ������ adc_data_rdy_i � ����� ��������� �� ���������� �������.
//������ adc_data_rdy_i ��� ���� ����� � ��������� ���������� 1. �������� � ��� ����������� � �������������� ����.
//�� ���������� ��������� �� ���������� 8-�� ���������� � � ����� �� �������, ��� ����� ��� ������ �� ����� � ������ ���������� data_rdy_o. 
//
//��� �������� �� ����� Verilog HDL ��� ������������� ����������� SystemVerilog

module data_acquire(
	input clk_i,
	input reset_n_i,
	
//ADC interface
	output reg   adc_data_req_o = 0,
	input	     adc_data_rdy_i,
	input [11:0] adc_data_i,
	
//Module output interface
	input              syncro_i,
	output reg [11:0]  data_o = 0,
	output reg         data_rdy_o = 1'b1
	

);

//signals
	reg        adc_data_rdy_i_1d = 1;
	reg        adc_data_rdy_i_2d = 1;
	reg [11:0] adc_data_i_1d = 0;
	reg [14:0] data_sum = 0;
	reg        syncro_i_1d = 0;
	reg        syncro_i_2d = 0;
	reg        strobe_syncro_i_1d = 0;
	reg        strobe_syncro_i_2d = 0;
	reg        adc_data_req_o_tmp = 0;
	reg [0:7]  adc_data_req_o_tmp_reg = 0;
	//reg        stop;
	reg        stop_1d = 0;
	reg        stop_2d = 0;
	reg        data_rdy_o_tmp = 1'b0;
	reg [2:0]  cnt8 = 0;
	reg [2:0]  cnt8_1d = 0;
	
	integer    index;
	
	
    assign strobe_syncro_i   = syncro_i_1d       & ~syncro_i_2d;
    assign strobe_data_rdy_i = adc_data_rdy_i_1d & ~adc_data_rdy_i_2d & data_rdy_o_tmp;  //��������� ����� ������ ������ � ���, ���� �� ������� ������ ������
	//or or_req_o(cut_syncro_i_3d, cut_syncro_i_2d, cut_syncro_i_1d, adc_data_req_o_tmp);
	assign stop        = (cnt8 == 3'b000)&(cnt8_1d == 3'b111);
	assign block_req_o = (cnt8 == 3'b111);
	assign next_req    = strobe_data_rdy_i & ~block_req_o; //��������� ������ ��� �������� 2-8, block_req_o -- ��������� 9-� ������
	reg    next_req_1d = 0;
	reg    next_req_2d = 0;
	assign round    = data_sum[2] & (data_sum[3] | ~data_sum[2] | data_sum[1] | data_sum[0]); //round to the nearest even // okrugleniye do blizhayshego chetnogo
	
	
always @(posedge clk_i) begin
    adc_data_rdy_i_1d <= adc_data_rdy_i;
    adc_data_rdy_i_2d <= adc_data_rdy_i_1d;
    adc_data_i_1d     <= adc_data_i;
    syncro_i_1d       <= syncro_i;
    syncro_i_2d       <= syncro_i_1d;
    
    
    strobe_syncro_i_1d <= strobe_syncro_i;
    strobe_syncro_i_2d <= strobe_syncro_i_1d;
    adc_data_req_o_tmp <= strobe_syncro_i_2d | strobe_syncro_i_1d | strobe_syncro_i;   //��������� ��� ����� ��� ������� �������
    
    
    adc_data_req_o_tmp_reg[0] <= adc_data_req_o_tmp;
    for (index = 1; index < 8; index = index + 1) 
    begin
    	adc_data_req_o_tmp_reg [index] <= adc_data_req_o_tmp_reg [index-1];  //����������� ������ ������
    end
    
    next_req_1d <= next_req;
    next_req_2d <= next_req_1d;
    adc_data_req_o <= adc_data_req_o_tmp_reg [7] | next_req | next_req_1d | next_req_2d; //��������� ��� ����� ��� �������� 2-8
    
    data_rdy_o <= ~data_rdy_o_tmp;
    
    stop_1d <= stop;
    stop_2d <= stop_1d;
    
end

always @(posedge clk_i or negedge reset_n_i) begin
    if (reset_n_i==0 | stop_2d==1)
        data_rdy_o_tmp <= 0;
    else
    begin
        if (strobe_syncro_i==1)
            data_rdy_o_tmp <= 1;
    end
    
    if (reset_n_i==0 | stop_2d==1)
        data_sum <= 0;
    else
    begin
        if (strobe_data_rdy_i==1)
            data_sum <= data_sum+{adc_data_i_1d[11],adc_data_i_1d[11],adc_data_i_1d[11],adc_data_i_1d}; //�������� � �����������
    end
    
    if (reset_n_i==0)
        cnt8 <= 0;
    else
    begin
        if (strobe_data_rdy_i==1)
           cnt8 <= cnt8+1;      //������� ���������� � ��� ������
    end
    
    if (reset_n_i==0)
        data_o <= 0;
    else
    begin
        if (stop)
           data_o <= data_sum[14:3]+round;  //������������ ����������: ����� ������ �� ��� ���� � ����������
    end
    
    if (reset_n_i==0)
        cnt8_1d <= 0;
    else
        cnt8_1d <= cnt8;
    
end

endmodule
