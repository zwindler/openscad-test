# Project Context

## Environment

- **OS**: Bazzite (Fedora Atomic/immutable desktop)
- **Editor**: VS Code terminal
- **Package management**: Flatpak is the primary method. Installing via rpm-ostree is possible but discouraged.
- **OpenSCAD status**: Installed via Flatpak (`org.openscad.OpenSCAD 2021.01`)
- **OpenSCAD CLI via Flatpak**: `flatpak run org.openscad.OpenSCAD [args]`

## Goal

Experiment with OpenSCAD to generate 3D models from code. Test and iterate on different designs.

## Repo Structure

Each experiment lives in its own folder:

```
openscad-test/
├── AGENTS.md               # project instructions for OpenCode
├── README.md
├── test-01-parametric-box/
│   └── model.scad
├── test-02-xxx/
│   └── model.scad
└── ...
```

## Workflow Rules

When creating a new model or modifying an existing one, **always** run both:

1. **PNG preview**: generate a `preview.png` in the test folder
2. **STL export**: generate a `model.stl` in the test folder

Since the terminal runs inside a VS Code Flatpak sandbox, use `flatpak-spawn --host` to invoke host commands. PNG rendering requires an X11 display; if it fails (no display available), note the failure and skip.

## CLI Usage (Flatpak)

Because VS Code runs as a Flatpak, all host commands must be prefixed with `flatpak-spawn --host`.

```bash
# Render to PNG preview
flatpak-spawn --host flatpak run --nosocket=wayland --env=DISPLAY=:0 org.openscad.OpenSCAD -o preview.png --camera=0,0,0,60,0,30,200 model.scad

# Export to STL
flatpak-spawn --host flatpak run org.openscad.OpenSCAD -o model.stl model.scad

# Export to 3MF
flatpak-spawn --host flatpak run org.openscad.OpenSCAD -o model.3mf model.scad
```

**Note on PNG rendering**: On Wayland (Bazzite), `--nosocket=wayland --env=DISPLAY=:0` is required to force XWayland fallback. Without this, OpenSCAD's offscreen OpenGL rendering fails.

## Tests Log

| # | Folder | Description | Status |
|---|--------|-------------|--------|
| 1 | test-01-parametric-box | Hollow box with configurable dimensions and wall thickness | Done |
| 2 | test-02-tintin-rocket | Tintin-style moon rocket with ogive nose, fins, nozzle, bands, portholes | Done |
