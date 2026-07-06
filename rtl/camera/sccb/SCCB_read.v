module SCCB_read(
	input clk,
	input rst_n,
	input en,
	output sio_c,
	output sio_d,
	input sio_din,
	output dout,
	output dout_vld
);

reg sio_c;
reg sio_d;
reg [7:0]dout;
reg dout_vld;

reg flag_add;

reg [5:0]cnt0;
wire add_cnt0;
wire end_cnt0;

reg [4:0]cnt1;
wire add_cnt1;
wire end_cnt1;

reg cnt2;
wire add_cnt2;
wire end_cnt2;

wire [20:0]tx_data0;
wire [20:0]tx_data1;

//cnt0
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		cnt0<=0;
	else if(add_cnt0)begin
		if(end_cnt0)
			cnt0<=0;
		else
			cnt0<=cnt0+1;
	end
end

assign add_cnt0=flag_add;
assign end_cnt0=add_cnt0&&cnt0==50-1;

//cnt1
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		cnt1<=0;
	else if(add_cnt1)begin
		if(end_cnt1)
			cnt1<=0;
		else
			cnt1<=cnt1+1;
	end
end

assign add_cnt1=end_cnt0;
assign end_cnt1=add_cnt1&&cnt1==21-1;

//cnt2
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		cnt2<=0;
	else if(add_cnt2)begin
		if(end_cnt2)
			cnt2<=0;
		else
			cnt2<=cnt2+1;
	end
end

assign add_cnt2=end_cnt1;
assign end_cnt2=add_cnt2&&cnt2==2-1;

//flag_add
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		flag_add<=0;
	else begin
		if(en)
			flag_add<=1;
		else if(end_cnt2)
			flag_add<=0;
	end
end

//sio_c
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		sio_c<=1;
	else if(add_cnt0&&cnt0==1-1&&cnt1>=1&&cnt1<21)
		sio_c<=0;
	else if(add_cnt0&&cnt0==50/2-1)
		sio_c<=1;
end

assign tx_data0={1'b0,ID_data,1'b1,subaddress_data,1'b1,1'b0,1'b1};
assign tx_data1={1'b0,ID_data,1'b1,8'b0,1'b1,1'b0,1'b1};

//sio_d
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		sio_d<=1;
	else if(add_cnt0&&cnt0==50/4-1)begin
		if(cnt2==1-1)
			sio_d<=tx_data0[20-cnt1];
		else
			sio_d<=tx_data1[20-cnt1];
	end
end

//dout
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		dout<=0;
	else if(cnt2==2-1&&cnt1>=11&&cnt1<19&&add_cnt0&&cnt0==50/4-1)
		dout[18-cnt1]<=sio_din;
end

//dout_vld
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		dout_vld<=0;
	else
		dout_vld<=end_cnt2;
end

endmodule 