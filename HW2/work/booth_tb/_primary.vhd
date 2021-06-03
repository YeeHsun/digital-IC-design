library verilog;
use verilog.vl_types.all;
entity booth_tb is
    generic(
        width           : integer := 6
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of width : constant is 1;
end booth_tb;
