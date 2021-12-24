include <base.scad>;

linear_extrude(height=PLATE_HEIGHT, center=true)
    union() {
        left(TYPE_A);
        right(TYPE_A);
    }
