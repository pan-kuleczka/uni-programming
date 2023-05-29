module mult(input [15:0] a, input [15:0] b, output [15:0] c);
    assign c = a * b;
endmodule

module circuit(
    input clk,
    input nrst,
    input start,
    input [15:0] inx,
    input [7:0] inn,
    output ready,
    output logic [15:0] out
);

    logic [15:0] result;
    logic [15:0] cx;
    logic [7:0] cn;

    wire [15:0] multOut;
    mult m(cn[0] ? result : cx, cx, multOut);

    
    always_ff @(posedge clk or negedge nrst) begin
        if(!nrst) begin
            result <= 1;
            cx <= 0;
            cn <= 0;
        end else if(!ready) begin
            if(cn[0]) begin
                result <= multOut;
                cn <= cn - 1;
            end else begin
                cx <= multOut;
                cn <= cn >> 1;
            end
        end else if(start) begin
            result <= 1;
            cx <= inx;
            cn <= inn;
        end            
    end

    assign ready = (cn == '0);
    assign out = result;

endmodule
