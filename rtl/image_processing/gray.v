module gray(
	input clk,				//工作时钟，时钟频率为 25M
	input rst_n,		 	//复位信号，低电平有效
	input [15:0]din, 		//输入的图像像素数据，格式为 RGB565 格式。din[15:11]：R din[10: 5]：G. din[ 4: 0 ]：B
	input din_vld, 		//输入图像数据有效指示信号
	input din_sop, 		//本帧图像的第一个像素
	input din_eop, 		//本帧图像的最后一个像素
	output reg [7:0]dout,		//本模块输出的灰度图像数据
	output reg dout_vld, 		//本模块输出的图像数据有效指示信号
	output reg dout_sop, 		//本帧图像的第一个像素
	output reg dout_eop 		//本帧图像的最后一个像素
);

reg dout_vld_ff0;
reg dout_sop_ff0;
reg dout_eop_ff0;

reg [7:0]gray_r;
reg [7:0]gray_g;
reg [7:0]gray_b;


always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		gray_r<=0;
		gray_g<=0;
		gray_b<=0;
	end
	else begin
		if(din_vld)begin
			gray_r={din[15:11],3'b000};
			gray_g={din[10:5],2'b00};
			gray_b={din[4:0],3'b000};
		end
	end
end


//dout
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		dout<=0;
	else if(din_vld)
		dout<=(gray_r*76 + gray_g*150+ gray_b*30)/256;
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