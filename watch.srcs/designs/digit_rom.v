module digit_rom(input [3:0] rom, input [6:0] row, input [6:0] col, //8*8 bitmap
    output reg digit
     ); 
     //declaration module with rom, row, col as input values and digit as output values
     //rom: number and characters 
     //row & column: the horizontal and vertical position in the bitmap
     //digiti: digit numerical shape 
     
    always @ *
    // define the shape for each digit and characters 
    begin
      case (rom) //run if the desired condition is TRUE as a case for rom
        4'd0: digit <= (row <= 6 || row >= 121 || col <= 6 || col >= 57); //shape of digit 0 
        4'd1: digit <= ((row>=0 && row <= 127) && (col>=28 && col <= 34)); //shape of digit 1
        4'd2: digit <= (row <= 6 || row >= 121 || (row >= 60 && row <= 66) || (col <=6 && row >=66) || (col >= 57 && row <=60)); //shape of digit 2
        4'd3: digit <= (row <=6 || row >= 121 || (row >= 60 && row <= 66) || col >= 57); //shape of digit 3
        4'd4: digit <= ((row >= 60 && row <= 66) || (col <=6 && row <= 60) || col >= 57); //shape of digit 4
        4'd5: digit <= (row <= 6 || row >= 121 || (row >= 60 && row <= 66) || (col <=6 && row <=60) || (col >= 57 && row >= 66)); //shape of digit 5
        4'd6: digit <= (row <=6 || row >= 121 || (row >= 60 && row <= 66) || col<=6 || (col >= 57 && row >= 66)); //shape of digit 6
        4'd7: digit <= ((row <= 6 && row > 0) || col >= 57); //shape of digit 7
        4'd8: digit <= (row <= 6 || row >= 121 || (row >= 60 && row <= 66) || col <= 6 || col >= 57); //shape of digit 8 
        4'd9: digit <= (row <= 6 || row >= 121 || (row >= 60 && row <= 66) || col >= 57 || (col <= 6 && row <= 60)); //shape of digit 9
        4'd10: digit <= (((col>=28 && col <= 34) && (row >= 50 && row <= 55)) || ((col>=28 && col <= 34) && (row >= 71 && row <= 76))); 
        // shape of digit colon (:)
        4'd11: digit <= ((col>=28 && col <= 34) && row >=121) ? 1:0; // shape of digit period (.) 
        default: digit = 0; //default case related to rom 
      endcase
    end  

endmodule




