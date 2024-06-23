module debounce(
    input clk,
    input in,
    output reg out
    );
/*
module that filtering out chattering in signal
clk: slow clock like ms
*/
    reg buff;
    parameter MAX=16; //how many counts input should last
    integer cnt;
    always@(posedge clk or negedge in) begin
    	if(!in) begin //when to reset
    		out=0;
    		cnt=0;
    	end
    	else begin
    		buff <= in; //synchronize
    		if(cnt==MAX)
    			out<=buff; //allow output to follow input
    		else if(buff != out)
    			cnt <= cnt+1;
    	end
    end
endmodule
