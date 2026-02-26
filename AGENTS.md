# Project Context

## Environment

- **OS**: Bazzite (Fedora Atomic/immutable desktop)
- **Editor**: VS Code terminal
- **Package management**: Flatpak is the primary method. Installing via rpm-ostree is possible but discouraged.
- **OpenSCAD status**: NOT yet installed. Recommended install method: `flatpak install flathub org.openscad.OpenSCAD`
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

## CLI Usage (Flatpak)

```bash
# Render to PNG preview
flatpak run org.openscad.OpenSCAD -o preview.png --camera=0,0,0,60,0,30,200 model.scad

# Export to STL
flatpak run org.openscad.OpenSCAD -o model.stl model.scad

# Export to 3MF
flatpak run org.openscad.OpenSCAD -o model.3mf model.scad
```

## Tests Log

| # | Folder | Description | Status |
|---|--------|-------------|--------|
| 1 | test-01-parametric-box | Hollow box with configurable dimensions and wall thickness | Pending |
