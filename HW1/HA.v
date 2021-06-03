module HA(s, c, x, y);
input x, y;
output reg s, c;

always@(x or y)
begin
	case({x,y})
	2'b00:
	begin
		s = 1'b0;
		c = 1'b0;
	end
	2'b01:
	begin
		s = 1'b1;
		c = 1'b0;
	end
	2'b10:
	begin
		s = 1'b1;
		c = 1'b0;
	end
	2'b11:
	begin
		s = 1'b0;
		c = 1'b1;
	end
	endcase
end 
endmodule
