module PSE ( clk,reset,Xin,Yin,point_num,valid,Xout,Yout);
input clk;
input reset;
input [9:0] Xin;
input [9:0] Yin;
input [2:0] point_num;
output reg valid;
output reg [9:0] Xout;
output reg [9:0] Yout;
reg [1:0] cstate; //current state
//reg [4:0] cstate; //next state
//input data
reg [10:0] input_x [0:5];
reg [10:0] input_y [0:5];

reg [10:0] temp_inputx; //for swapping used
reg [10:0] temp_inputy;
integer input_counter; 
integer output_counter;
reg [2:0] cal_counter;
//temp vector
reg [10:0] A_x;
reg [10:0] A_y;
reg [10:0] B_x;
reg [10:0] B_y;
integer i ;
reg  [21:0] temp1; //for multiple
reg  [21:0] temp2;
reg  [22:0] temp3;
parameter  s_read = 2'd0 , s_calculate = 2'd1 ,  s_done = 2'd2;
//seqeuntial circuit
always@(posedge clk) begin
	if(reset) begin
		valid = 1'd0;
		Xout = 10'd0;
		Yout = 10'd0;
		temp_inputx = 11'd0;
		temp_inputy = 11'd0;
		temp1 = 22'd0;
		temp2 = 22'd0;
		temp3 = 23'd0;
		cstate = s_read;
		input_counter = 0;
		output_counter = 0;
		cal_counter = 3'd0;
		A_x = 11'd0;
		A_y = 11'd0;
		B_x = 11'd0;
		B_y = 11'd0;
		for(i=0;i<=5;i=i+1)begin
			input_x[i] = 11'd0;
			input_y[i] = 11'd0;
		end
	end		
	else begin
		case(cstate)	
			s_read:begin
				valid = 1'd0;
				Xout = 10'd0;
				Yout = 10'd0;
				cal_counter = point_num-3'd1;
				output_counter = 0;
				temp_inputx = 11'd0;
				temp_inputy = 11'd0;
				temp1 = 22'd0;
				temp2 = 22'd0;
				temp3 = 23'd0;
				A_x = 11'd0;
				A_y = 11'd0;
				B_x = 11'd0;
				B_y = 11'd0;
				input_x[input_counter] = {1'b0,Xin};
				input_y[input_counter] = {1'b0,Yin};
				if(input_counter < (point_num-1))begin
					input_counter = input_counter + 1;
					cstate = s_read;
				end
				else begin
					input_counter = 0;
					cstate = s_calculate;
				end
			end
			s_calculate:begin
				//use bubble sort
				valid = 1'd0;
				Xout = 10'd0;
				Yout = 10'd0;
				output_counter = 0;
				if(cal_counter>=3'd2) begin
					for(i=1;i<cal_counter;i=i+1) begin
						if(i<=4) begin
							//vector calculation
							A_x = input_x[i] - input_x[0];
							A_y = input_y[i] - input_y[0];
							B_x = input_x[i+1] - input_x[0];
							B_y = input_y[i+1] - input_y[0];
							
							//sign extension
							temp1 = {{11{A_x[10]}},A_x}*{{11{B_y[10]}},B_y};
							temp2 = {{11{A_y[10]}},A_y}*{{11{B_x[10]}},B_x};
							temp3 = {temp1[21],temp1} - {temp2[21],temp2};
							if(temp3[22] == 0)begin // i is bigger than i+1
								//swap i amd i+1
								temp_inputx = input_x[i];
								input_x[i] = input_x[i+1];
								input_x[i+1] = temp_inputx;
								temp_inputy = input_y[i];
								input_y[i] = input_y[i+1];
								input_y[i+1] = temp_inputy;
							end
						end
					end
					cal_counter = cal_counter-3'd1;
					cstate = s_calculate;
				end
				else begin
					cal_counter = point_num-3'd1;
					cstate = s_done;
				end
			end
			s_done:begin
				temp_inputx = 11'd0;
				temp_inputy = 11'd0;
				temp1 = 22'd0;
				temp2 = 22'd0;
				temp3 = 23'd0;
				cstate = s_read;
				input_counter = 0;
				cal_counter = 3'd0;
				A_x = 11'd0;
				A_y = 11'd0;
				B_x = 11'd0;
				B_y = 11'd0;
				Xout = input_x[output_counter][9:0];
				Yout = input_y[output_counter][9:0];
				if(output_counter==point_num)begin
					valid = 1'd0;
					output_counter = 0;
					cstate = s_read;
				end
				else begin
					valid = 1'd1;
					output_counter = output_counter + 1;
					cstate = s_done;
				end
			end
		endcase
	end
end
endmodule