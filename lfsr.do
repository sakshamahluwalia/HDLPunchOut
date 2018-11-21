vlib work

vlog -timescale 1ns/1ns lfsr.v

vsim lfsr

log {/*}

add wave {/*}

force {reset_n} 0
force {clock} 0 0ns, 1 10ns
run 20ns

force {reset_n} 1
force {enable} 0 
force {counter_val} 2#01110010
force {clock} 0 0ns, 1 10ns -repeat 20ns
run 80ns

force {reset_n} 1
force {enable} 1 
force {counter_val} 2#00110100
force {clock} 0 0ns, 1 10ns -repeat 20ns
run 160ns