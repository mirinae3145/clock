module time_setting (
    input clk,
    input rstb,
    input left, right,
    input inc, dec,
    input set,mode,
    input [17:0] prst_d,
    input [17:0] prst_t,
    output reg [17:0] t, date,
    output reg [17:0] tmp,
    output reg [2:0] digit,
    output reg set_done
);

// registers used to store time and date information
reg [5:0] yr,mon,day,hr,min,sec;


// following are used to make one pulse of inputs
wire [5:0] trig;
assign trig[5]=0;
one_shot o3s(.clk(clk),.n(left),.out(trig[4]));
one_shot o4s(.clk(clk),.in(right),.out(trig[3]));
one_shot o5s(.clk(clk),.in(inc),.out(trig[2]));
one_shot o6s(.clk(clk),.in(dec),.out(trig[1]));
one_shot o7s(.clk(clk),.in(set),.out(trig[0]));


always@(posedge clk or negedge rstb) begin
	// reset
	if(!rstb) begin
		digit <= 0;
		tmp <= 0;
		if(prst_d)begin
			{yr,mon,day}<=prst_d;
			date<=prst_d;
		end else begin
			{yr,mon,day}<={6'd24,6'd1,6'd1};
			date<={6'd24,6'd1,6'd1};
		end
		if(prst_t)begin
			{hr,min,sec}<=prst_t;
			t<=prst_t;
		end else begin
			{hr,min,sec}<=0;
			t<=0;
		end
	set_done=0;
	end
	else begin
		// triggers on each buttons
        case (trig)
            6'b010000: begin // left
                if (digit == 3'd5)
                    digit <= 0;
                else
                    digit <= digit + 1;
            end
            6'b001000: begin // right
                if (digit == 3'b0)
                    digit <= 3'd5;
                else
                    digit <= digit - 1;
            end
            6'b000100: begin // inc
                case ({mode, digit})
                    4'b0_000: begin		// increase units of second
                        if (sec == 6'd59)
                            sec <= 0;
                        else
                            sec <= (sec + 1);
                    end
                    4'b0_001: begin		// increase tens of second
                        if (sec >= 6'd50)
                            sec <= (sec - 6'd50);
                        else
                            sec <= (sec + 10);
                    end
                    4'b0_010: begin		// increase units of minute
                        if (min == 6'd59)
                            min <= 0;
                        else
                            min <= (min + 1);
                    end
                    4'b0_011: begin		// increase tens of minute
                        if (min  >= 6'd50)
                            min <= (min - 6'd50);
                        else
                            min <= (min + 10);
                    end
                    4'b0_100: begin		// increase units of hour
                        if (hr ==6'd23)
                            hr <= 0;
                        else
                            hr <= (hr + 1);
                    end
                    4'b0_101: begin		// increase tens of hour
                        if (hr < 6'd14)
                            hr <= (hr + 10);
                        else
                            hr <= 6'd23;
                    end
                    4'b1_000: begin		// increase units of days
                        case (mon)
                            6'd4, 6'd6, 6'd9, 6'd11: begin
                                day <= ((day == 6'd30) ? 1 : (day + 1));
                            end
                            6'd2: begin
                                if (yr & 6'b000011) begin   // if year % 4 != 0
                                    day <= ((day == 6'd28) ? 1 : (day + 1));
                                end
                                else begin
                                    day <= ((day == 6'd29) ? 1 : (day + 1));
                                end
                            end
                            default: begin
                                day <= ((day == 6'd31) ? 1 : (day + 1));
                            end
                        endcase
                    end
                    4'b1_001: begin		// increase tens of days
                        case (mon)
                            6'd4, 6'd6, 6'd9, 6'd11: begin
                                day <= ((day >= 6'd20) ? 6'd30 : (day + 10));
                            end
                            6'd2: begin
                                if (yr & 6'b000011) begin   // if year % 4 != 0
                                    day <= ((day >= 6'd18) ? 6'd28 : (day + 10));
                                end
                                else begin
                                    day <= ((day >= 6'd19) ? 6'd29 : (day + 10));
                                end
                            end
                            default: begin
                                day <= ((day >= 6'd21) ? 6'd31 : (day + 10));
                            end
                        endcase
                    end
                    4'b1_010: begin		// increase units of month
                        mon <= ((mon == 6'd12) ? 6'd1 : (mon + 1));
                    end
                    4'b1_011: begin		// incrase tens of month
                        mon <= ((mon >= 6'd3) ? 6'd12 : (mon + 10));
                    end
                    4'b1_100: begin		// increase units of year
                        yr <= (yr + 1);
                    end
                    4'b1_101: begin		// increase tens of year
                        yr <= ((yr >= 6'd53) ? 6'd63 : (yr + 6'd10));
                    end
                    default: begin
                        sec <= 0;
                        min <= 0;
                        hr <= 0;
                        day <= 1;
                        mon <= 1;
                        yr <= 24;
                    end
                endcase
//                VAL_CHANGED <= 1;
            end
            6'b000010: begin // dec
                case ({mode, digit})
                    4'b0_000: begin		// decrease units of second
                        sec <= ((sec == 0) ? 6'd59 : (sec - 1));
                    end
                    4'b0_001: begin		// decrease tens of second
                        sec <= ((sec <= 6'd9) ? (sec + 6'd50) : (sec - 6'd10));
                    end
                    4'b0_010: begin		// decrease units of minute
                        min <= ((min == 0) ? 6'd59 : (min - 1));
                    end
                    4'b0_011: begin		// decrease tens of minute
                        min <= ((min <= 6'd9) ? (min + 6'd50) : (min - 6'd10));
                    end
                    4'b0_100: begin		// decrease units of hour
                        hr <= ((hr == 0) ? 6'd23 : (hr - 1));
                    end
                    4'b0_101: begin		// decrease tens of hour
                        hr <= ((hr <= 6'd10) ? 0 : (hr - 6'd10));
                    end
                    4'b1_000: begin		// decrease units of days
                        case (mon)
                            6'd4, 6'd6, 6'd9, 6'd11: begin
                                day <= ((day == 6'd1) ? 6'd30 : (day - 1));
                            end
                            6'd2: begin
                                if (yr & 6'b000011) begin   // if year % 4 != 0
                                    day <= ((day == 6'd1) ? 6'd28 : (day - 1));
                                end
                                else begin
                                    day <= ((day == 6'd1) ? 6'd29 : (day - 1));
                                end
                            end
                            default: begin
                                day <= ((day == 6'd1) ? 6'd31 : (day - 1));
                            end
                        endcase
                    end
                    4'b1_001: begin		// decrease tens of days
                        day <= ((day <= 6'd11) ? 6'd1 : (day - 10));
                    end
                    4'b1_010: begin		// decrease units of month
                        mon <= ((mon == 6'd1) ? 6'd12 : (mon - 1));
                    end
                    4'b1_011: begin		// decrease tens of month
                        mon <= ((mon == 6'd12) ? 6'd2 : 6'd1);
                    end
                    4'b1_100: begin		// decrease units of year
                        yr <= (yr - 1);
                    end
                    4'b1_101: begin		// decrease tens of year
                        yr <= ((yr <= 6'd10) ? 6'd0 : (yr - 6'd10));
                    end
                    default: begin
                        sec <= 0;
                        min <= 0;
                        hr <= 0;
                        day <= 1;
                        mon <= 1;
                        yr <= 24;
                    end
                endcase
            end
            6'b000001: begin // set
                if(mode)		// set date information
                	date<=tmp;
                else			// set time information
                	t <= tmp;
                set_done<=1;
            end
            default: begin
            
            end
        endcase 
    	if(mode)			// store date information to tmp
    		tmp<={yr,mon,day};
    	else				// store time information to tmp
    		tmp<={hr,min,sec};
    end
end
endmodule