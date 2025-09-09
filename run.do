vlog arbiter/RTL/arbiter.sv

# vlog arbiter/TB/tb_arbiter_self_checking.sv
# vsim tb_arbiter_basic
# run -all

# vlog arbiter/TB/tb_arbiter_prog.sv
# vsim tb_arbiter_prog
# run -all

# vlog arbiter/TB/arbiter_tb_if.sv
# vsim tb_arbiter_if
# run -all

# vlog arbiter/TB/arbiter_tb_modport1.sv
# vsim tb_arbiter_modport1
# run -all

vlog arbiter/TB/arbiter_tb_modport2.sv
vsim tb_arbiter_modport2
run -all

quit