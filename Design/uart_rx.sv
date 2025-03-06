
module uart_rx #(
    parameter int DATA_WIDTH = 8,
    parameter int CLK_FREQ = 50000000, 
    parameter int BAUD_RATE = 19200
)(
    input logic clk,
    input logic rst,
    input logic rx,
    output logic [DATA_WIDTH-1:0] rx_data_out
);

    localparam CLK_DIVIDE = (CLK_FREQ / BAUD_RATE);

    typedef enum bit [2:0] {
        IDLE   = 3'b000,
        START  = 3'b001,
        DATA   = 3'b010,
        STOP   = 3'b011,
        DONE   = 3'b100
    } rx_state;
    rx_state rx_current, rx_next;

    typedef struct {
        integer clk_div;
        logic [DATA_WIDTH-1:0] data;
        integer index;
    } rx_config;
    rx_config rx_curr_config, rx_next_config;

    always_ff @(posedge clk) begin
        if (rst) begin
            rx_current <= IDLE;
            rx_curr_config.clk_div <= 0;
            rx_curr_config.data <= 0;
            rx_curr_config.index <= 0;
        end else begin
            rx_current <= rx_next;
            rx_curr_config.clk_div <= rx_next_config.clk_div;
            rx_curr_config.data <= rx_next_config.data;
            rx_curr_config.index <= rx_next_config.index;
        end
    end

    assign rx_data_out = rx_curr_config.data;

    always_comb begin
        rx_next = rx_current;
        rx_next_config.clk_div = rx_curr_config.clk_div;
        rx_next_config.data = rx_curr_config.data;
        rx_next_config.index = rx_curr_config.index;

        case (rx_current)					 
            IDLE: begin
                rx_next_config.clk_div = 0;
                rx_next_config.index = 0;
                if (rx == 0) begin
                    rx_next = START;
                end else begin
                    rx_next = IDLE;
                end
            end

            START: begin
                if (rx_curr_config.clk_div < CLK_DIVIDE / 2) begin
                    if (rx == 0) begin
                        rx_next_config.clk_div = 0;
                        rx_next = DATA;
                    end else begin
                        rx_next = IDLE;
                    end
                end else begin
                    rx_next_config.clk_div = rx_curr_config.clk_div + 1;
                    rx_next = START;
                end
            end

            DATA: begin
                if (rx_curr_config.clk_div < CLK_DIVIDE / 2) begin
                    rx_next_config.clk_div = rx_curr_config.clk_div + 1;
                    rx_next = DATA;
                end else begin
                    rx_next_config.clk_div = 0;
                    rx_next_config.data[rx_curr_config.index] = rx;
                    if (rx_curr_config.index < (DATA_WIDTH - 1)) begin
                        rx_next_config.index = rx_next_config.index + 1;
                        rx_next = DATA;
                    end else begin
                        rx_next_config.index = 0;
                        rx_next = STOP;
                    end
                end
            end

            STOP: begin
                if (rx_curr_config.clk_div < CLK_DIVIDE / 2) begin
                    rx_next_config.clk_div = rx_curr_config.clk_div + 1;
                    rx_next = STOP;
                end else begin
                    rx_next_config.clk_div = 0;
                    rx_next = DONE;
                end
            end

            DONE: begin
                rx_next = IDLE;
            end

            default: rx_next = IDLE;
        endcase
    end

endmodule

