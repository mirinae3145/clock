module vga
 #(
 parameter Tvw       = 12'd6   ,  //VSYNC Pulse Width
 parameter Tvbp      = 12'd29  ,  //VSYNC Back Porch
 parameter Tvfp      = 12'd3   ,   //Vertical Front Porch
 parameter Tvdw      = 12'd768 ,  //Vertical valid data width
 parameter Thw       = 12'd136 ,  //HSYNC Pulse Width        
parameter Thbp      = 12'd160 ,  //HSYNC Back Porch         
parameter Thfp      = 12'd24  ,   //Horizontal Front Porch     
parameter Thdw      = 12'd1024,  //Horizontal valid data width
 parameter Vsync_pol = 1'b1    ,   //VSync Polarity, 1 = Active Low  
parameter Hsync_pol = 1'b1       //HSync Polarity, 1 = Active Low 
)
//set parameter for Horizontal Sync and Vertical Sync that fit computer  
 (
 /*****************************************************
 ** Input Signal Define                              **
 *****************************************************/
 input  wire            clk, 
 input  wire            rstb,
 input  wire            pattern_en,
 input wire [5:0] sec,
 input wire [5:0] min, 
 input wire [5:0] hour,
 input wire [5:0] curr_hour,
 input wire [5:0] curr_min, 
 input wire [17:0] current, 
 input wire [17:0] sw_time, 
 input wire [17:0] date,
 input wire [17:0] t,
 /*****************************************************
 ** Output Signal Define                             **
 *****************************************************/ 
 output wire            vga_vs      ,
 output wire            vga_hs      ,
 output wire [3:0]      vga_r       ,
 output wire [3:0]      vga_g       ,
 output wire [3:0]      vga_b
 );
//declaration module with clk, rstb, pattern_en, sec, min, hour, curr_hour, curr_min, current, sw_time, date, t as input values 
//and vga_vs, vga_hs, vga_r, vga_g, vga_b as output values

 /*****************************************************
 ** Parameter Definition                             **
 *****************************************************/
localparam Tvp   = Tvw + Tvbp + Tvfp + Tvdw;//VSYNC Period   
localparam Thp   = Thw + Thbp + Thfp + Thdw;//HSYNC Period   
localparam VSYNC_ACT = ~Vsync_pol; //active state for VSYNC based on the VSYNC polarity 
//VSYNC_pol is high -> the active state is low 
//VSYNC_pol is low -> the active state is high
localparam HSYNC_ACT = ~Hsync_pol; //active state for HSYNC based on the HSYNC polarity
//HSYNC_pol is high -> the active state is low 
//HSYNC_pol is low -> the active state is high  

 /*****************************************************
 ** Reg Definition                                  **
 *****************************************************/
 reg   [11:0]   hcnt        ; //horizontal counter
 reg   [11:0]   vcnt        ; //vertical counter
 reg   [11:0]   pat_hcnt    ; //pattern horizontal counter
 reg   [11:0]   pat_vcnt    ; //pattern vertical counter 
 reg           pat_vs      ; //pattern VSYNC signal 
 reg           pat_hs      ; //pattern HSYNC signal 
 reg           pat_de      ; //pattern data enable signal 
 reg   [3:0]   pat_r       ; //pattern red color
 reg   [3:0]   pat_g       ; //pattern green color
 reg   [3:0]   pat_b       ; //pattern blue color
 wire          clk_65       ; //65MHz clock signal 

  clk_wiz_0 clock_gen_65
   (.clk_out1(clk_65),     // output 65 MHz clock
    .clk_in1(clk) );        // input  100 MHz clock
   //use clock wizard to generate 65 MHz clock from input clock

 /*****************************************************
 ** HSYNC Period/VSYNC Period Count
 *****************************************************/
 always @(posedge clk_65 or negedge rstb) begin 
   if (!rstb) begin
       hcnt   <= 12'd0; //reset horizontal counter to 0
       vcnt   <= 12'd0; //reset vertical counter to 0
   end
   else begin
      /** HSYNC Period **/
      if (hcnt == (Thp - 1)) begin
         hcnt <= 12'd0; //reset horizontal counter when reach the end of the period 
      end
      else begin
         hcnt <= hcnt + 1'b1; //increase horizontal counter
      end
      /** VSYNC Period **/
      if (hcnt == (Thp - 1)) begin
         if (vcnt == (Tvp - 1)) begin
            vcnt <= 12'd0; //reset vertical counter when reach the end of the period 
         end
         else begin
            vcnt <= vcnt + 1'b1; //increase vertical counter
         end
      end
   end
 end

/*****************************************************
 ** VSYNC Signal Gen.
 *****************************************************/
 always @(posedge clk_65 or negedge rstb) begin 
   if (!rstb) begin
       pat_vs <= VSYNC_ACT; //reset VSYNC signal to active state
   end
   else begin
      if (hcnt == (Thp - 1)) begin
         if (vcnt == (Tvw - 1)) begin
            pat_vs <= ~VSYNC_ACT; //assign VSYNC signal at the end of the pulse width
         end
         else if (vcnt == (Tvp - 1)) begin 
            pat_vs <= VSYNC_ACT; //set VSYNC signal back to active state at the end of the period 
         end
      end
   end
 end
 /*****************************************************
 ** HSYNC Signal Gen.
 *****************************************************/
 always @(posedge clk_65 or negedge rstb) begin 
   if (!rstb) begin
       pat_hs <= HSYNC_ACT; //reset HSYNC signal to active state
   end
   else begin
      if (hcnt == (Thw - 1)) begin
         pat_hs <= ~HSYNC_ACT; //assign HSYNC signal at the end of the pulse width  
      end
      else if (hcnt == (Thp - 1)) begin
         pat_hs <= HSYNC_ACT; //set HSYNC signal back to active state at the end of the period 
      end
   end
 end
 /*****************************************************
 ** HSYNC/VSYNC Data Enable Signal Gen.
 *****************************************************/
 always @(posedge clk_65 or negedge rstb) begin 
   if (!rstb) begin
       pat_de   <= 1'b0; //reset data enable signal to 0 
   end
   else begin
      if ((vcnt >= (Tvw + Tvbp)) && (vcnt <= (Tvp - Tvfp - 1))) begin
         if (hcnt == (Thw + Thbp - 1)) begin
            pat_de <= 1'b1; //enable data signal at the end of the back porch 
         end
         else if (hcnt == (Thp - Thfp - 1))begin
            pat_de <= 1'b0; //disable data signal at the start of the front porch
         end
      end
   end
 end
 
 /*****************************************************
 ** Horizontal Valid Pixel Count
 *****************************************************/
 always @(posedge clk_65 or negedge rstb) begin 
   if (!rstb) begin
      pat_hcnt    <= 'd0; //reset horizontal pattern counter to 0 
   end
   else begin
      if (pat_de) begin
         pat_hcnt <= pat_hcnt + 'b1; //increase horizontal pattern counter
      end
      else begin
         pat_hcnt <= 'd0; //reset horizontal pattern counter when data enable is 0 
      end 
   end
 end
 /*****************************************************
 ** Vertical Valid Pixel Count
 *****************************************************/
 always @(posedge clk_65 or negedge rstb) begin 
   if (!rstb) begin
      pat_vcnt <= 'd0; //reset vertical pattern counter to 0 
   end
   else begin
      if ((vcnt >= (Tvw + Tvbp)) && (vcnt <= (Tvp - Tvfp - 1))) begin
         if (hcnt == (Thp - 1)) begin
            pat_vcnt <= pat_vcnt + 'd1; //increase vertical pattern counter at the end of each horizontal period 
         end
      end
      else begin
      pat_vcnt <= 'd0; //reset vertical pattern counter when out of active region 
      end
   end
 end
 
 /*****************************************************
 ** Color Generator
 *****************************************************/
 pixel_clk_generation pixel_clk_gen(.clk(clk_65), .display_on(pattern_en), .pixel_x(pat_hcnt), .pixel_y(pat_vcnt), .sec(sec), .min(min), .hour(hour), .curr_hour(curr_hour), .curr_min(curr_min), .current(current), .sw_time(sw_time), .date(date), .t(t), .R_data(vga_r), .G_data(vga_g), .B_data(vga_b));
 //generate pixel colors and digit numbers using pixel_clk_generation
 /*****************************************************
 ** Signal Interconnect
 *****************************************************/
 //connect generated VSYNC and HSYNC signals to output by assigning
 assign vga_vs  = pat_vs;
 assign vga_hs  = pat_hs;
 
 endmodule 
