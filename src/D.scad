include <base.scad>;

linear_extrude(height=PLATE_HEIGHT, center=true)
    union() {
        difference() {
            left(TYPE_C, PADDING);
            left(TYPE_C, 0.5*PADDING);
        };

        difference() {
            right(TYPE_C, PADDING);
            right(TYPE_C, 0.5*PADDING);
        };
    };
