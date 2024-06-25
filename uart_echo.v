`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:03:34 03/15/2022 
// Design Name: 
// Module Name:    uart_echo 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module uart_echo(
        input  wire  CLK,
        input  wire  RX,
		  input  wire  RX_0,
		  input  wire  RX_1,
		  
		  output wire  TX,
		  output wire  TX_0,
		  output wire  TX_1,
		  output reg LED1=0
		  
		  );
        
reg rst=0;
wire [7:0]data_out_usb;
wire [7:0]data_out_0;
wire [7:0]data_out_1;
reg [7:0]buf0=0;
reg [7:0]buf1=0;
reg index0=0;
reg index1=0;
reg buf0_val=0;
reg buf1_val=0;
reg [1:0]state=2'b00; //normal;
reg en1=0;
reg en0=0;

 
wire valid_usb;
wire valid_rx_0;
wire valid_rx_1;



//Add transmitter_usb // to pc
uart_tx tx(
    .clk(CLK),
    .rst(rst),
    .en(valid_usb),
    .data_in(data_out_0),
    .rdy(rdy),
    .dout(TX_usb)
    );
	 
//Add transmitter //To dev
uart_tx tx_0(
    .clk(CLK),
    .rst(rst),
    .en(en0),
    .data_in(buf0),
    .rdy(rdy),
    .dout(TX)
    );

//Add receiver //From dev
uart_rx rx_0(
    .clk(CLK),
    .rst(rst),
    .data_out(data_out_0),
    .valid(valid_rx_0),
    .din(RX_0)
    );

////Add transmitter_1 //To dev 1
//uart_tx tx_1(
//    .clk(CLK),
//    .rst(rst),
//    .en(en1),
//    .data_in(buf0),
//    .rdy(rdy1),
//    .dout(TX_1)
//    );
//
////Add receiver_1 //From dev1
//uart_rx rx_1(
//    .clk(CLK),
//    .rst(rst),
//    .data_out(data_out_1),
//    .valid(valid_rx_1),
//    .din(RX_1)
//    );
//	 
always@(posedge CLK)begin
//Here we want to check
	

	if(valid_usb==1) begin
	if(data_out_usb==8'h47) begin
		state<=2'b10;		//GREEN
		end
		else if(data_out_usb==8'h72) begin
		state<=2'b01; //RED
		end
		else begin
		state<=2'b00; //NORMAL
		if(state==2'b01) begin
		buf0<=8'h47;
		buf0_val<=1;
		end
		end

	end
	
	
	en1<=0;
	if (buf0_val==1 & rdy1==1) begin
	en1<=1;
	buf0_val<=0;
	end
	
	en0<=0;
	if (buf1_val==1 & rdy0==1) begin
	en0<=1;
	buf1_val<=0;
	end
	
	
	
	case(state)
		2'b00: begin//normal
		if (valid_rx_0==1) begin//check for valid_rx_0
			buf0<=data_out_0;
			buf0_val<=1;
			end
		if (valid_rx_1==1) begin//check for valid_rx_1
			buf1<=data_out_1;
			buf1_val<=1;
		end
		end
		2'b01: begin//all red
		end
		2'b10: begin//all green
		LED1<=1;
		buf0<=8'h47;
		buf1<=8'h47;
		buf0_val<=1;
		buf1_val<=1;
		end
		
		endcase
			
		
//	d1=data_out_0[index];
//	index<=index+1;

//		
//	
	end
//	

endmodule
