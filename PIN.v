`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:08:38 03/17/2022 
// Design Name: 
// Module Name:    PIN 
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
module PIN(
		  input  wire  CLK,
        input  wire  RX_usb,
		  input  wire  RX_0,
		  
		  output wire  TX_usb,
		  output wire  TX_0,
		  output reg RESET,
		  output reg LED1=0
    );

reg rst=0;
reg en0;
reg en_usb;
reg [7:0]buf_0;
reg [7:0]buf_usb;
reg buf_val_0;
reg buf_val_usb;
wire[7:0]data_out_rx_0;
wire[7:0]data_out_usb;
wire valid_rx_0;
wire valid_usb;
reg [1:0]state=2'b00; //receving the string from the device and forwarding the response to python 
reg [7:0]buf_response;
reg [31:0]response_cc=32'b00000000000000000000000000000000; //handle it on python
reg [4:0]count;
reg [2:0]byte_cnt=2'b000;


//Add receiver_usb
uart_rx rx(
    .clk(CLK),
    .rst(rst),
    .data_out(data_out_usb),
    .valid(valid_usb),
    .din(RX_usb)
    );
	 

//Add transmitter_usb
uart_tx tx(
    .clk(CLK),
    .rst(rst),
    .en(en_usb),
    .data_in(buf_usb),
    .rdy(rdy_usb),
    .dout(TX_usb)
    );
	 
//Add transmitter_0 //To dev 0 
uart_tx tx_0(
    .clk(CLK),
    .rst(rst),
    .en(en0),
    .data_in(buf_0),
    .rdy(rdy0),
    .dout(TX_0)
    );

//Add receiver_0 //From dev 0
uart_rx rx_0(
    .clk(CLK),
    .rst(rst),
    .data_out(data_out_rx_0),
    .valid(valid_rx_0),
    .din(RX_0)
    );

always@(posedge CLK)begin
		en0<=0;
		en_usb<=0;
	
	//receives from python
	if(valid_usb==1)begin
		buf_val_usb<=1;
		buf_0<=data_out_usb;
		if(data_out_usb==8'h9)begin
			state<=2'b11;	
		end
		else if(state<=2'b00) begin
			state<=2'b10;
		end
	end
	//sends to the device
	if(buf_val_usb==1 && rdy0==1)begin
			en0<=1;
			buf_val_usb<=0;
	end
	

	case(state)
	2'b00: begin//normal
		//receive from device
		RESET<=1;
		count<=0;
		if(valid_rx_0==1)begin 	//we've recived smth
			buf_val_0<=1;
			buf_usb<=data_out_rx_0;	
		end
		//sends to python
		//we want to send the string as response
		if(buf_val_0==1 && rdy_usb==1)begin
			en_usb<=1;
			buf_val_0<=0;
		end
	end

	2'b01: begin //count response time in cycles after sending 16bytes
		RESET<=1;
		if(valid_rx_0==1)begin 	//we've recived smth
			buf_val_0<=1;
			case (byte_cnt)
			3'b000:begin 
				buf_usb<=response_cc[7:0];
				byte_cnt<=byte_cnt+1;
				end
			3'b001:begin 
				buf_usb<=response_cc[15:8];
				byte_cnt<=byte_cnt+1;
				end
			3'b010:begin
				buf_usb<=response_cc[23:16];
				byte_cnt<=byte_cnt+1;
				end
			3'b011:begin
				buf_usb<=response_cc[31:24];
				byte_cnt<=byte_cnt+1;
//				state<=2'b11;
				end
			endcase
			
			end
		else begin
			response_cc<=response_cc+1;
		end
//		if (response_cc>1300000000) begin
//			LED1<=1;
//		end
		//sends to python
		//we want to send the time in cc it took for response
		if(buf_val_0==1 && rdy_usb==1)begin
			en_usb<=1;
			buf_val_0<=0;
			if(byte_cnt==3'b100)begin
				state<=2'b11;
			end
		end
	end
		
	2'b10: begin //send the bytes via python
		if(count<16)begin
			if(valid_usb==1)begin
				count<=count+1;
				end
		else begin
			count<=0;
			state<=2'b01; 
			end
		end
		if(buf_val_usb==1 & rdy0==1)begin
			en0<=1;
			buf_val_usb<=0;
			end
		end
		
	2'b11: begin //reset
		RESET<=0;
		buf_val_0<=0;
		response_cc<=0;
		byte_cnt<=2'b00;
		state<=2'b00;
		end
	endcase

end

endmodule
