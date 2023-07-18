

              /////////////7Segment/////////////////        
module led
(
input wire [2:0] inp,
output reg [6:0] seg

);
always @ (inp)
case (inp)
3'b000 : seg= 7'b1111110; 
3'b001 : seg= 7'b0110000;
3'b010 : seg= 7'b1101101;
3'b011 : seg= 7'b1111001;
default: seg= 7'b1001111;
endcase
endmodule

          //////////////16bit_Adder///////////////////////

module adder
(
input wire [15:0] dataa,
input wire [15:0] datab,
output wire [15:0] sum

);
wire [16:0] sum1;
assign sum1={ 1'b0 , dataa} + { 1'b0 , datab};
assign sum= sum1[15:0] ;
endmodule 

            ///////////2Bit_Asynchronous_Counter///////////////

module counterr (
input clk,aclr_n ,
output reg [1:0] count_out );

always@(posedge clk ,negedge aclr_n)
    begin 
        if(!aclr_n)
            count_out <= 0 ;
        else 
             count_out <=count_out+1  ;
    end 

endmodule

           //////////////////////FSM////////////////////

module mult_control (
    input clk, reset_a,
    input start, input [1:0] count,
	 output reg [1:0] input_sel,
	 output reg [1:0] shift_sel,
         output [2:0] state_out,
	 output reg done, clk_ena, sclr_n
    
);

    // states encoding
    localparam [2:0] IDLE = 3'b000,
                     LSB  = 3'b001,
                     MID  = 3'b010,
		     MSB  = 3'b011,
		     Done = 3'b100,
		     ERR  = 3'b101;
							
	// next and current state signals declaration
	reg [2:0] state, next_state;
	
	// state register
   always @(posedge clk, negedge reset_a)
		begin
		if (!reset_a)
		state <= IDLE;
                else
                state <= next_state;
		end

    // next state and output logic
    always @(*)
        begin
            // default output to avoid latches
            next_state = IDLE;
            input_sel = 2'bxx;
            shift_sel = 2'bxx;
            done = 0;
            clk_ena = 0;
            sclr_n = 0;
            case (state)
                IDLE:
                    begin
                        if (start)
			begin
                            next_state = LSB;
			    done = 0;
			    clk_ena = 1;
			    sclr_n = 0;
                            input_sel = 2'bxx;
                            shift_sel = 2'bxx; 
			end
                        else
			begin
                            next_state = IDLE;
                            done = 0;
			    clk_ena = 0;
			    sclr_n = 1;
			end 
                     end
                LSB:
                    begin
                        if (!start && count==2'b00)
			begin
                            next_state = MID;
			    input_sel = 2'b00;
		            shift_sel = 2'b00;
			    done = 0;
			    clk_ena = 1;
			    sclr_n = 1;
		        end 
                        else
			begin
                            next_state = ERR;
			    done = 0;
			    clk_ena = 0;
			    sclr_n = 1;
                            input_sel=2'bxx;
                            shift_sel=2'bxx;
			end 
                    end
                MID:
                    begin
                        if (!start && count==2'b01)
			begin
                            next_state = MID;
			    input_sel = 2'b01;
			    shift_sel = 2'b01;
			    done = 0;
			    clk_ena = 1;
			    sclr_n = 1;
			end
                        else if (!start && count==2'b10)
			     begin
                            next_state = MSB;
			    input_sel = 2'b10;
	                    shift_sel = 2'b01;
			    done = 0;
			    clk_ena = 1;
			    sclr_n = 1;	
			     end
			else
			begin
		        next_state = ERR;
			done = 0;
			clk_ena = 0;
			sclr_n = 1;
                        input_sel=2'bxx;
                        shift_sel=2'bxx;
			end
                    end
                MSB:
                    begin
                        if (!start && count==2'b11)
		    begin
                            next_state = Done;
			    input_sel = 2'b11;
			    shift_sel = 2'b10;
			    done = 0;
			    clk_ena = 1;
			    sclr_n = 1;
		     end 
                        else
		     begin
                            next_state = ERR;
			    done = 0;
			   clk_ena = 0;
			   sclr_n = 1;
                           input_sel=2'bxx;
                           shift_sel=2'bxx;
		     end 
                    end
                Done:
                    begin
                        if (!start)
			begin
                            next_state = IDLE;
			    done = 1;
			    clk_ena = 0;
			    sclr_n = 1;
                            input_sel = 2'bxx;
                            shift_sel = 2'bxx;
			end
                        else
		        begin
                            next_state = ERR;
			    done = 0;
			    clk_ena = 0;
			    sclr_n = 1;
                            input_sel=2'bxx;
                            shift_sel=2'bxx;
			end 
                    end
                ERR:
                    begin
                        if (!start)
		        begin
                            next_state = ERR;
			    done = 0;
			    clk_ena = 0;
			    sclr_n = 1;
                            input_sel = 2'bxx;
                            shift_sel = 2'bxx;
			end
                        else
		        begin
                            next_state = LSB;
			    done = 0;
			    clk_ena = 1;
			    sclr_n = 0;
                            input_sel = 2'bxx;
                            shift_sel = 2'bxx;
			end 
                    end
                default:
                    next_state = IDLE;
            endcase
        end 

assign state_out = next_state;
endmodule
               
              ///////////////Multiplier_4x4/////////////////////

module mul4bit(
input  [3:0] dataa,datab,
output  [7:0] product);

wire [3:0] x1;
wire [4:0] x2;
wire [5:0] x3;
wire [6:0] x4;
wire [7:0] s1,s2 ,s3;

assign x1={4{dataa[0]}} & datab[3:0] ;
assign x2={4{dataa[1]}} & datab[3:0] ;
assign x3={4{dataa[2]}} & datab[3:0] ;
assign x4={4{dataa[3]}} & datab[3:0] ;

assign s1= x1+(x2<<1);
assign s2= s1+(x3<<2);
assign s3= s2+(x4<<3);
assign product = s3 ;

endmodule 

               //////////////Multiplexer///////////////////

module mux
(
input wire [3:0] a,
input wire [3:0] b,
input wire sel,
output reg [3:0] mux_out
);
always @ (a , b , sel)
begin
if ( sel == 1'b0)
mux_out = a;
else 
mux_out= b;
end
endmodule 

             //////////////////16Bit_Register/////////////////////

module reg16(input clk, sclr_n, clk_ena, 
  input [15:0] datain ,   output reg [15:0] reg_out); 
 
always @(posedge clk )
 begin
     if(clk_ena==0)
       begin
       end
     else begin
      if(clk_ena==1 && sclr_n==0)
         reg_out<=16'b0;
      else
         reg_out<=datain;
        end
 end
endmodule 

            /////////////////////////Shifter////////////////////////

module shifter1 (
input [7:0] inp,
input [1:0] shift_cntrl,
output reg [15:0] shift_out);

always @(*)
 begin
  case(shift_cntrl)
     2'b00: shift_out=inp;
     2'b01: shift_out=inp<<4;
     2'b10: shift_out=inp<<8;
     2'b11: shift_out=inp;
     default:shift_out=inp;
  endcase
 end
endmodule

            /////////////Top_Layer/////////////////////////

module mul8x8(
input [7:0] data1,data2,
input start,clk,reset_a,
output  done_flag,
output [15:0] product8x8_out,
output [6:0] seg
);

wire clk_ena,sclr_n;
wire [1:0] sel,shift,count;
wire [2:0] state_out;
wire [3:0] aout,bout;
wire [7:0] product;
wire [15:0] shift_out,sum;

mux x1(.a(data1[3:0]),
    .b(data1[7:4]),
    .sel(sel[1]),
    .mux_out(aout));
mux x2(.a(data2[3:0]),.b(data2[7:4]),.sel(sel[0]),.mux_out(bout));
shifter1 x3(.inp(product),
    .shift_cntrl(shift),
    .shift_out(shift_out));
reg16 x4(.clk(clk),
    .sclr_n(sclr_n),
    .clk_ena(clk_ena),
    .datain(sum),
    .reg_out(product8x8_out));
mul4bit x5(.dataa(aout),
    .datab(bout),
    .product(product));
counterr x6(.clk(clk),
    .aclr_n(!start),
    .count_out(count));
adder x7(.dataa(shift_out),
    .datab(product8x8_out),
    .sum(sum));
led x8(state_out,
    seg);
mult_control x9(.clk(clk),
    .reset_a(reset_a),
    .start(start),
    .count(count),
    .input_sel(sel),
    .shift_sel(shift),
    .state_out(state_out),
    .done(done_flag),
    .clk_ena(clk_ena),
    .sclr_n(sclr_n));
endmodule

