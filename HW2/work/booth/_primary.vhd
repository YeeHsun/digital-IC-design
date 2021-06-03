library verilog;
use verilog.vl_types.all;
entity booth is
    port(
        \out\           : out    vl_logic_vector(11 downto 0);
        in1             : in     vl_logic_vector(5 downto 0);
        in2             : in     vl_logic_vector(5 downto 0)
    );
end booth;
