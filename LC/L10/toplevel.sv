module RAM(
    input wr, clk,
    input [9:0] rdaddr, wraddr,
    input [15:0] in,
    output logic [15:0] out
);
    logic [15:0] mem [0:1023];

    assign out = mem[rdaddr];

    always_ff @(posedge clk)
        if (wr) mem[wraddr] <= in;
endmodule

module circuit(
    input nrst,
    input step,
    input [15:0] d,
    input push,
    input [1:0] op,
    output logic [15:0] out,
    output logic [9:0] cnt
);

    wire [15:0] memout;

    logic [15:0] top;
    logic [9:0] size;

    initial top = '0;
    initial size = '0;
    
    assign out = top;
    assign cnt = size;

    const logic [9:0] MAX_ADDR = 10'b1111111111;   

    RAM ram(nrst && push && size != MAX_ADDR, step, size - 1, size, top, memout);
    
    always_ff @(posedge step) begin
        if(!nrst) begin
            top <= 16'b0;
            size <= 10'b0;
        end else if(push) begin
            if(size != MAX_ADDR) begin
                top <= d;
                size <= size + 1;
            end
        end else begin
            unique case(op)
                1: top <= -top;
                2: if(size > 1) begin
                    top <= top + memout;
                    size <= size - 1;
                end
                3: if(size > 1) begin
                    top <= top * memout;
                    size <= size - 1;
                end
            endcase
        end
    end
endmodule
