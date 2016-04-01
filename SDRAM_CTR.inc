declare SDRAM{
	input	DRAM_DI[16];
	output 	DRAM_DO[16];
	output	DRAM_A[13];
	output	DRAM_BA[2];
	output 	DRAM_LDQM;
	output 	DRAM_UDQM;
	output 	DRAM_RAS;
	output 	DRAM_CAS;
	output 	DRAM_CKE;
	output 	DRAM_CLK;
	output 	DRAM_WE;
	output 	DRAM_CS;

	input 	banki[2];
	input	rowi[13];
	input	columni[10];
	input	datai[16];
	output	datao[16];
	func_in	rd(banki, rowi, columni);
	func_in wt(banki, rowi, columni, datai);
	output	wtf;
	output	done;
}