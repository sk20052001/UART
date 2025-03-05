module uart_top #(
    parameter int DATA_WIDTH = 8,
    parameter CLK_FREQ = 50000000, //MHz
    parameter BAUD_RATE = 19200, //bits per second
) (
    input logic clk, rst,
    input logic rx,
    input logic [DATA_WIDTH - 1:0] tx_data_in,
    input logic start,
    output logic tx, 
    output logic [DATA_WIDTH - 1:0] rx_data_out,
    output logic tx_active,
    output logic done_tx
);

    UART_RX #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .DATA_WIDTH(DATA_WIDTH)
    ) receiver (
        .clk(clk),
        .rst(rst),
        .start(start),
        .tx_data
    );

    UART_TX #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .DATA_WIDTH(DATA_WIDTH)
    ) transmitter (.*);

endmodule

