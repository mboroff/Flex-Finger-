#!/usr/bin/env python3
"""
stepper.py - Drive a 28BYJ-48 stepper motor (via a ULN2003 driver board)
from a Raspberry Pi 4B.

Accepts number of steps and direction as parameters, either from the
command line or as an import.

CLI usage:
    python3 stepper.py --steps 512 --direction cw
    python3 stepper.py --steps 512 --direction ccw --delay 0.0015

Import usage:
    from stepper import rotate
    rotate(steps=512, direction="cw")
"""

import argparse
import time

try:
    import RPi.GPIO as GPIO
    _SIMULATE = False
except (ImportError, RuntimeError):
    # RuntimeError covers "not running on a Pi" on some RPi.GPIO builds
    GPIO = None
    _SIMULATE = True

# ---------------------------------------------------------------------------
# Configuration - edit to match your wiring
# ---------------------------------------------------------------------------
# ULN2003 IN1..IN4 -> Raspberry Pi BCM GPIO pins
PINS = [17, 18, 27, 22]

# Half-step sequence (8 steps/cycle). Half-stepping gives smoother motion
# and finer position resolution than full-stepping, at the same top speed.
# One full output-shaft revolution ≈ 2048 half-steps (28BYJ-48's ~1:64
# gearbox x 32 half-steps per internal motor revolution). Treat that as a
# rule of thumb, not a guarantee -- gear ratios vary slightly by batch.
HALF_STEP_SEQUENCE = [
    [1, 0, 0, 0],
    [1, 1, 0, 0],
    [0, 1, 0, 0],
    [0, 1, 1, 0],
    [0, 0, 1, 0],
    [0, 0, 1, 1],
    [0, 0, 0, 1],
    [1, 0, 0, 1],
]

DEFAULT_DELAY = 0.002  # seconds between half-steps; lower = faster, less torque


def _gpio_setup():
    if _SIMULATE:
        return
    GPIO.setmode(GPIO.BCM)
    for pin in PINS:
        GPIO.setup(pin, GPIO.OUT)
        GPIO.output(pin, 0)


def _gpio_cleanup():
    if _SIMULATE:
        return
    for pin in PINS:
        GPIO.output(pin, 0)
    GPIO.cleanup(PINS)


def rotate(steps: int, direction: str = "cw", delay: float = DEFAULT_DELAY) -> None:
    """
    Rotate the stepper a given number of half-steps.

    steps:     number of half-steps to move (non-negative int)
    direction: "cw" or "ccw"
    delay:     seconds to pause between each half-step; controls speed
    """
    if steps < 0:
        raise ValueError("steps must be >= 0")

    direction = direction.lower()
    if direction not in ("cw", "ccw"):
        raise ValueError("direction must be 'cw' or 'ccw'")

    sequence = HALF_STEP_SEQUENCE if direction == "cw" else list(reversed(HALF_STEP_SEQUENCE))

    _gpio_setup()
    try:
        for i in range(steps):
            step = sequence[i % len(sequence)]
            if not _SIMULATE:
                for pin, val in zip(PINS, step):
                    GPIO.output(pin, val)
            time.sleep(delay)
    finally:
        _gpio_cleanup()


def main():
    parser = argparse.ArgumentParser(description="Drive a 28BYJ-48 stepper motor via ULN2003.")
    parser.add_argument("--steps", type=int, required=True, help="Number of half-steps to move")
    parser.add_argument("--direction", choices=["cw", "ccw"], required=True, help="Rotation direction")
    parser.add_argument("--delay", type=float, default=DEFAULT_DELAY, help="Delay between half-steps, in seconds")
    args = parser.parse_args()

    if _SIMULATE:
        print("RPi.GPIO not available -- running in simulation mode (no pins driven).")

    rotate(args.steps, args.direction, args.delay)
    print(f"Moved {args.steps} half-steps {args.direction}.")


if __name__ == "__main__":
    main()
