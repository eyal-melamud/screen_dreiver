
/**
    input clk            - clock signal from the ctxo.
    input reset          - bottun reset signal.

    output color         - the cell color (black or white).
    output vsync         - the vertical sync pulse.
    output hsync         - the horizontal sync puls.
    output clk_to_screen - main lcd clock.
    output disp          - allows power to the lcd. not relevent connected to vcc in the board.
    output den           - enable data write.
    output leds          - debug leds.


    the purpuse of this code is to print a white squar in the middle of the lcd screen.
    in this moudule i check the timing of the lcd display and how to work with it.

    row - x
    col - y
*/
module controls_basic(
    input clk,
    input reset,
    
    input rx,
    output tx,
    output uart_sample,

    output [15:0]color,
    output vsync,
    output hsync,
    output clk_to_screen,
    //output disp,
    output den);

    parameter V_START=3'h0, VBP=3'h1, H_START=3'h2, HBP=3'h3, LCD_COL=3'h4, HFP=3'h5, VFP=3'h6, IDLE=3'h7; 
    parameter WHITE = 16'hffff, RED = 16'h001f, GEREEN = 16'h07e0, BLUE = 16'hf800, BLACK = 16'h0;

    reg clk_lcd, display_on_off;
    reg [2:0] state, next_state;
    reg [14:0] count;
    reg [8:0] col, row;
    wire temp;

    initial begin
        display_on_off  <= 1'b1 ;
        col             <= 9'b0 ;
        row             <= 9'b0 ;
        count           <= 15'b0;
        state           <= IDLE;
        clk_lcd         <= 1'b0 ;  
        
    end

    always @(*) begin
        case (state)
            V_START : next_state <= (count >=   1) ? VBP                            :V_START;
            VBP     : next_state <= (count >=  12) ? H_START                        :VBP    ;
            H_START : next_state <= (count >=   1) ? HBP                            :H_START;
            HBP     : next_state <= (count >=  43) ? LCD_COL                        :HBP    ;
            LCD_COL : next_state <= (count >= 480) ? HFP                            :LCD_COL;
            HFP     : next_state <= (count >=   2) ? ((col >= 272) ? VFP : H_START) :HFP    ;
            VFP     : next_state <= (count >=   1) ? IDLE                           :VFP    ;
            IDLE   : next_state  <= (count>=32000) ? V_START                        :IDLE   ; 
            default : next_state <=                                                  V_START;
        endcase
    end


    always @(posedge clk) begin
        clk_lcd <= ~clk_lcd;
    end

    always @(posedge clk_lcd) begin
        if (reset) begin
            display_on_off  <= 1'b1 ;
            col             <= 9'b0 ;
            row             <= 9'b0 ;
            count           <= 15'b0;
            state           <= IDLE;
        end else begin
            if (state == H_START) row <= 9'b0;
            if (state == V_START) col <= 9'b0;
            if (state == LCD_COL) row <= row + 1;
            if (state != next_state) begin
                if (state == HFP) col <= col + 1;
                state <= next_state;
                count <= 15'b0;;
            end else begin
                state <= next_state;
                count <= count + 1;
            end
        end
        
    end




    assign clk_to_screen    = clk_lcd           ;
    assign den              = (state == LCD_COL);
    //assign color            = ((row > 100) && (row < 150) && (col > 215) && (col < 265)) ? 24'hffffff: 24'h0;
    assign color            = ((row < 200) && (col < 128)) ? ((row[3] & col[3])&(col < 120) ? WHITE : BLUE) : ((col[5]) ? WHITE : RED);
    assign vsync            = ~((state == IDLE));
    assign hsync            = (state > H_START) && (state < VFP);
    ///assign disp             = ~reset;

    assign temp = rx;
    assign tx = temp;
    assign uart_sample = temp;
endmodule