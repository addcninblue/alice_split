include <base.scad>;
right(TYPE_D);

translate([0, 0, PLATE_HEIGHT])
    right(TYPE_C);

left(TYPE_D);

translate([0, 0, PLATE_HEIGHT])
    left(TYPE_C);
