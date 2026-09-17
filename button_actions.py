#!/usr/bin/env python3
"""
button_actions.py - High-level Flex 6800 button actions, built on stepper.py.

The radio's front button behaves like this:
    - Momentary press          -> toggles power on/off
    - Press and hold, then let
      go once it glows white   -> system reset

So both actions here are "move arm onto button, dwell, move arm back."
The only difference between a power toggle and a reset is the dwell time.

*** You must calibrate PRESS_STEPS for your own printed geometry before
    these will do anything useful -- see the README calibration section. ***

CLI usage:
    python3 button_actions.py power
    python3 button_actions.py reset

Import usage:
    from button_actions import power_toggle, system_reset
    power_toggle()
"""

import argparse
import time

from stepper import rotate

# ---------------------------------------------------------------------------
# Calibration constants -- tune these for your printed arm/hub geometry.
# See README.md "Calibration procedure".
# ---------------------------------------------------------------------------
PRESS_STEPS = 40          # half-steps from "home" to "button fully pressed"
PRESS_DIRECTION = "cw"    # direction that moves the arm onto the button
RELEASE_DIRECTION = "ccw" # direction that moves the arm back to home
STEP_DELAY = 0.002        # seconds between half-steps

RESET_HOLD_SECONDS = 6.0  # how long to hold before releasing for a reset;
                           # the radio's button glows white once this is
                           # long enough -- watch it the first few times
                           # and adjust rather than trusting this number


def _press():
    rotate(PRESS_STEPS, PRESS_DIRECTION, STEP_DELAY)


def _release():
    rotate(PRESS_STEPS, RELEASE_DIRECTION, STEP_DELAY)


def power_toggle():
    """Momentary press: turns the radio on if off, or off if on."""
    _press()
    _release()


def system_reset():
    """
    Press and hold until the button would glow white, then release.
    Only call this when you're confident PRESS_STEPS/PRESS_DIRECTION are
    correct -- an unwanted multi-second hold is a reset you didn't want.
    """
    _press()
    time.sleep(RESET_HOLD_SECONDS)
    _release()


def main():
    parser = argparse.ArgumentParser(description="Press the Flex 6800 power/reset button.")
    parser.add_argument("action", choices=["power", "reset"], help="Which action to perform")
    args = parser.parse_args()

    if args.action == "power":
        power_toggle()
        print("Power toggle complete.")
    else:
        confirm = input("This will hold the button for a system reset. Type 'yes' to continue: ")
        if confirm.strip().lower() == "yes":
            system_reset()
            print("Reset sequence complete.")
        else:
            print("Aborted.")


if __name__ == "__main__":
    main()
