// Comentarios
module FIFO #(parameter tam=32, parameter size=8)(
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

  wire countR_e, countR_reset, countR_ud;  //en R y W UpDown siempre va a valer 1 porque siempre aumentamos la cuenta
  wire [$clog2(tam-1)-1:0] countR;

  wire countW_e, countW_reset, countW_ud;
  wire [$clog2(tam-1)-1:0] countW;

  //Señales auxiliares RAM
  wire ramW_e;
  wire ramR_e;

  
  // CONTROL PATH
    //FSM
      //LOGICA DE ESTADOS - Secuencial
      always_ff (@posedge CLOCK or negedge RESET_N)
        begin
        if (!RESET_N)
          estado <= vacio;
        else
          if(!CLEAR_N)
            estado <= vacio;
          else
            case (estado)
              vacio:
              begin
                if(WRITE and !READ)
                  estados <= otros;
                else
                  estado <= vacio;
              end

              otros:
              begin
                if(WRITE and !READ and USE_DW == 31)
                  estados <= lleno;
                else if (!WRITE and READ and USE_DW == 1)
                  estados <= vacio;
                else
                  estados <= otros;
              end

              lleno:
              begin
                if(!WRITE and READ)
                  estados <= otros;
                else
                  estados <= lleno;
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

            // Resetear tdo

            if (WRITE and READ)
              DATA_OUT <= DATA_IN;
            else if (WRITE and !READ)
            begin
              countW_e = 1'b1;
              countW_ud = 1'b1;
              countUSE_e = 1'b1;
              countUSE_ud = 1'b1;
              ramW_e = 1'b1;
            end
            
          end

          otros:
          begin
            F_EMPTY_N <= 1'b1;
            F_FULL_N <= 1'b1;

            if (WRITE and READ)
            begin
              countR_e = 1'b1;
              countR_ud = 1'b1;
              ramR_e = 1'b1;
              
              countW_e = 1'b1;
              countW_ud = 1'b1;
              ramW_e = 1'b1;
            end
            else if (WRITE and !READ)
            begin
              countW_e = 1'b1;
              countW_ud = 1'b1;
              countUSE_e = 1'b1;
              countUSE_ud = 1'b1;
              ramR_e = 1'b0;
              ramW_e = 1'b1;
            end
            else if (!WRITE and READ)
            begin
              countR_e = 1'b1;
              countR_ud = 1'b1;
              countUSE_e = 1'b1;
              countUSE_ud = 1'b0;
              ramR_e = 1'b1;
              ramW_e = 1'b0;
            end
            
          end

          lleno:
          begin
            F_EMPTY_N <= 1'b1;
            F_FULL_N <= 1'b0;

            if (WRITE and READ)
            begin
              countR_e = 1'b1;
              countR_ud = 1'b1;
              ramR_e = 1'b1;
              
              countW_e = 1'b1;
              countW_ud = 1'b1;
              ramW_e = 1'b1;
            end
            else if (!WRITE and READ)
            begin
              countR_e = 1'b1;
              countR_ud = 1'b1;
              countUSE_e = 1'b1;
              countUSE_ud = 1'b0;
              ramR_e = 1'b1;
              ramW_e = 1'b0;
            end
            
          end
        
        endcase
            
      end
  
  // CONTADOR
    counter contadorUSE #(.fin_cuenta(.........)) (
      .iCLK(CLOCK),
      .iRST_n(RESET_N),
      .iENABLE(countUSE_e),
      .iUP_DOWN(countUSE_ud),
      .oCOUNT(USE_DW),
      .oTC(countUSE_tc));

    counter contadorR #(.fin_cuenta(.........)) (
      .iCLK(CLOCK),
      .iRST_n(RESET_N),
      .iENABLE(countR_e),
      .iUP_DOWN(countR_ud),
      .oCOUNT(countR),
      .oTC());

    counter contadorW #(.fin_cuenta(.........)) (
      .iCLK(CLOCK),
      .iRST_n(RESET_N),
      .iENABLE(countW_e),
      .iUP_DOWN(countW_ud),
      .oCOUNT(countW),
      .oTC());

  // DATA PATH
    ram_dp ram #(.mem_depth(tam), .size(size)) (
      .data_in(DATA_IN),
      .wren(ramW_e),
      .clock(CLOCK),
      .rden(ramR_e),
      .wraddress(countW),
      .rdaddress(countR),
      .data_out(DATA_OUT));

endmodule