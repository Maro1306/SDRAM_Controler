################################################################################
# Makefile : sof file generation using Quartus II
# Usage:
#		make compile for synthesis all files
#       make download for download .sof file to FPGA board
################################################################################
# 2014.07.22 Initial version by T.Furukawa (based on AISoC's makefile)
################################################################################

ifndef SRCDIR
SRCDIR	= .
endif
WORKDIR		= $(SRCDIR)/work
DEBUGDIR	= $(SRCDIR)/debug
VPATH		= $(SRCDIR)
ifndef DESIGN
DESIGN		= DE0_CV
endif
TARGET		=
PROJECT		= $(DESIGN)
NSL2VL    	= nsl2vl
NSL2SC    	= nsl2sc
NSLFLAGS  	= -sim -neg_res -I$(SRCDIR) 
NSLSCFLAGS	= $(NSLFLAGS) -sc_split_header -sc_trace
MKPROJ		= $(SRCDIR)/mkproj-$(DESIGN).tcl
LBITS		= $(shell getconf LONG_BIT)
ifeq	($(LBITS),64)
	Q2SH		= quartus_sh --64bit
	Q2PGM		= quartus_pgm --64bit
else
	Q2SH		= quartus_sh 
	Q2PGM		= quartus_pgm 
endif
Q2SHOPT		= -fit "fast fit"

CABLE		= "USB-Blaster"
PMODE		= JTAG

VERIOPT		= -LDFLAGS -lX11
SRCS		= RAM.nsl BINARY.nsl
SYNTHSRCS	= $(PROJECT).nsl $(SRCS)
VFILES 		= $(SYNTHSRCS:%.nsl=%.v) 
LIBS		=
RESULT		= result.txt

SCFILES		=$(SRCS:%.nsl=%.sc)
INCDIR		=$(SYSTEMC_INCLUDE_DIRS) -I$(DEBUGDIR) -I$(SRCDIR)
LIBDIR		=$(SYSTEMC_LIBRARY_DIRS)
LIBSC		=-lsystemc -x c++

##################################################################################
#quartus
##################################################################################

all:
	@if [ ! -d $(WORKDIR) ]; then \
		echo mkdir $(WORKDIR); \
		mkdir $(WORKDIR); \
	fi
	( cd $(WORKDIR); make -f ../Makefile SRCDIR=.. compile )

########

.SUFFIXES: .v .nsl

%.v:%.nsl
	$(NSL2VL) $(NSLFLAGS) $< -o $@

$(PROJECT).qsf: $(VFILES) $(LIBS) 
	$(Q2SH) -t $(MKPROJ) $(Q2SHOPT) -project $(PROJECT) $^

$(PROJECT).sof: $(PROJECT).qsf 
	$(Q2SH) --flow compile $(PROJECT)

########

compile: $(PROJECT).sof
	@echo "**** $(PROJECT).fit.summary" | tee -a $(RESULT)
	@cat $(PROJECT).fit.summary | tee -a $(RESULT)
	@echo "**** $(PROJECT).tan.rpt" | tee -a $(RESULT)
#	@grep "Info: Fmax" $(PROJECT).tan.rpt | tee -a $(RESULT)

download: config-n

config: all
	$(Q2PGM) -c $(CABLE) -m $(PMODE) -o "p;$(WORKDIR)/$(PROJECT).sof"
config-n: # without re-compile
	$(Q2PGM) -c $(CABLE) -m $(PMODE) -o "p;$(WORKDIR)/$(PROJECT).sof"

##################################################################################
#verilator
##################################################################################

%.sim:
	@if [ ! -d $(DEBUGDIR) ]; then \
		echo mkdir $(DEBUGDIR); \
		mkdir $(DEBUGDIR); \
	fi
	( cd $(DEBUGDIR); make -f ../Makefile SRCDIR=.. TARGET=$(@:%.sim=%) V$(@:%.sim=%) )

V$(TARGET).h: $(VFILES) $(TARGET)_sim.cpp
	sed -i -e "s/#1//" *.v
	verilator --cc $(VERIOPT) $(TARGET).v --exe $(SRCDIR)/$(TARGET)_sim.cpp

V$(TARGET): V$(TARGET).h 
	@echo "simulation"
	(cd obj_dir; make -j -f V$(TARGET).mk V$(TARGET) )

%.run:%.sim
	(time $(DEBUGDIR)/obj_dir/V$(@:%.run=%))

%.rerun:
	(time $(DEBUGDIR)/obj_dir/V$(@:%.rerun=%))


##################################################################################
#iverilog
##################################################################################

%.:
	@if [ ! -d $(DEBUGDIR) ]; then \
		echo mkdir $(DEBUGDIR); \
		mkdir $(DEBUGDIR); \
	fi
	( cd $(DEBUGDIR); make -f ../Makefile SRCDIR=.. TARGET=$(@:%.sim=%) V$(@:%.sim=%) )

%.vvp: $(TARGET)_sim.v $(VFILES)
	iverilog -o $@ 





clean:
	rm -rf - $(WORKDIR)
	rm -rf - $(DEBUGDIR)

##################################################################################
#SystemC
##################################################################################
%.sc:%.nsl
	$(NSL2SC) $(NSLSCFLAGS) $< -o $@
	echo '#include "NSL_SC.cpp"'>> $*.sc

%.scsim:
	@if [ ! -d $(DEBUGDIR) ]; then \
		echo mkdir $(DEBUGDIR); \
		mkdir $(DEBUGDIR); \
	fi
	( cd $(DEBUGDIR); make -f ../Makefile SRCDIR=.. PROJECT=$(@:%.scsim=%) $(@:%.scsim=%).run )

$(PROJECT).exe:$(PROJECT)_main.cpp $(SCFILES)
	$(CXX) $(CXXFLAGS) $(INCDIR) $(LIBDIR) -o $@ $(LIBSC) $< $(SCFILES)

$(PROJECT).run: $(PROJECT).exe
	$(DEBUGDIR)/$(PROJECT).exe
	
##################################################################################

