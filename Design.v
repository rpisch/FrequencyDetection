`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module FreqCounter(
	 //Clock input pin B8
	 input mclk,
	 //signal input pin B2
	 input signalleftred,
	 input signalleftblue,
	 input signalrightred,
	 input signalrightblue,	 
	 //binary frequency module output	 
	 output red,
	 output blue,
	 
	 output a, b, c, d, e, f, g, //the individual LED output for the seven segment
     output an
    );
parameter countTo = 55000000; //50,000,000 is about 1 sec

//Set up registers
// These registers are used to count, avg, and tie the frequency to the output
reg [15:0] freq_count;
reg [15:0] freq_out;
reg [15:0] freqHold0;
reg [15:0] freqHold1;
reg [15:0] freqHold2;
reg [15:0] freqHold3;
reg [15:0] freqHold4;
reg [15:0] freqHold5;
reg [15:0] freqHold6;
reg [15:0] freqHold7;
reg [15:0] freqHold8;
reg [15:0] freqHold9;
reg [15:0] freqHold10;
reg [15:0] freqHold11;
reg [15:0] freqHold12;
reg [15:0] freqHold13;
reg [15:0] freqHold14;
reg [15:0] freqHold15;
reg temp_red = 0;
reg temp_blue = 0;


// This register is used to create a count timing to compare the signal to
reg [25:0] count;

//This register is used for comparison of the signal from cycle to cycle
reg old_sig;

//this register used to debounce the incoming signal
reg [4:0] debounce_sig;

//this register is used to keep track of different readings over time
reg [2:0] avClk;

reg [18:0] freqTemp;

// 7 segment display temp values
reg temp_an;
reg temp_sseg;

//Initializing regs to 0 to prevent float error
initial begin
	count = 26'b0;
	old_sig = 1'b0;
	freq_out = 16'b0;
	freq_count = 16'b0;
	avClk = 3'b0;
	freqTemp = 19'b0;
	freqHold0 = 16'b0;
	freqHold1 = 16'b0;
	freqHold2 = 16'b0;
	freqHold3 = 16'b0;
	freqHold4 = 16'b0;
	freqHold5 = 16'b0;
	freqHold6 = 16'b0;
	freqHold7 = 16'b0;
	freqHold8 = 16'b0;
	freqHold9 = 16'b0;
	freqHold10 = 16'b0;
	freqHold11 = 16'b0;
	freqHold12 = 16'b0;
	freqHold13 = 16'b0;
	freqHold14 = 16'b0;
	freqHold15 = 16'b0;
	temp_an = 0;
	temp_sseg = 0;

end



always @(posedge mclk) begin
	//Increment count once per up clock edge
	count = count + 1;
	
	//shift the signal into debounce_sig up to 8 bits
	debounce_sig[0] = signalleftred;
	debounce_sig[0] = signalleftblue;
	debounce_sig[0] = signalrightred;
	debounce_sig[0] = signalrightblue;
	debounce_sig = debounce_sig << 1;
	
	//If debounce_sig is filled with ones or zeros
	if ((&debounce_sig) | (~&debounce_sig))begin
		if ((signalleftred != old_sig) || (signalleftblue != old_sig) || (signalrightred != old_sig) || (signalrightblue != old_sig)) begin
			freq_count = freq_count +1;
		end
	end
	
	//When the count is at approximately 1 sec (as close as the clock will get)
	// output the shifted count and reset values counts to 0
	if (count >= (countTo >> 4)) begin
		freq_out = freq_count << 3;// >> 1;
		count = 0;
		freq_count = 0;
		avClk = avClk + 1;
	end

	case (avClk)
		0 : freqHold0 = freq_out;
		1 : freqHold1 = freq_out;
		2 : freqHold2 = freq_out;
		3 : freqHold3 = freq_out;
		4 : freqHold4 = freq_out;
		5 : freqHold5 = freq_out;
		6 : freqHold6 = freq_out;
		7 : begin
				freqHold7 = freq_out;
				//Adding all frequency readings
				freqTemp = freqHold0 + freqHold1 + freqHold2 + freqHold3 +freqHold4 + freqHold5 + freqHold6 + freqHold7+freqHold8 + freqHold9 + freqHold10 + freqHold11 +freqHold12 + freqHold13 + freqHold14 + freqHold15;
			 end

		default :;
	endcase
	
	//Setting up old signal for next clock pulse comparison
	old_sig = signalleftred;
	old_sig = signalleftblue;
	old_sig = signalrightred;
	old_sig = signalrightblue;
	
	

	//Holding old readings to mix with new
	freqHold8 = freqHold0;
	freqHold9 = freqHold1;
	freqHold10 = freqHold2;
	freqHold11 = freqHold3;
	freqHold12 = freqHold4;
	freqHold13 = freqHold5;
	freqHold14 = freqHold6;
	freqHold15 = freqHold7;


    if ((freqTemp >> 4) >= 350) begin
        temp_red = 1;
        temp_an = 4'b1110;
        temp_sseg = 7'b1000110;   // Displays a 'C' for criminal    
    end
    else begin
        temp_red = 0;
        temp_an = 4'b1110;
        temp_sseg = 7'b0111111;  // Displays a '-' when nothing is detected
    end
    
    
    if (((freqTemp >> 4) < 350) && ((freqTemp >> 4) > 100)) begin
        temp_blue = 1;
        temp_an = 4'b1110;
        temp_sseg = 7'b0001110;  // Displays an 'F' for friendly
    end
    else begin
        temp_blue = 0;
        temp_an = 4'b1110;
        temp_sseg = 7'b0111111; // Displays a '-' when nothing is detected
    end

end
    
	
	assign red = temp_red;
	assign blue = temp_blue;
	assign an = temp_an;
	assign {g, f, e, d, c, b, a} = temp_sseg;

			
endmodule
