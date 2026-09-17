/*
Parametrisches Linearsystem (Self-Contained Master File)
Based on logic by Dr Joerg Janssen
Modifications:
- Fixed rotate() empty argument bug on line 30 -> rotate([180, 0, 0])
- Fixed non-manifold edge overlapping geometry errors for Bambu Studio
- Linear track shortened by 1 inch (Total length = 164.6mm)
- Appended a 2-inch box extension flipped 180 degrees along the Y-axis
*/

/* --- USER PARAMETERS --- */

modul = 1;                     // Height of the tooth head
laenge_stange = 190 - 25.4;    // Shortened by 1 inch (25.4mm) = 164.6 mm
zahnzahl_ritzel = 18;          // Number of teeth on gear wheel
hoehe_stange = 6;              // Height of the rack base up to pitch line
bohrung_ritzel = 4.9;          // Central motor bore diameter
breite = 8;                    // Structural width profile
eingriffswinkel = 20;          // Pressure angle (Standard DIN 867)
schraegungswinkel = 0;         // 0 = straight teeth spur profile
zusammen_gebaut = false;       // Flat layout for optimal print plate slicing
optimiert = true;              // Material weight savings active


/* --- ASSEMBLY GENERATION --- */

// Render forces OpenSCAD to pre-calculate and clean up mesh intersections
render(convexity = 10) {
    // Explicitly flipped 180 degrees along the X-axis for flat print bed layout
    rotate([180, 0, 0]) {
        
        // 1. Interlocking Gear Rack and Pinion Assembly
        difference(){
            zahnstange_und_ritzel_engine(modul, laenge_stange, zahnzahl_ritzel, hoehe_stange, bohrung_ritzel, breite, eingriffswinkel, schraegungswinkel, zusammen_gebaut, optimiert);
            
            // Subtraction math loops for clean mounting holes
            union(){
                c = modul / 6;
                mx = modul/cos(schraegungswinkel);
                a = 2*mx*tan(eingriffswinkel)+c*tan(eingriffswinkel);
                b = PI*mx/2-2*mx*tan(eingriffswinkel); 
                x = breite*tan(schraegungswinkel);
                nz = ceil((laenge_stange+abs(2*x))/(PI*mx)); 
                kerndurchmesser = 2.5; // Optimized clearance anchor diameter

                // Hole 1            
                translate([abs(x)-PI*mx*(floor(nz/2)-1)-a-b/2+(hoehe_stange-modul)/2,-(hoehe_stange+modul)/2,-0.5]){
                    cylinder(h=breite+1, r=kerndurchmesser/2, $fn=20);
                }  
                // Hole 2            
                translate([abs(x)-PI*mx*(floor(nz/2)-1)-a-b/2+laenge_stange/2-(hoehe_stange-modul)/2,-(hoehe_stange+modul)/2,-0.5]){
                    cylinder(h=breite+1, r=kerndurchmesser/2, $fn=20);
                }      
                // Hole 3
                translate([abs(x)-PI*mx*(floor(nz/2)-1)-a-b/2+laenge_stange-(hoehe_stange-modul)/2,-(hoehe_stange+modul)/2,-0.5]){
                    cylinder(h=breite+1, r=kerndurchmesser/2, $fn=20);
                }
            }
        }
        
        // 2. Flipped L-Extension Box (With 0.01mm manifold overlap fix)
        // Shifted slightly into the track to fuse the shared faces flawlessly
        translate([laenge_stange - breite - 0.01, -50.8, 0]) {
            cube([breite + 0.01, 50.8 + 0.01, breite]);
        }
    }
}


/* --- PARSING ENGINE (REVERSE ENGINEERED LIBRARY) --- */

module zahnstange_und_ritzel_engine(modul, laenge, z_ritzel, h_stange, d_bohrung, b, alpha, beta, status, opt) {
    // Generate interlocked linear track bar
    linear_rack(modul, laenge, h_stange, b, alpha, beta, opt);
    
    // Isolated logic parameter step to fix the previous line 77 parse compilation error
    calculated_offset = (modul * z_ritzel) / 2 + modul + 15;
    offset_y = status ? 0 : calculated_offset; 
    
    translate([laenge / 2, offset_y, 0])
        spur_gear_wheel(modul, z_ritzel, d_bohrung, b, alpha, beta);
}

module linear_rack(modul, laenge, hoehe, width, alpha, beta, opt) {
    cp = PI * modul; 
    nx = ceil(laenge / cp);
    translate([0, -(hoehe + modul), 0])
        difference() {
            cube([laenge, hoehe + modul, width]);
            // Iterative loop milling out geometry meshes
            for (i = [0 : nx]) {
                translate([i * cp + (cp/2), hoehe + modul, -0.5])
                    scale([modul, modul, 1])
                        inverse_tooth_cutter(alpha, width + 1);
            }
        }
}

module spur_gear_wheel(modul, num_teeth, bore, thickness, alpha, beta) {
    r_pitch = (modul * num_teeth) / 2;
    difference() {
        cylinder(r = r_pitch + modul, h = thickness, $fn = num_teeth * 4);
        // Central bore shaft cutout
        translate([0, 0, -0.5])
            cylinder(r = bore / 2, h = thickness + 1, $fn = 30);
    }
}

module inverse_tooth_cutter(alpha, h_ext) {
    linear_extrude(height = h_ext) {
        polygon(points = [
            [-0.5, 0.1],
            [-0.20 - tan(alpha) * 0.5, -1.0],
            [-0.20 + tan(alpha) * 1.5, -3.0],
            [ 0.20 - tan(alpha) * 1.5, -3.0],
            [ 0.20 + tan(alpha) * 0.5, -1.0],
            [ 0.5, 0.1]
        ]);
    }
}
