# Multi Color Bowling Ball Holder with Text

A fully customizable multicolor bowling ball holder with text on it! Change the font, text size, spacing, and depth. Modify all diameters, the wall thickness, lip size, and more.  Export multiple stl files to combine in your slices to create a multi color print!

| SCAD | Printed Example |
| - | - |
| ![SCAD Example](holder.png) | ![Printed Example](example.jpg) |

## Customize

**It is generally recommend using OpenSCAD**  This way, you may make and view your modifications prior to rendering.  Unfortunately, rendering can take a lot of time because, OpenSCAD is single threaded. You may wish to consider switching to a nightly build and changing the backend from CGAL to manifold in the advanced section, and enabling the lazy union feature.

### OpenSCAD

1. Open `holder.scad`
2. Modify the variable in the file or on the right with the Customizer
3. Render it: _F6_ OR _Design➡Render_ (Many minuets depending on openSCAD version)
4. Export it: _F7_ for `stl` OR _File➡Export_ and select the file type wanted.

#### Multicolor

1. Slide the `SHOW_EXTRUDER_NUMBER` slider in the customizer to select the separated parts: base & text
2. Export them individually by repeating steps 3 & 4 above
3. Import the files into your favorite slicer at the same time
4. Color each part separately there

### Command-line

Adjust the parameters in the `holder.json` file, then run the following command: (Replace `stl` with `3mf` or other supported export types)

```sh
openscad -o holder.stl -p holder.json holder.scad
```

Repeat as necessary for multicolor parts.

## Contribute

_Become a contributor!  Feel free to issue any pull requests for added features to share._

---

SCAD Bowling Ball Holder with Text © 2025 by Matthew Cordaro is licensed under CC BY-NC-SA 4.0
