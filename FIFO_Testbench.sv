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
	logic [$clog2(tam-1):0] USE_DW;
	logic [size-1:0] DATA_OUT;

	FIFO32x8 #(.tam(tam), .size(size)) FIFO (.READ(READ), .WRITE(WRITE), .CLEAR_N(CLEAR_N), .RESET_N(RESET_N), .CLOCK(CLOCK), .DATA_IN(DATA_IN), .F_FULL_N(F_FULL_N), .F_EMPTY_N(F_EMPTY_N), .USE_DW(USE_DW), .DATA_OUT(DATA_OUT));
	

	initial
		begin
			CLOCK = 1'b0;
			READ = 1'b0;
			WRITE = 1'b0;
			CLEAR_N = 1'b1;
			
			
			#(T)
			$display("Inicio del caso de test 1");
			reset();
			#(T)
			escribir(8'b00000000,33);
			#(T/2)
			leer(35);
			#(T)
			//assert(q==8) else $error("Error en FIFO");
			reset();
			$stop;
		end

	task reset;
		begin
			@(posedge CLOCK);
			RESET_N = 1'b0;
			#(T)
			@(posedge CLOCK);
			RESET_N = 1'b1;
			@(posedge CLOCK);
		end
	endtask
	
	task escribir(reg [7:0] valor, int reps);
		WRITE = 1'b1;
		i = -1;
		repeat (reps)
			begin
				i = i+1;
				@(negedge CLOCK);
				DATA_IN = valor+i;
			end
		#(T)
		WRITE = 1'b0;
	endtask
	
	task leer(int reps);
		READ = 1'b1;
		#(T*(reps))
		/*repeat (reps)
			begin
				@(posedge CLOCK);
			end*/
		READ = 1'b0;
	endtask

	task leer_escribir(reps);

	endtask


	always
		begin
			#(T/2) CLOCK <= ~CLOCK;
		end
endmodule 