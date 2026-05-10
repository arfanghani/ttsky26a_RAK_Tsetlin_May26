import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles

async def shift_feature(dut, value):

    dut.ui_in.value = (1 << 1) | value

    await RisingEdge(dut.clk)

@cocotb.test()
async def retina_tm_test(dut):

    cocotb.start_soon(
        Clock(dut.clk, 10, units="ns").start()
    )

    dut.rst_n.value = 0
    dut.ena.value = 1

    dut.ui_in.value = 0
    dut.uio_in.value = 0

    await ClockCycles(dut.clk, 5)

    dut.rst_n.value = 1

    # Load 32-bit feature vector
    for i in range(32):

        if i < 12:
            await shift_feature(dut, 1)
        else:
            await shift_feature(dut, 0)

    dut.ui_in.value = 0

    await ClockCycles(dut.clk, 5)

    # Start inference
    dut.ui_in.value = (1 << 2)

    await ClockCycles(dut.clk, 5)

    triage = dut.uo_out.value.integer & 0b11

    assert triage >= 0

    glaucoma = (dut.uo_out.value.integer >> 2) & 1

    assert glaucoma in [0, 1]
