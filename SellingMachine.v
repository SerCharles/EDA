
//main module, used for the main control
module SellingMachine(clk_original,add_money0,add_money1,add_money5,
buy_thing1,buy_thing2,refund,remind_1,remind_2,remind_refund, remind_restore_1, remind_restore_2,
show_num,show_place);
input clk_original;
input add_money0,add_money1,add_money5;	//control adding money 0.5,1,5
input buy_thing1,buy_thing2;				//control buying 1.5 and 2.5
input refund;		//control refund
//control reminding of no money, refund, restore things
output remind_1,remind_2,remind_refund, remind_restore_1, remind_restore_2;
output[6:0]show_num;		//the number that will be shown
output[5:0]show_place;	//the place that will show
wire[9:0] current_money;				//currentMoney
wire[5:0] change_state;
wire clk_original;
wire clk;
wire clk_great;
//generate new clock, used in showing
counter count_mux(clk_original,clk);	
//generate new_clock, used in changing
counter_great count_mux_great(clk_original,clk_great);
//judge how to change
judge_change judge_mux(clk_great,add_money0,add_money1,add_money5,
buy_thing1,buy_thing2,refund,change_state);
//change
change_state change_mux(clk_great,change_state,current_money,remind_1,
remind_2,remind_refund, remind_restore_1, remind_restore_2);
//manage showing money
show_control_ten_continuously show_mux(current_money,clk,show_num,show_place);
endmodule


//judge how to change
module judge_change(clk,add_money0,add_money1,add_money5,
buy_thing1,buy_thing2,refund,change_state);
input clk;
input add_money0,add_money1,add_money5;	//control adding money 0.5,1,5
input buy_thing1,buy_thing2;				//control buying 1.5 and 2.5
input refund;		//control refund
reg[5:0]previous_state;
output reg[5:0]change_state;
always@(posedge clk)
begin
begin
if(add_money0 == 0 && previous_state[0] == 1) change_state <= 6'b000001;
else if(add_money1 == 0 && previous_state[1] == 1) change_state <= 6'b000010;

else if(add_money5 == 0 && previous_state[2] == 1) change_state <= 6'b000100;

else if(buy_thing1 != previous_state[3]) change_state <= 6'b001000;
else if(buy_thing2 != previous_state[4]) change_state <= 6'b010000;
else if(refund != previous_state[5]) change_state <= 6'b100000;
else change_state <= 6'b000000;
end
previous_state[5] <= refund;
previous_state[4] <= buy_thing2;
previous_state[3] <= buy_thing1;
previous_state[2] <= add_money5;
previous_state[1] <= add_money1;
previous_state[0] <= add_money0;
end
endmodule

//change
module change_state(clk,change_state,money,remind_1,
remind_2,remind_refund, remind_restore_1, remind_restore_2);
input clk;
input[5:0]change_state;
output reg[9:0]money;
output reg remind_1,remind_2,remind_refund, remind_restore_1, remind_restore_2;
always@(posedge clk)
begin
case(change_state)
	6'b000001:
		begin
			begin
			if(remind_1 == 1 && money > 10'd9) 
			begin remind_1 <= 0; end
			if(remind_2 == 1 && money > 10'd19)
			begin remind_2 <= 0; end
			end
			money<=money + 10'd5;
			remind_refund <= 0;
			remind_restore_1 <= 0;
			remind_restore_2 <= 0;
			begin
			if(money > 10'd999) money<= 10'd999;
			end
		end
	6'b000010:
		begin
			begin
			if(remind_1 == 1 && money > 10'd4) 
			begin remind_1 <= 0; end
			if(remind_2 == 1 && money > 10'd14) 
			begin remind_2 <= 0; end
			end
			money<=money + 10'd10;
			remind_refund <= 0;
			remind_restore_1 <= 0;
			begin
			if(money > 10'd999) money<= 10'd999;
			end
		end
	6'b000100:
		begin
			money<=money + 10'd50;
			remind_refund <= 0;
			remind_restore_1 <= 0;
			remind_restore_2 <= 0;
			remind_1 <= 0;
			remind_2 <= 0;
			begin
			if(money > 10'd999) money<= 10'd999;
			end
		end
	6'b001000:
		begin
			if(money < 10'd15) 			remind_1 <= 1;
			else
			begin
			money <= money - 10'd15;
			remind_restore_1 <= 1;
			remind_1 <= 0;
			end	
		end
	6'b010000:
		begin
			if(money < 10'd25) 			remind_2 <= 1;
			else
			begin
			money <= money - 10'd25;
			remind_restore_2 <= 1;
			remind_2 <= 0;
			end	
		end
	6'b100000:
		begin
			money <= 10'd0;
			remind_refund <= 1;
		end
	endcase

end
endmodule

//used in showing decimals continuously
module show_control_ten_continuously(ans_r,clk,show_num,show_place);
input clk;
wire clk;
input[9:0] ans_r;
output[6:0]show_num;
output[5:0]show_place;
reg[3:0] to_be_shown;
reg[6:0]show_num;
reg[5:0]show_place;
reg[3:0]ten_behind;
reg[3:0]ten_forward;
reg[3:0]ten_middle;
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

module counter_great(clk_original,clk);
input[0:0] clk_original;
output[0:0] clk;
wire clk_original;
reg clk;
reg[32:0] count;
always@(posedge clk_original)
begin
if(count == 32'd400000) 
begin
	count <= 32'd0;
	clk <= ~clk;
end
else count <= count + 1;
end
endmodule
