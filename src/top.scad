include <base.scad>;
right(TYPE_B);

translate([0, 0, PLATE_HEIGHT])
    right(TYPE_A);

left(TYPE_B);

translate([0, 0, PLATE_HEIGHT])
    left(TYPE_A);
