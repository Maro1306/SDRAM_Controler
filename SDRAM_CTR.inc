declare SDRAM_CTR{
	input	DRAM_DI[16];
	output	DRAM_DO[16];
	output	DRAM_A[13];
	output	DRAM_BA[2];
	output 	DRAM_LDQM;
	output 	DRAM_UDQM;
	output 	DRAM_RAS;
	output 	DRAM_CAS;
	output 	DRAM_CKE;
	output 	DRAM_WE;
	output 	DRAM_CS;

	input	rxin;
	output	rxout;
	output	finish_init;
	input	rw_mode;
	input	bank[2];
	input	row[13];
	input	column[10];
	input	datai[16];
	output	datao[16];
}
