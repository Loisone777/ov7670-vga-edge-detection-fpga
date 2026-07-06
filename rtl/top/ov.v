module ov(
	input clk,
	input rst_n,
	input key_in,
	output hys,
	output vys,
	output [23:0]rgb_data,
	output vga_sync,
	output vga_black
);

wire clk0;

wire [7:0]data;
wire [7:0]sub_addr;
wire key_vld;
wire ready;
wire sio_c;
wire sio_d;
wire m_valid;
wire data_start;

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

pll i4(
	.inclk0		(clk),
	.c0			(clk_0)
);

capture c1(
	.clk			(clk_0			),
	.rst_n			(rst_n		),
	.en_capture	(data_start	),
	.vsync			(vsync		),
	.href			(href			),		
	.din			(din			),
	.dout			(dout_capture		),
	.dout_vld		(dout_vld_capture	),
	.dout_sop		(dout_sop_capture	),
	.dout_eop		(dout_eop_capture	)
);

gray c2(
	.clk			(clk_0		),				
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

filter c3(
	.clk				(clk_0		),				
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

bin c4( 
    .clk				(clk_0			),			//pclk
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

sobel c5(
	.clk				(clk_0		),				
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

fifo c6(
		.clk			(clk_0	),
		.rst_n		(rst_n),
		            
		.wr_en		(dout_vld_sobel),
		.din			(dout_sobel),
		.full			(full	),
                   
		.rd_en		(dout_vld_sobel),
		.dout			(fifo_data	),
		.empty		(empty)
);

vga c7(
	.clk				(clk_0			),
	.rst_n			(rst_n		),
	.fifo_data		(fifo_data	),
	.hys				(hys			),
	.vys				(vys			),       
	.rgb_data		(rgb_data	),	
	.vga_black		(vga_black	),
   .vga_sync		(vga_sync	)
);


endmodule 