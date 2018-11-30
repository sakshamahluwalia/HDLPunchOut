vlib work

vlog -timescale 1ns/1ns enemycd.v

vsim enemycd

log {/*}

add wave {/*}

force {reset_n} 0
force {clock} 0 0ns, 1 10ns
run 20ns

force {health} 2#1000
force {reset_n} 1
force {go} 0 0ns, 1 9.5ns -repeat 20ns
force {clock} 0 0ns, 1 5ns -repeat 10ns
run 100ns

force {health} 2#0001
force {go} 0 0ns, 1 9.5ns -repeat 20ns
force {clock} 0 0ns, 1 5ns -repeat 10ns
run 100ns
#
#force {health} 2#0000
#force {go} 0 0ns, 1 9.5ns -repeat 20ns
#force {clock} 0 0ns, 1 5ns -repeat 10ns
#run 100ns


