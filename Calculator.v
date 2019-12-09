
//main module, used for the main control
module Calculator(sel,i0,i1,ans_r,btn_control,show_num,show_place,sign_out,clk_original);
input[1:0]btn_control;  //control showing which num
input[1:0]sel;          //control calculating type
input[3:0]i0,i1;			//input number 0 and number 1
input clk_original;
output[7:0]ans_r;			//answer
output[6:0]show_num;		//the number that will be shown
output[5:0]show_place;	//the place that will show
output sign_out;			//the sign that will show
wire[7:0]ans_plus,ans_minus,ans_multiply;	//four calculation numbers that will be shown
wire sign1,sign2,sign3;	//four signs of the calculation results
wire ten_forward,ten_middle,ten_behind;	//the integer digits of the result
wire clk_original;
wire clk;
Plus4 plus_mux(i0,i1,ans_plus);		//calculate plus	
Minus4 minus_mux(i0,i1,ans_minus,sign);	//calculate minus
Multiply4 multiply_mux(i0,i1,ans_multiply);	//calculate multiply
four_choose_one select_mux(sel,8'b00000000,ans_plus,ans_minus,ans_multiply,ans_r);	//select the calculation result you want
four_choose_one_simple select_one_simple_mux(sel,0,0,sign,0,sign_out);//select the sign you want

//show_control show_mux(i0,i1,ans_r[7:4],ans_r[3:0],btn_control,show_num,show_place);//show,used in showing 16 number
//show_control_ten show_mux(ans_r,btn_control,show_num,show_place);//show,used in showing 10 number

counter count_mux(clk_original,clk);						//generate new clock using original clock
show_control_ten_continuously show_mux(ans_r,clk,show_num,show_place);//show,used in showing 10 number continuously
endmodule


//used in plus
module Plus4(i0,i1,sum);
input[3:0]i0,i1;
output[7:0]sum;
assign sum = i0 + i1;
endmodule

//used in minus
module Minus4(i0,i1,sum,sign);
input[3:0]i0,i1;
output[7:0]sum;
output sign;
reg[7:0]sum;
reg sign;
always@(*)
begin
if(i0>=i1)
	begin
	sum = i0 - i1;
	sign = 0;
	end
else
	begin
	sign = 1;
	sum = ~(i0-i1-1);
	end
end
endmodule

//used in multiply
module Multiply4(i0,i1,sum);
input[3:0]i0,i1;
output[7:0]sum;
assign sum = i0 * i1;
endmodule


//used in choosing one 4 digit signal in for, used in selecting
module four_choose_one(sel,num_00,num_01,num_10,num_11,out);
input[7:0]num_00,num_01,num_10,num_11;
input[1:0]sel;
output[7:0]out;
reg[7:0]out;
always@(*)
begin
	case(sel)
		2'b00:out = num_00;
		2'b01:out = num_01;
		2'b10:out = num_10;
		2'b11:out = num_11;
	endcase
end
endmodule


//used for choosing 1 digit signal in four signals
module four_choose_one_simple(sel,num_00,num_01,num_10,num_11,out);
input num_00,num_01,num_10,num_11;
input[1:0]sel;
output out;
reg out;
always@(*)
begin
	case(sel)
		2'b00:out = num_00;
		2'b01:out = num_01;
		2'b10:out = num_10;
		2'b11:out = num_11;
	endcase
end
endmodule


//used in showing 16 numbers
module show_control(i0,i1,ans_forward,ans_behind,btn_control,show_num,show_place);
input[3:0]i0,i1,ans_forward,ans_behind;
output[6:0]show_num;
output[5:0]show_place;
input[1:0]btn_control;
reg[3:0]to_be_shown;
reg[6:0]show_num;
reg[5:0]show_place;
reg[6:0] show0 = 7'b0000001;
reg[6:0] show1 = 7'b1001111;
reg[6:0] show2 = 7'b0010010;
reg[6:0] show3 = 7'b0000110;
reg[6:0] show4 = 7'b1001100;
reg[6:0] show5 = 7'b0100100;
reg[6:0] show6 = 7'b0100000;
reg[6:0] show7 = 7'b0001111;
reg[6:0] show8 = 7'b0000000;
reg[6:0] show9 = 7'b0000100;
reg[6:0] show10 = 7'b0001000;
reg[6:0] show11 = 7'b1100000;
reg[6:0] show12 = 7'b0110001;
reg[6:0] show13 = 7'b0100010;
reg[6:0] show14 = 7'b0110000;
reg[6:0] show15 = 7'b0111000;
always@(*)
begin
	case(btn_control)
		2'b00:
		begin
		show_place = 6'b101111;
		to_be_shown = i0;
		end
		2'b01:
		begin
		show_place = 6'b111011;
		to_be_shown = i1;
		end
		2'b10:
		begin
		show_place = 6'b111101;
		to_be_shown = ans_forward;
		end
		2'b11:
		begin
		show_place = 6'b111110;
		to_be_shown = ans_behind;
		end
	endcase
end
always@(*)
begin
	case(to_be_shown)
		4'b0000:show_num = show0;
		4'b0001:show_num = show1;
		4'b0010:show_num = show2;
		4'b0011:show_num = show3;
		4'b0100:show_num = show4;
		4'b0101:show_num = show5;
		4'b0110:show_num = show6;
		4'b0111:show_num = show7;
		4'b1000:show_num = show8;
		4'b1001:show_num = show9;
		4'b1010:show_num = show10;
		4'b1011:show_num = show11;
		4'b1100:show_num = show12;
		4'b1101:show_num = show13;
		4'b1110:show_num = show14;
		4'b1111:show_num = show15;
	endcase
end

endmodule



//used in showing decimals
module show_control_ten(ans_r,btn_control,show_num,show_place);
input[7:0] ans_r;
output[6:0]show_num;
output[5:0]show_place;
input[1:0]btn_control;
reg[3:0] to_be_shown;
reg[6:0]show_num;
reg[5:0]show_place;
reg[3:0] ten_behind,ten_forward,ten_middle;
always@(*)
begin
ten_forward = ans_r/8'd100;
ten_middle = (ans_r-8'd100*ten_forward)/4'd10;
ten_behind = ans_r%4'd10;
end
reg[6:0] show0 = 7'b0000001;
reg[6:0] show1 = 7'b1001111;
reg[6:0] show2 = 7'b0010010;
reg[6:0] show3 = 7'b0000110;
reg[6:0] show4 = 7'b1001100;
reg[6:0] show5 = 7'b0100100;
reg[6:0] show6 = 7'b0100000;
reg[6:0] show7 = 7'b0001111;
reg[6:0] show8 = 7'b0000000;
reg[6:0] show9 = 7'b0000100;
reg[6:0] show10 = 7'b0001000;
reg[6:0] show11 = 7'b1100000;
reg[6:0] show12 = 7'b0110001;
reg[6:0] show13 = 7'b0100010;
reg[6:0] show14 = 7'b0110000;
reg[6:0] show15 = 7'b0111000;
always@(*)
begin
	case(btn_control)
		2'b00:
		begin
		show_place = 6'b111111;
		to_be_shown = 4'd0;
		end
		2'b01:
		begin
		show_place = 6'b111011;
		to_be_shown = ten_forward;
		end
		2'b10:
		begin
		show_place = 6'b111101;
		to_be_shown = ten_middle;
		end
		2'b11:
		begin
		show_place = 6'b111110;
		to_be_shown = ten_behind;
		end
	endcase
end
always@(*)
begin
	case(to_be_shown)
		4'b0000:show_num = show0;
		4'b0001:show_num = show1;
		4'b0010:show_num = show2;
		4'b0011:show_num = show3;
		4'b0100:show_num = show4;
		4'b0101:show_num = show5;
		4'b0110:show_num = show6;
		4'b0111:show_num = show7;
		4'b1000:show_num = show8;
		4'b1001:show_num = show9;
		4'b1010:show_num = show10;
		4'b1011:show_num = show11;
		4'b1100:show_num = show12;
		4'b1101:show_num = show13;
		4'b1110:show_num = show14;
		4'b1111:show_num = show15;
	endcase
end
endmodule


//used in showing decimals continuously
module show_control_ten_continuously(ans_r,clk,show_num,show_place);
input clk;
wire clk;
input[7:0] ans_r;
output[6:0]show_num;
output[5:0]show_place;
reg[3:0] to_be_shown;
reg[6:0]show_num;
reg[5:0]show_place;
reg[3:0] ten_behind,ten_forward,ten_middle;
reg[1:0]show_state;
always@(*)
begin
ten_forward = ans_r/8'd100;
ten_middle = (ans_r-8'd100*ten_forward)/4'd10;
ten_behind = ans_r%4'd10;
end
reg[6:0] show0 = 7'b0000001;
reg[6:0] show1 = 7'b1001111;
reg[6:0] show2 = 7'b0010010;
reg[6:0] show3 = 7'b0000110;
reg[6:0] show4 = 7'b1001100;
reg[6:0] show5 = 7'b0100100;
reg[6:0] show6 = 7'b0100000;
reg[6:0] show7 = 7'b0001111;
reg[6:0] show8 = 7'b0000000;
reg[6:0] show9 = 7'b0000100;
reg[6:0] show10 = 7'b0001000;
reg[6:0] show11 = 7'b1100000;
reg[6:0] show12 = 7'b0110001;
reg[6:0] show13 = 7'b0100010;
reg[6:0] show14 = 7'b0110000;
reg[6:0] show15 = 7'b0111000;

always@(posedge clk)
begin
	case(show_state)
		2'b00:
		begin
		show_place <= 6'b111111;
		to_be_shown <= 4'd0;
		show_state <=2'b01;
		end
		2'b01:
		begin
		show_place <= 6'b111011;
		to_be_shown <= ten_forward;
		show_state <=2'b10;
		end
		2'b10:
		begin
		show_place <= 6'b111101;
		to_be_shown <= ten_middle;
		show_state <=2'b11;
		end
		2'b11:
		begin
		show_place <= 6'b111110;
		to_be_shown <= ten_behind;
		show_state <=2'b01;
		end
	endcase
end
always@(*)
begin
	case(to_be_shown)
		4'b0000:show_num <= show0;
		4'b0001:show_num <= show1;
		4'b0010:show_num <= show2;
		4'b0011:show_num <= show3;
		4'b0100:show_num <= show4;
		4'b0101:show_num <= show5;
		4'b0110:show_num <= show6;
		4'b0111:show_num <= show7;
		4'b1000:show_num <= show8;
		4'b1001:show_num <= show9;
		4'b1010:show_num <= show10;
		4'b1011:show_num <= show11;
		4'b1100:show_num <= show12;
		4'b1101:show_num <= show13;
		4'b1110:show_num <= show14;
		4'b1111:show_num <= show15;
	endcase
end
endmodule


module counter(clk_original,clk);
input[0:0] clk_original;
output[0:0] clk;
wire clk_original;
reg clk;
reg[16:0] count;
always@(posedge clk_original)
begin
if(count == 16'd4000) 
begin
	count <= 16'd0;
	clk <= ~clk;
end
else count <= count + 1;
end
endmodule

