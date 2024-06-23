module show_digit(
		input clk, rstb,dot,
		input [31:0] numbers,
		output [7:0] digit,
		output reg [7:0] seg_data
	);
/*
dynamic display module, clk must be slow
dot: whether show dots for date mark
numbers: 8-digits decimals to display
digit: which segment currently representing, decoded
*/
	wire [7:0]data[7:0];
	genvar i;
	generate for(i=0;i<8;i=i+1) begin
		seg7 seg(.n(numbers[4*i+3:4*i]),.seg(data[i])); //generate instances for each segment device in platform
	end endgenerate
	reg [2:0]d;
	assign digit = 2**d;
	
	always@(posedge clk or negedge rstb) begin
		if (!rstb) begin
			d = 0;
			seg_data = 0;
		end
		else begin
			d = d + 1;
			seg_data = data[7-d]; //lsb first in board
			seg_data[7] = dot & (d==7 | d==5 | d==3); //seperating yr, mon, day
		end
	end
endmodule
