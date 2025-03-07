
module uart_tx #(
    parameter int DATA_WIDTH = 8,
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 19200
) (
    input logic clk,
    input logic rst,
    input logic start,
    input logic [DATA_WIDTH-1:0] tx_data_in,
    output logic tx,
    output logic tx_active,
    output logic done_tx
);

    localparam CLK_DIVIDE = (CLK_FREQ / BAUD_RATE);

    typedef enum bit [2:0] {
        IDLE   = 3'b000,
        START  = 3'b001,
        DATA   = 3'b010,
        STOP   = 3'b011,
        DONE   = 3'b100
    } tx_state;
    tx_state tx_current, tx_next;

    typedef struct {
        integer clk_div;
        logic [DATA_WIDTH-1:0] data;
        integer index;
    } tx_config;
    tx_config tx_curr_config, tx_next_config;

    logic tx_out, tx_out_next;

    assign tx_active = (tx_current == DATA);
    assign tx = tx_out;

    always_ff @(posedge clk) begin
        if (rst) begin
            tx_current <= IDLE;
            tx_curr_config.clk_div <= 0;
            tx_out <= 0;
            tx_curr_config.data <= 0;
            tx_curr_config.index <= 0;
        end else begin
            tx_current <= tx_next;
            tx_curr_config.clk_div <= tx_next_config.clk_div;
            tx_out <= tx_out_next;
            tx_curr_config.data <= tx_next_config.data;
            tx_curr_config.index <= tx_next_config.index;
        end
    end

    always_comb begin
        tx_next = tx_current;
        tx_next_config.clk_div = tx_curr_config.clk_div;
        tx_out_next = tx_out;
        tx_next_config.data = tx_curr_config.data;
        tx_next_config.index = tx_curr_config.index;
        done_tx = 0;

        case (tx_current)
            IDLE: begin
                tx_out_next = 1;
                tx_next_config.clk_div = 0;
                tx_next_config.index = 0;
                if (start == 1) begin
                    tx_next_config.data = tx_data_in;
                    tx_next = START;
                end else begin
                    tx_next = IDLE;
                end
            end

            START: begin
                tx_out_next = 0;
                if (tx_curr_config.clk_div < CLK_DIVIDE / 2) begin
                    tx_next_config.clk_div = tx_curr_config.clk_div + 1;
                    tx_next = START;
                end else begin
                    tx_next_config.clk_div = 0;
                    tx_next = DATA;
                end
            end

            DATA: begin
                tx_out_next = tx_curr_config.data[tx_curr_config.index];
                if (tx_curr_config.clk_div < CLK_DIVIDE / 2) begin
                    tx_next_config.clk_div = tx_curr_config.clk_div + 1;
                    tx_next = DATA;
                end else begin
                    tx_next_config.clk_div = 0;
                    if (tx_curr_config.index < (DATA_WIDTH - 1)) begin
                        tx_next_config.index = tx_curr_config.index + 1;
                        tx_next = DATA;
                    end else begin
                        tx_next_config.index = 0;
                        tx_next = STOP;
                    end
                end
            end

            STOP: begin
                tx_out_next = 1;
                if (tx_curr_config.clk_div < CLK_DIVIDE / 2) begin
                    tx_next_config.clk_div = tx_curr_config.clk_div + 1;
                    tx_next = STOP;
                end else begin
                    tx_next_config.clk_div = 0;
                    tx_next = DONE;
                end
            end

            DONE: begin
                done_tx = 1;
                tx_next = IDLE;
            end

            default: tx_next = IDLE;
        endcase
    end

endmodule

