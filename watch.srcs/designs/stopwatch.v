module stopwatch(
input clk, rstb, sw_lap, sw_pause,
input [17:0] current,
output reg [71:0] laps,
output reg [17:0] sw_time);
/*
sw_lap: to record a laptime, press triggered
sw_pause: to pause, activate. to release, supress
current: input time, must be re-initialized to sw_time when pause is released
sw_time: represent stopwatch time
laps: laptimes, concat
*/

wire trig;
one_shot o2135s(.clk(clk),.in(sw_lap),.out(trig));
reg [17:0] buff;
always @(posedge clk) begin
	if (!rstb) begin 
		laps=0;
		sw_time = 18'b0;
	end
	else begin
		if(!sw_pause)
			buff<=current;
		if(trig) begin
			laps=laps<<18;
			laps[17:0]<=sw_time;
		end
		sw_time<=buff;
	end
end
endmodule
