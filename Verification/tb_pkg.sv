package tb_pkg;
    class randomData;
        rand bit [7:0] data;

        constraint range_c {
            data >= 8'h00;
            data <= 8'hFF;
        }

        function bit [7:0] randomc();
            if (!this.randomize()) begin
                $display("Randomization failed.");
            end
            return data;
        endfunction
    endclass

    covergroup cg_uart(input logic clk, input bit [7:0] random_data, input logic tx_active);
        coverpoint random_data {
            bins low_values = {[0:63]};
            bins mid_values = {[64:127]};
            bins high_values = {[128:191]};
            bins max_values = {[192:255]};
        }
        coverpoint tx_active {
            bins tx_inactive = {0};
            bins tx_active = {1};
        }

    endgroup: cg_uart

endpackage
