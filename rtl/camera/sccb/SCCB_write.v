module SCCB_write(
	input clk,
	input rst_n,
	input en,
	input subaddress_data,
	input data,
	input done,
	output ready,
	output reg sio_c,
	output reg sio_d
);

parameter ID_data=8'b0100_0010;

reg flag_add;

reg [5:0]cnt0;
wire add_cnt0;
wire end_cnt0;

reg [4:0]cnt1;
wire add_cnt1;
wire end_cnt1;

wire [29:0]tx_data;

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
assign end_cnt1=add_cnt1&&cnt1==30-1;

//flag_add
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		flag_add<=0;
	else begin
		if(en)
			flag_add<=1;
		else if(done)
			flag_add<=0;
	end
end

//sio_c
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		sio_c<=1;
	else if(add_cnt0&&cnt0==1-1&&cnt1>=1&&cnt1<30)
		sio_c<=0;
	else if(add_cnt0&&cnt0==50/2-1)
		sio_c<=1;
end

assign tx_data={1'b0,ID_data,1'b1,subaddress_data,1'b1,data,1'b1,1'b0,1'b1};

//sio_d
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		sio_d<=1;
	else if(add_cnt0&&cnt0==50/4-1)
		sio_d<=tx_data[29-cnt1];
end

//ready
assign ready=flag_add&&cnt0==0&&cnt1==0;

endmodule 