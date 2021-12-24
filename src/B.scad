include <base.scad>;

linear_extrude(height=PLATE_HEIGHT, center=true)
    union() {
        left(TYPE_B);
        right(TYPE_B);
    }
