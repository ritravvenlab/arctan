onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group std_inputs /encoder_tb/period
add wave -noupdate -expand -group std_inputs /encoder_tb/clk
add wave -noupdate -expand -group std_inputs /encoder_tb/reset_n
add wave -noupdate -expand -group {file i/o} /encoder_tb/clr_std_logic
add wave -noupdate -expand -group {file i/o} /encoder_tb/encoder_in_std_logic
add wave -noupdate -expand -group {encoder i/o} /encoder_tb/encoder_in
add wave -noupdate -expand -group {encoder i/o} /encoder_tb/clr
add wave -noupdate -expand -group {encoder i/o} -radix unsigned /encoder_tb/count_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {650 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 154
configure wave -valuecolwidth 58
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {1169 ns}
