module fifo(
		input               clk,
		input               rst_n,
		
		input               wr_en,
		input         		  din,
		output              full,
		
		input               rd_en,
		output  			     dout,
		output              empty
);

parameter WIDTH=1;
parameter DEPTH=1280;

reg  [10:0] wr_cnt=0;
reg  [10:0] rd_cnt=0;
wire [9:0] wr_p,rd_p;

assign wr_p = wr_cnt[9:0];
assign rd_p = rd_cnt[9:0];

reg [WIDTH-1:0] mem [DEPTH-1:0];
reg dout_r;

assign dout = dout_r;

//如果两个指针的MSB不同，说明写指针比读指针多折回了一次
//如果两个指针的MSB相同，则说明两个指针折回的次数相等。其余位相等，说明FIFO为空；
assign full = (wr_cnt[10]!= rd_cnt[10]&&wr_p==rd_p)? 1:0;
																		
assign empty = (wr_cnt== rd_cnt)?1:0;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        wr_cnt <=0;
        rd_cnt <=0;
    end
    else begin
        if(!full&&wr_en)begin
            mem[wr_p] <=  din;
            wr_cnt <= wr_cnt +1;
        end
        
        if(!empty&&rd_en)begin
            dout_r  <= mem[rd_p];
            rd_cnt <= rd_cnt + 1;
        end
			if(full)begin
				wr_cnt<=0;
				rd_cnt<=0;
			end
    end
end

endmodule 