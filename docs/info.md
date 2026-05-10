<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements an explainable hardware AI inference engine for
retinal disease triage and glaucoma referral support using a
Tsetlin-inspired Boolean inference architecture.

The ASIC is designed for:
- edge AI inference
- low-resource healthcare systems
- explainable machine learning
- retinal disease screening
- glaucoma referral support

The design operates using compressed binary feature vectors extracted
from retinal images in software.

Example software-generated features include:
- lesion indicators
- vessel density metrics
- optic cup ratio abnormalities
- hemorrhage detection
- brightness abnormalities
- structural asymmetry indicators

These binary features are serially shifted into the ASIC using the
Tiny Tapeout GPIO interface.

Internally, the chip contains:
- a 32-bit feature register
- multiple Boolean clause engines
- vote accumulation logic
- confidence estimation logic
- retinal triage classification logic
- glaucoma detection logic

The clause engines evaluate combinations of features using AND/NOT
Boolean logic similar to Tsetlin Machine inference.

Example clause:

```text
(FEATURE_0 AND FEATURE_2 AND NOT FEATURE_5)
```

Each clause contributes votes toward a final classification decision.

The hardware generates:
- retinal triage classification
- glaucoma detection flag
- confidence indication
- clause activation debug outputs

Triage outputs:
- `00` = NORMAL
- `01` = REFER
- `10` = URGENT

The project demonstrates how explainable symbolic AI inference can be
implemented efficiently in ASIC hardware for medical edge computing.

## How to test

### Inputs

| Pin | Function |
|---|---|
| ui[0] | Serial feature input |
| ui[1] | Feature load enable |
| ui[2] | Inference start |

### Outputs

| Pin | Function |
|---|---|
| uo[1:0] | Triage classification |
| uo[2] | Glaucoma detection |
| uo[4:3] | Confidence indicator |
| uo[5] | Clause active flag |
| uo[7] | Features loaded |

### Test Procedure

1. Apply reset (`rst_n = 0`)
2. Release reset (`rst_n = 1`)
3. Shift a 32-bit binary feature vector serially into `ui[0]`
4. Assert `ui[1]` during shifting
5. After all 32 bits are loaded, deassert `ui[1]`
6. Assert `ui[2]` to start inference
7. Observe classification outputs on `uo_out`

Example:
- low feature activity should produce `NORMAL`
- moderate clause activation should produce `REFER`
- strong positive clause voting should produce `URGENT`

Clause activations can be monitored through:
- `uio[7:0]`

Simulation can be executed using:

```sh
make -B
```

Gate-level simulation:

```sh
make -B GATES=yes
```

Waveform viewing:

```sh
gtkwave tb.vcd
```

---


## External hardware

This project does not require external hardware to function.

Optional demonstration hardware:
- RP2040 or ESP32 microcontroller
- UART-to-USB bridge
- LEDs for output visualization
- OLED display for classification display
- retinal image acquisition system
- mobile application frontend

Example demonstration flow:

Retinal camera
→ Feature extraction software
→ Tiny Tapeout ASIC inference
→ Hardware triage output
