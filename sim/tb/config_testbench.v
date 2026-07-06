`timescale 1ns/1ns

module config_testbench();

//输入信号
reg clk;
reg rst_n;
reg key_in;

//时钟周期，单位为ns，数值大小可以根据需要来调整
parameter CYCLE = 20;

//复位信号，表示为3个时钟周期，可调
parameter RST_TIME = 3;

wire [7:0]data;
wire [7:0]sub_addr;
wire key_vld;
wire ready;
wire sio_c;
wire sio_d;
wire m_valid;
wire data_start;

//待测试模块的例化
key i1(
	.clk					(clk	),
	.rst_n				(rst_n),
	.key_in				(key_in),		//按键信号
	.key_vld				(key_vld)		//输出按键信号
);

SCCB_write i2(
	.clk					(clk	),
	.rst_n				(rst_n),
	.en					(key_vld),
	.subaddress_data	(sub_addr),
	.data					(data	),
	.done					(data_start),
	.ready				(ready),
	.sio_c				(sio_c),
	.sio_d				(sio_d)
);

ov_config i3(
	.clk			(clk		),
	.rst_n		(rst_n	),
	.m_ready		(ready	),
	.sub_addr	(sub_addr),
	.data			(data		),       
	.m_valid		(m_valid	),	
	.data_start	(data_start)
);

//生成本地时钟：50M
initial begin
	clk=0;
	forever
	#(CYCLE/2)
	clk=~clk;
end

//生成复位信号
initial begin
	rst_n=1;
	#2;
	rst_n=0;
	#(CYCLE*RST_TIME);
	rst_n=1;
end

//生成key_in信号
initial begin
	key_in=0;
	#2;
	key_in=0;
	#(CYCLE*RST_TIME);
	#CYCLE
	key_in=1;
	#CYCLE
	key_in=0;
end

endmodule