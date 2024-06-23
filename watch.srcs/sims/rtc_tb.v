`timescale 10ns / 1ns
module rtc_tb;
    wire [9:0] MS;
    reg CLK;
    reg RSTB;
    reg [35:0] PRESET_TEST;
    wire [17:0]T;
    reg [2:0]SCALE;

    rtc rtc1(.clk(CLK),.rstb(RSTB),.scale(SCALE),.ms(MS));
//    rtc.freq=1;
    time_transform tt1(.clk(CLK),.rstb(RSTB),.mode(0),.ms(MS),.prst(PRESET_TEST),.t(T));
    
    initial begin
        CLK=0;
        RSTB=0;
        SCALE=3;
        PRESET_TEST=35'o01_01_01_10_20_30; //test initial time in oct
        #30 RSTB=1;
        #1000000 SCALE=4;
    end
    always #0.5 CLK = ~CLK;
    
endmodule