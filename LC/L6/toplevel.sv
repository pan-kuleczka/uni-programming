module d_latch(output q, nq, input en, d);
    logic nr, ns;
    nand gq(q, nr, nq), gnq(nq, ns, q),
    gr(nr, d, en), gs(ns, nr, en);
endmodule

module dff_ms(output q, nq, input clk, d);
    logic q1;
    d_latch dl1(q1, , !clk, d), dl2(q, nq, clk, q1);
endmodule

module clocked_mux(output q, input clk, l, r, dl, dr, d);
    dff_ms ff(q, , clk,
            (!l && !r && q)
        ||  (l && !r && dr)
        ||  (!l && r && dl)
        ||  (l && r && d)
    );
endmodule


module circuit(output [7:0] q, input i, c, l, r, input [7:0] d);
    clocked_mux
        cm7(q[7], c, l, r, q[6], i, d[7]),
        cm6(q[6], c, l, r, q[5], q[7], d[6]),
        cm5(q[5], c, l, r, q[4], q[6], d[5]),
        cm4(q[4], c, l, r, q[3], q[5], d[4]),
        cm3(q[3], c, l, r, q[2], q[4], d[3]),
        cm2(q[2], c, l, r, q[1], q[3], d[2]),
        cm1(q[1], c, l, r, q[0], q[2], d[1]),
        cm0(q[0], c, l, r, i, q[1], d[0]);
endmodule
