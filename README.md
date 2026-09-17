# Flex Radio Mechanical Button Actuator (Linear Stepper Version)

A stepper-driven mechanism that physically presses the front-panel power button on a FlexRadio Flex 6xxx or 8xxx series software-defined radio (SDR), allowing it to be powered on, powered off, or force-reset (long hold) remotely from a Raspberry Pi.

This version replaces the original rotating servo-driven arm concept with a **28BYJ-48 stepper motor** paired with a linear rack-and-pinion finger, delivering high precision, smooth linear movement, and eliminating positional jitter.

---

## 📟 How the Radio's Button Behaves

The radio's front button behaves based on duration and state:

| Action | Result |
|---|---|
| Momentary press while off | Radio powers on |
| Momentary press while on | Radio powers off |
| Press and hold (while off) until the button glows white (~6.0s), then release | System factory reset |

The driver software handles two routines: a **momentary press** (power toggle) and a **long hold-then-release** (system reset). Both actions are "move finger onto button, dwell, move finger back," with the wait time being the only operational difference.

---

## 🏗️ Hardware & Wiring

### Parts List
- **Controller:** Raspberry Pi 4B (installed natively in `/home/pi`)
- **Motor Assembly:** 28BYJ-48 stepper motor + ULN2003 driver board
- **Enclosure & Mechanism:** 3D printed linear rack, pinion gear, and custom case (printed in PETG)
- **Fasteners:** M3 hardware for mounting the brackets near the radio panel
- **Power & Logic:** 4x jumper wires (Pi GPIO -> ULN2003 IN1-IN4), plus 5V/GND for the driver board.
  *(Note: Power the ULN2003 board from the Pi's 5V pin or a separate 5V supply if you see brownouts — the motor can pull enough current to reset the Pi on some setups).*

### Wiring Diagram

```
Raspberry Pi (BCM)      ULN2003 board
-------------------     -------------
GPIO17  -------------->  IN1
GPIO18  -------------->  IN2
GPIO27  -------------->  IN3
GPIO22  -------------->  IN4
5V      -------------->  VCC (motor supply)
GND     -------------->  GND
```

Pin mappings match the configuration variables in `software/stepper.py`. Update the code pins array if you wire the hardware differently.

---

## ⚙️ Mechanism & OpenSCAD Modeling

The 28BYJ-48 has a ~1:64 internal gear reduction, which provides high holding torque and precise positioning at low speed—ideal for a push-finger that needs to land reliably in the same spot every time. 

### 1. Actuator Mechanism (`finger.scad` / `gear.scad`)
- **The Linear Finger (`finger.scad`):** An L-shaped rack track with customized gear mesh teeth. The short edge of the "L" hangs over the front panel of the radio cabinet directly above the power button. 
- **The Drive Pinion Gear (`gear.scad`):** A custom 13-tooth gear designed with a specialized trapezoidal profile. It features a complete through-hole socket with a dual-flat profile (Double-D shape) matching the machined output shaft of the stepper motor perfectly.

### 2. Custom Electronics Enclosure (`enclosure.scad`)
- A 2.5-inch square custom travel box with integrated alignment pin standoffs configured specifically to securely seat the ULN2003 board.
- Includes built-in structural wire drop slits on opposite side walls and a custom friction-fit ventilation lid featuring a clean hexagonal cutout pattern for active airflow.

### Print Settings (PETG)
- **Nozzle Temp:** 230-240 °C, **Bed Temp:** 80-85 °C
- **Perimeters:** 3-4 walls, **Infill:** 20-25% (parts are low-load)
- **Supports:** No supports needed on any part as drawn (flat bottoms, bore facing up)
- Print the pinion gear with the bore axis vertical for precision accuracy on the Double-D profile.

---

## 💻 Software & Script Configuration

The control software is divided into a low-level driver and an automated action script wrapper:

*   `stepper.py` — Low-level motor driver. Takes step count + direction as parameters (CLI or import), and drives the ULN2003 half-step sequence.
*   `button_actions.py` — High-level automated actions (`power_toggle()`, `system_reset()`), containing your physical calibration constants.

### Direct Command-Line Examples

**Low-Level Rotation Example via `stepper.py`:**
```bash
python3 stepper.py --steps 512 --direction cw
```

**High-Level Button Automation Examples via `button_actions.py`:**
```bash
# Execute a standard power cycle toggle
python3 button_actions.py power

# Execute a system factory reset sequence (Requires terminal confirmation)
python3 button_actions.py reset
```

---

## 🔬 Calibration Procedure

Because the stepper motor is driven open-loop (no encoder), the "home" and "pressed" positions are step counts you calibrate once to match your printed geometry:

1. Home the linear finger by hand (with the motor unpowered) so it sits just clear of the physical radio button. Note this as position 0.
2. Run `stepper.py` with small step increments in the advance direction until you find the step count that fully depresses the button. Record this value as `PRESS_STEPS`.
3. Update `PRESS_STEPS` and `PRESS_DIRECTION` in `button_actions.py`.
4. Test the `power_toggle` action first (safe to get wrong). Only test the `system_reset` route once you are fully confident—an unintentional 6+ second hold will wipe your radio settings.

---

## 📂 Repository Structure

```
flex-button-bot/
├── README.md
├── hardware/
│   ├── enclosure.scad          # Custom ULN2003 case & hex lid
│   ├── finger.scad             # Linear moving rack-finger track
│   └── gear.scad               # Double-D shaft drive pinion gear
└── software/
    ├── stepper.py              # Low-level ULN2003 motor driver
    └── button_actions.py       # High-level macro action script
```

---

## ⚠️ Safety Notes

- **Stuck State Risk:** The reset action holds the button down for several seconds. If the software crashes or loses power while the arm is advanced, it could hold the radio in a perpetual reset loop. Consider a manual mechanical fail-safe (like a physical return spring) if running completely unattended.
- **Coil Management:** `stepper.py` always releases all coils in its `cleanup()` phase (including on unexpected crash exceptions), ensuring the motor never sits under continuous holding current when idle.
