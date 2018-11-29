vlib work

vlog -timescale 1ns/1ns user_control.v

vsim user_control

log {/*}

add wave {/*}

force {reset_n} 0
force {clock} 0 0ns, 1 10ns
run 20ns

force {health} 2#1000
force {reset_n} 1
force {block} 0 0ns, 1 10ns -repeat 20ns
force {clock} 0 0ns, 1 5ns -repeat 10ns
run 100ns

force {health} 2#0001
force {reset_n} 1
force {r} 0 0ns, 1 10ns -repeat 20ns
force {clock} 0 0ns, 1 5ns -repeat 10ns
run 100ns

force {health} 2#0000
force {reset_n} 1
force {block} 0 0ns, 1 10ns -repeat 20ns
force {clock} 0 0ns, 1 5ns -repeat 10ns
run 100ns




