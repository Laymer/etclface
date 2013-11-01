
#
# etclface test suit.
#

package require etclface

set myname [info script]

set mynode	etclface1
set myhost	localhost
set myipaddr	127.0.0.1
set myalive	$mynode
set mynodename	"${mynode}@${myhost}"

set cookie	secretcookie
set timeout	5000 ;# milliseconds

set remnode	erlnode
set remhost	localhost
set remnodename	"erlnode@localhost"
set remipaddr	127.0.0.1
set remserver	server1

# The array all_tests will be populated with test name/description
# entries below:
array set all_tests {}

# error report for investigation by user
# args are as generated by catch
proc error_report {result options} {
	puts stderr "=== result ========"
	puts stderr $result
	puts stderr "=== Error Trace ==="
	puts stderr $options
	puts stderr "==================="
}


array set all_tests {init_1 {etclface::init without args}}
proc init_1 {} {
	if [catch { set ec [etclface::init] } result] {
		if [string match {wrong # args:*} $result] { return }
		return -code error $result
	}
	return -code error "etclface::init with no args succeeded"
}

array set all_tests {init_2 {etclface::init without cookie}}
proc init_2 {} {
	if [catch { set ec [etclface::init $::mynode] } result] {
		return -code error $result
	}
	if {![string match "ec0x*" $ec]} { return -code error $result }
	etclface::ec_free $ec
	return
}

array set all_tests {init_3 {etclface::init with cookie}}
proc init_3 {} {
	if [catch { set ec [etclface::init $::mynode $::cookie] } result] {
		return -code error $result
	}
	if {![string match "ec0x*" $ec]} { return -code error $result }
	etclface::ec_free $ec
	return
}

array set all_tests {xinit_1 {etclface::xinit without args}}
proc xinit_1 {} {
	if [catch { set ec [etclface::xinit] } result] {
		if [string match {wrong # args:*} $result] { return }
		return -code error $result
	}
	return -code error "etclface::xinit with no args succeeded"
}

array set all_tests {xinit_2 {etclface::xinit without cookie}}
proc xinit_2 {} {
	if [catch { set ec [etclface::xinit $::myhost $::myalive $::mynodename $::myipaddr] } result] {
		return -code error $result
	}
	if {![string match "ec0x*" $ec]} { return -code error $result }
	etclface::ec_free $ec
	return
}

array set all_tests {xinit_3 {etclface::xinit with cookie}}
proc xinit_3 {} {
	if [catch { set ec [etclface::xinit $::myhost $::myalive $::mynodename $::myipaddr $::cookie] } result] {
		return -code error $result
	}
	if {![string match "ec0x*" $ec]} { return -code error $result }
	etclface::ec_free $ec
	return
}

array set all_tests {connect_1 {etclface::connect without arguments}}
proc connect_1 {} {
	if [catch { etclface::connect } result] {
		if [string match {wrong # args:*} $result] { return }
		return -code error $result
	}
	return -code error "etclface::connect with no args succeeded"
}

array set all_tests {connect_2 {etclface::connect with no timeout}}
proc connect_2 {} {
	if [catch {	set ec [etclface::init $::mynode $::cookie]
			set fd [etclface::connect $ec $::remnodename]
			} result] {
		if [info exists ec ] {etclface::ec_free $ec}
		if [info exists fd ] {etclface::disconnect $fd}
		return -code error $result
	}
	if {![string is integer $fd]} { return -code error "etclface::connect did not return an integer ($fd)" }
	etclface::ec_free $ec
	etclface::disconnect $fd
	return
}

array set all_tests {connect_3 {etclface::connect with timeout}}
proc connect_3 {} {
	if [catch {	set ec [etclface::init $::mynode $::cookie]
			set fd [etclface::connect $ec $::remnodename $::timeout]
			} result] {
		if [info exists ec ] {etclface::ec_free $ec}
		if [info exists fd ] {etclface::disconnect $fd}
		return -code error $result
	}
	if {![string is integer $fd]} { return -code error "etclface::connect did not return an integer ($fd)" }
	etclface::ec_free $ec
	etclface::disconnect $fd
	return
}

array set all_tests {connect_4 {etclface::connect with invalid timeout}}
proc connect_4 {} {
	if [catch {	set ec [etclface::init $::mynode $::cookie]
			set fd [etclface::connect $ec $::remnodename not_a_timeout]
			} result] {
		if {[info exists ec]} { etclface::ec_free $ec }
		if [string match {expected integer but got *} $result] { return }
		return -code error $result
	}
	if [info exists ec ] {etclface::ec_free $ec}
	if [info exists fd ] {etclface::disconnect $fd}
	return -code error "etclface::connect with invalid timeout succeeded"
}

array set all_tests {xconnect_1 {etclface::xconnect without arguments}}
proc xconnect_1 {} {
	if [catch { etclface::xconnect } result] {
		if [string match {wrong # args:*} $result] { return }
		return -code error $result
	}
	return -code error "etclface::xconnect with no args succeeded"
}

array set all_tests {xconnect_2 {etclface::xconnect with no timeout}}
proc xconnect_2 {} {
	if [catch {	set ec [etclface::init $::mynode $::cookie]
			set fd [etclface::xconnect $ec $::remipaddr $::remnode]
			} result] {
		if [info exists ec] {etclface::ec_free $ec}
		if [info exists fd] {etclface::disconnect $fd}
		return -code error $result
	}
	etclface::ec_free $ec
	etclface::disconnect $fd
	if {![string is integer $fd]} {
		return -code error "etclface::xconnect did not return an integer ($fd)"
	}
	return
}

array set all_tests {xconnect_3 {etclface::xconnect with timeout}}
proc xconnect_3 {} {
	if [catch {	set ec [etclface::init $::mynode $::cookie]
			set fd [etclface::xconnect $ec $::remipaddr $::remnode $::timeout]
			} result] {
		if [info exists ec] {etclface::ec_free $ec}
		if [info exists fd] {etclface::disconnect $fd}
		return -code error $result
	}
	if {![string is integer $fd]} { return -code error "etclface::xconnect did not return an integer ($fd)" }
	etclface::ec_free $ec
	etclface::disconnect $fd
	return
}

array set all_tests {xconnect_4 {etclface::xconnect with invalid timeout}}
proc xconnect_4 {} {
	if [catch {	set ec [etclface::init $::mynode $::cookie]
			set fd [etclface::xconnect $ec $::remipaddr $::remnode not_a_timeout]
			} result] {
		if [info exists ec] {etclface::ec_free $ec}
		if [info exists fd] {etclface::disconnect $fd}
		if [string match {expected integer but got *} $result] { return }
		return -code error $result
	}
	etclface::ec_free $ec
	etclface::disconnect $fd
	return -code error "etclface::xconnect with invalid timeout succeeded"
}

array set all_tests {xbuff_1 {etclface::xb_new with bad arguments}}
proc xbuff_1 {} {
	if [catch { etclface::xb_new a_bad_argument } result ] {
		if [string match {ETCLFACE ERROR Only -withversion*} $result] { return }
		return -code error $result
	}
	return -code error "etclface:xb_new with bad arguments succeeded!"
}

array set all_tests {xbuff_2 {etclface::xb_new no version}}
proc xbuff_2 {} {
	if [catch { set xb [etclface::xb_new] }] {
		return -code error $result
	}
	etclface::xb_free $xb
	return
}

array set all_tests {xbuff_3 {etclface::xb_new with version}}
proc xbuff_3 {} {
	if [catch { set xb [etclface::xb_new -withversion] } result] {
		return -code error $result
	}
	etclface::xb_free $xb
	return
}

array set all_tests {xbuff_4 {etclface::xb_show with bad argument}}
proc xbuff_4 {} {
	if [catch {etclface::xb_show a_bad_argument} result] {
		if [string match {ETCLFACE ERROR Invalid xb handle} $result] { return }
		return -code error $result
	}
	return -code error "etclface:xb_show with bad argument succeeded!"
}

array set all_tests {xbuff_5 {etclface::xb_show with good argument}}
proc xbuff_5 {} {
	if [catch {	set xb [etclface::xb_new]
			etclface::xb_show $xb
			} result] {
		if [info exists xb] {etclface::xb_free $xb}
		return -code error $result
	}
	etclface::xb_free $xb
	if {![string match {buff * buffsz * index *} $result]} {
		return -code error "etclface::xb_show returned >$result<"
	}
	return
}

array set all_tests {xbuff_6 {etclface::xb_free with bad argument}}
proc xbuff_6 {} {
	if [catch {etclface::xb_free a_bad_argument} result] {
		if [string match {ETCLFACE ERROR Invalid xb handle} $result] { return }
		return -code error $result
	}
	return -code error "etclface::xb_free with bad argument succeeded!"
}

array set all_tests {xbuff_7 {etclface::xb_free with good argument}}
proc xbuff_7 {} {
	if [catch {	set xb [etclface::xb_new]
			etclface::xb_free $xb
			} result] {
		return -code error $result
	}
	return
}

array set all_tests {reg_send_1 {reg_send with wrong arguments}}
proc reg_send_1 {} {
	if [catch { etclface::reg_send } result] {
		if [string match {wrong # args*} $result] { return }
		return -code error $result
	}
	return -code error "etclface::reg_send with no argument succeeded!"
}

array set all_tests {reg_send_2 {reg_send without timeout}}
proc reg_send_2 {} {
	if [catch {	set ec [etclface::init $::mynode $::cookie]
			set fd [etclface::connect $ec $::remnodename]
			set xb [etclface::xb_new -withversion]
			etclface::encode_string $xb "Hello, World!"
			etclface::reg_send $ec $fd $::remserver $xb
			} result] {
		if [info exists ec] { etclface::ec_free $ec }
		if [info exists fd] { etclface::disconnect $fd }
		if [info exists xb] { etclface::xb_free $xb }
		return -code error $result
	}
	etclface::ec_free $ec
	etclface::disconnect $fd
	etclface::xb_free $xb
	return
}

array set all_tests {reg_send_3 {reg_send with timeout}}
proc reg_send_3 {} {
	if [catch {	set ec [etclface::init $::mynode $::cookie]
			set fd [etclface::connect $ec $::remnodename]
			set xb [etclface::xb_new -withversion]
			etclface::encode_string $xb "Hello, World!"
			etclface::reg_send $ec $fd $::remserver $xb $::timeout
			} result] {
		if [info exists ec] { etclface::ec_free $ec }
		if [info exists fd] { etclface::disconnect $fd }
		if [info exists xb] { etclface::xb_free $xb }
		return -code error $result
	}
	etclface::ec_free $ec
	etclface::disconnect $fd
	etclface::xb_free $xb
	return
}

array set all_tests {encode_atom_1 {encode atom with wrong arguments}}
proc encode_atom_1 {} {
	if [catch {etclface::encode_atom} result] {
		if [string match {wrong # args*} $result] { return }
		return -code error $result
	}
	return -code error "etclface::encode_atom with no args succeeded!"
}

array set all_tests {encode_atom_2 {encode atom with bad arguments}}
proc encode_atom_2 {} {
	if [catch {etclface::encode_atom bad_xb hello} result] {
		if [string match {ETCLFACE ERROR Invalid xb handle*} $result] { return }
		return -code error $result
	}
	return -code error "etclface::encode_atom with bad args succeeded!"
}

array set all_tests {encode_atom_3 {encode atom success}}
proc encode_atom_3 {} {
	if [catch {	set xb [etclface::xb_new]
			etclface::encode_atom $xb hello
			} result] {
		return -code error $result
	}
	etclface::xb_free $xb
	return
}

array set all_tests {encode_boolean_1 {encode boolean with wrong arguments}}
proc encode_boolean_1 {} {
	if [catch {etclface::encode_boolean} result] {
		if [string match {wrong # args*} $result] { return }
		return -code error $result
	}
	return -code error "etclface::encode_boolean with no args succeeded!"
}

array set all_tests {encode_boolean_2 {encode boolean with bad arguments}}
proc encode_boolean_2 {} {
	if [catch {	set xb [etclface::xb_new]
			etclface::encode_boolean $xb positive
			} result] {
		if [string match {expected boolean*} $result] { return }
		return -code error $result
	}
	return -code error "etclface::encode_boolean with bad args succeeded!"
}

array set all_tests {encode_boolean_3 {encode boolean with good arguments}}
proc encode_boolean_3 {} {
	if [catch {	set xb [etclface::xb_new]
			etclface::encode_boolean $xb true
			} result] {
		return -code error $result
	}
	etclface::xb_free $xb
	return
}

array set all_tests {encode_char_1 {encode char with wrongs arguments}}
proc encode_char_1 {} {
	if [catch {etclface::encode_char} result] {
		if [string match {wrong # args*} $result] { return }
		return -code error $result
	}
	return -code error "etclface::encode_char with no args succeeded!"
}

array set all_tests {encode_char_2 {encode char with bad arguments}}
proc encode_char_2 {} {
	if [catch {	set xb [etclface::xb_new]
			etclface::encode_char $xb -200
			} result] {
		if [string match {ETCLFACE ERROR char must be a number *} $result] { return }
		return -code error $result
	}
	return -code error "etclface::encode_char with bad args succeeded!"
}

array set all_tests {encode_char_3 {encode char with good args}}
proc encode_char_3 {} {
	if [catch {	set xb [etclface::xb_new]
			etclface::encode_char $xb [scan {Z} {%c}]
			} result] {
		if [info exists xb] {etclface::xb_free $xb}
		return -code error $result
	}
	etclface::xb_free $xb
	return
}

array set all_tests {encode_double_1 {encode double with wrong arguments}}
proc encode_double_1 {} {
	if [catch {etclface::encode_double} result] {
		if [string match {wrong # args*} $result] { return }
		return -code error $result
	}
	return -code error "etclface::encode_double with no args succeeded!"
}

array set all_tests {encode_double_2 {encode double with bad number}}
proc encode_double_2 {} {
	if [catch {	set xb [etclface::xb_new]
			etclface::encode_double $xb bad_number
			} result] {
		if [string match {expected floating-point*} $result] { return }
		if [info exists xb] {etclface::xb_free $xb}
		return -code error $result
	}
	if [info exists xb] {etclface::xb_free $xb}
	return -code error "etclface::encode_double with bad number succeeded!"
}

array set all_tests {encode_double_3 {encode double with good number}}
proc encode_double_3 {} {
	if [catch {	set xb [etclface::xb_new]
			etclface::encode_double $xb 3.1415
			} result] {
		if [info exists xb] {etclface::xb_free $xb}
		return -code error $result
	}
	etclface::xb_free $xb
	return
}

array set all_tests {encode_long_1 {encode long with wrong arguments}}
proc encode_long_1 {} {
	if [catch {etclface::encode_long} result] {
		if [string match {wrong # args*} $result] { return }
		return -code error $result
	}
	return -code error "etclface::encode_long with no args succeeded!"
}

array set all_tests {encode_long_2 {encode long with bad number}}
proc encode_long_2 {} {
	if [catch {	set xb [etclface::xb_new]
			etclface::encode_long $xb not_a_number
			} result] {
		if [info exists xb] {etclface::xb_free $xb}
		if [string match {expected integer *} $result] { return }
		return -code error $result
	}
	etclface::xb_free $xb
	return -code error "etclface::encode_long with bad args succeeded!"
}

array set all_tests {encode_long_3 {encode long with good number}}
proc encode_long_3 {} {
	if [catch {	set xb [etclface::xb_new]
			etclface::encode_long $xb 42
			} result] {
		if [info exists xb] {etclface::xb_free $xb}
		return -code error $result
	}
	etclface::xb_free $xb
	return
}

array set all_tests {encode_string_1 {encode string with wrong arguments}}
proc encode_string_1 {} {
	if [catch {etclface::encode_string} result] {
		if [string match {wrong # args*} $result] { return }
		return -code error $result
	}
	return -code error "etclface::encode_string with no args succeeded!"
}

array set all_tests {encode_string_2 {encode string with good arguments}}
proc encode_string_2 {} {
	if [catch {	set xb [etclface::xb_new]
			etclface::encode_string $xb {how long is a piece of string?}
			} result] {
		if [info exists xb] {etclface::xb_free $xb}
		return -code error $result
	}
	etclface::xb_free $xb
	return
}

array set all_tests {encode_list_1 {encode list with wrong arguments}}
proc encode_list_1 {} {
	if [catch {etclface::encode_list_header} result] {
		if [string match {wrong # args*} $result] { return }
		return -code error $result
	}
	return -code error "etclface::encode_list_header with no args succeeded!"
}

array set all_tests {encode_list_2 {encode list with bad arity}}
proc encode_list_2 {} {
	if [catch {	set xb [etclface::xb_new]
			etclface::encode_list_header $xb -1
			} result] {
		if [info exists xb] {etclface::xb_free $xb}
		if [string match {ETCLFACE ERROR arity cannot be*} $result] { return }
		return -code error $result
	}
	return -code error "etclface::encode_list_header with bad args succeeded!"
}

array set all_tests {encode_list_3 {encode list with good arguments}}
proc encode_list_3 {} {
	if [catch {	set xb [etclface::xb_new]
			etclface::encode_list_header $xb 2
			} result] {
		if [info exists xb] {etclface::xb_free $xb}
		return -code error $result
	}
	etclface::xb_free $xb
	return
}

array set all_tests {encode_empty_list_1 {encode empty list with wrong arguments}}
proc encode_empty_list_1 {} {
	if [catch {etclface::encode_empty_list} result] {
		if [string match {wrong # args*} $result] { return }
		return -code error $result
	}
	return -code error "etclface::encode_empty_list with no args succeeded!"
}

array set all_tests {encode_empty_list_2 {encode empty list with good arguments}}
proc encode_empty_list_2 {} {
	if [catch {	set xb [etclface::xb_new]
			etclface::encode_empty_list $xb
			} result] {
		if [info exists xb] {etclface::xb_free $xb}
		return -code error $result
	}
	etclface::xb_free $xb
	return
}

array set all_tests {encode_tuple_1 {encode tuple with wrong arguments}}
proc encode_tuple_1 {} {
	if [catch {etclface::encode_tuple_header} result] {
		if [string match {wrong # args*} $result] { return }
		return -code error $result
	}
	return -code error "etclface::encode_tuple_header with no args succeeded!"
}

array set all_tests {encode_tuple_2 {encode tuple with bad arguments}}
proc encode_tuple_2 {} {
	if [catch {	set xb [etclface::xb_new]
			etclface::encode_tuple_header $xb -1
			} result] {
		if [info exists xb] {etclface::xb_free $xb}
		if [string match {ETCLFACE ERROR arity cannot be*} $result] { return }
		return -code error $result
	}
	if [info exists xb] {etclface::xb_free $xb}
	return -code error "etclface::encode_tuple_header with bad args succeeded!"
}

array set all_tests {encode_tuple_3 {encode tuple with good arguments}}
proc encode_tuple_3 {} {
	if [catch {	set xb [etclface::xb_new]
			etclface::encode_tuple_header $xb 2
			} result] {
		if [info exists xb] {etclface::xb_free $xb}
		return -code error $result
	}
	etclface::xb_free $xb
	return
}

array set all_tests {encode_pid_1 {encode pid with wrong arguments}}
proc encode_pid_1 {} {
	if [catch {etclface::encode_pid} result] {
		if [string match {wrong # args*} $result] { return }
		return -code error $result
	}
	return -code error "etclface::encode_pid with no args succeeded!"
}

array set all_tests {encode_pid_2 {encode pid with bad arguments}}
proc encode_pid_2 {} {
	if [catch {	set xb [etclface::xb_new]
			etclface::encode_pid $xb not_a_pid
			} result] {
		if [info exists xb] {etclface::xb_free $xb}
		if [string match {ETCLFACE ERROR Invalid pid handle*} $result] { return }
		return -code error $result
	}
	etclface::xb_free $xb
	return -code error "etclface::encode_pid with bad args succeeded!"
}

array set all_tests {encode_pid_3 {encode pid with good arguments}}
proc encode_pid_3 {} {
	if [catch {	set ec [etclface::init $::mynode]
			set xb [etclface::xb_new]
			etclface::encode_pid $xb [etclface::self $ec]
			} result] {
		if [info exists ec] {etclface::ec_free $ec}
		if [info exists xb] {etclface::xb_free $xb}
		return -code error $result
	}
	etclface::ec_free $ec
	etclface::xb_free $xb
	return
}

array set all_tests {decode_long_1 {decode long with no arguments}}
proc decode_long_1 {} {
	if [catch {etclface::decode_long} result] {
		if [string match {wrong # args*} $result] { return }
		return -code error $result
	}
	return -code error "etclface::decode_long with no args succeeded!"
}

array set all_tests {decode_long_2 {decode long with bad arguments}}
proc decode_long_2 {} {
	if [catch {	set xb [etclface::xb_new -withversion]
			etclface::xb_reset $xb
			etclface::decode_long $xb
			} result] {
		if [string match {ETCLFACE ERROR ei_decode_long failed*} $result] { return }
		if [info exists xb] {etclface::xb_free $xb}
		return -code error $result
	}
	etclface::xb_free $xb
	return -code error "etclface::decode_long with bad args succeeded!"
}

array set all_tests {decode_long_3 {decode long with good arguments}}
proc decode_long_3 {} {
	set long_before 42
	if [catch {	set xb [etclface::xb_new]
			etclface::encode_long $xb $long_before
			etclface::xb_reset $xb
			set long_after [etclface::decode_long $xb]
			} result] {
		if [info exists xb] {etclface::xb_free $xb}
		return -code error $result
	}
	etclface::xb_free $xb
	if {$long_before != $long_after} {
		return -code error "etclface::decode_long returned $long_after, expected $long_before"
	}
	return
}

array set all_tests {decode_atom_1 {decode atom with no arguments}}
proc decode_atom_1 {} {
	if [catch {etclface::decode_atom} result] {
		if [string match {wrong # args*} $result] { return }
		return -code error $result
	}
	return -code error "etclface::decode_atom with no args succeeded!"
}

array set all_tests {decode_atom_2 {decode atom with bad arguments}}
proc decode_atom_2 {} {
	if [catch {	set xb [etclface::xb_new -withversion]
			etclface::xb_reset $xb
			etclface::decode_atom $xb
			} result] {
		if [string match {ETCLFACE ERROR ei_decode_atom failed*} $result] { return }
		if [info exists xb] {etclface::xb_free $xb}
		return -code error $result
	}
	etclface::xb_free $xb
	return -code error "etclface::decode_atom with bad args succeeded!"
}

array set all_tests {decode_atom_3 {decode atom with good arguments}}
proc decode_atom_3 {} {
	set atom_before hello
	if [catch {	set xb [etclface::xb_new]
			etclface::encode_atom $xb $atom_before
			etclface::xb_reset $xb
			set atom_after [etclface::decode_atom $xb]
			} result] {
		if [info exists xb] {etclface::xb_free $xb}
		return -code error $result
	}
	etclface::xb_free $xb
	if {$atom_before != $atom_after} {
		return -code error "etclface::decode_atom returned $atom_after, expected $atom_before"
	}
	return
}

array set all_tests {pid_show_1 {pid_show with no arguments}}
proc pid_show_1 {} {
	if [catch { etclface::pid_show } result ] {
		if [string match {wrong # args*} $result] { return }
		return -code error $result
	}
	return -code error "etclface::pid_show without args succeeded!"
}

array set all_tests {pid_show_2 {pid_show with bad arguments}}
proc pid_show_2 {} {
	if [catch { etclface::pid_show not_a_pid } result ] {
		if [string match {ETCLFACE ERROR Invalid pid handle} $result] { return }
		return -code error $result
	}
	return -code error "etclface::pid_show with bad pid succeeded!"
}

array set all_tests {pid_show_3 {pid_show with good arguments}}
proc pid_show_3 {} {
	if [catch {	set ec [etclface::init $::mynode]
			etclface::pid_show [etclface::self $ec]
			} result ] {
		if [info exists ec] {etclface::ec_free $ec}
		return -code error $result
	}
	etclface::ec_free $ec
	set pidkeys {creation node num serial}
	set reskeys [lsort [dict keys $result]]
	if {![string match $pidkeys $reskeys]} {
		return -code error "unexpected pid dict: $result"
	}
	return
}

array set all_tests {ec_show_1 {ec_show with no arguments}}
proc ec_show_1 {} {
	if [catch { etclface::ec_show } result ] {
		if [string match {wrong # args*} $result] { return }
		return -code error $result
	}
	return -code error "etclface::ec_show without args succeeded!"
}

array set all_tests {ec_show_2 {ec_show with bad arguments}}
proc ec_show_2 {} {
	if [catch { etclface::ec_show a_bad_ec } result ] {
		if [string match {ETCLFACE ERROR Invalid ec handle} $result] { return }
		return -code error $result
	}
	return -code error "etclface::ec_show with bad ec succeeded!"
}

array set all_tests {ec_show_3 {ec_show with good arguments}}
proc ec_show_3 {} {
	if [catch {	set ec [etclface::init $::mynode]
			etclface::ec_show $ec
			} result ] {
		if [info exists ec] {etclface::ec_free $ec}
		return -code error $result
	}
	etclface::ec_free $ec
	set eckeys  {alivename cookie creation hostname nodename self}
	set reskeys [lsort [dict keys $result]]
	if {![string match $eckeys $reskeys]} {
		return -code error "unexpected ec dict: $result"
	}
	return
}

