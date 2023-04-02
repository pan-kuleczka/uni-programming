module circuit(input [15:0] i, output logic [15:0] o);
    integer it1, it2;
    always_comb begin
        var [3:0] val1, val2;
        o = i;
        for(it1 = 0; it1 < 4; it1++) for(it2 = it1 + 1; it2 < 4; it2++) begin
            val1 = o[(it1 * 4) + 3 : it1 * 4];
            val2 = o[(it2 * 4) + 3 : it2 * 4];
          if(val1 > val2) begin o[(it1 * 4) + 3 : it1 * 4] = val2; o[(it2 * 4) + 3 : it2 * 4] = val1; end
            else begin o[(it1 * 4) + 3 : it1 * 4] = val1; o[(it2 * 4) + 3 : it2 * 4] = val2; end
        end
    end
endmodule
