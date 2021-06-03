module booth(out, in1, in2);

parameter width = 6;

input  	[width-1:0] in1;   //multiplicand
input  	[width-1:0] in2;   //multiplier
output  reg [2*width-1:0] out; //product



reg [2*width:0] P;
reg [width-1:0] temp = 6'b0;
reg [width-1:0] substract;
reg [width-1:0] sum;

always@(*)
begin
	P = {temp,in2,1'b0};
	// #1
	case(P[1:0])
		2'b00:begin
			P = {P[2*width],P[2*width:1]};
		end
		2'b01:begin
			sum = P[2*width:width+1] + in1;
			P = {sum[width-1],sum,P[width:1]};
		end
		2'b10:begin
			substract = P[2*width:width+1] + ~in1 + 6'b000001;
			P = {substract[width-1],substract,P[width:1]};
		end
		default:begin
			P = {P[2*width],P[2*width:1]};
		end
	endcase

	// #2
	case(P[1:0])
		2'b00:begin
			P = {P[2*width],P[2*width:1]};
		end
		2'b01:begin
			sum = P[2*width:width+1] + in1;
			P = {sum[width-1],sum,P[width:1]};
		end
		2'b10:begin
			substract = P[2*width:width+1] + ~in1 + 6'b000001;
			P = {substract[width-1],substract,P[width:1]};
		end
		default:begin
			P = {P[2*width],P[2*width:1]};
		end
	endcase
	
	// #3
	case(P[1:0])
		2'b00:begin
			P = {P[2*width],P[2*width:1]};
		end
		2'b01:begin
			sum = P[2*width:width+1] + in1;
			P = {sum[width-1],sum,P[width:1]};
		end
		2'b10:begin
			substract = P[2*width:width+1] + ~in1 + 6'b000001;
			P = {substract[width-1],substract,P[width:1]};
		end
		default:begin
			P = {P[2*width],P[2*width:1]};
		end
	endcase
	
	// #4
	case(P[1:0])
		2'b00:begin
			P = {P[2*width],P[2*width:1]};
		end
		2'b01:begin
			sum = P[2*width:width+1] + in1;
			P = {sum[width-1],sum,P[width:1]};
		end
		2'b10:begin
			substract = P[2*width:width+1] + ~in1 + 6'b000001;
			P = {substract[width-1],substract,P[width:1]};
		end
		default:begin
			P = {P[2*width],P[2*width:1]};
		end
	endcase

	// #5
	case(P[1:0])
		2'b00:begin
			P = {P[2*width],P[2*width:1]};
		end
		2'b01:begin
			sum = P[2*width:width+1] + in1;
			P = {sum[width-1],sum,P[width:1]};
		end
		2'b10:begin
			substract = P[2*width:width+1] + ~in1 + 6'b000001;
			P = {substract[width-1],substract,P[width:1]};
		end
		default:begin
			P = {P[2*width],P[2*width:1]};
		end
	endcase
	
	// #6
	case(P[1:0])
		2'b00:begin
			P = {P[2*width],P[2*width:1]};
		end
		2'b01:begin
			sum = P[2*width:width+1] + in1;
			P = {sum[width-1],sum,P[width:1]};
		end
		2'b10:begin
			substract = P[2*width:width+1] + ~in1 + 6'b000001;
			P = {substract[width-1],substract,P[width:1]};
		end
		default:begin
			P = {P[2*width],P[2*width:1]};
		end
	endcase

	
	out = P[2*width:1];
	
end
endmodule

