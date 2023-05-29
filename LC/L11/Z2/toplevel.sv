module ctlpath(
    input eq,
    input less,
    input start,
    output logic operation,
    output logic ready,
    output logic load
);
    const logic OP_SWAP = 0, OP_SUB = 1;

    always_comb begin
        if(eq || less) operation = OP_SWAP;
        else operation = OP_SUB;

        ready = eq;
        load = eq && start;
    end
endmodule

module datapath(
    input clk,
    input nrst,
    input [7:0] ina,
    input [7:0] inb,
    output [7:0] out,
    input load,
    input operation,
    output eq,
    output less
);
    const logic OP_SWAP = 0, OP_SUB = 1;

    logic [7:0] a;
    logic [7:0] b;

    always_ff @(posedge clk or negedge nrst) begin
        if(!nrst) begin
            a <= '0;
            b <= '0;
        end else if(load) begin
            a <= ina;
            b <= inb;
        end else unique case(operation)
            OP_SWAP: begin a <= b; b <= a; end
            OP_SUB: a <= a - b;
        endcase
    end

    assign out = a;
    assign eq = (a == b);
    assign less = (a < b);
endmodule

module circuit(
    input clk,
    input nrst,
    input start,
    input [7:0] ina,
    input [7:0] inb,
    output ready,
    output [7:0] out
);

    wire eq, less, operation, load;

    ctlpath ctlpath(eq, less, start, operation, ready, load);
    datapath datapath(clk, nrst, ina, inb, out, load, operation, eq, less);
endmodule
