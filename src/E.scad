include <base.scad>;

linear_extrude(height=PLATE_HEIGHT, center=true)
    union() {
        left(TYPE_C, PADDING);
        right(TYPE_C, PADDING);
    };
