module circuit(
    input clk,
    input nrst,
    input door,
    input start,
    input finish,
    output logic heat,
    output logic light,
    output logic bell
);

    const logic [2:0] CLOSED = 3'd0, OPEN = 3'd1, COOK = 3'd2, BELL = 3'd3, PAUSE = 3'd4;

    logic [2:0] q;

    // output
    always_comb begin
        heat = 0; light = 0; bell = 0;
        unique case(q)
            CLOSED:;
            OPEN: light = 1;
            COOK: begin light = 1; heat = 1; end
            BELL: bell = 1;
            PAUSE: light = 1;
        endcase
    end

    // delta
    always_ff @(posedge clk or negedge nrst)
    if(!nrst) q <= CLOSED;
    else unique case(q)
        CLOSED: if(door) q <= OPEN; else if(start && !door) q <= COOK;
        OPEN: if(!door) q <= CLOSED;
        COOK: if(door) q <= PAUSE; else if(finish && !door) q <= BELL;
        BELL: if(door) q <= OPEN;
        PAUSE: if(!door) q <= COOK;
    endcase

endmodule
