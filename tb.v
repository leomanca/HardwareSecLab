`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:27:15 03/19/2022
// Design Name:   PIN
// Module Name:   /media/sf_vmshare/hwLab_target1/tb.v
// Project Name:  hwLab_target1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: PIN
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb;

	// Inputs
	reg CLK;
	reg RX_usb;
	reg RX_0;

	// Outputs
	wire TX_usb;
	wire TX_0;
	wire RESET;
	wire LED1;

	// Instantiate the Unit Under Test (UUT)
	PIN uut (
		.CLK(CLK), 
		.RX_usb(RX_usb), 
		.RX_0(RX_0), 
		.TX_usb(TX_usb), 
		.TX_0(TX_0), 
		.RESET(RESET), 
		.LED1(LED1)
	);

	initial begin
		// Initialize Inputs
		CLK = 0;
		RX_usb = 0;
		RX_0 = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

