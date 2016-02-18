
########## Tcl recorder starts at 01/18/16 21:11:33 ##########

set version "2.0"
set proj_dir "D:/lscc/ispLEVER_Classic2_0/examples/test01"
cd $proj_dir

# Get directory paths
set pver $version
regsub -all {\.} $pver {_} pver
set lscfile "lsc_"
append lscfile $pver ".ini"
set lsvini_dir [lindex [array get env LSC_INI_PATH] 1]
set lsvini_path [file join $lsvini_dir $lscfile]
if {[catch {set fid [open $lsvini_path]} msg]} {
	 puts "File Open Error: $lsvini_path"
	 return false
} else {set data [read $fid]; close $fid }
foreach line [split $data '\n'] { 
	set lline [string tolower $line]
	set lline [string trim $lline]
	if {[string compare $lline "\[paths\]"] == 0} { set path 1; continue}
	if {$path && [regexp {^\[} $lline]} {set path 0; break}
	if {$path && [regexp {^bin} $lline]} {set cpld_bin $line; continue}
	if {$path && [regexp {^fpgapath} $lline]} {set fpga_dir $line; continue}
	if {$path && [regexp {^fpgabinpath} $lline]} {set fpga_bin $line}}

set cpld_bin [string range $cpld_bin [expr [string first "=" $cpld_bin]+1] end]
regsub -all "\"" $cpld_bin "" cpld_bin
set cpld_bin [file join $cpld_bin]
set install_dir [string range $cpld_bin 0 [expr [string first "ispcpld" $cpld_bin]-2]]
regsub -all "\"" $install_dir "" install_dir
set install_dir [file join $install_dir]
set fpga_dir [string range $fpga_dir [expr [string first "=" $fpga_dir]+1] end]
regsub -all "\"" $fpga_dir "" fpga_dir
set fpga_dir [file join $fpga_dir]
set fpga_bin [string range $fpga_bin [expr [string first "=" $fpga_bin]+1] end]
regsub -all "\"" $fpga_bin "" fpga_bin
set fpga_bin [file join $fpga_bin]

if {[string match "*$fpga_bin;*" $env(PATH)] == 0 } {
   set env(PATH) "$fpga_bin;$env(PATH)" }

if {[string match "*$cpld_bin;*" $env(PATH)] == 0 } {
   set env(PATH) "$cpld_bin;$env(PATH)" }

lappend auto_path [file join $install_dir "ispcpld" "tcltk" "lib" "ispwidget" "runproc"]
package require runcmd

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:11:33 ###########


########## Tcl recorder starts at 01/18/16 21:12:58 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:12:58 ###########


########## Tcl recorder starts at 01/18/16 21:13:11 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:13:11 ###########


########## Tcl recorder starts at 01/18/16 21:14:24 ##########

# Commands to make the Process: 
# Post-Fit Pinouts
# - none -
# Application to view the Process: 
# Post-Fit Pinouts
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-src test01.tt4 -type PLA -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -postfit -lci test01.lco
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:14:24 ###########


########## Tcl recorder starts at 01/18/16 21:23:55 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:23:55 ###########


########## Tcl recorder starts at 01/18/16 21:24:04 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:24:04 ###########


########## Tcl recorder starts at 01/18/16 21:26:06 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:26:06 ###########


########## Tcl recorder starts at 01/18/16 21:27:23 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:27:23 ###########


########## Tcl recorder starts at 01/18/16 21:27:39 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:27:39 ###########


########## Tcl recorder starts at 01/18/16 21:28:20 ##########

# Commands to make the Process: 
# Post-Fit Pinouts
# - none -
# Application to view the Process: 
# Post-Fit Pinouts
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-src test01.tt4 -type PLA -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -postfit -lci test01.lco
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:28:20 ###########


########## Tcl recorder starts at 01/18/16 21:29:03 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:29:03 ###########


########## Tcl recorder starts at 01/18/16 21:29:31 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:29:31 ###########


########## Tcl recorder starts at 01/18/16 21:29:54 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:29:54 ###########


########## Tcl recorder starts at 01/18/16 21:30:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:30:34 ###########


########## Tcl recorder starts at 01/18/16 21:30:45 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:30:45 ###########


########## Tcl recorder starts at 01/18/16 21:31:23 ##########

# Commands to make the Process: 
# Post-Fit Pinouts
# - none -
# Application to view the Process: 
# Post-Fit Pinouts
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-src test01.tt4 -type PLA -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -postfit -lci test01.lco
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:31:23 ###########


########## Tcl recorder starts at 01/18/16 21:32:50 ##########

# Commands to make the Process: 
# Post-Fit Pinouts
# - none -
# Application to view the Process: 
# Post-Fit Pinouts
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-src test01.tt4 -type PLA -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -postfit -lci test01.lco
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:32:50 ###########


########## Tcl recorder starts at 01/18/16 21:33:55 ##########

# Commands to make the Process: 
# Post-Fit Pinouts
# - none -
# Application to view the Process: 
# Post-Fit Pinouts
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-src test01.tt4 -type PLA -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -postfit -lci test01.lco
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:33:55 ###########


########## Tcl recorder starts at 01/18/16 21:34:41 ##########

# Commands to make the Process: 
# Post-Fit Re-Compile
# - none -
# Application to view the Process: 
# Post-Fit Re-Compile
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-src test01.bl5 -type BLIF -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct -prc test01.lco -log test01.log -touch test01.fti
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:34:41 ###########


########## Tcl recorder starts at 01/18/16 21:34:50 ##########

# Commands to make the Process: 
# Pre-Fit Equations
if [runCmd "\"$cpld_bin/blif2eqn\" test01.bl5 -o test01.eq2 -use_short -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:34:50 ###########


########## Tcl recorder starts at 01/18/16 21:35:35 ##########

# Commands to make the Process: 
# Post-Fit Pinouts
# - none -
# Application to view the Process: 
# Post-Fit Pinouts
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-src test01.tt4 -type PLA -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -postfit -lci test01.lco
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:35:35 ###########


########## Tcl recorder starts at 01/18/16 21:36:52 ##########

# Commands to make the Process: 
# Post-Fit Pinouts
# - none -
# Application to view the Process: 
# Post-Fit Pinouts
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-src test01.tt4 -type PLA -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -postfit -lci test01.lco
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:36:52 ###########


########## Tcl recorder starts at 01/18/16 21:38:16 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:38:16 ###########


########## Tcl recorder starts at 01/18/16 21:38:29 ##########

# Commands to make the Process: 
# Post-Fit Pinouts
# - none -
# Application to view the Process: 
# Post-Fit Pinouts
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-src test01.tt4 -type PLA -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -postfit -lci test01.lco
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:38:29 ###########


########## Tcl recorder starts at 01/18/16 21:40:23 ##########

# Commands to make the Process: 
# Post-Fit Pinouts
# - none -
# Application to view the Process: 
# Post-Fit Pinouts
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-src test01.tt4 -type PLA -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -postfit -lci test01.lco
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:40:23 ###########


########## Tcl recorder starts at 01/18/16 21:41:10 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:41:10 ###########


########## Tcl recorder starts at 01/18/16 21:43:20 ##########

# Commands to make the Process: 
# Post-Fit Pinouts
# - none -
# Application to view the Process: 
# Post-Fit Pinouts
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-src test01.tt4 -type PLA -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -postfit -lci test01.lco
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:43:20 ###########


########## Tcl recorder starts at 01/18/16 21:44:05 ##########

# Commands to make the Process: 
# Post-Fit Re-Compile
# - none -
# Application to view the Process: 
# Post-Fit Re-Compile
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-src test01.bl5 -type BLIF -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct -prc test01.lco -log test01.log -touch test01.fti
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:44:05 ###########


########## Tcl recorder starts at 01/18/16 21:44:13 ##########

# Commands to make the Process: 
# Post-Fit Pinouts
# - none -
# Application to view the Process: 
# Post-Fit Pinouts
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-src test01.tt4 -type PLA -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -postfit -lci test01.lco
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:44:13 ###########


########## Tcl recorder starts at 01/18/16 21:54:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:54:45 ###########


########## Tcl recorder starts at 01/18/16 21:56:41 ##########

# Commands to make the Process: 
# Post-Fit Pinouts
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Post-Fit Pinouts
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-src test01.tt4 -type PLA -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -postfit -lci test01.lco
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:56:41 ###########


########## Tcl recorder starts at 01/18/16 21:58:09 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:58:09 ###########


########## Tcl recorder starts at 01/18/16 21:59:15 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 21:59:15 ###########


########## Tcl recorder starts at 01/18/16 21:59:25 ##########

# Commands to make the Process: 
# Synplify Synthesize Verilog File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd

########## Tcl recorder end at 01/18/16 21:59:25 ###########


########## Tcl recorder starts at 01/18/16 22:00:02 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 22:00:02 ###########


########## Tcl recorder starts at 01/18/16 22:00:36 ##########

# Commands to make the Process: 
# Post-Fit Pinouts
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Post-Fit Pinouts
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-src test01.tt4 -type PLA -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -postfit -lci test01.lco
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 22:00:36 ###########


########## Tcl recorder starts at 01/18/16 22:02:59 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 22:02:59 ###########


########## Tcl recorder starts at 01/18/16 22:03:12 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 22:03:12 ###########


########## Tcl recorder starts at 01/18/16 22:05:00 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 22:05:00 ###########


########## Tcl recorder starts at 01/18/16 22:05:56 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 22:05:56 ###########


########## Tcl recorder starts at 01/18/16 22:07:53 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 22:07:53 ###########


########## Tcl recorder starts at 01/18/16 22:07:58 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 22:07:58 ###########


########## Tcl recorder starts at 01/18/16 22:10:12 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 22:10:12 ###########


########## Tcl recorder starts at 01/18/16 22:10:21 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 22:10:21 ###########


########## Tcl recorder starts at 01/18/16 22:13:31 ##########

# Commands to make the Process: 
# ISC-1532 File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2i "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 22:13:31 ###########


########## Tcl recorder starts at 01/18/16 22:25:18 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 22:25:18 ###########


########## Tcl recorder starts at 01/18/16 22:25:54 ##########

# Commands to make the Process: 
# Constraint Editor
# - none -
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 22:25:54 ###########


########## Tcl recorder starts at 01/18/16 22:27:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 22:27:08 ###########


########## Tcl recorder starts at 01/18/16 22:27:14 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 22:27:14 ###########


########## Tcl recorder starts at 01/18/16 22:28:11 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 22:28:11 ###########


########## Tcl recorder starts at 01/18/16 23:45:53 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/18/16 23:45:53 ###########


########## Tcl recorder starts at 01/19/16 00:06:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 00:06:50 ###########


########## Tcl recorder starts at 01/19/16 00:07:16 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 00:07:16 ###########


########## Tcl recorder starts at 01/19/16 00:08:10 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 00:08:10 ###########


########## Tcl recorder starts at 01/19/16 00:08:10 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01_lse.env w} rspFile] {
	puts stderr "Cannot create response file test01_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open test01.synproj w} rspFile] {
	puts stderr "Cannot create response file test01.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064V
-top test01
-lib \"work\" -ver test01.h test01.v
-output_edif test01.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"test01.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01_lse.env
file delete test01.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 00:08:10 ###########


########## Tcl recorder starts at 01/19/16 00:08:47 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 00:08:47 ###########


########## Tcl recorder starts at 01/19/16 00:08:47 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 00:08:47 ###########


########## Tcl recorder starts at 01/19/16 00:10:48 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 00:10:48 ###########


########## Tcl recorder starts at 01/19/16 00:10:53 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 00:10:53 ###########


########## Tcl recorder starts at 01/19/16 00:30:25 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 00:30:25 ###########


########## Tcl recorder starts at 01/19/16 00:31:25 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 00:31:25 ###########


########## Tcl recorder starts at 01/19/16 00:31:30 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 00:31:30 ###########


########## Tcl recorder starts at 01/19/16 00:34:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 00:34:05 ###########


########## Tcl recorder starts at 01/19/16 00:34:12 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 00:34:12 ###########


########## Tcl recorder starts at 01/19/16 00:36:55 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 00:36:55 ###########


########## Tcl recorder starts at 01/19/16 00:39:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 00:39:17 ###########


########## Tcl recorder starts at 01/19/16 00:39:26 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 00:39:26 ###########


########## Tcl recorder starts at 01/19/16 00:40:47 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 00:40:47 ###########


########## Tcl recorder starts at 01/19/16 00:42:00 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 00:42:00 ###########


########## Tcl recorder starts at 01/19/16 00:42:09 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 00:42:09 ###########


########## Tcl recorder starts at 01/19/16 00:42:21 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 00:42:21 ###########


########## Tcl recorder starts at 01/19/16 00:44:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 00:44:42 ###########


########## Tcl recorder starts at 01/19/16 00:44:58 ##########

# Commands to make the Process: 
# Optimization Constraint
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Optimization Constraint
if [catch {open opt_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file opt_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-global -lci test01.lct -touch test01.imp
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/optedit\" @opt_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 00:44:58 ###########


########## Tcl recorder starts at 01/19/16 00:52:41 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 00:52:41 ###########


########## Tcl recorder starts at 01/19/16 01:20:35 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 01:20:35 ###########


########## Tcl recorder starts at 01/19/16 01:20:45 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 01:20:45 ###########


########## Tcl recorder starts at 01/19/16 01:22:28 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 01:22:29 ###########


########## Tcl recorder starts at 01/19/16 01:22:41 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 01:22:41 ###########


########## Tcl recorder starts at 01/19/16 01:26:10 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 01:26:11 ###########


########## Tcl recorder starts at 01/19/16 01:26:27 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 01:26:27 ###########


########## Tcl recorder starts at 01/19/16 01:26:39 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 01:26:39 ###########


########## Tcl recorder starts at 01/19/16 01:30:22 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/19/16 01:30:22 ###########


########## Tcl recorder starts at 01/23/16 15:50:25 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 15:50:25 ###########


########## Tcl recorder starts at 01/23/16 15:58:19 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 15:58:19 ###########


########## Tcl recorder starts at 01/23/16 16:23:39 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 16:23:39 ###########


########## Tcl recorder starts at 01/23/16 16:27:41 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 16:27:41 ###########


########## Tcl recorder starts at 01/23/16 16:29:16 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 16:29:16 ###########


########## Tcl recorder starts at 01/23/16 16:29:34 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 16:29:34 ###########


########## Tcl recorder starts at 01/23/16 16:36:14 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 16:36:14 ###########


########## Tcl recorder starts at 01/23/16 16:36:59 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 16:36:59 ###########


########## Tcl recorder starts at 01/23/16 16:37:07 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 16:37:07 ###########


########## Tcl recorder starts at 01/23/16 16:40:50 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 16:40:50 ###########


########## Tcl recorder starts at 01/23/16 16:44:44 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 16:44:44 ###########


########## Tcl recorder starts at 01/23/16 16:45:00 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 16:45:00 ###########


########## Tcl recorder starts at 01/23/16 16:45:34 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 16:45:34 ###########


########## Tcl recorder starts at 01/23/16 16:47:35 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 16:47:35 ###########


########## Tcl recorder starts at 01/23/16 16:47:39 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 16:47:39 ###########


########## Tcl recorder starts at 01/23/16 16:48:57 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 16:48:57 ###########


########## Tcl recorder starts at 01/23/16 16:50:00 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 16:50:00 ###########


########## Tcl recorder starts at 01/23/16 16:50:12 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 16:50:12 ###########


########## Tcl recorder starts at 01/23/16 16:52:10 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 16:52:10 ###########


########## Tcl recorder starts at 01/23/16 16:52:22 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 16:52:22 ###########


########## Tcl recorder starts at 01/23/16 16:53:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 16:53:26 ###########


########## Tcl recorder starts at 01/23/16 16:53:35 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 16:53:35 ###########


########## Tcl recorder starts at 01/23/16 16:56:24 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 16:56:24 ###########


########## Tcl recorder starts at 01/23/16 16:58:47 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 16:58:47 ###########


########## Tcl recorder starts at 01/23/16 17:55:29 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 17:55:29 ###########


########## Tcl recorder starts at 01/23/16 18:00:17 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:00:17 ###########


########## Tcl recorder starts at 01/23/16 18:00:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:00:50 ###########


########## Tcl recorder starts at 01/23/16 18:01:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:01:08 ###########


########## Tcl recorder starts at 01/23/16 18:01:17 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:01:17 ###########


########## Tcl recorder starts at 01/23/16 18:09:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:09:50 ###########


########## Tcl recorder starts at 01/23/16 18:10:04 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:10:04 ###########


########## Tcl recorder starts at 01/23/16 18:18:30 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:18:30 ###########


########## Tcl recorder starts at 01/23/16 18:20:21 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:20:21 ###########


########## Tcl recorder starts at 01/23/16 18:20:28 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:20:28 ###########


########## Tcl recorder starts at 01/23/16 18:27:13 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:27:13 ###########


########## Tcl recorder starts at 01/23/16 18:30:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:30:40 ###########


########## Tcl recorder starts at 01/23/16 18:30:51 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:30:51 ###########


########## Tcl recorder starts at 01/23/16 18:35:55 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:35:56 ###########


########## Tcl recorder starts at 01/23/16 18:36:10 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:36:10 ###########


########## Tcl recorder starts at 01/23/16 18:44:22 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:44:22 ###########


########## Tcl recorder starts at 01/23/16 18:45:56 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:45:56 ###########


########## Tcl recorder starts at 01/23/16 18:46:23 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:46:23 ###########


########## Tcl recorder starts at 01/23/16 18:47:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:47:08 ###########


########## Tcl recorder starts at 01/23/16 18:47:26 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:47:26 ###########


########## Tcl recorder starts at 01/23/16 18:48:09 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:48:09 ###########


########## Tcl recorder starts at 01/23/16 18:48:19 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:48:19 ###########


########## Tcl recorder starts at 01/23/16 18:48:57 ##########

# Commands to make the Process: 
# Fitter Report (HTML)
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:48:57 ###########


########## Tcl recorder starts at 01/23/16 18:55:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:55:36 ###########


########## Tcl recorder starts at 01/23/16 18:57:10 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:57:10 ###########


########## Tcl recorder starts at 01/23/16 18:57:24 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:57:24 ###########


########## Tcl recorder starts at 01/23/16 18:59:02 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:59:02 ###########


########## Tcl recorder starts at 01/23/16 18:59:16 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 18:59:16 ###########


########## Tcl recorder starts at 01/23/16 19:01:14 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:01:14 ###########


########## Tcl recorder starts at 01/23/16 19:02:15 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:02:15 ###########


########## Tcl recorder starts at 01/23/16 19:02:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:02:42 ###########


########## Tcl recorder starts at 01/23/16 19:03:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:03:25 ###########


########## Tcl recorder starts at 01/23/16 19:03:35 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:03:35 ###########


########## Tcl recorder starts at 01/23/16 19:05:09 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:05:09 ###########


########## Tcl recorder starts at 01/23/16 19:05:30 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:05:30 ###########


########## Tcl recorder starts at 01/23/16 19:06:54 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" cntr.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:06:54 ###########


########## Tcl recorder starts at 01/23/16 19:07:12 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" cntr.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:07:12 ###########


########## Tcl recorder starts at 01/23/16 19:07:21 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:07:21 ###########


########## Tcl recorder starts at 01/23/16 19:07:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:07:38 ###########


########## Tcl recorder starts at 01/23/16 19:08:01 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" bcd2seg.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:08:01 ###########


########## Tcl recorder starts at 01/23/16 19:08:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" bcd2seg.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:08:05 ###########


########## Tcl recorder starts at 01/23/16 19:08:29 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:08:29 ###########


########## Tcl recorder starts at 01/23/16 19:11:58 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:11:58 ###########


########## Tcl recorder starts at 01/23/16 19:14:16 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" bcd2seg.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:14:16 ###########


########## Tcl recorder starts at 01/23/16 19:15:44 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:15:44 ###########


########## Tcl recorder starts at 01/23/16 19:15:53 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:15:53 ###########


########## Tcl recorder starts at 01/23/16 19:16:04 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:16:04 ###########


########## Tcl recorder starts at 01/23/16 19:18:07 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:18:07 ###########


########## Tcl recorder starts at 01/23/16 19:18:15 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:18:15 ###########


########## Tcl recorder starts at 01/23/16 19:18:24 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:18:24 ###########


########## Tcl recorder starts at 01/23/16 19:23:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" cntr.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:23:45 ###########


########## Tcl recorder starts at 01/23/16 19:24:03 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" cntr.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:24:03 ###########


########## Tcl recorder starts at 01/23/16 19:24:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:24:49 ###########


########## Tcl recorder starts at 01/23/16 19:25:06 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:25:06 ###########


########## Tcl recorder starts at 01/23/16 19:25:24 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:25:24 ###########


########## Tcl recorder starts at 01/23/16 19:26:56 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:26:56 ###########


########## Tcl recorder starts at 01/23/16 19:27:05 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:27:05 ###########


########## Tcl recorder starts at 01/23/16 19:27:43 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:27:43 ###########


########## Tcl recorder starts at 01/23/16 19:27:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:27:52 ###########


########## Tcl recorder starts at 01/23/16 19:28:04 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:28:04 ###########


########## Tcl recorder starts at 01/23/16 19:28:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" cntr.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:28:45 ###########


########## Tcl recorder starts at 01/23/16 19:28:51 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:28:51 ###########


########## Tcl recorder starts at 01/23/16 19:29:54 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" cntr.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:29:54 ###########


########## Tcl recorder starts at 01/23/16 19:30:06 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:30:06 ###########


########## Tcl recorder starts at 01/23/16 19:31:32 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:31:32 ###########


########## Tcl recorder starts at 01/23/16 19:31:43 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:31:43 ###########


########## Tcl recorder starts at 01/23/16 19:33:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:33:49 ###########


########## Tcl recorder starts at 01/23/16 19:34:00 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:34:00 ###########


########## Tcl recorder starts at 01/23/16 19:35:41 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:35:41 ###########


########## Tcl recorder starts at 01/23/16 19:35:53 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:35:53 ###########


########## Tcl recorder starts at 01/23/16 19:37:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" cntr.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:37:26 ###########


########## Tcl recorder starts at 01/23/16 19:37:51 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:37:51 ###########


########## Tcl recorder starts at 01/23/16 19:38:00 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:38:00 ###########


########## Tcl recorder starts at 01/23/16 19:38:16 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:38:16 ###########


########## Tcl recorder starts at 01/23/16 19:40:04 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:40:04 ###########


########## Tcl recorder starts at 01/23/16 19:40:26 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:40:26 ###########


########## Tcl recorder starts at 01/23/16 19:41:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:41:40 ###########


########## Tcl recorder starts at 01/23/16 19:41:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:41:45 ###########


########## Tcl recorder starts at 01/23/16 19:41:54 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:41:54 ###########


########## Tcl recorder starts at 01/23/16 19:45:22 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" cntr.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:45:22 ###########


########## Tcl recorder starts at 01/23/16 19:46:27 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" cntr.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:46:27 ###########


########## Tcl recorder starts at 01/23/16 19:47:19 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:47:19 ###########


########## Tcl recorder starts at 01/23/16 19:47:26 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:47:26 ###########


########## Tcl recorder starts at 01/23/16 19:50:12 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" cntr.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:50:12 ###########


########## Tcl recorder starts at 01/23/16 19:50:30 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" cntr.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:50:30 ###########


########## Tcl recorder starts at 01/23/16 19:50:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" cntr.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:50:38 ###########


########## Tcl recorder starts at 01/23/16 19:51:56 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" cntr.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:51:56 ###########


########## Tcl recorder starts at 01/23/16 19:52:46 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:52:46 ###########


########## Tcl recorder starts at 01/23/16 19:55:18 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:55:18 ###########


########## Tcl recorder starts at 01/23/16 19:56:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" cntr.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:56:42 ###########


########## Tcl recorder starts at 01/23/16 19:56:46 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" cntr.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:56:46 ###########


########## Tcl recorder starts at 01/23/16 19:57:51 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:57:51 ###########


########## Tcl recorder starts at 01/23/16 19:58:29 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:58:29 ###########


########## Tcl recorder starts at 01/23/16 19:58:36 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:58:36 ###########


########## Tcl recorder starts at 01/23/16 19:59:13 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" cntr.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:59:13 ###########


########## Tcl recorder starts at 01/23/16 19:59:20 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 19:59:20 ###########


########## Tcl recorder starts at 01/23/16 20:00:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:00:52 ###########


########## Tcl recorder starts at 01/23/16 20:01:02 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:01:02 ###########


########## Tcl recorder starts at 01/23/16 20:17:09 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:17:10 ###########


########## Tcl recorder starts at 01/23/16 20:18:02 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:18:02 ###########


########## Tcl recorder starts at 01/23/16 20:21:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:21:40 ###########


########## Tcl recorder starts at 01/23/16 20:24:04 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:24:04 ###########


########## Tcl recorder starts at 01/23/16 20:25:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:25:45 ###########


########## Tcl recorder starts at 01/23/16 20:26:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:26:08 ###########


########## Tcl recorder starts at 01/23/16 20:26:27 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:26:27 ###########


########## Tcl recorder starts at 01/23/16 20:27:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:27:33 ###########


########## Tcl recorder starts at 01/23/16 20:28:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:28:49 ###########


########## Tcl recorder starts at 01/23/16 20:28:57 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:28:57 ###########


########## Tcl recorder starts at 01/23/16 20:33:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:33:08 ###########


########## Tcl recorder starts at 01/23/16 20:33:20 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:33:20 ###########


########## Tcl recorder starts at 01/23/16 20:34:02 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:34:02 ###########


########## Tcl recorder starts at 01/23/16 20:35:10 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:35:10 ###########


########## Tcl recorder starts at 01/23/16 20:35:16 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:35:16 ###########


########## Tcl recorder starts at 01/23/16 20:38:51 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:38:51 ###########


########## Tcl recorder starts at 01/23/16 20:39:14 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:39:14 ###########


########## Tcl recorder starts at 01/23/16 20:39:22 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:39:22 ###########


########## Tcl recorder starts at 01/23/16 20:41:20 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:41:20 ###########


########## Tcl recorder starts at 01/23/16 20:41:25 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:41:26 ###########


########## Tcl recorder starts at 01/23/16 20:42:00 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:42:00 ###########


########## Tcl recorder starts at 01/23/16 20:44:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:44:05 ###########


########## Tcl recorder starts at 01/23/16 20:44:12 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:44:12 ###########


########## Tcl recorder starts at 01/23/16 20:47:43 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:47:43 ###########


########## Tcl recorder starts at 01/23/16 20:47:52 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:47:52 ###########


########## Tcl recorder starts at 01/23/16 20:49:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:49:38 ###########


########## Tcl recorder starts at 01/23/16 20:49:51 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:49:51 ###########


########## Tcl recorder starts at 01/23/16 20:49:58 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:49:58 ###########


########## Tcl recorder starts at 01/23/16 20:52:55 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:52:55 ###########


########## Tcl recorder starts at 01/23/16 20:53:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:53:25 ###########


########## Tcl recorder starts at 01/23/16 20:53:32 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:53:32 ###########


########## Tcl recorder starts at 01/23/16 20:55:44 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:55:44 ###########


########## Tcl recorder starts at 01/23/16 20:56:18 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:56:18 ###########


########## Tcl recorder starts at 01/23/16 20:57:30 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:57:30 ###########


########## Tcl recorder starts at 01/23/16 20:57:42 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 20:57:42 ###########


########## Tcl recorder starts at 01/23/16 21:00:06 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 21:00:06 ###########


########## Tcl recorder starts at 01/23/16 21:00:15 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 21:00:15 ###########


########## Tcl recorder starts at 01/23/16 21:02:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 21:02:50 ###########


########## Tcl recorder starts at 01/23/16 21:02:56 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 21:02:56 ###########


########## Tcl recorder starts at 01/23/16 21:04:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 21:04:42 ###########


########## Tcl recorder starts at 01/23/16 21:04:49 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 21:04:49 ###########


########## Tcl recorder starts at 01/23/16 21:07:13 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 21:07:13 ###########


########## Tcl recorder starts at 01/23/16 21:07:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 21:07:26 ###########


########## Tcl recorder starts at 01/23/16 21:07:31 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 21:07:31 ###########


########## Tcl recorder starts at 01/23/16 21:11:03 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 21:11:04 ###########


########## Tcl recorder starts at 01/23/16 21:11:12 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 21:11:12 ###########


########## Tcl recorder starts at 01/23/16 21:13:24 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 21:13:24 ###########


########## Tcl recorder starts at 01/23/16 21:13:29 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 21:13:29 ###########


########## Tcl recorder starts at 01/23/16 22:21:32 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 22:21:32 ###########


########## Tcl recorder starts at 01/23/16 22:21:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 22:21:38 ###########


########## Tcl recorder starts at 01/23/16 22:21:48 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 22:21:48 ###########


########## Tcl recorder starts at 01/23/16 22:45:10 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 22:45:10 ###########


########## Tcl recorder starts at 01/23/16 22:47:19 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 22:47:19 ###########


########## Tcl recorder starts at 01/23/16 22:48:00 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 22:48:00 ###########


########## Tcl recorder starts at 01/23/16 22:48:05 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 22:48:05 ###########


########## Tcl recorder starts at 01/23/16 22:50:37 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 22:50:37 ###########


########## Tcl recorder starts at 01/23/16 22:56:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 22:56:33 ###########


########## Tcl recorder starts at 01/23/16 22:56:41 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 22:56:41 ###########


########## Tcl recorder starts at 01/23/16 23:05:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 23:05:26 ###########


########## Tcl recorder starts at 01/23/16 23:05:43 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 23:05:43 ###########


########## Tcl recorder starts at 01/23/16 23:08:19 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 23:08:19 ###########


########## Tcl recorder starts at 01/23/16 23:08:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 23:08:25 ###########


########## Tcl recorder starts at 01/23/16 23:08:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 23:08:40 ###########


########## Tcl recorder starts at 01/23/16 23:08:46 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 23:08:46 ###########


########## Tcl recorder starts at 01/23/16 23:10:24 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 23:10:24 ###########


########## Tcl recorder starts at 01/23/16 23:10:33 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 23:10:33 ###########


########## Tcl recorder starts at 01/23/16 23:12:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 23:12:08 ###########


########## Tcl recorder starts at 01/23/16 23:12:15 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 23:12:15 ###########


########## Tcl recorder starts at 01/23/16 23:13:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 23:13:40 ###########


########## Tcl recorder starts at 01/23/16 23:13:57 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/23/16 23:13:57 ###########


########## Tcl recorder starts at 01/24/16 01:18:11 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" cntr.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:18:11 ###########


########## Tcl recorder starts at 01/24/16 01:18:39 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:18:39 ###########


########## Tcl recorder starts at 01/24/16 01:18:52 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:18:52 ###########


########## Tcl recorder starts at 01/24/16 01:22:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:22:33 ###########


########## Tcl recorder starts at 01/24/16 01:22:55 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:22:55 ###########


########## Tcl recorder starts at 01/24/16 01:24:51 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:24:51 ###########


########## Tcl recorder starts at 01/24/16 01:24:58 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:24:58 ###########


########## Tcl recorder starts at 01/24/16 01:26:59 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:26:59 ###########


########## Tcl recorder starts at 01/24/16 01:31:43 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:31:43 ###########


########## Tcl recorder starts at 01/24/16 01:31:51 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:31:51 ###########


########## Tcl recorder starts at 01/24/16 01:36:18 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:36:18 ###########


########## Tcl recorder starts at 01/24/16 01:36:33 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:36:33 ###########


########## Tcl recorder starts at 01/24/16 01:39:01 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:39:01 ###########


########## Tcl recorder starts at 01/24/16 01:39:20 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:39:20 ###########


########## Tcl recorder starts at 01/24/16 01:39:25 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:39:25 ###########


########## Tcl recorder starts at 01/24/16 01:41:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:41:42 ###########


########## Tcl recorder starts at 01/24/16 01:43:04 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:43:04 ###########


########## Tcl recorder starts at 01/24/16 01:43:16 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:43:16 ###########


########## Tcl recorder starts at 01/24/16 01:44:56 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:44:56 ###########


########## Tcl recorder starts at 01/24/16 01:45:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:45:26 ###########


########## Tcl recorder starts at 01/24/16 01:45:54 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:45:54 ###########


########## Tcl recorder starts at 01/24/16 01:46:12 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:46:12 ###########


########## Tcl recorder starts at 01/24/16 01:48:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:48:05 ###########


########## Tcl recorder starts at 01/24/16 01:48:12 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:48:12 ###########


########## Tcl recorder starts at 01/24/16 01:52:48 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:52:48 ###########


########## Tcl recorder starts at 01/24/16 01:53:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:53:05 ###########


########## Tcl recorder starts at 01/24/16 01:53:14 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v cntr.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 01:53:14 ###########


########## Tcl recorder starts at 01/24/16 13:11:24 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/16 13:11:24 ###########


########## Tcl recorder starts at 01/25/16 08:29:30 ##########

# Commands to make the Process: 
# Constraint Editor
# - none -
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 08:29:30 ###########


########## Tcl recorder starts at 01/25/16 08:29:48 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 08:29:49 ###########


########## Tcl recorder starts at 01/25/16 08:30:36 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 08:30:36 ###########


########## Tcl recorder starts at 01/25/16 08:31:17 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 08:31:17 ###########


########## Tcl recorder starts at 01/25/16 08:33:22 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 08:33:22 ###########


########## Tcl recorder starts at 01/25/16 08:37:15 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 08:37:15 ###########


########## Tcl recorder starts at 01/25/16 08:37:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 08:37:40 ###########


########## Tcl recorder starts at 01/25/16 08:38:14 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 08:38:14 ###########


########## Tcl recorder starts at 01/25/16 08:38:22 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 08:38:22 ###########


########## Tcl recorder starts at 01/25/16 08:39:13 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 08:39:13 ###########


########## Tcl recorder starts at 01/25/16 08:40:32 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 08:40:32 ###########


########## Tcl recorder starts at 01/25/16 08:40:39 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 08:40:39 ###########


########## Tcl recorder starts at 01/25/16 08:42:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 08:42:52 ###########


########## Tcl recorder starts at 01/25/16 08:43:03 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 08:43:03 ###########


########## Tcl recorder starts at 01/25/16 08:45:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 08:45:45 ###########


########## Tcl recorder starts at 01/25/16 08:45:58 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 08:45:58 ###########


########## Tcl recorder starts at 01/25/16 08:47:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 08:47:17 ###########


########## Tcl recorder starts at 01/25/16 08:47:46 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 08:47:46 ###########


########## Tcl recorder starts at 01/25/16 08:47:59 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 08:47:59 ###########


########## Tcl recorder starts at 01/25/16 08:50:44 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 08:50:44 ###########


########## Tcl recorder starts at 01/25/16 08:50:55 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 08:50:55 ###########


########## Tcl recorder starts at 01/25/16 08:52:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 08:52:33 ###########


########## Tcl recorder starts at 01/25/16 08:52:55 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 08:52:55 ###########


########## Tcl recorder starts at 01/25/16 08:56:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 08:56:34 ###########


########## Tcl recorder starts at 01/25/16 08:57:51 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 08:57:51 ###########


########## Tcl recorder starts at 01/25/16 08:58:09 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 08:58:09 ###########


########## Tcl recorder starts at 01/25/16 09:13:47 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:13:47 ###########


########## Tcl recorder starts at 01/25/16 09:14:10 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:14:10 ###########


########## Tcl recorder starts at 01/25/16 09:16:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:16:52 ###########


########## Tcl recorder starts at 01/25/16 09:17:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:17:17 ###########


########## Tcl recorder starts at 01/25/16 09:17:29 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:17:29 ###########


########## Tcl recorder starts at 01/25/16 09:24:07 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:24:08 ###########


########## Tcl recorder starts at 01/25/16 09:25:20 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:25:20 ###########


########## Tcl recorder starts at 01/25/16 09:26:06 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:26:06 ###########


########## Tcl recorder starts at 01/25/16 09:26:35 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:26:35 ###########


########## Tcl recorder starts at 01/25/16 09:28:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:28:26 ###########


########## Tcl recorder starts at 01/25/16 09:29:06 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:29:06 ###########


########## Tcl recorder starts at 01/25/16 09:30:15 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:30:15 ###########


########## Tcl recorder starts at 01/25/16 09:30:31 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:30:31 ###########


########## Tcl recorder starts at 01/25/16 09:30:39 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:30:39 ###########


########## Tcl recorder starts at 01/25/16 09:31:19 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:31:19 ###########


########## Tcl recorder starts at 01/25/16 09:31:25 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:31:25 ###########


########## Tcl recorder starts at 01/25/16 09:32:21 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:32:21 ###########


########## Tcl recorder starts at 01/25/16 09:32:34 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:32:34 ###########


########## Tcl recorder starts at 01/25/16 09:33:35 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:33:35 ###########


########## Tcl recorder starts at 01/25/16 09:33:39 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:33:39 ###########


########## Tcl recorder starts at 01/25/16 09:34:39 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:34:39 ###########


########## Tcl recorder starts at 01/25/16 09:34:45 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:34:45 ###########


########## Tcl recorder starts at 01/25/16 09:36:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:36:42 ###########


########## Tcl recorder starts at 01/25/16 09:37:01 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" pu_reset.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:37:01 ###########


########## Tcl recorder starts at 01/25/16 09:37:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" pu_reset.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:37:17 ###########


########## Tcl recorder starts at 01/25/16 09:37:29 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:37:29 ###########


########## Tcl recorder starts at 01/25/16 09:37:36 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h pu_reset.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:37:36 ###########


########## Tcl recorder starts at 01/25/16 09:41:43 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:41:43 ###########


########## Tcl recorder starts at 01/25/16 09:41:54 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h pu_reset.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:41:54 ###########


########## Tcl recorder starts at 01/25/16 09:46:06 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:46:06 ###########


########## Tcl recorder starts at 01/25/16 09:49:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:49:42 ###########


########## Tcl recorder starts at 01/25/16 09:49:50 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:49:50 ###########


########## Tcl recorder starts at 01/25/16 09:51:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:51:49 ###########


########## Tcl recorder starts at 01/25/16 09:52:12 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 09:52:12 ###########


########## Tcl recorder starts at 01/25/16 10:26:13 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 10:26:13 ###########


########## Tcl recorder starts at 01/25/16 10:26:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 10:26:36 ###########


########## Tcl recorder starts at 01/25/16 10:26:57 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 10:26:57 ###########


########## Tcl recorder starts at 01/25/16 10:27:18 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 10:27:18 ###########


########## Tcl recorder starts at 01/25/16 10:30:00 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 10:30:00 ###########


########## Tcl recorder starts at 01/25/16 10:39:46 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 10:39:46 ###########


########## Tcl recorder starts at 01/25/16 10:39:58 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 10:39:58 ###########


########## Tcl recorder starts at 01/25/16 10:41:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 10:41:34 ###########


########## Tcl recorder starts at 01/25/16 10:41:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 10:41:49 ###########


########## Tcl recorder starts at 01/25/16 10:41:56 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 10:41:56 ###########


########## Tcl recorder starts at 01/25/16 11:45:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 11:45:05 ###########


########## Tcl recorder starts at 01/25/16 11:47:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 11:47:34 ###########


########## Tcl recorder starts at 01/25/16 11:47:47 ##########

# Commands to make the Process: 
# Fitter Report (HTML)
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 11:47:47 ###########


########## Tcl recorder starts at 01/25/16 11:51:04 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" bcd2seg.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 11:51:04 ###########


########## Tcl recorder starts at 01/25/16 11:51:20 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" bcd2seg.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 11:51:20 ###########


########## Tcl recorder starts at 01/25/16 11:51:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" bcd2seg.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 11:51:26 ###########


########## Tcl recorder starts at 01/25/16 11:52:23 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 11:52:23 ###########


########## Tcl recorder starts at 01/25/16 11:58:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 11:58:45 ###########


########## Tcl recorder starts at 01/25/16 11:58:59 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 11:58:59 ###########


########## Tcl recorder starts at 01/25/16 12:01:55 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:01:55 ###########


########## Tcl recorder starts at 01/25/16 12:02:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:02:25 ###########


########## Tcl recorder starts at 01/25/16 12:02:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:02:36 ###########


########## Tcl recorder starts at 01/25/16 12:03:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:03:40 ###########


########## Tcl recorder starts at 01/25/16 12:03:51 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:03:51 ###########


########## Tcl recorder starts at 01/25/16 12:07:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:07:49 ###########


########## Tcl recorder starts at 01/25/16 12:07:54 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:07:54 ###########


########## Tcl recorder starts at 01/25/16 12:09:37 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:09:37 ###########


########## Tcl recorder starts at 01/25/16 12:09:42 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:09:42 ###########


########## Tcl recorder starts at 01/25/16 12:11:29 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:11:29 ###########


########## Tcl recorder starts at 01/25/16 12:11:34 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:11:34 ###########


########## Tcl recorder starts at 01/25/16 12:17:13 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:17:13 ###########


########## Tcl recorder starts at 01/25/16 12:17:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:17:26 ###########


########## Tcl recorder starts at 01/25/16 12:17:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:17:33 ###########


########## Tcl recorder starts at 01/25/16 12:17:47 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:17:47 ###########


########## Tcl recorder starts at 01/25/16 12:20:56 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:20:56 ###########


########## Tcl recorder starts at 01/25/16 12:21:23 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:21:23 ###########


########## Tcl recorder starts at 01/25/16 12:21:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:21:40 ###########


########## Tcl recorder starts at 01/25/16 12:22:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:22:05 ###########


########## Tcl recorder starts at 01/25/16 12:22:14 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:22:14 ###########


########## Tcl recorder starts at 01/25/16 12:23:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:23:49 ###########


########## Tcl recorder starts at 01/25/16 12:24:02 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:24:02 ###########


########## Tcl recorder starts at 01/25/16 12:26:57 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:26:57 ###########


########## Tcl recorder starts at 01/25/16 12:27:09 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:27:09 ###########


########## Tcl recorder starts at 01/25/16 12:27:38 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:27:38 ###########


########## Tcl recorder starts at 01/25/16 12:31:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:31:05 ###########


########## Tcl recorder starts at 01/25/16 12:31:11 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:31:11 ###########


########## Tcl recorder starts at 01/25/16 12:34:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:34:36 ###########


########## Tcl recorder starts at 01/25/16 12:34:55 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:34:55 ###########


########## Tcl recorder starts at 01/25/16 12:37:31 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:37:31 ###########


########## Tcl recorder starts at 01/25/16 12:37:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:37:50 ###########


########## Tcl recorder starts at 01/25/16 12:37:57 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:37:57 ###########


########## Tcl recorder starts at 01/25/16 12:39:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:39:40 ###########


########## Tcl recorder starts at 01/25/16 12:39:55 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:39:55 ###########


########## Tcl recorder starts at 01/25/16 12:42:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:42:08 ###########


########## Tcl recorder starts at 01/25/16 12:42:11 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:42:11 ###########


########## Tcl recorder starts at 01/25/16 12:42:16 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:42:16 ###########


########## Tcl recorder starts at 01/25/16 12:44:27 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:44:27 ###########


########## Tcl recorder starts at 01/25/16 12:44:33 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:44:33 ###########


########## Tcl recorder starts at 01/25/16 12:45:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:45:52 ###########


########## Tcl recorder starts at 01/25/16 12:46:13 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:46:13 ###########


########## Tcl recorder starts at 01/25/16 12:48:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:48:26 ###########


########## Tcl recorder starts at 01/25/16 12:48:36 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:48:36 ###########


########## Tcl recorder starts at 01/25/16 12:51:46 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:51:46 ###########


########## Tcl recorder starts at 01/25/16 12:57:11 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:57:11 ###########


########## Tcl recorder starts at 01/25/16 12:57:17 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 12:57:17 ###########


########## Tcl recorder starts at 01/25/16 13:00:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:00:36 ###########


########## Tcl recorder starts at 01/25/16 13:01:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:01:33 ###########


########## Tcl recorder starts at 01/25/16 13:02:02 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:02:02 ###########


########## Tcl recorder starts at 01/25/16 13:02:44 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:02:44 ###########


########## Tcl recorder starts at 01/25/16 13:04:44 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:04:44 ###########


########## Tcl recorder starts at 01/25/16 13:04:49 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:04:49 ###########


########## Tcl recorder starts at 01/25/16 13:07:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:07:34 ###########


########## Tcl recorder starts at 01/25/16 13:07:47 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:07:47 ###########


########## Tcl recorder starts at 01/25/16 13:11:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:11:26 ###########


########## Tcl recorder starts at 01/25/16 13:11:32 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:11:32 ###########


########## Tcl recorder starts at 01/25/16 13:13:47 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:13:47 ###########


########## Tcl recorder starts at 01/25/16 13:15:51 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:15:51 ###########


########## Tcl recorder starts at 01/25/16 13:16:55 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:16:55 ###########


########## Tcl recorder starts at 01/25/16 13:25:53 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:25:53 ###########


########## Tcl recorder starts at 01/25/16 13:26:47 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:26:47 ###########


########## Tcl recorder starts at 01/25/16 13:27:15 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:27:15 ###########


########## Tcl recorder starts at 01/25/16 13:29:02 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:29:02 ###########


########## Tcl recorder starts at 01/25/16 13:30:56 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:30:56 ###########


########## Tcl recorder starts at 01/25/16 13:31:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:31:17 ###########


########## Tcl recorder starts at 01/25/16 13:31:36 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:31:36 ###########


########## Tcl recorder starts at 01/25/16 13:33:44 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:33:44 ###########


########## Tcl recorder starts at 01/25/16 13:34:27 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:34:27 ###########


########## Tcl recorder starts at 01/25/16 13:34:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:34:40 ###########


########## Tcl recorder starts at 01/25/16 13:35:27 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:35:27 ###########


########## Tcl recorder starts at 01/25/16 13:35:48 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:35:48 ###########


########## Tcl recorder starts at 01/25/16 13:35:55 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:35:55 ###########


########## Tcl recorder starts at 01/25/16 13:37:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:37:50 ###########


########## Tcl recorder starts at 01/25/16 13:38:05 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:38:05 ###########


########## Tcl recorder starts at 01/25/16 13:40:54 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:40:54 ###########


########## Tcl recorder starts at 01/25/16 13:41:12 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:41:12 ###########


########## Tcl recorder starts at 01/25/16 13:41:18 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:41:18 ###########


########## Tcl recorder starts at 01/25/16 13:46:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:46:17 ###########


########## Tcl recorder starts at 01/25/16 13:48:30 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:48:30 ###########


########## Tcl recorder starts at 01/25/16 13:48:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:48:49 ###########


########## Tcl recorder starts at 01/25/16 13:49:06 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:49:06 ###########


########## Tcl recorder starts at 01/25/16 13:49:31 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:49:31 ###########


########## Tcl recorder starts at 01/25/16 13:51:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:51:36 ###########


########## Tcl recorder starts at 01/25/16 13:53:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:53:17 ###########


########## Tcl recorder starts at 01/25/16 13:53:24 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:53:24 ###########


########## Tcl recorder starts at 01/25/16 13:56:58 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:56:58 ###########


########## Tcl recorder starts at 01/25/16 13:57:23 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 13:57:23 ###########


########## Tcl recorder starts at 01/25/16 14:00:14 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:00:14 ###########


########## Tcl recorder starts at 01/25/16 14:00:19 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:00:19 ###########


########## Tcl recorder starts at 01/25/16 14:02:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:02:26 ###########


########## Tcl recorder starts at 01/25/16 14:02:33 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:02:33 ###########


########## Tcl recorder starts at 01/25/16 14:31:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:31:33 ###########


########## Tcl recorder starts at 01/25/16 14:31:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:31:45 ###########


########## Tcl recorder starts at 01/25/16 14:31:55 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:31:55 ###########


########## Tcl recorder starts at 01/25/16 14:32:58 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:32:58 ###########


########## Tcl recorder starts at 01/25/16 14:33:02 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:33:02 ###########


########## Tcl recorder starts at 01/25/16 14:33:44 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:33:44 ###########


########## Tcl recorder starts at 01/25/16 14:33:50 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:33:50 ###########


########## Tcl recorder starts at 01/25/16 14:35:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:35:36 ###########


########## Tcl recorder starts at 01/25/16 14:37:04 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:37:04 ###########


########## Tcl recorder starts at 01/25/16 14:37:13 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:37:13 ###########


########## Tcl recorder starts at 01/25/16 14:42:03 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:42:03 ###########


########## Tcl recorder starts at 01/25/16 14:43:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:43:36 ###########


########## Tcl recorder starts at 01/25/16 14:44:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:44:34 ###########


########## Tcl recorder starts at 01/25/16 14:45:07 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:45:07 ###########


########## Tcl recorder starts at 01/25/16 14:46:45 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:46:45 ###########


########## Tcl recorder starts at 01/25/16 14:47:38 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:47:38 ###########


########## Tcl recorder starts at 01/25/16 14:50:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:50:08 ###########


########## Tcl recorder starts at 01/25/16 14:51:46 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:51:46 ###########


########## Tcl recorder starts at 01/25/16 14:52:31 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:52:31 ###########


########## Tcl recorder starts at 01/25/16 14:52:37 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:52:37 ###########


########## Tcl recorder starts at 01/25/16 14:54:15 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:54:15 ###########


########## Tcl recorder starts at 01/25/16 14:55:21 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:55:21 ###########


########## Tcl recorder starts at 01/25/16 14:55:29 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 14:55:29 ###########


########## Tcl recorder starts at 01/25/16 15:00:22 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 15:00:22 ###########


########## Tcl recorder starts at 01/25/16 15:05:12 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 15:05:12 ###########


########## Tcl recorder starts at 01/25/16 15:05:50 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 15:05:50 ###########


########## Tcl recorder starts at 01/25/16 15:07:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 15:07:36 ###########


########## Tcl recorder starts at 01/25/16 15:08:01 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 15:08:02 ###########


########## Tcl recorder starts at 01/25/16 15:09:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 15:09:08 ###########


########## Tcl recorder starts at 01/25/16 15:09:12 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 15:09:12 ###########


########## Tcl recorder starts at 01/25/16 15:18:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 15:18:49 ###########


########## Tcl recorder starts at 01/25/16 15:18:59 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 15:18:59 ###########


########## Tcl recorder starts at 01/25/16 15:19:09 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 15:19:09 ###########


########## Tcl recorder starts at 01/25/16 15:19:16 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 15:19:16 ###########


########## Tcl recorder starts at 01/25/16 15:24:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 15:24:26 ###########


########## Tcl recorder starts at 01/25/16 15:25:24 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 15:25:24 ###########


########## Tcl recorder starts at 01/25/16 15:25:33 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 15:25:33 ###########


########## Tcl recorder starts at 01/25/16 15:31:19 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 15:31:19 ###########


########## Tcl recorder starts at 01/25/16 15:31:55 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 15:31:55 ###########


########## Tcl recorder starts at 01/25/16 15:32:01 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 15:32:01 ###########


########## Tcl recorder starts at 01/25/16 15:33:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 15:33:38 ###########


########## Tcl recorder starts at 01/25/16 15:33:56 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 15:33:56 ###########


########## Tcl recorder starts at 01/25/16 15:36:06 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 15:36:06 ###########


########## Tcl recorder starts at 01/25/16 15:36:42 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 15:36:42 ###########


########## Tcl recorder starts at 01/25/16 15:38:27 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 15:38:27 ###########


########## Tcl recorder starts at 01/25/16 15:38:38 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 15:38:38 ###########


########## Tcl recorder starts at 01/25/16 17:38:14 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/16 17:38:14 ###########


########## Tcl recorder starts at 01/28/16 00:14:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" bcd2seg.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:14:45 ###########


########## Tcl recorder starts at 01/28/16 00:15:51 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" bcd2seg0_2.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:15:51 ###########


########## Tcl recorder starts at 01/28/16 00:15:59 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" bcd2seg0_2.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:15:59 ###########


########## Tcl recorder starts at 01/28/16 00:16:44 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" bcd2seg0_5.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:16:44 ###########


########## Tcl recorder starts at 01/28/16 00:16:48 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" bcd2seg0_5.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:16:48 ###########


########## Tcl recorder starts at 01/28/16 00:17:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" bcd2seg0_9.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:17:08 ###########


########## Tcl recorder starts at 01/28/16 00:17:35 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg0_2.v bcd2seg0_9.v bcd2seg0_5.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:17:35 ###########


########## Tcl recorder starts at 01/28/16 00:22:41 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:22:41 ###########


########## Tcl recorder starts at 01/28/16 00:24:21 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:24:21 ###########


########## Tcl recorder starts at 01/28/16 00:26:35 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:26:35 ###########


########## Tcl recorder starts at 01/28/16 00:26:51 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg0_2.v bcd2seg0_9.v bcd2seg0_5.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:26:51 ###########


########## Tcl recorder starts at 01/28/16 00:37:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:37:45 ###########


########## Tcl recorder starts at 01/28/16 00:38:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:38:34 ###########


########## Tcl recorder starts at 01/28/16 00:42:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:42:50 ###########


########## Tcl recorder starts at 01/28/16 00:42:57 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg0_2.v bcd2seg0_9.v bcd2seg0_5.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:42:57 ###########


########## Tcl recorder starts at 01/28/16 00:43:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:43:38 ###########


########## Tcl recorder starts at 01/28/16 00:43:44 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg0_2.v bcd2seg0_9.v bcd2seg0_5.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:43:44 ###########


########## Tcl recorder starts at 01/28/16 00:45:11 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:45:11 ###########


########## Tcl recorder starts at 01/28/16 00:46:35 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:46:35 ###########


########## Tcl recorder starts at 01/28/16 00:46:44 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg0_2.v bcd2seg0_9.v bcd2seg0_5.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:46:44 ###########


########## Tcl recorder starts at 01/28/16 00:49:56 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:49:56 ###########


########## Tcl recorder starts at 01/28/16 00:50:01 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:50:01 ###########


########## Tcl recorder starts at 01/28/16 00:51:21 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:51:21 ###########


########## Tcl recorder starts at 01/28/16 00:51:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:51:50 ###########


########## Tcl recorder starts at 01/28/16 00:52:03 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg0_2.v bcd2seg0_9.v bcd2seg0_5.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:52:03 ###########


########## Tcl recorder starts at 01/28/16 00:54:03 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:54:03 ###########


########## Tcl recorder starts at 01/28/16 00:54:13 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg0_2.v bcd2seg0_9.v bcd2seg0_5.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:54:13 ###########


########## Tcl recorder starts at 01/28/16 00:57:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:57:17 ###########


########## Tcl recorder starts at 01/28/16 00:57:28 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg0_2.v bcd2seg0_9.v bcd2seg0_5.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 00:57:28 ###########


########## Tcl recorder starts at 01/28/16 01:01:44 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 01:01:44 ###########


########## Tcl recorder starts at 01/28/16 01:01:57 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg0_2.v bcd2seg0_9.v bcd2seg0_5.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 01:01:57 ###########


########## Tcl recorder starts at 01/28/16 01:04:02 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 01:04:03 ###########


########## Tcl recorder starts at 01/28/16 01:04:12 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg0_2.v bcd2seg0_9.v bcd2seg0_5.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 01:04:12 ###########


########## Tcl recorder starts at 01/28/16 01:29:01 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 01:29:01 ###########


########## Tcl recorder starts at 01/28/16 01:29:23 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 01:29:23 ###########


########## Tcl recorder starts at 01/28/16 01:30:24 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 01:30:24 ###########


########## Tcl recorder starts at 01/28/16 01:30:44 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/28/16 01:30:44 ###########


########## Tcl recorder starts at 02/02/16 20:15:28 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/02/16 20:15:29 ###########


########## Tcl recorder starts at 02/02/16 20:15:38 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg0_2.v bcd2seg0_9.v bcd2seg0_5.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/02/16 20:15:38 ###########


########## Tcl recorder starts at 02/02/16 20:17:38 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/02/16 20:17:38 ###########


########## Tcl recorder starts at 02/02/16 20:43:04 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/02/16 20:43:04 ###########


########## Tcl recorder starts at 02/02/16 20:45:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/02/16 20:45:33 ###########


########## Tcl recorder starts at 02/02/16 20:45:41 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg0_2.v bcd2seg0_9.v bcd2seg0_5.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/02/16 20:45:41 ###########


########## Tcl recorder starts at 02/02/16 20:46:53 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/02/16 20:46:53 ###########


########## Tcl recorder starts at 02/02/16 20:46:59 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg0_2.v bcd2seg0_9.v bcd2seg0_5.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/02/16 20:46:59 ###########


########## Tcl recorder starts at 02/02/16 20:49:05 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/02/16 20:49:05 ###########


########## Tcl recorder starts at 02/02/16 20:50:47 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/02/16 20:50:47 ###########


########## Tcl recorder starts at 02/02/16 20:51:18 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/02/16 20:51:18 ###########


########## Tcl recorder starts at 02/02/16 20:51:28 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg0_2.v bcd2seg0_9.v bcd2seg0_5.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/02/16 20:51:28 ###########


########## Tcl recorder starts at 02/02/16 20:58:22 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/02/16 20:58:22 ###########


########## Tcl recorder starts at 02/02/16 20:58:29 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg0_2.v bcd2seg0_9.v bcd2seg0_5.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/02/16 20:58:29 ###########


########## Tcl recorder starts at 02/02/16 21:03:57 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/02/16 21:03:57 ###########


########## Tcl recorder starts at 02/02/16 21:32:15 ##########

# Commands to make the Process: 
# Constraint Editor
# - none -
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/02/16 21:32:15 ###########


########## Tcl recorder starts at 02/02/16 21:33:16 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/02/16 21:33:16 ###########


########## Tcl recorder starts at 02/07/16 21:18:58 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/07/16 21:18:58 ###########


########## Tcl recorder starts at 02/07/16 21:19:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/07/16 21:19:33 ###########


########## Tcl recorder starts at 02/07/16 21:19:40 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg0_2.v bcd2seg0_9.v bcd2seg0_5.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/07/16 21:19:40 ###########


########## Tcl recorder starts at 02/07/16 21:21:57 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i test01.bl5 -o test01.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src test01.bl5 -type BLIF -presrc test01.bl3 -crf test01.crf -sif test01.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_30.dev\" -lci test01.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/07/16 21:21:57 ###########


########## Tcl recorder starts at 02/18/16 09:37:23 ##########

set version "2.0"
set proj_dir "D:/FPGA_Projects/fpga_simple_clock/clock_isplvr_prj"
cd $proj_dir

# Get directory paths
set pver $version
regsub -all {\.} $pver {_} pver
set lscfile "lsc_"
append lscfile $pver ".ini"
set lsvini_dir [lindex [array get env LSC_INI_PATH] 1]
set lsvini_path [file join $lsvini_dir $lscfile]
if {[catch {set fid [open $lsvini_path]} msg]} {
	 puts "File Open Error: $lsvini_path"
	 return false
} else {set data [read $fid]; close $fid }
foreach line [split $data '\n'] { 
	set lline [string tolower $line]
	set lline [string trim $lline]
	if {[string compare $lline "\[paths\]"] == 0} { set path 1; continue}
	if {$path && [regexp {^\[} $lline]} {set path 0; break}
	if {$path && [regexp {^bin} $lline]} {set cpld_bin $line; continue}
	if {$path && [regexp {^fpgapath} $lline]} {set fpga_dir $line; continue}
	if {$path && [regexp {^fpgabinpath} $lline]} {set fpga_bin $line}}

set cpld_bin [string range $cpld_bin [expr [string first "=" $cpld_bin]+1] end]
regsub -all "\"" $cpld_bin "" cpld_bin
set cpld_bin [file join $cpld_bin]
set install_dir [string range $cpld_bin 0 [expr [string first "ispcpld" $cpld_bin]-2]]
regsub -all "\"" $install_dir "" install_dir
set install_dir [file join $install_dir]
set fpga_dir [string range $fpga_dir [expr [string first "=" $fpga_dir]+1] end]
regsub -all "\"" $fpga_dir "" fpga_dir
set fpga_dir [file join $fpga_dir]
set fpga_bin [string range $fpga_bin [expr [string first "=" $fpga_bin]+1] end]
regsub -all "\"" $fpga_bin "" fpga_bin
set fpga_bin [file join $fpga_bin]

if {[string match "*$fpga_bin;*" $env(PATH)] == 0 } {
   set env(PATH) "$fpga_bin;$env(PATH)" }

if {[string match "*$cpld_bin;*" $env(PATH)] == 0 } {
   set env(PATH) "$cpld_bin;$env(PATH)" }

lappend auto_path [file join $install_dir "ispcpld" "tcltk" "lib" "ispwidget" "runproc"]
package require runcmd

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg0_2.v bcd2seg0_9.v bcd2seg0_5.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/18/16 09:37:23 ###########


########## Tcl recorder starts at 02/18/16 09:39:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" test01.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/18/16 09:39:17 ###########


########## Tcl recorder starts at 02/18/16 09:39:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" bcd2seg0_2.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/18/16 09:39:33 ###########


########## Tcl recorder starts at 02/18/16 09:39:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" bcd2seg0_5.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/18/16 09:39:45 ###########


########## Tcl recorder starts at 02/18/16 09:39:54 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" bcd2seg0_9.v -p \"$install_dir/ispcpld/generic\" -predefine test01.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/18/16 09:39:54 ###########


########## Tcl recorder starts at 02/18/16 09:40:12 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open test01.cmd w} rspFile] {
	puts stderr "Cannot create response file test01.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: test01.sty
PROJECT: test01
WORKING_PATH: \"$proj_dir\"
MODULE: test01
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" test01.h bcd2seg0_2.v bcd2seg0_9.v bcd2seg0_5.v test01.v
OUTPUT_FILE_NAME: test01
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e test01 -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf test01.edi -out test01.bl0 -err automake.err -log test01.log -prj test01 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"test01.bl1\" -o \"test01.bl2\" -omod \"test01\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj test01 -lci test01.lct -log test01.imp -err automake.err -tti test01.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -blifopt test01.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" test01.bl2 -sweep -mergefb -err automake.err -o test01.bl3 @test01.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -diofft test01.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" test01.bl3 -family AMDMACH -idev van -o test01.bl4 -oxrf test01.xrf -err automake.err @test01.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci test01.lct -dev lc4k -prefit test01.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp test01.bl4 -out test01.bl5 -err automake.err -log test01.log -mod test01 @test01.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open test01.rs1 w} rspFile] {
	puts stderr "Cannot create response file test01.rs1: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -nojed -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open test01.rs2 w} rspFile] {
	puts stderr "Cannot create response file test01.rs2: $rspFile"
} else {
	puts $rspFile "-i test01.bl5 -lci test01.lct -d m4s_64_30 -lco test01.lco -html_rpt -fti test01.fti -fmt PLA -tto test01.tt4 -eqn test01.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@test01.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete test01.rs1
file delete test01.rs2
if [runCmd "\"$cpld_bin/tda\" -i test01.bl5 -o test01.tda -lci test01.lct -dev m4s_64_30 -family lc4k -mod test01 -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj test01 -if test01.jed -j2s -log test01.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 02/18/16 09:40:12 ###########

