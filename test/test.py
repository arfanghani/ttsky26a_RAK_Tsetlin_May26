import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles

@cocotb.test()
async def retina_tm_test(dut):

    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.ui_in.value = 0

    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1

    # -------------------------
    # LOAD 8 BITS
    # -------------------------
    for i in range(8):
        dut.ui_in.value = 0b00000001  # load_en=1, bit_in=0/1 ignored safely
        await RisingEdge(dut.clk)

    dut.ui_in.value = 0

    await ClockCycles(dut.clk, 3)

    # -------------------------
    # INFER
    # -------------------------
    dut.ui_in.value = 0b00000100  # infer_req

    await ClockCycles(dut.clk, 3)

    result = dut.uo_out.value.integer
    class_out = result & 0b11

    assert class_out in [0, 1, 2]
