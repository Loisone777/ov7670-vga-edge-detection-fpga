module SCCB(
	input clk,
	input rst_n,
	input wr_en,
	input rd_en,
	output sio_c,
	output sio_dout,
	input sio_din,
	output dout,
	output dout_vld
);

SCCB_write i1(
	clk			(clk		),
	rst_n			(rst_n	),
	en				(wr_en	),
	sio_c			(sio_c	),
	sio_d			(sio_dout)
);

SCCB_read i2(
	clk			(clk		),
	rst_n			(rst_n	),
	en				(rd_en	),
	sio_c			(sio_c	),
	sio_d			(sio_dout),
	sio_din		(sio_din	),
	dout			(dout		),
	dout_vld		(dout_vld)
);

endmodule 