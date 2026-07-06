module sobel(
	input clk, 			//工作时钟，时钟频率为 25M
	input rst_n, 		//复位信号，低电平有效
	input din,			//输入的二值化像素数据
	input din_vld, 	//输入二值化数据有效指示信号
	input din_sop, 	//本帧图像的第一个像素
	input din_eop, 	//本帧图像的最后一个像素
	output reg dout, 		//本模块滤波输出的图像数据
	output reg dout_vld, 	//本模块输出的图像数据有效指示信号
	output reg dout_sop, 	//本帧图像的第一个像素
	output reg dout_eop 	//本帧图像的最后一个像素
);

parameter sobel_threshold=2'd3;

wire shiftout;
wire row1;
wire row2;
wire row3;

reg matrix11;
reg matrix12;
reg matrix13;

reg matrix21;
reg matrix22;
reg matrix23;

reg matrix31;
reg matrix32;
reg matrix33;

reg [7:0]xdata1;
reg [7:0]xdata2;
reg [7:0]xdata;
reg [7:0]ydata1;
reg [7:0]ydata2;
reg [7:0]ydata;
wire [7:0]sobel_data;

reg dout_vld_ff0;
reg dout_sop_ff0;
reg dout_eop_ff0;

sobel_shift my_shift_ram(
	.clken			(din_vld),
	.clock			(clk),
	.shiftin			(din),
	.shiftout		(shiftout),
	.taps0x			(row3),
	.taps1x			(row2),
	.taps2x			(row1)
);


always@(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		matrix11<=0;
		matrix12<=0;
		matrix13<=0;
		
		matrix21<=0;
		matrix22<=0;
		matrix23<=0;
		
		matrix31<=0;
		matrix32<=0;
		matrix33<=0;
	end
	else begin
		if(din_vld)begin
			matrix11<=matrix12;
			matrix12<=matrix13;
			matrix13<=row1;
			
			matrix21<=matrix22;
			matrix22<=matrix23;
			matrix23<=row2;
			
			matrix31<=matrix32;
			matrix32<=matrix33;
			matrix33<=row3;
		end
		else begin
			matrix11<=matrix11;
			matrix12<=matrix12;
			matrix13<=matrix13;
			          
			matrix21<=matrix21;
			matrix22<=matrix22;
			matrix23<=matrix23;
			          
			matrix31<=matrix31;
			matrix32<=matrix32;
			matrix33<=matrix33;
		end
	end
end

//x
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		xdata1<=0;
		xdata2<=0;
		xdata<=0;
	end
	else begin
		xdata1<=matrix11+matrix21<<1+matrix31;
		xdata2<=matrix13+matrix23<<1+matrix33;
		xdata<=(xdata1>xdata2)?(xdata1-xdata2):(xdata2-xdata1);
	end
end

//y
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		ydata1<=0;
		ydata2<=0;
		ydata<=0;
	end
	else begin
		ydata1<=matrix11+matrix12<<1+matrix13;
		ydata2<=matrix31+matrix32<<1+matrix33;
		ydata<=(ydata1>ydata2)?(ydata1-ydata2):(ydata2-ydata1);
	end
end

//sobel_data
assign sobel_data=xdata+ydata;

//dout
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		dout<=0;
	else 
		dout<=(sobel_data>=sobel_threshold)?0:1;	//边缘为0，非边缘为1
end

//dout_vld
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		dout_vld<=0;
		dout_vld_ff0<=0;
	end
	else begin
		dout_vld_ff0<=din_vld;
		dout_vld<=dout_vld_ff0;
	end
end

//dout_sop
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		dout_sop<=0;
		dout_sop_ff0<=0;
	end
	else begin
		dout_sop_ff0<=din_sop;
		dout_sop<=dout_sop_ff0;
	end
end

//dout_eop
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		dout_eop<=0;
		dout_eop_ff0<=0;
	end
	else begin
		dout_eop_ff0<=din_eop;
		dout_eop<=dout_eop_ff0;
	end
end

endmodule 