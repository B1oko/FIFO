`timescale 1ns/1ps

module FIFO_Testbench ();
	
	localparam T = 20;

	parameter tam = 32;
	parameter size = 8;

	integer i;

	logic [size-1:0] data_random;
	logic var_a = $random;

	logic READ, WRITE, CLEAR_N, RESET_N, CLOCK;
	logic [size-1:0] DATA_IN;

	logic F_FULL_N, F_EMPTY_N;
	logic [$clog2(tam-1)-1:0] USE_DW;
	logic [size-1:0] DATA_OUT;

	FIFO32x8 #(.tam(tam), .size(size)) FIFO (.READ(READ), .WRITE(WRITE), .CLEAR_N(CLEAR_N), .RESET_N(RESET_N), .CLOCK(CLOCK), .DATA_IN(DATA_IN), .F_FULL_N(F_FULL_N), .F_EMPTY_N(F_EMPTY_N), .USE_DW(USE_DW), .DATA_OUT(DATA_OUT));
	

	initial 
		begin
         CLOCK = 1'b0;
			#2
			$display("Inicio del caso de test 1");
			reset();
			#2
			escribe(8);
			lee();
			#2
			//assert(q==8) else $error("Error en FIFO");
			reset();
		end

	task reset;
		begin
			RESET_N = 1'b0;
			#2
			RESET_N = 1'b1;
		end
	endtask
	
	task escribe(reps);
		begin
			WRITE = 1'b1;
			int random = $random();
			for(i=0;i<reps;i=i+1)
				begin
					DATA_IN = random;
				end
		end
	endtask

	always
		begin
			#(T/2) CLOCK <= ~CLOCK;
		end
endmodule 