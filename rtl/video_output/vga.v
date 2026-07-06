module vga(
    clk			,
    rst_n		,
	 fifo_data	,
    hys			,
    vys			,
    rgb_data	,
	 vga_black	,
	 vga_sync	
);

input clk;
input rst_n;
input fifo_data;
output hys;
output vys;
output [23:0]rgb_data;
output vga_sync;
output vga_black;

reg hys;
reg vys;
reg [23:0]rgb_data;
wire vga_sync;
reg vga_black;

reg [9:0]h_cnt;
wire add_h_cnt;
wire end_h_cnt;

reg [9:0]v_cnt;
wire add_v_cnt;
wire end_v_cnt;

reg valid_area;

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        hys <= 0;
    end
    else if(add_h_cnt&&h_cnt==96-1)begin
        hys <= 1;
    end
    else if(end_h_cnt)begin
        hys <= 0;
    end
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        h_cnt <= 0;
    end
    else if(add_h_cnt)begin
        if(end_h_cnt)
            h_cnt <= 0;
        else
            h_cnt <= h_cnt + 1;
    end
end

assign add_h_cnt = 1;       
assign end_h_cnt = add_h_cnt && h_cnt== 800-1;   

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        vys <= 0;
    end
    else if(add_v_cnt&&v_cnt==2-1)begin
        vys <= 1;
    end
    else if(end_v_cnt)begin
        vys <= 0;
    end
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        v_cnt <= 0;
    end
    else if(add_v_cnt)begin
        if(end_v_cnt)
            v_cnt <= 0;
        else
            v_cnt <= v_cnt + 1;
    end
end

assign add_v_cnt = end_h_cnt;       
assign end_v_cnt = add_v_cnt && v_cnt== 525-1;

always @(*)begin
    valid_area=((h_cnt>=(96+48))&&(h_cnt<(96+48+640)))&&((v_cnt>=(2+33))&&(v_cnt<(2+33+480)));
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        rgb_data <= 0;
    end
    else if(valid_area)begin
			if(fifo_data==1'b1)
				rgb_data <= 24'b00000000_00000000_00000000;
			else if(fifo_data==1'b0)
				rgb_data <= 24'b11111111_11111111_11111111;
    end
end

assign vga_sync=0;

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        vga_black <= 0;
    end
    else if(((h_cnt>=(96+48))&&(h_cnt<(96+48+640)))&&((v_cnt>=(2+33))&&(v_cnt<(2+33+480))))begin
        vga_black<=1;
    end
	 else begin
        vga_black<=0;
    end
end

endmodule 