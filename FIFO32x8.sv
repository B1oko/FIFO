// Comentarios
module FIFO32x8 #(parameter tam=32, parameter size=8)(
	input READ, WRITE, CLEAR_N, RESET_N, CLOCK,
	input [size-1:0] DATA_IN,

	output logic F_FULL_N, F_EMPTY_N,
	output logic [$clog2(tam-1)-1:0] USE_DW, // log2(tam)-1 cambiar
	output logic [size-1:0] DATA_OUT
);

	// Estados
	enum logic [1:0] {vacio, otros, lleno} estado;

	// Señales auxiliares contadores
	wire countUSE_e, countUSE_ud, countUSE_tc;

	wire countR_e, countR_reset;  //en R y W UpDown siempre va a valer 1 porque siempre aumentamos la cuenta
	wire [$clog2(tam-1)-1:0] countR;

	wire countW_e, countW_reset;
	wire [$clog2(tam-1)-1:0] countW;

	//Señales auxiliares RAM
	wire ramW_e;
	wire ramR_e;

	wire select;

	wire [size-1:0] data_out;


	// CONTROL PATH
	//FSM
		//LOGICA DE ESTADOS - Secuencial
		always_ff @ (posedge CLOCK or negedge RESET_N)
		begin
		if (!RESET_N)
			estado <= vacio;
		else if(!CLEAR_N)
				estado <= vacio;
			else
				case (estado)
				vacio:
					begin
						if(WRITE && !READ)
							estado <= otros;
						else
							estado <= vacio;
					end

				otros:
					begin
						if(WRITE && !READ && USE_DW == 31)
							estado <= lleno;
						else if (!WRITE && READ && USE_DW == 1)
							estado <= vacio;
						else
							estado <= otros;
					end

				lleno:
					begin
						if(!WRITE && READ)
							estado <= otros;
						else
							estado <= lleno;
					end
				endcase
		end

		//SEÑALES DE CONTROL - Combinacional
		always_comb
		begin
		case(estado)
			vacio:
			begin
				F_EMPTY_N <= 1'b0;
				F_FULL_N <= 1'b1;
				
				countR_e = 1'b0;
				countW_e = 1'b0;
				countUSE_e = 1'b0;
				countUSE_ud = 1'b0;
				ramR_e = 1'b0;
				ramW_e = 1'b0;
				select = 1'b0;

				// Resetear tdo

				if (WRITE && READ)
				begin
					select = 1'b1;
					end
					
				else if (WRITE && !READ)
				begin
					countW_e = 1'b1;

					countR_e = 1'b0;
					ramR_e = 1'b0;
					
					countUSE_e = 1'b1;
					countUSE_ud = 1'b1;

					ramW_e = 1'b1;
					ramR_e = 1'b0;
				end   
				else
				begin
					countR_e = 1'b0;
					countW_e = 1'b0;
					countUSE_e = 1'b0;
					ramR_e = 1'b0;
					ramW_e = 1'b0;
				end
			end

			otros:
			begin 
			countR_e = 1'b0;
				countW_e = 1'b0;
				countUSE_e = 1'b0;
				countUSE_ud = 1'b0;
				ramR_e = 1'b0;
				ramW_e = 1'b0;
				select = 1'b0;
				
			
				F_EMPTY_N <= 1'b1;
				F_FULL_N <= 1'b1;

				if (WRITE && READ)
				begin
				countR_e = 1'b1;
				ramR_e = 1'b1;
				
				countW_e = 1'b1;
				ramW_e = 1'b1;

				countUSE_e = 1'b0;
				end
				else if (WRITE && !READ)
				begin
				countW_e = 1'b1;
				
				countR_e = 1'b0;
				
				countUSE_e = 1'b1;
				countUSE_ud = 1'b1;
				
				ramR_e = 1'b0;
				ramW_e = 1'b1;
				end
				else if (!WRITE && READ)
				begin
				countR_e = 1'b1;

				countW_e = 1'b0;
				
				countUSE_e = 1'b1;
				countUSE_ud = 1'b0;
				
				ramR_e = 1'b1;
				ramW_e = 1'b0;
				end
				else
				begin
					countR_e = 1'b0;
					countW_e = 1'b0;
					countUSE_e = 1'b0;
					ramR_e = 1'b0;
					ramW_e = 1'b0;
				end
			end
			
			lleno:
			begin
			countR_e = 1'b0;
				countW_e = 1'b0;
				countUSE_e = 1'b0;
				countUSE_ud = 1'b0;
				ramR_e = 1'b0;
				ramW_e = 1'b0;
				select = 1'b0;
				
			
				F_EMPTY_N <= 1'b1;
				F_FULL_N <= 1'b0;

				if (WRITE && READ)
				begin
				countR_e = 1'b1;
				ramR_e = 1'b1;
				
				countW_e = 1'b1;
				ramW_e = 1'b1;

				countUSE_e = 1'b0;

				end
				else if (!WRITE && READ)
				begin
				countR_e = 1'b1;

				countW_e = 1'b0;

				countUSE_e = 1'b1;
				countUSE_ud = 1'b0;
				
				ramR_e = 1'b1;
				ramW_e = 1'b0;
				end
				else 
				begin
					countR_e = 1'b0;
					countW_e = 1'b0;
					countUSE_e = 1'b0;
					ramR_e = 1'b0;
					ramW_e = 1'b0;
				end
				
			end
		
		endcase
		end
		assign DATA_OUT = (select)? DATA_IN:data_out;
  
  // CONTADORES
    counterFIFO #(.fin_cuenta(tam)) contadorUSE (
      .iCLK(CLOCK),
      .iRST_n(RESET_N),
      .iENABLE(countUSE_e),
      .iUP_DOWN(countUSE_ud),
      .oCOUNT(USE_DW),
      .oTC(countUSE_tc));

    counterFIFO #(.fin_cuenta(tam)) contadorR (
      .iCLK(CLOCK),
      .iRST_n(RESET_N),
      .iENABLE(countR_e),
      .iUP_DOWN(1'b1),
      .oCOUNT(countR),
      .oTC());

    counterFIFO #(.fin_cuenta(tam)) contadorW (
      .iCLK(CLOCK),
      .iRST_n(RESET_N),
      .iENABLE(countW_e),
      .iUP_DOWN(1'b1),
      .oCOUNT(countW),
      .oTC());

  // DATA PATH
    ram_dp_FIFO #(.mem_depth(tam), .size(size)) ram (
      .data_in(DATA_IN),
      .wren(ramW_e),
      .clock(CLOCK),
      .rden(ramR_e),
      .wraddress(countW),
      .rdaddress(countR),
      .data_out(data_out));

endmodule 