module seg7(
    input [3:0] n,
    output [7:0] seg
    );
/*
n: number to display
seg: segment configure
*/
    //standard 7-segment form
    assign seg[0] = n==0 || n==2 || n==3 || n==5 || n==6 || n==7 || n==8 || n==9;
    assign seg[1] = n==0 || n==1 || n==2 || n==3 || n==4 || n==7 || n==8 || n==9;
    assign seg[2] = n==0 || n==1 || n==3 || n==4 || n==5 || n==6 || n==7 || n==8 || n==9;
    assign seg[3] = n==0 || n==2 || n==3 || n==5 || n==6 || n==8 || n==9;
    assign seg[4] = n==0 || n==2 || n==6 || n==8;
    assign seg[5] = n==0 || n==4 || n==5 || n==6 || n==7 || n==8 || n==9;
    assign seg[6] = n==2 || n==3 || n==4 || n==5 || n==6 || n==8 || n==9;
    assign seg[7] = 1'bz;
endmodule
