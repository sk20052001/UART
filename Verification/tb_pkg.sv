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

endpackage
