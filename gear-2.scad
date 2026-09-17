// ============================================================
// gear.scad
// Gear extracted from finger_and_ger_google_V3_fixed.stl
//
// Measured from the original STL (component 2 of the mesh):
//   - 13 teeth
//   - addendum (tip) radius  ~ 7.99 mm  -> outer diameter ~16.0 mm
//   - root radius             ~ 5.44 mm  -> ~10.9 mm
//   - center shaft hole dia.  ~ 5.15 mm
//   - gear thickness (height) ~ 7.60 mm
//
// Changes requested:
//   1) Shaft hole reshaped to match the 28BYJ-48's actual output
//      shaft: a round shaft with flats machined on TWO opposite
//      sides ("double-D" / stadium profile, confirmed from photos),
//      enlarged slightly for clearance -> 5.5 mm round dia.,
//      flattened to ~3 mm across the flats (adjust flat_half_width
//      below to match calipers on your actual motor)
//   2) Teeth extended (radially) by 1 mm  -> tip radius 7.99 -> 8.99 mm
//   3) Teeth made 1 mm thinner (circumferentially), both at the
//      root and the tip of each tooth
//
// This is a simple trapezoidal-tooth gear (not a true involute
// profile, matching the look of the scanned/printed original),
// built as a base cylinder (root circle) with trapezoidal teeth
// unioned on, then the shaft hole subtracted. Everything below
// is parametric -- change the values in the CONFIG section and
// the gear updates automatically.
// ============================================================

/* [CONFIG] */

// Number of teeth
teeth = 13;

// Root circle radius (base of the teeth) [mm]
root_r = 5.44;

// Tip (addendum) circle radius [mm]
// original was 7.99 -> extended by 1 mm per request
tip_r = 7.99 + 1;          // = 8.99

// Tooth width at the root, measured tangentially [mm]
// original estimate 2.0 -> made 1 mm thinner per request
tooth_root_width = 2.0 - 1;   // = 1.0

// Tooth width at the tip, measured tangentially [mm]
// original estimate 1.4 -> made 1 mm thinner per request
tooth_tip_width = 1.4 - 1;    // = 0.4

// Gear thickness / height [mm]
gear_thickness = 7.6;

// Shaft hole diameter [mm]
// original ~5.15 mm -> enlarged slightly for 28BYJ-48 stepper shaft
hole_diameter = 5.5;

// The 28BYJ-48 output shaft is flattened on TWO opposite sides
// (a symmetric "double-D" / stadium shape), not round, and not
// just a single flat. Set add_flats = true to cut both flats.
add_flats = true;

// Distance from the hole center to each flat face [mm]
// i.e. half the "across the flats" width.
// 28BYJ-48 shaft is ~5mm round stock flattened down to roughly
// 3mm across the flats -- measure your actual shaft with calipers
// and set flat_half_width = (across-flats measurement)/2.
// This is independent of hole_diameter, which still sets the
// diameter of the round part between the flats.
flat_half_width = 1.5;

// Rendering smoothness
$fn = 100;

/* [END CONFIG] */

module tooth() {
    linear_extrude(height = gear_thickness)
        polygon(points = [
            [-tooth_root_width/2, root_r],
            [-tooth_tip_width/2,  tip_r],
            [ tooth_tip_width/2,  tip_r],
            [ tooth_root_width/2, root_r]
        ]);
}

module shaft_hole() {
    h = gear_thickness + 4;
    if (add_flats) {
        // Round hole intersected with a box that is narrower than the
        // hole diameter -> leaves a flat cut on both the top and
        // bottom side, symmetric about the center (the 28BYJ-48's
        // "double-D" shaft profile).
        intersection() {
            translate([0, 0, -2])
                cylinder(d = hole_diameter, h = h);
            translate([-hole_diameter, -flat_half_width, -2])
                cube([hole_diameter * 2, flat_half_width * 2, h]);
        }
    } else {
        translate([0, 0, -2])
            cylinder(d = hole_diameter, h = h);
    }
}

module gear() {
    difference() {
        union() {
            cylinder(r = root_r, h = gear_thickness);
            for (i = [0 : teeth - 1])
                rotate([0, 0, i * 360 / teeth])
                    tooth();
        }
        shaft_hole();
    }
}

gear();
