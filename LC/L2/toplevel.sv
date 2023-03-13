module circuit(input [3:0]i, output o);
    assign block1 = !(i[2] && i[3]) && i[1] && i[0];
    assign block2 = !(i[2] && i[3]) && (i[2] || i[3]) && (i[0] || i[1]);
    assign block3 = i[2] && i[3] && !(i[0] && i[1]);
    assign block4 = !(i[0] && i[1]) && (i[0] || i[1]) && (i[2] || i[3]);
    assign o = block1 || block2 || block3 || block4;
endmodule

//      00 01 10 11
//   00 0  0  0  1 
//   01 0  24 24 12
//   10 0  24 24 12 
//   11 3  34 34 0