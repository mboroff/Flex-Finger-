// Custom Enclosure for ULN2003 Stepper Motor Driver Board
// Updated: Box height 1 9/16", pin standoffs, and a printable sliding wire retention ring.

$fn = 40; // Circle smoothness

// --- PARAMETERS ---
box_size = 63.5;       // 2.5 inches square
box_height = 39.69;    // 1 9/16 inches overall height
wall_thick = 2.0;      // Outer shell wall thickness

// Board Mounting Dimensions (Calculated from ruler photos: ~26mm x 30mm)
pcb_hole_w = 26.0;     // Center-to-center hole spacing (Width)
pcb_hole_l = 30.0;     // Center-to-center hole spacing (Length)

standoff_h = 5.0;      // Height of main support base
standoff_dia = 6.0;    // Diameter of standoff base pillars
pin_h = 5.0;           // UPDATED: Increased from 3.0 to 5.0 for a taller registration fit
pin_dia = 2.0;         // Diameter of alignment pin (fits standard PCB holes)

// Slits for wires (Halfway down opposite walls)
slit_w = 5.0;          // Width of wire drop slots
slit_depth = box_height / 2; 

// Wire Retention Ring Dimensions
ring_height = 6.35;    // 1/4 inch high
ring_width = 6.35;     // 1/4 inch wall thickness
ring_clearance = 0.05; // UPDATED: Tightened from 0.15 to 0.05 to ensure a tight slide fit inside the box


// --- PRINT BED ARRANGEMENT (Z = 0) ---
// Tightly packed to fit within the 180x180mm footprint of the Bambu Lab A1 Mini

// 1. Main Enclosure Base
translate([0, 0, 0]) {
    main_enclosure_base();
}

// 2. Enclosure Lid (Shifted closer from box_size + 15 down to box_size + 5)
translate([box_size + 5, 0, wall_thick]) {
    rotate([180, 0, 0]) {
        enclosure_lid();
    }
}

// 3. Sliding Wire Retention Ring (Tucked right below the main base with a tight 5mm gap)
translate([0, box_size + 5, 0]) {
    wire_retention_ring();
}


// --- MODULES ---

module main_enclosure_base() {
    difference() {
        // Outer Solid Box
        cube([box_size, box_size, box_height]);
        
        // Inner Hollow Space
        translate([wall_thick, wall_thick, wall_thick])
            cube([box_size - (wall_thick * 2), box_size - (wall_thick * 2), box_height]);
        
        // Wire Slit 1 (Left wall, centered)
        translate([-0.1, box_size / 2 - slit_w / 2, box_height - slit_depth])
            cube([wall_thick + 0.2, slit_w, slit_depth + 0.1]);
            
        // Wire Slit 2 (Right wall, centered)
        translate([box_size - wall_thick - 0.1, box_size / 2 - slit_w / 2, box_height - slit_depth])
            cube([wall_thick + 0.2, slit_w, slit_depth + 0.1]);
    }
    
    // Four Centered PCB Pin Standoffs
    translate([box_size / 2, box_size / 2, wall_thick]) {
        for (x = [-pcb_hole_w / 2, pcb_hole_w / 2]) {
            for (y = [-pcb_hole_l / 2, pcb_hole_l / 2]) {
                translate([x, y, 0]) {
                    // Standoff Support Base
                    cylinder(h = standoff_h, d = standoff_dia);
                    // Alignment Pin on top
                    translate([0, 0, standoff_h])
                        cylinder(h = pin_h, d = pin_dia);
                }
            }
        }
    }
}

module enclosure_lid() {
    lid_lip_height = 4.0; // Deeper friction path for a tight fit
    lid_clearance = 0.02; // UPDATED: Reduced from 0.1 to 0.02 for a tighter snap/friction fit
    lip_thick = 3.0;      // Thicker wall layers on the inner lip profile
    
    // Main Lid Flat Plate
    difference() {
        cube([box_size, box_size, wall_thick]);
        
        // Ventilation Array (Hexagonal patterns centered on the top)
        translate([box_size / 2, box_size / 2, -0.1]) {
            for (xi = [-2:2]) {
                for (yi = [-2:2]) {
                    translate([xi * 8 + (yi % 2 * 4), yi * 7, 0])
                        cylinder(h = wall_thick + 0.2, r = 2.5, $fn = 6);
                }
            }
        }
    }
    
    // Reinforced Inner Alignment Lip 
    difference() {
        translate([wall_thick + lid_clearance, wall_thick + lid_clearance, -lid_lip_height])
            cube([box_size - (wall_thick * 2) - (lid_clearance * 2), box_size - (wall_thick * 2) - (lid_clearance * 2), lid_lip_height]);
        
        // Inner clearance cutout leaving a strong, thick tracking lip perimeter
        translate([wall_thick + lid_clearance + lip_thick, wall_thick + lid_clearance + lip_thick, -lid_lip_height - 0.1])
            cube([box_size - (wall_thick * 2) - (lid_clearance * 2) - (lip_thick * 2), box_size - (wall_thick * 2) - (lid_clearance * 2) - (lip_thick * 2), lid_lip_height + 0.2]);
    }
}

module wire_retention_ring() {
    // Computes the size needed to slide perfectly into the box's inner footprint
    outer_ring_size = box_size - (wall_thick * 2) - (ring_clearance * 2);
    inner_ring_size = outer_ring_size - (ring_width * 2);
    
    difference() {
        // Outer ring solid boundary
        cube([outer_ring_size, outer_ring_size, ring_height]);
        
        // Center cutout to leave a 1/4" boundary profile
        translate([ring_width, ring_width, -0.1])
            cube([inner_ring_size, inner_ring_size, ring_height + 0.2]);
    }
}
