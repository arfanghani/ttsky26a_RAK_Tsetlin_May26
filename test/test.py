import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles

@cocotb.test()
async def retina_tm_test(dut):

    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1

    # -------------------------
    # LOAD FEATURES (8 cycles)
    # -------------------------
    for i in range(8):
        bit = 1 if i % 2 == 0 else 0
        dut.ui_in.value = (bit) | (1 << 1)
        await RisingEdge(dut.clk)

    # stop loading
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 3)

    # -------------------------
    # INFERENCE TRIGGER
    # -------------------------
    dut.ui_in.value = (1 << 2)
    await ClockCycles(dut.clk, 3)

    # read output
    result = dut.uo_out.value.integer

    class_out = result & 0b11
    loaded = (result >> 3) & 1

    dut._log.info(f"class={class_out}, loaded={loaded}")

    assert loaded == 1
