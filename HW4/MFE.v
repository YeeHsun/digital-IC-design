
`timescale 1ns/10ps

module MFE(clk,reset,busy,ready,iaddr,idata,data_rd,data_wr,addr,wen);
	input				clk;
	input				reset;  //Active-high asynchronous reset signal. 	
	input				ready;  //Grayscale image ready indication signal. 
	input	[7:0]		idata;	
	input	[7:0]		data_rd;
	output	reg			busy;	//System busy indication signal. 
	output	reg [13:0]	iaddr;
	output	reg [7:0]   data_wr;
	output	reg [13:0]	addr;
	output	reg			wen;
	
reg [2:0] cstate;
reg [2:0] nstate;
reg [7:0] data [0:8];  //9 pixels that are going to be proccessed
reg [7:0] data_ready [0:8];  //prevent multiple constant drivers for data
reg [13:0] pixel;  //output pixel
reg [3:0] proccessed_pixel;
reg [6:0] count_to_127; //count to 127 to determine where is the boundry (for padding)
reg [3:0] sort_count;
reg [3:0] i; // for iteration
reg [7:0] temp; // for swapping
//reg a;
wire [3:0] index;  //for assigning data
reg new_data;
parameter s_read = 3'd0 , s_ready = 3'd1 , s_sort = 3'd2 , s_write = 3'd3 , s_done = 3'd4 , s_assign = 3'd5;

assign index = proccessed_pixel - 4'd2;
//state block
always@(*)begin
	case(cstate)
		s_read:begin
			if(proccessed_pixel < 4'd10)
				nstate = s_read;
			else
				nstate = s_ready;
		end
		s_ready:begin //the proccessed pixels are all ready
			nstate = s_assign;
		end
		s_assign:begin
			nstate = s_sort;
		end
		s_sort:begin
			if(sort_count >= 1)
				nstate = s_sort;
			else
				nstate = s_write;
		end
		s_write:begin
			if(pixel == 14'd16383)
				nstate = s_done;
			else
				nstate = s_read;
			
			//nstate = s_test;
		end
		/*s_test:begin
			if(a == 1'd1)
				nstate = s_done;
			else
				nstate = s_test;
		end*/
		s_done:nstate = s_done;
		default:nstate = s_done;
	endcase
end
always@(posedge clk)begin
	if(reset)begin
		new_data <= 0;
		proccessed_pixel <= 4'd0;
		pixel <= 14'd0;
		count_to_127 <= 7'd0;
		busy <= 0;
		iaddr <= 14'd0;
		sort_count <= 4'd8;
		temp <= 8'd0;
		cstate <= s_read;
		wen = 0;
		//a = 1'd0;
	end
	else begin
		cstate <= nstate;
		case(cstate)
			s_read:begin
				busy <= 1;
				wen <= 0;
				case(proccessed_pixel)
					4'd0:iaddr <= pixel - 14'd129;
					4'd1:iaddr <= pixel - 14'd128;
					4'd2:iaddr <= pixel - 14'd127;
					4'd3:iaddr <= pixel - 14'd1;
					4'd4:iaddr <= pixel;
					4'd5:iaddr <= pixel + 14'd1;
					4'd6:iaddr <= pixel + 14'd127;
					4'd7:iaddr <= pixel + 14'd128;
					default:iaddr <= pixel + 14'd129;	
				endcase	
				if(proccessed_pixel < 4'd10)
					proccessed_pixel = proccessed_pixel + 4'd1;
				else
					proccessed_pixel = 4'd0;
			end
			s_ready:begin
				busy <= 1;
				wen <= 0;
			end
			s_assign:begin
				busy <= 1;
				wen <= 0;
			end
			s_sort:begin
				busy <= 1;
				wen <= 0;
				sort_count <= sort_count - 4'd1;
			end
			s_write:begin
				busy <= 1;
				wen <= 1;
				if(pixel == 14'd16383)
					pixel <= 14'd16383;
				else
					pixel <= pixel +14'd1;
				proccessed_pixel <= 4'd0;
				sort_count <= 4'd8;
				if(count_to_127 < 7'd127)
					count_to_127 <= count_to_127 + 7'd1;
				else
					count_to_127 <= 7'd0;
			end
			/*s_test:begin
				busy <= 1;
				wen <= 0;
				addr <= 14'd0;
				a <= 1'd1;
			end*/
			s_done:begin
				busy <= 0;
			end
			default:;
		endcase
	end
end

always@(sort_count or cstate)begin
	case(cstate)
		s_assign:begin
			for(i=0;i<=8;i=i+1)
				data_ready[i] = data[i];
		end
		s_sort:begin //bubble sort
			for(i=0;i<8;i=i+1)begin
				if(i<=4'd7)begin
					if(data_ready[i]>data_ready[i+1])begin //swap
						temp = data_ready[i];
						data_ready[i] = data_ready[i+1];
						data_ready[i+1] = temp;
					end
					else begin
						temp = temp;
						data_ready[i] = data_ready[i];
						data_ready[i+1] = data_ready[i+1];
					end
				end
			end
		end
		s_write:begin
			addr = pixel;
			data_wr = data_ready[4];
		end
		default:;
	endcase
end

//use for test whether the data is stored into memory
/*always@(data_rd)begin
	case(cstate)
		s_test:begin
			median = data_rd;
		end
		default:;
	endcase
end*/

always@(negedge clk)begin
	if(cstate == s_read || cstate == s_ready)
		new_data = ~new_data;
	else
		new_data = 0;
end

always@(new_data)begin
	if(busy == 1 && wen == 0)begin
		if(count_to_127 == 7'd0)begin //left bound of image
			if(pixel <= 14'd127)begin //upper bound of image
				case(index)
					4'd0:data[index] = 8'd0;
					4'd1:data[index] = 8'd0;
					4'd2:data[index] = 8'd0;
					4'd3:data[index] = 8'd0;
					4'd6:data[index] = 8'd0;
					default:data[index] = idata;
				endcase
			end
			else if(pixel >= 14'd16256 && pixel <= 14'd16383)begin  //lower bound of image
				case(index)
					4'd0:data[index] = 8'd0;
					4'd3:data[index] = 8'd0;
					4'd6:data[index] = 8'd0;
					4'd7:data[index] = 8'd0;
					4'd8:data[index] = 8'd0;
					default:data[index] = idata;
				endcase
			end
			else begin
				case(index)
					4'd0:data[index] = 8'd0;
					4'd3:data[index] = 8'd0;
					4'd6:data[index] = 8'd0;
					default:data[index] = idata;
				endcase
			end
		end
		else if(count_to_127 == 7'd127)begin //right bound of image
			if(pixel <= 14'd127)begin //upper bound of image
				case(index)
					4'd0:data[index] = 8'd0;
					4'd1:data[index] = 8'd0;
					4'd2:data[index] = 8'd0;
					4'd5:data[index] = 8'd0;
					4'd8:data[index] = 8'd0;
					default:data[index] = idata;
				endcase
			end
			else if(pixel >= 14'd16256 && pixel <= 14'd16383)begin  //lower bound of image
				case(index)
					4'd2:data[index] = 8'd0;
					4'd5:data[index] = 8'd0;
					4'd6:data[index] = 8'd0;
					4'd7:data[index] = 8'd0;
					4'd8:data[index] = 8'd0;
					default:data[index] = idata;
				endcase
			end
			else begin
				case(index)
					4'd2:data[index] = 8'd0;
					4'd5:data[index] = 8'd0;
					4'd8:data[index] = 8'd0;
					default:data[index] = idata;
				endcase 
			end
		end
		else begin
			if(pixel <= 14'd127)begin //upper bound of image
				case(index)
					4'd0:data[index] = 8'd0;
					4'd1:data[index] = 8'd0;
					4'd2:data[index] = 8'd0;
					default:data[index] = idata;
				endcase
			end
			else if(pixel >= 14'd16256 && pixel <= 14'd16383)begin  //lower bound of image
				case(index)
					4'd6:data[index] = 8'd0;
					4'd7:data[index] = 8'd0;
					4'd8:data[index] = 8'd0;
					default:data[index] = idata;
				endcase
			end
			else begin
				data[index] = idata;
			end
		end
		
		
	end
end
endmodule


	





