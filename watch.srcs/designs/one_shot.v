module one_shot(
    input clk,
    input in,
    output reg out
    );
/*
a pulser whose signal lasts a period of clk
*/
    reg buff;
    always@(posedge clk) begin
    	buff <= in;
    	out <= in && !buff; //only true with rising
    end
endmodule
