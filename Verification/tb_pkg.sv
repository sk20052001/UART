package tb_pkg;
    class randomData #(parameter int DATA_WIDTH = 8);
        rand bit [DATA_WIDTH:0] data;

        function bit [7:0] randomc();
            if (!this.randomize()) begin
                $display("Randomization failed.");
            end
            return data;
        endfunction
    endclass

endpackage
