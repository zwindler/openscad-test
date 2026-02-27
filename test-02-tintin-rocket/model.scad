// Tintin-style Moon Rocket (v9)
// Inspired by Hergé's "Destination Moon" / "Explorers on the Moon"
//
// Each leg = wide flat fin root blending into body -> narrowing curved blade
//            -> large spherical reactor bulb at tip

$fn = 80;

// --- Body ---
body_radius     = 14;
nose_height     = 40;
nose_tip_h      = 6;
nose_tip_r      = 1.5;
upper_height    = 50;
lower_height    = 15;
lower_base_r    = 16;

// --- Leg parameters ---
leg_count       = 3;
stalk_steps     = 18;

// Stalk cross-section: width (radial) and thickness (tangential)
stalk_w_base    = 10;    // wide at root (blade width) - bigger
stalk_w_min     = 4.5;   // narrows in middle - thicker
stalk_w_tip     = 5;     // slight swell before bulb
stalk_t         = 3;     // tangential thickness (flat blade) - thicker

// Stalk curve geometry
stalk_spread    = 40;    // how far out - more spread
stalk_drop      = 50;    // how far below body base

// Reactor bulb
bulb_radius     = 10;    // bigger bulb

// --- Z positions ---
ground_z    = 0;
body_base_z = stalk_drop + bulb_radius;
lower_z     = body_base_z;
upper_z     = lower_z + lower_height;
nose_z      = upper_z + upper_height;
tip_z       = nose_z + nose_height;

// --- Nose cone (tangent ogive) ---
module nose_cone() {
    L = nose_height;
    R = body_radius;
    rho = (R*R + L*L) / (2*R);

    translate([0, 0, nose_z - 0.5])
        rotate_extrude()
            polygon(points=concat(
                [[0, 0]],
                [ for (i = [0 : 100])
                    let(
                        t = i / 100,
                        y_model = t * (L + 0.5),
                        y_ogive = min(t * L, L),
                        r = sqrt(rho*rho - y_ogive*y_ogive) + R - rho
                    )
                    [max(r, 0), y_model]
                ],
                [[0, L + 0.5]]
            ));
}

module nose_tip() {
    translate([0, 0, tip_z - 1])
        cylinder(h=nose_tip_h + 1, r1=nose_tip_r * 2.5, r2=0);
}

module upper_body() {
    translate([0, 0, upper_z - 0.5])
        cylinder(h=upper_height + 1, r=body_radius);
}

module lower_body() {
    translate([0, 0, lower_z - 0.5])
        cylinder(h=lower_height + 1, r1=lower_base_r, r2=body_radius);
}

// --- Stalk width profile (radial dimension) ---
// Wide at root, narrows, slight swell at tip
function stalk_width(t) =
    (t < 0.35) ?
        stalk_w_base + (stalk_w_min - stalk_w_base) * (t / 0.35) :
    (t < 0.75) ?
        stalk_w_min :
        stalk_w_min + (stalk_w_tip - stalk_w_min) * ((t - 0.75) / 0.25);

// --- Cubic bezier ---
function cbez_x(t, p0, p1, p2, p3) =
    (1-t)*(1-t)*(1-t)*p0[0] + 3*(1-t)*(1-t)*t*p1[0] +
    3*(1-t)*t*t*p2[0] + t*t*t*p3[0];
function cbez_z(t, p0, p1, p2, p3) =
    (1-t)*(1-t)*(1-t)*p0[2] + 3*(1-t)*(1-t)*t*p1[2] +
    3*(1-t)*t*t*p2[2] + t*t*t*p3[2];

// --- Single leg ---
module leg() {
    // --- Fin root: large smooth blend from body into stalk ---
    hull() {
        // Upper fin point (high on body)
        translate([body_radius - 1, 0, lower_z + lower_height * 0.8])
            scale([1, 0.35, 1]) sphere(r=5);
        // Lower-outer fin point (at body base, sticking out)
        translate([lower_base_r + 4, 0, lower_z - 3])
            scale([1, 0.35, 1]) sphere(r=6);
        // Inner body overlap (deep inside body)
        translate([body_radius * 0.3, 0, lower_z + 3])
            scale([1, 0.35, 1]) sphere(r=6);
        // Lower connection toward stalk
        translate([lower_base_r, 0, lower_z - 7])
            scale([1, 0.35, 1]) sphere(r=5);
    }

    // --- Curved stalk (flat blade) ---
    // Pronounced outward bow: stalk goes almost horizontal first, then sweeps down
    p0  = [lower_base_r + 1, 0, lower_z - 5];
    cp1 = [stalk_spread * 1.0, 0, lower_z - 2];      // strongly outward, barely dropping
    cp2 = [stalk_spread * 1.2, 0, ground_z + stalk_drop * 0.25]; // far out, then drops
    p3  = [stalk_spread, 0, ground_z + bulb_radius * 1.05];

    for (s = [0 : stalk_steps - 1]) {
        t1 = s / stalk_steps;
        t2 = (s + 1) / stalk_steps;

        x1 = cbez_x(t1, p0, cp1, cp2, p3);
        z1 = cbez_z(t1, p0, cp1, cp2, p3);
        x2 = cbez_x(t2, p0, cp1, cp2, p3);
        z2 = cbez_z(t2, p0, cp1, cp2, p3);

        w1 = stalk_width(t1);
        w2 = stalk_width(t2);

        hull() {
            // Flat blade: wide in radial (x), thin tangentially (y)
            translate([x1, 0, z1]) scale([w1/stalk_t, 1, w1/stalk_t])
                sphere(r=stalk_t);
            translate([x2, 0, z2]) scale([w2/stalk_t, 1, w2/stalk_t])
                sphere(r=stalk_t);
        }
    }

    // --- Reactor bulb (sits on ground) ---
    translate([stalk_spread, 0, ground_z + bulb_radius])
        sphere(r=bulb_radius);
}

// All 3 legs
module legs() {
    for (i = [0 : leg_count - 1])
        rotate([0, 0, i * 360 / leg_count])
            leg();
}

// --- Checkerboard bands ---
// Prominent raised squares around circumference
module checkerboard_band(z_pos, band_h, n_squares) {
    arc_deg = 360 / n_squares;
    for (j = [0 : n_squares - 1]) {
        if (j % 2 == 0) {
            rotate([0, 0, j * arc_deg])
                translate([0, 0, z_pos])
                    intersection() {
                        difference() {
                            cylinder(h=band_h, r=body_radius + 1.5);
                            translate([0, 0, -0.1])
                                cylinder(h=band_h + 0.2, r=body_radius - 0.3);
                        }
                        // Pie slice - use full arc_deg for square coverage
                        linear_extrude(height=band_h)
                            polygon(points=[
                                [0, 0],
                                [(body_radius + 3) * cos(0.5),
                                 (body_radius + 3) * sin(0.5)],
                                [(body_radius + 3) * cos(arc_deg - 0.5),
                                 (body_radius + 3) * sin(arc_deg - 0.5)]
                            ]);
                    }
        }
    }
}

module all_bands() {
    n_sq = 8;
    bh = 8;      // taller squares
    gap = 0.8;   // small gap between rows

    band_block_h = 4 * bh + 3 * gap;
    start_z = upper_z + (upper_height - band_block_h) / 2;

    for (row = [0 : 3]) {
        z = start_z + row * (bh + gap);
        offset_angle = (row % 2 == 0) ? 0 : 360 / n_sq / 2;
        rotate([0, 0, offset_angle])
            checkerboard_band(z, bh, n_sq);
    }
}

// --- Assembly ---
rocket();

module rocket() {
    union() {
        nose_cone();
        nose_tip();
        upper_body();
        lower_body();
        legs();
        all_bands();
    }
}
