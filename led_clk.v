module led_clk(
    input clk,
    input rst, 
    output [5:0] led);
    
    reg [5:0] l;
    reg [24:0] clk_to_sec;
    

    initial begin
        l <= 6'h0;
        clk_to_sec <= 25'h1;
    end
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            l <= 6'b0;
            clk_to_sec <= 25'h1;
        end else begin
            clk_to_sec <= clk_to_sec + 1;
            if (~(|clk_to_sec)) 
                l <= l + 1;
        end
    end

    assign led = ~l;
endmodule