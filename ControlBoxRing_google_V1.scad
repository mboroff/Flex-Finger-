// Custom Isolated Wire Retention Ring
// For ULN2003 Enclosure (2.5 inches square box with 2mm walls)

$fn = 40; // Circle smoothness

// --- FIXED PARAMETERS FROM EXISTING BOX ---
box_size = 63.5;       // 2.5 inches square base
wall_thick = 2.0;      // 2mm outer box walls

// --- RETENTION RING DIMENSIONS ---
ring_height = 6.35;    // 1/4 inch high
ring_width = 6.35;     // 1/4 inch wall thickness
ring_clearance = 0.15; // Clearance tolerance to slide down smoothly inside your printed box

// --- RENDER EXECUTION ---
wire_retention_ring();

// --- MODULE ---
module wire_retention_ring() {
    // Computes the exact size needed to slide inside the printed box's inner footprint
    outer_ring_size = box_size - (wall_thick * 2) - (ring_clearance * 2);
    inner_ring_size = outer_ring_size - (ring_width * 2);
    
    difference() {
        // Outer ring solid boundary
        cube([outer_ring_size, outer_ring_size, ring_height]);
        
        // Center cutout to leave a precise 1/4" boundary profile
        translate([ring_width, ring_width, -0.1])
            cube([inner_ring_size, inner_ring_size, ring_height + 0.2]);
    }
}
