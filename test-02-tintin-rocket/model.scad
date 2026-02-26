// Tintin-style Moon Rocket
// Inspired by Hergé's "Destination Moon" / "Explorers on the Moon"
//
// Features:
// - Tangent ogive nose cone
// - Cylindrical fuselage with decorative bands
// - Tapered lower section
// - Four swept fins with landing pads
// - Flared engine nozzle

$fn = 80;

// --- Parameters ---

body_radius     = 12;

// Nose cone
nose_height     = 35;

// Upper fuselage
upper_height    = 55;

// Lower fuselage
lower_height    = 35;
lower_base_r    = 14;

// Fins
fin_count       = 4;
fin_height      = 40;
fin_span        = 22;
fin_thickness   = 2.5;
fin_sweep       = 15;

// Engine nozzle
nozzle_height   = 10;
nozzle_top_r    = 10;
nozzle_bottom_r = 13;
nozzle_wall     = 1.5;

// Landing pads
pad_radius      = 3;
pad_height      = 2;

// Portholes
porthole_r      = 1.5;
porthole_depth  = 2;
porthole_count  = 4;

// --- Z positions (bottom at Z=0) ---
nozzle_z = 0;
lower_z  = nozzle_height;
upper_z  = lower_z + lower_height;
nose_z   = upper_z + upper_height;

// --- Nose cone (tangent ogive via rotate_extrude) ---
module nose_cone() {
    rho = (body_radius * body_radius + nose_height * nose_height)
          / (2 * body_radius);

    translate([0, 0, nose_z - 0.5])  // overlap into upper body
        rotate_extrude()
            polygon(points=concat(
                [[0, 0]],
                [ for (i = [0 : 50])
                    let(
                        t = i / 50,
                        y = t * (nose_height + 0.5),
                        y_ogive = t * nose_height,
                        r = sqrt(rho*rho - (nose_height - y_ogive)
                            * (nose_height - y_ogive)) - (rho - body_radius)
                    )
                    [max(r, 0), y]
                ],
                [[0, nose_height + 0.5]]
            ));
}

// --- Upper fuselage ---
module upper_body() {
    translate([0, 0, upper_z - 0.5])  // overlap into lower body
        cylinder(h=upper_height + 1, r=body_radius);  // +1 overlaps into nose
}

// --- Lower fuselage (cone frustum) ---
module lower_body() {
    translate([0, 0, lower_z - 0.5])  // overlap into nozzle
        cylinder(h=lower_height + 1, r1=lower_base_r, r2=body_radius);
}

// --- Engine nozzle (solid, hollowed in assembly) ---
module nozzle_outer() {
    translate([0, 0, nozzle_z])
        cylinder(h=nozzle_height + 0.5, r1=nozzle_bottom_r, r2=nozzle_top_r);
}

module nozzle_inner() {
    translate([0, 0, nozzle_z - 0.1])
        cylinder(h=nozzle_height + 0.2,
                 r1=nozzle_bottom_r - nozzle_wall,
                 r2=nozzle_top_r - nozzle_wall);
}

// --- Single fin ---
module fin() {
    fin_base_z = lower_z;
    root_x = body_radius * 0.5;

    hull() {
        translate([root_x, 0, fin_base_z + fin_height])
            cube([1, fin_thickness, 0.1], center=true);

        translate([root_x, 0, fin_base_z])
            cube([1, fin_thickness, 0.1], center=true);

        translate([body_radius + fin_span, 0, fin_base_z - fin_sweep])
            cube([1, fin_thickness * 0.4, 0.1], center=true);

        translate([body_radius + fin_span * 0.3, 0, fin_base_z - fin_sweep])
            cube([1, fin_thickness * 0.4, 0.1], center=true);
    }
}

module fins() {
    for (i = [0 : fin_count - 1])
        rotate([0, 0, i * 360 / fin_count])
            fin();
}

// --- Landing pads ---
module landing_pads() {
    for (i = [0 : fin_count - 1])
        rotate([0, 0, i * 360 / fin_count])
            translate([body_radius + fin_span, 0,
                       lower_z - fin_sweep - pad_height])
                cylinder(h=pad_height + 0.5, r=pad_radius);
}

// --- Portholes (cylinders to subtract) ---
module portholes() {
    spacing = upper_height / (porthole_count + 1);

    for (i = [1 : porthole_count])
        for (angle = [0, 180])
            rotate([0, 0, angle])
                translate([body_radius - porthole_depth + 0.1, 0,
                           upper_z + i * spacing])
                    rotate([0, 90, 0])
                        cylinder(h=porthole_depth + 0.5, r=porthole_r);
}

// --- Decorative bands (fully overlap into body) ---
module band(z_pos, band_h) {
    translate([0, 0, z_pos])
        difference() {
            cylinder(h=band_h, r=body_radius + 0.5);
            translate([0, 0, -0.1])
                cylinder(h=band_h + 0.2, r=body_radius - 0.5);
        }
}

// --- Assembly ---
module rocket() {
    difference() {
        union() {
            nose_cone();
            upper_body();
            lower_body();
            nozzle_outer();
            fins();
            landing_pads();

            band(upper_z + 5, 4);
            band(upper_z + upper_height - 9, 4);
            band(nose_z - 5, 3);
        }

        // Hollow out the nozzle
        nozzle_inner();

        // Cut portholes
        portholes();
    }
}

rocket();
