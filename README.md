# VLSI Task 2 – Sequential RTL Design, Counters, FSMs

Sumerix Global – VLSI Design and Semiconductor Engineering Internship.
Author: T R Jyothirmay Dikshith (GitHub: JYOTHIRMAYD)

Synthesizable Verilog-2001 modules with self-checking testbenches for
flip-flops, registers, shift registers, counters, parameterized modules,
Moore/Mealy FSMs and a configurable digital stopwatch.

## Folder structure
```
rtl/     synthesizable Verilog sources
tb/      self-checking testbenches (each prints RESULT: PASS / FAIL)
sim/     VCD waveforms + logs (generated)
docs/    FSM diagrams, timing notes, progress log, screenshots/
run_all.sh   compile + run every testbench
```

## Module map
| Part / Exercise | RTL file | Testbench |
|---|---|---|
| A / Ex1 D flip-flop (sync + async reset) | `d_flip_flop.v` | `tb_d_flip_flop.v` |
| A / Ex1 8-bit register | `register8.v`, `register_n.v` | `tb_register.v` |
| A / Ex1 shift register (SISO/SIPO) | `shift_register_n.v` | `tb_shift_register.v` |
| B / Ex2 up, down, mod-10, ring, Johnson | `up_counter4.v` `down_counter4.v` `mod10_counter.v` `ring_counter4.v` `johnson_counter4.v` | `tb_counters.v` |
| C / Ex3 N-bit register, counter, shift reg | `register_n.v` `counter_n.v` `shift_register_n.v` | `tb_param.v` (N = 3,4,8,16) |
| D / Ex4 Moore + Mealy traffic light | `traffic_light_moore.v` `traffic_light_mealy.v` | `tb_traffic_moore.v` `tb_traffic_mealy.v` |
| E / Ex5 setup/hold timing | – (behavioral model in tb) | `tb_timing_demo.v` |
| F / Ex6 reusable testbenches | clock gen, reset, multiple patterns in every tb | all |
| H Mini project: Moore FSM traffic light | `traffic_light_moore.v` | `tb_traffic_moore.v` |
| Ex7 Stopwatch controller | `stopwatch_controller.v` | `tb_stopwatch.v` |

## Run
Ubuntu / WSL with Icarus Verilog and GTKWave installed:
```
./run_all.sh                    # all testbenches
./run_all.sh tb_counters        # one testbench
gtkwave sim/tb_counters.vcd     # view waveform
```

## Design notes
- Non-blocking (`<=`) in all sequential blocks, blocking (`=`) in combinational ones.
- `ASYNC_RESET` parameter selects async (`posedge clk or posedge reset`) or sync reset.
- Traffic light: `{red, yellow, green}` encoding, `GREEN_T` / `YELLOW_T` parameters (clock cycles).
- Moore vs Mealy: outputs of the Moore version change only after a clock edge;
  the Mealy version adds an `emergency` input and turns both lights red in the same
  cycle, with no clock edge (see `tb_traffic_mealy` waveform).
- Stopwatch: `CLK_PER_TICK` sets cycles per second (50_000_000 for a 50 MHz clock).

See `docs/FSM_and_timing.md` for diagrams, truth tables and timing explanation.
