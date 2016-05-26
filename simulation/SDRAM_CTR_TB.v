module tb;
	parameter tCYC_SDRAM=7.5;
	parameter tCYC_TOP=20;
	parameter tPD=(tCYC_TOP/10);

	reg p_reset;
	reg m_clock;
	reg sdrclk;

	SDRAM_SIM SDRAM_SIM_instance(
		.p_reset(p_reset),
		.m_clock(m_clock),
		.sdrclk(sdrclk)
	);

	initial forever #(tCYC_TOP/2) m_clock = ~m_clock;
	initial forever #(tCYC_SDRAM/2) sdrclk = ~sdrclk;

	initial begin
		$dumpfile("SDRAM_SIM.vcd");
		$dumpvars(0,SDRAM_SIM_instance);
	end

	initial begin
		#(tPD)
			p_reset = 1;
			m_clock = 0;
			sdrclk  = 0;
		#(tCYC_TOP)
			p_reset = 0;
	end
endmodule
