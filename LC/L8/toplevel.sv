module circuit(
    input clk,
    input [15:0] d,
    input [1:0] sel,
    output logic [15:0] cnt,
    output logic [15:0] cmp,
    output logic [15:0] top,
    output logic out
);
    assign out = cnt < cmp;

    always_ff @(posedge clk) begin
        cnt <= cnt >= top ? 0 : cnt + 16'd1;
        if (sel == 2'd1) cmp <= d;
        if (sel == 2'd2) top <= d;
        if (sel == 2'd3) cnt <= d;
    end

endmodule
