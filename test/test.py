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

    # Initialize
    dut.rst_n.value = 0
    dut.ena.value = 1

    dut.ui_in.value = 0
    dut.uio_in.value = 0

    await ClockCycles(dut.clk, 5)

    # Release reset
    dut.rst_n.value = 1

    await ClockCycles(dut.clk, 2)

    # Load feature vector
    for i in range(32):

        if i < 12:
            await shift_feature(dut, 1)
        else:
            await shift_feature(dut, 0)

    # Stop loading
    dut.ui_in.value = 0

    await ClockCycles(dut.clk, 5)

    # Start inference
    dut.ui_in.value = (1 << 2)

    await ClockCycles(dut.clk, 2)

    triage = dut.uo_out.value.integer & 0b11
    glaucoma = (dut.uo_out.value.integer >> 2) & 1

    cocotb.log.info(f"Triage={triage}")
    cocotb.log.info(f"Glaucoma={glaucoma}")

    assert glaucoma in [0, 1]

    await ClockCycles(dut.clk, 5)
