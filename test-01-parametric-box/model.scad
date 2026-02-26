// Parametric Hollow Box
// A simple open-top box with configurable dimensions and wall thickness.

// --- Parameters ---
width     = 40;   // outer width (X)
depth     = 30;   // outer depth (Y)
height    = 25;   // outer height (Z)
wall      = 2;    // wall thickness
bottom    = 2;    // bottom thickness (can differ from walls)

// --- Computed inner dimensions ---
inner_w = width  - 2 * wall;
inner_d = depth  - 2 * wall;
inner_h = height - bottom;

// --- Model ---
module hollow_box(w, d, h, wall, bottom) {
    difference() {
        // Outer shell
        cube([w, d, h]);

        // Inner cavity (shifted up by bottom thickness, inset by wall)
        translate([wall, wall, bottom])
            cube([w - 2*wall, d - 2*wall, h - bottom + 1]);
            // +1 on Z to cleanly cut through the top (open top)
    }
}

hollow_box(width, depth, height, wall, bottom);
