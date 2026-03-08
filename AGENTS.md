# Project Context

## Environment

- **OS**: Bazzite (Fedora Atomic/immutable desktop)
- **Editor**: VS Code (runs as Flatpak)
- **Package management**: Flatpak is the primary method. Installing via rpm-ostree is possible but discouraged.
- **OpenSCAD**: Installed via Flatpak (`org.openscad.OpenSCAD 2021.01`)

## Goal

Experiment with OpenSCAD to generate 3D models from code. Test and iterate on different designs.

## Repo Structure

Each experiment lives in its own folder:

```
openscad-test/
├── AGENTS.md
├── README.md
├── test-01-name/
│   ├── model.scad       # source code
│   ├── model.stl        # exported mesh
│   └── preview.png      # rendered preview
├── test-02-name/
│   └── ...
└── ...
```

## Workflow Rules

When creating or modifying a model, **always** generate both outputs in the test folder:

1. **STL export** (`model.stl`)
2. **PNG preview** (`preview.png`)

Run commands **from the test folder** (use `workdir` parameter).

After STL export, check the output for `Simple: yes` to confirm valid 2-manifold geometry.

## CLI Commands

VS Code runs as a Flatpak, so all host commands must be prefixed with `flatpak-spawn --host`.

```bash
# Export to STL (no display needed)
flatpak-spawn --host flatpak run org.openscad.OpenSCAD -o model.stl model.scad

# Render to PNG preview
flatpak-spawn --host flatpak run --nosocket=wayland --env=DISPLAY=:0 org.openscad.OpenSCAD -o preview.png --camera=0,0,0,60,0,30,200 model.scad

# Export to 3MF
flatpak-spawn --host flatpak run org.openscad.OpenSCAD -o model.3mf model.scad
```

**PNG rendering on Wayland**: `--nosocket=wayland --env=DISPLAY=:0` is required to force XWayland fallback. Without this, OpenSCAD's offscreen OpenGL rendering fails silently. If no X11 display is available, skip PNG and note the failure.

**Camera parameter**: `--camera=tx,ty,tz,rx,ry,rz,dist` — adjust per model. Typical values: translate to center the object vertically, distance 200-500 depending on size.

## OpenSCAD Guidelines & Pitfalls

### Version limitations (2021.01)

- **No local `function` inside `module`** — define functions at global scope
- Older syntax only; some newer OpenSCAD features are unavailable

### 2-Manifold geometry (valid STL)

- Adjacent body sections sharing exact boundary faces cause non-manifold geometry. **Always add small overlaps** (0.5mm) between sections: `translate([0, 0, z - 0.5]) cylinder(h=h + 1, ...)`
- Sub-parts (fins, legs, attachments) must **penetrate well inside** the parent body, not just touch the surface
- After export, check for `Simple: yes` in OpenSCAD output

### Modeling tips

- **`$fn`**: controls facet count. Use `$fn = 80` for smooth renders; lower (e.g. 40) for faster iteration
- **`hull()` chains with spheres** are expensive to render (~1 min+ for complex organic shapes). Minimize `hull()` segment count where possible
- **Tangent ogive** (nose cone) formula: `r(y) = sqrt(rho² - y²) + R - rho` where `rho = (R² + L²)/(2R)`, y=0 at base (r=R), y=L at tip (r≈0)
- **Organic curved shapes**: use cubic bezier paths with hull-chained scaled spheres. Define 4 control points (start, cp1, cp2, end) and interpolate position + radius along the path
- **Flat blade cross-sections**: use `scale([w, 1, w]) sphere(r=t)` inside hull to create blade/fin shapes instead of round tubes

### Render performance

- STL export with complex hull chains: expect 1-2 minutes
- PNG preview: fast (~2-3 seconds, uses OpenGL not CGAL)
- For faster iteration, lower `$fn` temporarily or comment out expensive parts

## Tests Log

| # | Folder | Description | Status |
|---|--------|-------------|--------|
| 1 | test-01-parametric-box | Hollow parametric box | Done |
| 2 | test-02-tintin-rocket | Tintin-style moon rocket (ogive nose, checkerboard bands, curved stalk legs with reactor bulbs) | Done |
