-64

-uvmhome /home/cc/mnt/XCELIUM2309/tools/methodology/UVM/CDNS-1.1d

// include directories, starting with UVM src directory
-incdir ../sv

// uncomment for gui
// -gui
+access+rwc

// default timescale
-timescale 1ns/100ps

// options
//+UVM_VERBOSITY=UVM_LOW
+UVM_VERBOSITY=UVM_HIGH
//+UVM_TESTNAME=demo_base_test
+UVM_TESTNAME=REGRESSION_TEST
+SVSEED=random
//+UVM_TESTNAME=hbus_master_topology

// compile files
../sv/ahb_pkg.sv
../sv/ahb_lite_if.sv 

design.sv
ahb_top.sv
 //coverage
// -covdut ahb_mscoreboard
-coverage U
-covoverwrite

-linedebug
