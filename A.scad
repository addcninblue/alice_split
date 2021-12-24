include <base.scad>;

linear_extrude(height=PLATE_HEIGHT, center=true)
    union() {
        left("A");
        right("A");
    }
