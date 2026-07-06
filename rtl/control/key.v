module key(
	clk,
	rst_n,
	key_in,		//按键信号
	key_vld		//输出按键信号
);

input clk;
input rst_n;
input key_in;
output key_vld;

reg key_vld;

reg key_in_ff0;		//按键信号延迟一拍
reg key_in_ff1;		//按键信号延迟两拍
reg key_in_ff2;		//按键信号延迟三拍，用作检测下降沿


//按键信号延迟处理
always @ (posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		key_in_ff0<=1'b0;
		key_in_ff1<=1'b0;
		key_in_ff2<=1'b0;
	end
	else begin
		key_in_ff0<=key_in;
		key_in_ff1<=key_in_ff0;
		key_in_ff2<=key_in_ff1;
	end
end


//按键信号检测下降沿
always @ (posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		key_vld<=0;
	end
	else begin
		key_vld<=~key_in_ff1&&key_in_ff2;
	end
end

endmodule 