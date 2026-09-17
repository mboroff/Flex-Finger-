// Custom Enclosure for ULN2003 Stepper Motor Driver Board
// Updated: Height raised to 1 9/16", snugger lid layers, and customized pin standoffs.

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
pin_h = 3.0;           // Height of alignment pin extending above standoff
pin_dia = 2.0;         // Diameter of alignment pin (fits standard PCB holes)

// Slits for wires (Halfway down opposite walls)
slit_w = 5.0;          // Width of wire drop slots
slit_depth = box_height / 2; 


// --- PRINT BED ARRANGEMENT (Z = 0) ---

// 1. Main Enclosure Base
translate([0, 0, 0]) {
    main_enclosure_base();
}

// 2. Enclosure Lid (Placed side-by-side with a 15mm layout gap)
translate([box_size + 15, 0, wall_thick]) {
    rotate([180, 0, 0]) {
        enclosure_lid();
    }
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
    lid_clearance = 0.1;  // Reduced clearance for a tighter snap fit
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
