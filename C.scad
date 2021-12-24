include <base.scad>;

linear_extrude(height=PLATE_HEIGHT, center=true)
    union() {
        difference() {
            left("C", PADDING);
            left("C", 0.5*PADDING);
        };

        difference() {
            right("C", PADDING);
            right("C", 0.5*PADDING);
        };
    };
