module funnelShifter(input[7:0] a, b, input[3:0] n, output[7:0] o);
    logic[15:0] concat, shifted;
    assign concat = {a, b};
    assign shifted = concat >> n;
    assign o = shifted[7:0];
endmodule

module circuit(input[7:0] i, input[3:0] n, input ar, lr, rot, output[7:0] o);
    logic[7:0] left, base, right, funnelInput1, funnelInput2;
    logic[3:0] funnelShift;

    assign left = (rot ? i : (ar ? {8{i[7]}} : 8'b0));
    assign base = i;
    assign right = (rot ? i : 8'b0);

    assign funnelInput1 = (lr ? base : left);
    assign funnelInput2 = (lr ? right : base);
    assign funnelShift = (lr ? 4'd8 - n : n);

    funnelShifter fs(funnelInput1, funnelInput2, funnelShift, o);
endmodule
