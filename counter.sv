module counter (iCLK, iRST_n, iENABLE, iUP_DOWN, oCOUNT, oTC);

    // 1 -> arriba
    // 0 -> abajo
    
	parameter fin_cuenta = 20;
	parameter n = $clog2(fin_cuenta-1);
	
	input iCLK, iRST_n, iENABLE, iUP_DOWN;
	output reg [n-1:0] oCOUNT;
	output reg oTC;

	always @(posedge iCLK)
		begin
			if (!iRST_n)
				begin
					oCOUNT <= 0;
					oTC <= 0;
				end
			else if (iENABLE)
				begin
					if (iUP_DOWN)
						begin
							if (oCOUNT == fin_cuenta-1)
								begin
									oCOUNT <= 0;
									oTC <= 1;
								end
							else
								begin
									oCOUNT <= oCOUNT+1;
									oTC <= 0;
								end
						end
					else
						begin
							if (oCOUNT == 0)
								begin
									oCOUNT <= fin_cuenta-1;
									oTC <= 1;
								end
							else
								begin
									oCOUNT <= oCOUNT-1;
									oTC <= 0;
								end
						end
				end
		end
	
endmodule