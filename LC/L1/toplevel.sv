module circuit(input a, b, c, d, x, y, output o);
    assign o =
        (!x && !y) && a
    ||  (!x && y) && b
    ||  (x && !y) && c
    ||  (x && y) && d;
endmodule