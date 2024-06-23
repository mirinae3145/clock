module vga_port(
    input clk,
    input rstb,    
    output HSYNC,
    output VSYNC,
    output reg display_on, //display on
    output [9:0] pixel_x,  //pixel positions of pixel x, value:0~799 (hsync width 800) 
    output [9:0] pixel_y   //pixel positions of pixel y, value:0~524 (vsync width 525)
    );
    
   
   	
	reg			[1:0]		tft_clk_cnt;
	reg						tft_iclk, hsync_1, vsync_1;

	integer                hsync_cnt, vsync_cnt;
	
//***********************************************************************
//***********************  parameter Definition **********************
//***********************************************************************	
parameter HSYNC_BACK_PORCH = 48; 
parameter HSYNC_FRONT_PORCH = 16;
parameter HSYNC_PULSE = 96; 
parameter HSYNC_DISPLAY = 640;
parameter VSYNC_BACK_PORCH = 33; 
parameter VSYNC_FRONT_PORCH = 10;
parameter VSYNC_PULSE = 2; 
parameter VSYNC_DISPLAY = 480;
parameter hsync_width = 800; //(B+F+P+D)
parameter vsync_width = 525; 
	
wire lcd_data_en = (hsync_1 & vsync_1);
wire hsync_load = (hsync_cnt >= (hsync_width - 1)) ? 1'b1 : 1'b0;
wire vsync_load = (vsync_cnt >= (vsync_width - 1)) ? 1'b1 : 1'b0;

//***********************************************************************
//***********************  pixcel Clock Generation **********************
//***********************************************************************
	always @(posedge clk or negedge rstb) begin
		if(!rstb) begin
			tft_iclk <= 1'b0;
			tft_clk_cnt <= 2'b00;
		end
		else begin
			if(tft_clk_cnt == 2'b10) begin
				tft_iclk <= 1'b1;
				tft_clk_cnt <= 2'b00;
			end
			else begin
				tft_iclk <= 1'b0;
				tft_clk_cnt <= tft_clk_cnt + 1;
			end
		end
	end


//display ON/OFF
	always @(posedge tft_iclk or negedge rstb) begin
		if(!rstb) 
		  display_on <= 1'b0;
		else begin
			if((hsync_cnt < HSYNC_DISPLAY) && (vsync_cnt < VSYNC_DISPLAY)) 
			begin
			  display_on <= 1'b1;
			end
			else	
			  display_on <= 1'b0;
		end
	end
	
//***********************************************************************
//*********************** Hsync Generation **********************
//***********************************************************************

	always @(posedge tft_iclk or negedge rstb) begin
		if(!rstb)	hsync_cnt <= 0;
		else 
		begin
			if(hsync_load)	
			  hsync_cnt <= 0;
			else				
			  hsync_cnt <= hsync_cnt + 1;
		end
	end
	
	always @(posedge tft_iclk or negedge rstb) begin
		if(!rstb) begin 
		     hsync_1 <= 1'b1;
		end
		else begin
		    //if (hsync_cnt < HSYNC_PULSE)
			if((hsync_cnt >= HSYNC_BACK_PORCH) & (hsync_cnt <= (hsync_width - (HSYNC_FRONT_PORCH - 1)))) 
			begin
					hsync_1 <= 1'b0;
			end
			else begin
			        hsync_1 <= 1'b1;
			end
		end
	end

//***********************************************************************
//*********************** Vsync Generation **********************
//***********************************************************************

	always @(posedge tft_iclk or negedge rstb) begin
		if(!rstb)	vsync_cnt <= 0;
		else begin
			//if(hsync_load) begin
				if(vsync_load)	vsync_cnt <= 0;
				else			vsync_cnt <= vsync_cnt + 1;
			//end
			//else vsync_cnt <= vsync_cnt;
		end
	end
	
	always @(posedge tft_iclk or negedge rstb) begin
		if(!rstb) vsync_1 <= 1'b1;
		else begin
			//if (vsync_cnt < VSYNC_PULSE)
			if((vsync_cnt >= VSYNC_BACK_PORCH) & (vsync_cnt <= (vsync_width - (VSYNC_FRONT_PORCH - 1)))) 
			begin
					vsync_1 <= 1'b0;
			end
			else	
			  vsync_1 <= 1'b01;
		end
	end



//***********************************************************************
//************************** output Generation **************************
//***********************************************************************
	assign HSYNC = hsync_1;
	assign VSYNC = vsync_1;
	assign pixel_x = hsync_cnt; 
	assign pixel_y = vsync_cnt;
	
	

endmodule
