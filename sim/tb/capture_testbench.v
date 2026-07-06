`timescale 1ns/1ns

module capture_testbench();

//输入信号
reg		clk;
reg		rst_n;
reg		en_capture;
reg		vsync;
reg		href;
reg [7:0]din;

//时钟周期，单位为ns，数值大小可以根据需要来调整
parameter CYCLE = 20;

//复位信号，表示为3个时钟周期，可调
parameter RST_TIME = 3;

wire [15:0]dout_capture;
wire		  dout_vld_capture;
wire		  dout_sop_capture;
wire		  dout_eop_capture;

wire [7:0]dout_gray;
wire   	  dout_vld_gray; 
wire   	  dout_sop_gray; 
wire   	  dout_eop_gray;	

wire  [7:0]dout_filter;
wire   	  dout_vld_filter; 
wire   	  dout_sop_filter; 
wire   	  dout_eop_filter;	

wire  	  dout_bin;
wire   	  dout_vld_bin; 
wire   	  dout_sop_bin; 
wire   	  dout_eop_bin;

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
capture i1(
	.clk			(clk			),
	.rst_n			(rst_n		),
	.en_capture	(en_capture	),
	.vsync			(vsync		),
	.href			(href			),		
	.din			(din			),
	.dout			(dout_capture		),
	.dout_vld		(dout_vld_capture	),
	.dout_sop		(dout_sop_capture	),
	.dout_eop		(dout_eop_capture	)
);

gray i2(
	.clk			(clk		),				
	.rst_n			(rst_n	),		 	
	.din			(dout_capture		), 
	.din_vld		(dout_vld_capture	), 
	.din_sop		(dout_sop_capture	), 
	.din_eop		(dout_eop_capture	), 
	.dout			(dout_gray			),		
	.dout_vld		(dout_vld_gray		), 		
	.dout_sop		(dout_sop_gray		), 	
	.dout_eop		(dout_eop_gray		) 	
);

filter i3(
	.clk				(clk		),				
	.rst_n			(rst_n	),		 	
	.din				(dout_gray		), 
	.din_vld			(dout_vld_gray	), 
	.din_sop			(dout_sop_gray	), 
	.din_eop			(dout_eop_gray	), 
	.dout				(dout_filter			),		
	.dout_vld		(dout_vld_filter		), 		
	.dout_sop		(dout_sop_filter		), 	
	.dout_eop		(dout_eop_filter		) 	
);

bin i4( 
    .clk				(clk			),			//pclk
    .rst_n			(rst_n		),		//复位信号
    .gus_din		(dout_filter	),		//高斯滤波输入
    .gus_valid		(dout_vld_filter	),	//高斯滤波输入有效标志
    .gus_eop		(dout_eop_filter),
	 .gus_sop		(dout_sop_filter),
    .bin_dout		(dout_bin	),	//二值化输出
    .bin_valid 	(dout_vld_bin), 	//二值化输出有效标志
	 .bin_sop		(dout_sop_bin),
	 .bin_eop		(dout_eop_bin)
);	

sobel i5(
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

fifo i6(
		.clk			(clk	),
		.rst_n		(rst_n),
		            
		.wr_en		(dout_vld_sobel),
		.din			(dout_sobel),
		.full			(full	),
                   
		.rd_en		(dout_vld_sobel),
		.dout			(fifo_data	),
		.empty		(empty)
);

vga i7(
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

//生成en信号
initial begin
	en_capture=1;
	#2;
	en_capture=0;
	#(CYCLE*RST_TIME);
	#CYCLE
	en_capture=1;
end

//din
initial begin
    #1
	 din=0;
	 #(CYCLE*RST_TIME);
	 #(CYCLE*10);
	 din=8'b00000001;
	 repeat(307200) begin
	 #CYCLE	 
    din<= {$random()}%256;        
    end
    #100 $stop;
end

//vsync
initial begin
	#1;
	//赋初值
	vsync = 0;
	#(CYCLE*RST_TIME);
	//开始赋值
	#(CYCLE*5);	
	vsync = 1;
	#(CYCLE);
	vsync = 0;
end

//href
initial begin
	#1;
	//赋初值
	href = 0;
	#(CYCLE*RST_TIME);
	//开始赋值
	#(CYCLE*9+1);		
	repeat(480) begin
	href = 1;
	#(1280*CYCLE);
	href = 0;
	#(288*CYCLE);
	end
end

endmodule