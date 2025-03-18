package tb_pkg;
    class randomData #(parameter int DATA_WIDTH = 8);
        rand bit [DATA_WIDTH-1:0] data;

        function bit [DATA_WIDTH-1:0] randomc();
            if (!this.randomize()) begin
                $display("Randomization failed.");
            end
            return data;
        endfunction
    endclass

endpackage
