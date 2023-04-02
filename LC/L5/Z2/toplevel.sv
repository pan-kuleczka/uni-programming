module circuit(input [31:0] i, output logic [31:0] o);
    logic [31:0] ccode, cbin;
    always_comb begin
        ccode = i;
        cbin = i;
        for(int cbit = 31; cbit >= 0; cbit--) begin
            ccode = ccode >> 1;
            cbin = cbin ^ ccode;
        end
        o = cbin;
    end
endmodule