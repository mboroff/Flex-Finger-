// ============================================================
// finger.scad
// Rack/finger extracted from finger_and_ger_google_V3_fixed.stl
// (the long L-shaped part, i.e. everything that is NOT the gear)
//
// Measured from the original STL (component 1 of the mesh):
//   - Overall length (long arm)      : 164.598 mm
//   - Toothed bar height             : 6.85 mm
//   - Bar extrusion thickness        : 7.598 mm  (same as the gear)
//   - Rack tooth (notch) pitch       : 2.6805 mm  -- VERY uniform
//     and consistent along the entire measured length (confirmed
//     by direct measurement of ~58 notches; this is not the source
//     of the skipping problem)
//   - Notch depth                    : 2.55 mm
//   - Notch opening width (at top)   : ~0.83 mm
//   - Notch bottom width             : ~0.59 mm
//   - Pivot/pin hole (through hole)  : dia. ~2.5 mm, located at
//                                       x=80.9, y=-3.4 from the
//                                       part's top-left corner
//   - Foot (short leg of the "L")    : 7.61 mm wide, originally
//                                       44.45 mm long (measured
//                                       from the top edge)
//
// Changes made (round 2, after test print):
//   1) Foot (short end) shortened by another 1/4" (6.35 mm), on
//      top of the 1/2" already removed:
//        44.45 -> 31.75 (round 1) -> 25.4 mm (this round)
//   2) The root-radius fix in gear.scad alone did not stop the
//      gear from catching the top of the next tooth, so the rack
//      pitch (tooth separation) is widened here instead, using the
//      gear's TIP circle rather than the root circle:
//          new_pitch = 2*pi*tip_r/teeth = 2*pi*8.99/13 = 4.348 mm
//      (up from the originally-measured 2.6805 mm -- a ~62% wider
//      spacing). The notch opening/bottom widths are scaled up by
//      the same ratio to keep the same proportions, and the notch
//      is cut deeper (3.45 mm, matching the gear's addendum height
//      of tip_r - root_r) so the now-taller, 1mm-longer gear teeth
//      can fully seat instead of skating across the top land and
//      catching the next tooth.
//   This is an empirical correction based on your test print --
//   print this version and check whether it still skips; the pitch
//   or notch depth may need another small nudge either way.
// ============================================================

/* [CONFIG] */

// --- Overall bar ---
total_length   = 164.598;  // full length of the part, end to end
bar_length     = 156.99;   // length of the toothed section (before the foot)
bar_height     = 6.85;     // height of the toothed bar (top edge = y0, bottom = -bar_height)
thickness      = 7.598;    // extrusion depth (Z), matches the gear thickness

// --- Rack teeth (notches cut into the top edge) ---
// Widened from the originally-measured 2.6805 mm to match the
// gear's tip-circle circumference (2*pi*8.99/13), since the root-
// circle-based pitch wasn't enough to stop the skipping in testing.
tooth_pitch        = 4.348;   // was 2.6805
tooth_depth        = 3.45;    // was 2.55 -- matches gear addendum height (tip_r - root_r)
tooth_top_width    = 1.35;    // was 0.83 -- scaled up with the wider pitch
tooth_bottom_width = 0.96;    // was 0.59 -- scaled up with the wider pitch
first_tooth_center = 1.334;   // x position of the first notch's center

// --- Pivot / pin hole ---
add_pivot_hole = true;
pivot_hole_x   = 80.9;    // measured from the left end of the part
pivot_hole_y   = -3.4;    // measured down from the top edge
pivot_hole_d   = 2.5;     // through-hole diameter

// --- Foot (short leg of the L-shape) ---
// Original measured length (from the top edge, y=0, down to the tip)
foot_length_original = 44.45;
// Shortened by 1/2" (round 1) then another 1/4" (round 2) per request
foot_length = foot_length_original - 12.7 - 6.35;   // = 25.4 mm

// Rendering smoothness
$fn = 60;

/* [END CONFIG] */

module tooth_notch() {
    translate([0, 0, -1])
        linear_extrude(height = thickness + 2)
            polygon(points = [
                [-tooth_top_width/2,    0],
                [-tooth_bottom_width/2, -tooth_depth],
                [ tooth_bottom_width/2, -tooth_depth],
                [ tooth_top_width/2,    0]
            ]);
}

module rack_teeth() {
    n = floor((bar_length - first_tooth_center) / tooth_pitch) + 1;
    for (i = [0 : n - 1]) {
        cx = first_tooth_center + i * tooth_pitch;
        // Skip whichever tooth would land on top of the pivot hole
        skip = add_pivot_hole && abs(cx - pivot_hole_x) < (pivot_hole_d/2 + 1.2);
        if (cx < bar_length && !skip)
            translate([cx, 0, 0])
                tooth_notch();
    }
}

module body() {
    union() {
        // main toothed bar, full length (top edge flush with the foot)
        translate([0, -bar_height, 0])
            cube([total_length, bar_height, thickness]);
        // foot: extra material hanging below the bar at the right end
        translate([bar_length, -foot_length, 0])
            cube([total_length - bar_length, foot_length - bar_height, thickness]);
    }
}

module pivot_hole() {
    translate([pivot_hole_x, pivot_hole_y, -1])
        cylinder(d = pivot_hole_d, h = thickness + 2);
}

module finger() {
    difference() {
        body();
        rack_teeth();
        if (add_pivot_hole)
            pivot_hole();
    }
}

finger();
