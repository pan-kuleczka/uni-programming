module circuit(input [7:0]a, input [7:0]b, input sub, output [7:0]o);

    function add(input a, input b, input incarry, output carry);
        carry = (a && b) || (a && incarry) || (b && incarry);
        add = a ^ b ^ incarry;
    endfunction

    function [1:0] add2(input [1:0]a, input [1:0]b, input incarry, output carry);
        logic midcarry;
        add2[0:0] = add(a[0:0], b[0:0], incarry, midcarry);
        add2[1:1] = add(a[1:1], b[1:1], midcarry, carry);
    endfunction

    function [3:0] add4(input [3:0]a, input [3:0]b, input incarry, output carry);
        logic midcarry;
        add4[1:0] = add2(a[1:0], b[1:0], incarry, midcarry);
        add4[3:2] = add2(a[3:2], b[3:2], midcarry, carry);
    endfunction

    function [7:0] add8(input [7:0]a, input [7:0]b, input incarry, output carry);
        logic midcarry;
        add8[3:0] = add4(a[3:0], b[3:0], incarry, midcarry);
        add8[7:4] = add4(a[7:4], b[7:4], midcarry, carry);
    endfunction

    function [7:0] flip(input [7:0] a);
        flip = add8(~a, 8'b1, 0);
    endfunction

    function [3:0] flip4(input [3:0] a);
        flip4 = add8(~a, 4'b1, 0);
    endfunction

    function bigger(input a, input b);
        bigger = a && !b;
    endfunction

    function bigger2(input [1:0]a, input [1:0]b);
        bigger2 = bigger(a[1:1], b[1:1]) 
            || (!bigger(b[1:1], a[1:1]) && bigger(a[0:0], b[0:0]));
    endfunction

    function bigger4(input [3:0]a, input [3:0]b);
        bigger4 = bigger2(a[3:2], b[3:2]) 
            || (!bigger2(b[3:2], a[3:2]) && bigger2(a[1:0], b[1:0]));
    endfunction

    function bigger8(input [7:0]a, input [7:0]b);
        bigger8 = bigger4(a[7:4], b[7:4]) 
            || (!bigger4(b[7:4], a[7:4]) && bigger4(a[3:0], b[3:0]));
    endfunction

    function [7:0] toBin(input [7:0] a);
        logic [7:0]d1, d2;
        d1 = {{4{0}}, a[7:4]};
        d2 = {{4{0}}, a[3:0]};
        toBin = add8(d2, add8(d1 << 3, d1 << 1, 0), 0);
    endfunction

    function [3:0] last4Sub(input [7:0] a, input [7:0] b);
        logic [7:0]result;
        logic bigger10;
        result = add8(a, flip(b), 0);
        logic [3:0] ten;
        ten = 4'd10;
        bigger10 = bigger4(result[3:0], ten);
        last4Sub = (
            (result[3:0] & {4{!bigger10}}) | (add4(result[3:0], flip4(ten)) & {4{bigger10}})
        );
    endfunction

    function [7:0] toDec(input [7:0] a);
        logic [7:0] c00, c10, c20, c30, c40, c50, c60, c70, c80, c90, c100;
        c00 = 8'd0;
        c10 = 8'd10;
        c20 = 8'd20;
        c30 = 8'd30;
        c40 = 8'd40;
        c50 = 8'd50;
        c60 = 8'd60;
        c70 = 8'd70;
        c80 = 8'd80;
        c90 = 8'd90;
        c100 = 8'd100;
        toDec = (
            ({4'd0, last4Sub(a, c00)} & {8{bigger8(a, c00)}} & {8{!bigger8(a, c10)}})
        |   ({4'd1, last4Sub(a, c10)} & {8{bigger8(a, c10)}} & {8{!bigger8(a, c20)}})
        |   ({4'd2, last4Sub(a, c20)} & {8{bigger8(a, c20)}} & {8{!bigger8(a, c30)}})
        |   ({4'd3, last4Sub(a, c30)} & {8{bigger8(a, c30)}} & {8{!bigger8(a, c40)}})
        |   ({4'd4, last4Sub(a, c40)} & {8{bigger8(a, c40)}} & {8{!bigger8(a, c50)}})
        |   ({4'd5, last4Sub(a, c50)} & {8{bigger8(a, c50)}} & {8{!bigger8(a, c60)}})
        |   ({4'd6, last4Sub(a, c60)} & {8{bigger8(a, c60)}} & {8{!bigger8(a, c70)}})
        |   ({4'd7, last4Sub(a, c70)} & {8{bigger8(a, c70)}} & {8{!bigger8(a, c80)}})
        |   ({4'd8, last4Sub(a, c80)} & {8{bigger8(a, c80)}} & {8{!bigger8(a, c90)}})
        |   ({4'd9, last4Sub(a, c90)} & {8{bigger8(a, c90)}} & {8{!bigger8(a, c100)}})
        );
    endfunction

    

    logic [7:0]abin, bbin, bsigned, result, resultpositive, resultcapped;
    logic negative, toobig;

    assign abin = toBin(a);
    assign bbin = toBin(b);
    assign bsigned = (
        (bbin & {8{!sub}}) | (flip(bbin) & {8{sub}})
    );
    assign result = add8(abin, bsigned, 0);
    assign negative = sub && bigger8(bbin, abin);
    
    logic [7:0] hundred;
    assign hundred = 8'd100;

    assign resultpositive = (
        (result & {8{!negative}}) | (add8(result, hundred, 0) & {8{negative}})
    );

    assign toobig = bigger8(resultpositive, hundred);
    assign resultcapped = (
        (resultpositive & {8{!toobig}}) | (add8(resultpositive, flip(hundred), 0) & {8{toobig}})
    );

    assign o = toDec(resultcapped);
endmodule
