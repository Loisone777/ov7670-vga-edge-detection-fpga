module bin( 
    input				clk,			//pclk
    input				rst_n,		//复位信号
    input		[7:0]	gus_din,		//高斯滤波输入
    input		      gus_valid,	//高斯滤波输入有效标志
	 input				gus_sop,
	 input				gus_eop,
    output	         bin_dout,	//二值化输出
    output	   reg   bin_valid,  	//二值化输出有效标志
	 output		reg   bin_sop,
	 output		reg   bin_eop
);		

parameter bin_threshold=7'd127;


reg dout_vld_ff0;
reg dout_sop_ff0;
reg dout_eop_ff0;
    //bin_dout:二值化输出
assign bin_dout = (gus_din > bin_threshold)?1'b1:1'b0;


//dout_vld
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		bin_valid<=0;
		dout_vld_ff0<=0;
	end
	else begin
		dout_vld_ff0<=gus_valid;
		bin_valid<=dout_vld_ff0;
	end
end

//dout_sop
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		bin_sop<=0;
		dout_sop_ff0<=0;
	end
	else begin
		dout_sop_ff0<=gus_sop;
		bin_sop<=dout_sop_ff0;
	end
end

//dout_eop
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		bin_eop<=0;
		dout_eop_ff0<=0;
	end
	else begin
		dout_eop_ff0<=gus_eop;
		bin_eop<=dout_eop_ff0;
	end
end
                        
endmodule
