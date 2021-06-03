library verilog;
use verilog.vl_types.all;
entity PSE is
    generic(
        s_read          : vl_logic_vector(0 to 1) := (Hi0, Hi0);
        s_calculate     : vl_logic_vector(0 to 1) := (Hi0, Hi1);
        s_done          : vl_logic_vector(0 to 1) := (Hi1, Hi0)
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        Xin             : in     vl_logic_vector(9 downto 0);
        Yin             : in     vl_logic_vector(9 downto 0);
        point_num       : in     vl_logic_vector(2 downto 0);
        valid           : out    vl_logic;
        Xout            : out    vl_logic_vector(9 downto 0);
        Yout            : out    vl_logic_vector(9 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of s_read : constant is 1;
    attribute mti_svvh_generic_type of s_calculate : constant is 1;
    attribute mti_svvh_generic_type of s_done : constant is 1;
end PSE;
