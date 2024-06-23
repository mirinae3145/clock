module scale(
	input clk,
    input rstb,
    input faster,
    input slower,
    input en,
    output reg [2:0] scale
    );
/*
en: enable to change scale
*/  
	//detect edge of switch input
	one_shot o43897598347s(.clk(clk),.in(faster&&en),.out(f_trig));
	one_shot o201s(.clk(clk),.in(slower&&en),.out(s_trig));
    always@(posedge clk) begin
    	if(!rstb)
        	scale<=3; //reset defualt 3
    	else begin
    		if(f_trig) begin //increase number
				if(scale == 7)
					scale <= scale;
				else
					scale <= scale + 1;
			end
			else if(s_trig) begin //decrease number
				if(scale == 0)
					scale <= scale;
				else
					scale <= scale - 1;
			end
			else
				scale<=scale;
    	end
    end			
endmodule
