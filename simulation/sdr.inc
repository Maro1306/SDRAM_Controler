declare sdr interface{
	input	Clk;
	input	Cke;
	input	Cs_n;
	input	Ras_n;
	input	Cas_n;
	input	We_n;
	input	Addr[13];
	input	Ba[2];
	inout	Dq[16];
	input	Dqm[2];
}
