`timescale 1ns/1ns

module vga_testbench();

//输入信号
reg clk;
reg rst_n;
reg  	  	  dout_bin;
reg   	  dout_vld_bin; 
reg   	  dout_sop_bin; 
reg   	  dout_eop_bin;
//时钟周期，单位为ns，数值大小可以根据需要来调整
parameter CYCLE = 20;

//复位信号，表示为3个时钟周期，可调
parameter RST_TIME = 3;

wire  	  dout_sobel;
wire   	  dout_vld_sobel; 
wire   	  dout_sop_sobel; 
wire   	  dout_eop_sobel;		

wire full;
wire empty;
wire fifo_data;

wire	hys;			
wire	vys;			
wire	rgb_data;	
wire	vga_black;	
wire	vga_sync;

//待测试模块的例化
sobel i1(
	.clk				(clk		),				
	.rst_n			(rst_n	),		 	
	.din				(dout_bin		), 
	.din_vld			(dout_vld_bin	), 
	.din_sop			(dout_sop_bin	), 
	.din_eop			(dout_eop_bin	), 
	.dout				(dout_sobel			),		
	.dout_vld		(dout_vld_sobel	), 		
	.dout_sop		(dout_sop_sobel	), 	
	.dout_eop		(dout_eop_sobel	) 	
);

fifo i2(
		.clk			(clk	),
		.rst_n		(rst_n),
		            
		.wr_en		(dout_vld_sobel),
		.din			(dout_sobel),
		.full			(full	),
                   
		.rd_en		(dout_vld_sobel),
		.dout			(fifo_data	),
		.empty		(empty)
);

vga i3(
	.clk				(clk			),
	.rst_n			(rst_n		),
	.fifo_data		(fifo_data	),
	.hys				(hys			),
	.vys				(vys			),       
	.rgb_data		(rgb_data	),	
	.vga_black		(vga_black	),
   .vga_sync		(vga_sync	)
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

//din
initial begin
    #1
	 dout_bin=0;
	 #(CYCLE*RST_TIME);
	 #(CYCLE*10);
	 repeat(307200) begin
	 #CYCLE;	 
    dout_bin<= $random;        
    end
    #100 $stop;
end

//vld
initial begin
    #1
	 dout_vld_bin=0;
	 #(CYCLE*RST_TIME);
	 #(CYCLE*10);
	 repeat(307200) begin
	 #(CYCLE);
	 #(CYCLE/2);
    dout_vld_bin=1;
	 #(CYCLE/2);
	 dout_vld_bin=0;
    end
    #100 $stop;
end

//sop
initial begin
    #1
	 dout_sop_bin=0;
	 #(CYCLE*RST_TIME);
	 #(CYCLE*10);
	 #CYCLE;
	 #(CYCLE/2);
    dout_sop_bin=1;
	 #(CYCLE/2);
	 dout_sop_bin=0;
end

//eop
initial begin
    #1
	 dout_eop_bin=0;
	 #(CYCLE*RST_TIME);
	 #(CYCLE*10);
	 #(CYCLE*307200);
	 #(CYCLE/2);
    dout_eop_bin=1;
	 #(CYCLE/2);
	 dout_eop_bin=0;
end

endmodule