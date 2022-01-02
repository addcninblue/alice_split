include <base.scad>;
right(TYPE_D);

translate([0, 0, BASE_HEIGHT])
    right(TYPE_C);

left(TYPE_D);

translate([0, 0, BASE_HEIGHT])
    left(TYPE_C);

translate([0, 0, PLATE_HEIGHT+BASE_HEIGHT])
right(TYPE_B);

translate([0, 0, 2*PLATE_HEIGHT+BASE_HEIGHT])
    right(TYPE_A);

translate([0, 0, PLATE_HEIGHT+BASE_HEIGHT])
left(TYPE_B);

translate([0, 0, 2*PLATE_HEIGHT+BASE_HEIGHT])
    left(TYPE_A);
