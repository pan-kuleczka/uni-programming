module d_latch(output q, nq, input en, d);
    logic nr, ns;
    nand gq(q, nr, nq), gnq(nq, ns, q),
    gr(nr, d, en), gs(ns, nr, en);
endmodule

module d_ff(output q, nq, input clk, d);
    logic q1;
    d_latch dl1(q1, , !clk, d), dl2(q, nq, clk, q1);
endmodule

module quad_ff(output [3:0] q, input clk, input [3:0] d);
    for(genvar i = 0; i < 4; i++) d_ff ff(q[i], , clk, d[i]);
endmodule

module fulladder(output logic s, cout, input a, b, cin);
        assign s = a ^ b ^ cin;
        assign cout = (a || b) && cin || a && b;
endmodule

module adder#(parameter W = 4) (output [W-1:0] o, output cn, input [W-1:0] a, b, input c0);
    logic [W:0] c;
    assign c[0] = c0;
    assign cn = c[W];
    genvar i;
    for (i = 0; i < W; i = i+1)
    fulladder fa1(o[i], c[i+1], a[i], b[i], c[i]);
endmodule

module val_mux(output logic [3:0] out, input [3:0] cstate, input nrst, step, down);
    adder a(out, , 
        nrst ? cstate : 0,
        nrst ? 
            (down ?
                (step ? -2 : -1)
                : (step ? 2 : 1)
            )
        : 0, 0);
endmodule

module circuit(output [3:0] out, input clk, nrst, step, down);
    logic [3:0] d;
    quad_ff q_ff(out, clk, d);
    val_mux v_m(d, out, nrst, step, down);
endmodule
