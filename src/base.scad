include <const.scad>;
include <constraints.scad>;

/* 1u = 1mm */
$fn = 50;
$fa = 5;
$fs = 0.1;

DEBUG = false;

// VARIABLES
KNOB_LOCATION = KNOB_LEFT;

// CONSTANTS
PLATE_PLACEHOLDER_SIZE = 19.05;
SWITCH_SIZE = 14; // Change to 18 to see keycap clearance
ROTATION = 12; // degrees
RIGHT_PLATE_OFFSET = 7;

// Thicknesses: 5 5 5 3
PLATE_HEIGHT = 5;
BASE_HEIGHT = 3;
OUTER_WIDTH = 3;
INNER_WIDTH = 1;

MAGNET_LENGTH = 25.4;
MAGNET_WIDTH = 3.2;
MAGNET_HEIGHT = 4; // 3.2
MAGNET_DISTANCE = 0;

AUDIO_LENGTH = 18;
AUDIO_RADIUS = 8.2/2;

IO_HOLE_LENGTH = 20;

HORIZONTAL_ANGLE = 20;
VERTICAL_ANGLE = -16;

// https://cdn.matt3o.com/uploads/2018/05/keycap-size-diagram.png
module plate_placeholder(width=1) {
    translate([width*PLATE_PLACEHOLDER_SIZE/2, PLATE_PLACEHOLDER_SIZE/2])
        square([width*PLATE_PLACEHOLDER_SIZE, PLATE_PLACEHOLDER_SIZE], center=true); // keycap placeholder space
}

module switch(width=1) {
    translate([width*PLATE_PLACEHOLDER_SIZE/2, PLATE_PLACEHOLDER_SIZE/2])
        square([SWITCH_SIZE, SWITCH_SIZE], center=true);
}

function sum(row, i = 0, sum_so_far = 0) = len(row) == i ? sum_so_far : sum(row, i+1, sum_so_far+row[i]);

function accumulate_lengths(row, i = 0, sum=0) = len(row) - 1 == i ? [sum] :
    concat(sum, accumulate_lengths(row, i+1, sum+row[i]));

module cluster(keys, type) { // 2d array
    for (row_index = [0:len(keys)-1]) {
        row_lengths = accumulate_lengths(keys[row_index]);

        for (col_index = [1:len(keys[row_index])-1]) {
            x_offset = row_lengths[col_index];
            y_offset = len(keys)-1-row_index;
            size = keys[row_index][col_index];

            if (size >= 1) {
                if (type == TYPE_B) {
                    translate([x_offset * PLATE_PLACEHOLDER_SIZE, y_offset * PLATE_PLACEHOLDER_SIZE, 0])
                        switch(size);
                } else if (type == TYPE_A) {
                    translate([x_offset * PLATE_PLACEHOLDER_SIZE, y_offset * PLATE_PLACEHOLDER_SIZE, 0])
                        plate_placeholder(size);
                }
            }
        }
    }
}

module ky_040(type) {
    if (type == TYPE_B) {
        circle(7/2);
    } else if (type == TYPE_A) {
        circle(16/2);
    }
}

module io_hole(type) {
    if (type == TYPE_C) {
         square([2*PADDING*PLATE_PLACEHOLDER_SIZE, IO_HOLE_LENGTH]);
    }
}

module audio_hole(type) {
    if (type == TYPE_B || type == TYPE_D) {
         rotate([0, 90, 0])
         cylinder(AUDIO_LENGTH+PADDING, AUDIO_RADIUS, AUDIO_RADIUS);
    }
}

// LEFT CLUSTER
esc_cluster = [[0.5, 1], [0.25, 1], [0, 1], [0, 0], [0, 0]];

//        PAD  ESC PAD   MODS KEY
left_cluster = [[1.5,  0.25, 1,    1],
                [1.25, 0.5, 1.25,  1],
                [1,    0.5,  1.5, 1],
                [1,    0.5,  1.75, 1],
                [1.5,        0]];

left_center_cluster = [[0.5,  1,   1, 1, 1],
                       [0,    1,   1, 1, 1],
                       [0.25, 1,   1, 1, 1],
                       [0.75, 1,   1, 1, 1],
                       [0.25, 1.25, 1, 1.25, 1.25]];

right_center_cluster = [[0.75, 1,   1, 1, 1],
                        [0.25, 1,   1, 1, 1],
                        [0.5,  1,   1, 1, 1],
                        [0,    1,   1, 1, 1],
                        [0, 1.25,    1, 1, 1.25]];

right_cluster = [[1.25,   1, 1, 1],
                 [1,   1, 1, 1.25],
                 [0.5,    1, 1, 1.75],
                 [0.25,   1, 1, 1, 0.65],
                 [1.25, 1, 1, 1]];

minus_key = [[0.25, 1], [0, 0], [0, 0], [0, 0], [0, 0]];
p_key = [[0, 0], [0, 1], [0, 0], [0, 0], [0, 0]];

echo(check_constraints([esc_cluster, left_cluster, left_center_cluster, right_center_cluster, right_cluster, minus_key, p_key]));

LEFT_CENTER_OFFSET = left_center_cluster[len(left_center_cluster) - 1][0];

WIDTH = 9;
HEIGHT = 5;
PADDING = 0.25;

module left(type, padding=PADDING) {
    LEFT_CENTER_LENGTH = sum(left_center_cluster[len(left_center_cluster) - 1]);

    module base(padding) {
        difference() {
            union() {
                // left
                translate([-padding*PLATE_PLACEHOLDER_SIZE, -padding*PLATE_PLACEHOLDER_SIZE, 0])
                    square([(4.5+LEFT_CENTER_OFFSET+padding)*PLATE_PLACEHOLDER_SIZE, (HEIGHT+2*padding)*PLATE_PLACEHOLDER_SIZE]);

                // middle left
                translate([3.6*PLATE_PLACEHOLDER_SIZE, 0.05*PLATE_PLACEHOLDER_SIZE, 0])
                    rotate(a=[0, 0, -ROTATION])
                    translate([-LEFT_CENTER_OFFSET*PLATE_PLACEHOLDER_SIZE, -padding*PLATE_PLACEHOLDER_SIZE, 0])
                    square([(LEFT_CENTER_LENGTH+padding)*PLATE_PLACEHOLDER_SIZE, (HEIGHT+2*padding)*PLATE_PLACEHOLDER_SIZE]);
            };

            union() {
                // Scuffed: Take out top triangle
                translate([0, (HEIGHT+padding)*PLATE_PLACEHOLDER_SIZE, 0])
                    square([(LEFT_CENTER_LENGTH+1)*PLATE_PLACEHOLDER_SIZE, PLATE_PLACEHOLDER_SIZE]);

                // Scuffed: Take out center left triangle
                translate([3.6*PLATE_PLACEHOLDER_SIZE, 0.05*PLATE_PLACEHOLDER_SIZE, 0])
                    rotate(a=[0, 0, -ROTATION])
                    translate([-(LEFT_CENTER_OFFSET+1)*PLATE_PLACEHOLDER_SIZE, (HEIGHT+padding)*PLATE_PLACEHOLDER_SIZE, 0])
                    square([(LEFT_CENTER_LENGTH+2)*PLATE_PLACEHOLDER_SIZE, PLATE_PLACEHOLDER_SIZE]);
            };
        };
    };

    module esc_cluster_cutout() {
        translate([0, 0.15*PLATE_PLACEHOLDER_SIZE, 0])
            cluster(esc_cluster, type);
    };

    module base_cutouts() {
        // left
        cluster(left_cluster, type);

        // center left
        translate([3.6*PLATE_PLACEHOLDER_SIZE, 0.05*PLATE_PLACEHOLDER_SIZE, 0])       // Move object to appropriate position
            rotate(a=[0, 0, -ROTATION])                 // Apply rotation, centered on bottom left key
            translate([-LEFT_CENTER_OFFSET*PLATE_PLACEHOLDER_SIZE, 0, 0]) // Translate bottom left cluster corner to 0,0
            cluster(left_center_cluster, type);

        // #2
        translate([3.75*PLATE_PLACEHOLDER_SIZE, 4.07*PLATE_PLACEHOLDER_SIZE, 0])
            if (type == TYPE_B) {
                switch(1);
            } else if (type == TYPE_A) {
                plate_placeholder(1);
            }

        // islands
        if (type == TYPE_A) {
            // left
            translate([3*PLATE_PLACEHOLDER_SIZE, PLATE_PLACEHOLDER_SIZE, 0])
                square([1.75*PLATE_PLACEHOLDER_SIZE, 4*PLATE_PLACEHOLDER_SIZE]);

            // center left
            translate([3.6*PLATE_PLACEHOLDER_SIZE, 0.05*PLATE_PLACEHOLDER_SIZE, 0])
                rotate(a=[0, 0, -ROTATION])
                translate([-LEFT_CENTER_OFFSET*PLATE_PLACEHOLDER_SIZE, PLATE_PLACEHOLDER_SIZE, 0])
                square([1*PLATE_PLACEHOLDER_SIZE, 4*PLATE_PLACEHOLDER_SIZE]);
        }
    };

    module magnet_cutouts() {
        translate([0, -padding*PLATE_PLACEHOLDER_SIZE - MAGNET_WIDTH/2, 0])
            square([MAGNET_LENGTH, MAGNET_WIDTH]);

        translate([0, (padding + 5)*PLATE_PLACEHOLDER_SIZE - MAGNET_WIDTH/2, 0])
            square([MAGNET_LENGTH, MAGNET_WIDTH]);

        translate([3.6*PLATE_PLACEHOLDER_SIZE, 0.05*PLATE_PLACEHOLDER_SIZE, 0])
            rotate(a=[0, 0, -ROTATION])
            translate([(3.5-LEFT_CENTER_OFFSET-padding)*PLATE_PLACEHOLDER_SIZE, -padding*PLATE_PLACEHOLDER_SIZE-MAGNET_WIDTH/2, 0])
            square([MAGNET_LENGTH, MAGNET_WIDTH]);

        translate([3.6*PLATE_PLACEHOLDER_SIZE, 0.05*PLATE_PLACEHOLDER_SIZE, 0])
            rotate(a=[0, 0, -ROTATION])
            translate([(3.5-LEFT_CENTER_OFFSET-padding)*PLATE_PLACEHOLDER_SIZE, (HEIGHT+padding)*PLATE_PLACEHOLDER_SIZE-MAGNET_WIDTH/2, 0])
            square([MAGNET_LENGTH, MAGNET_WIDTH]);
    };

    module io_cutout() {
        translate([3.6*PLATE_PLACEHOLDER_SIZE, 0.05*PLATE_PLACEHOLDER_SIZE, 0])
            rotate(a=[0, 0, -ROTATION])
            translate([(5-LEFT_CENTER_OFFSET)*PLATE_PLACEHOLDER_SIZE, (HEIGHT)*PLATE_PLACEHOLDER_SIZE-IO_HOLE_LENGTH, 0])
        io_hole(type);
    };

    module audio_cutout() {
        if (type == TYPE_B) {
            translate([3.6*PLATE_PLACEHOLDER_SIZE, 0.05*PLATE_PLACEHOLDER_SIZE, 0])
                rotate(a=[0, 0, -ROTATION])
                translate([(5-LEFT_CENTER_OFFSET-0.50)*PLATE_PLACEHOLDER_SIZE, (HEIGHT-0.5)*PLATE_PLACEHOLDER_SIZE-IO_HOLE_LENGTH, 0])
                audio_hole(type);
        } else if (type == TYPE_D) {
            translate([3.6*PLATE_PLACEHOLDER_SIZE, 0.05*PLATE_PLACEHOLDER_SIZE, 0])
                rotate(a=[0, 0, -ROTATION])
                translate([(5-LEFT_CENTER_OFFSET-0.50)*PLATE_PLACEHOLDER_SIZE, (HEIGHT-0.5)*PLATE_PLACEHOLDER_SIZE-IO_HOLE_LENGTH])
                audio_hole(type);
        }
    };

    module base_rotate() {
        translate([0, 0, (5+2*PADDING)*PLATE_PLACEHOLDER_SIZE * sin(-VERTICAL_ANGLE)])
            rotate([VERTICAL_ANGLE, -HORIZONTAL_ANGLE, 0])
            children();
    };

    module case() {
        difference() {
            minkowski() {
                base(padding);
                circle(OUTER_WIDTH);
            };

            if (type == TYPE_A) {
                minkowski() {
                    base_cutouts();
                    circle(INNER_WIDTH);
                };

                minkowski() {
                    esc_cluster_cutout();
                    circle(INNER_WIDTH);
                }
            } else if (type == TYPE_B) {
                base_cutouts();
                esc_cluster_cutout();
            } else if (type == TYPE_C) {
                base(0.5*PADDING);
            }
        };
    };

    if (DEBUG) {
        case();
    } else {
        difference() {
            if (type == TYPE_D) {
                difference() {
                    linear_extrude(height=100)
                        base_rotate()
                        case();

                    base_rotate()
                        translate([0, 0, 50])
                        cube([500, 500, 100], center=true);
                }
            } else {
                linear_extrude(height=PLATE_HEIGHT)
                    case();
            }

            if (type == TYPE_B) {
                translate([0, 0, MAGNET_DISTANCE])
                    linear_extrude(height=MAGNET_HEIGHT)
                    magnet_cutouts();
                audio_cutout();
            } else if (type == TYPE_D) {
                base_rotate()
                union() {
                    translate([0, 0, -MAGNET_DISTANCE-MAGNET_HEIGHT])
                        linear_extrude(height=MAGNET_HEIGHT)
                        magnet_cutouts();
                    audio_cutout();
                }
            }
        };
    }
}

module right(type, padding=PADDING) {
    RIGHT_CENTER_MAX_LENGTH = sum(right_center_cluster[0]);
    RIGHT_LENGTH = sum(right_cluster[len(right_cluster) - 2]);

    module base(padding) {
        difference(){
            union() {
                // center right
                translate([0.5 * PLATE_PLACEHOLDER_SIZE, 0, 0])
                    rotate(a=[0, 0, ROTATION])
                    translate([-(RIGHT_CENTER_MAX_LENGTH + padding)*PLATE_PLACEHOLDER_SIZE, -padding*PLATE_PLACEHOLDER_SIZE, 0])
                    square([(RIGHT_CENTER_MAX_LENGTH + 4*padding)*PLATE_PLACEHOLDER_SIZE, (HEIGHT+2*padding)*PLATE_PLACEHOLDER_SIZE]);

                // right
                translate([-(padding+0.2)*PLATE_PLACEHOLDER_SIZE, -(padding+0.05)*PLATE_PLACEHOLDER_SIZE, 0])
                    square([(RIGHT_LENGTH+2*padding)*PLATE_PLACEHOLDER_SIZE, (HEIGHT+2*padding)*PLATE_PLACEHOLDER_SIZE]);
            }

            union() {
                // Scuffed: Take out center right triangle
                translate([0.5 * PLATE_PLACEHOLDER_SIZE, 0, 0])
                    rotate(a=[0, 0, ROTATION])
                    translate([-(RIGHT_CENTER_MAX_LENGTH + padding)*PLATE_PLACEHOLDER_SIZE, (HEIGHT+padding)*PLATE_PLACEHOLDER_SIZE, 0])
                    square([(RIGHT_CENTER_MAX_LENGTH + 4*padding)*PLATE_PLACEHOLDER_SIZE, PLATE_PLACEHOLDER_SIZE]);

                // Scuffed: Take out top triangle
                translate([-(padding+0.5)*PLATE_PLACEHOLDER_SIZE, (HEIGHT+padding-0.05)*PLATE_PLACEHOLDER_SIZE, 0])
                    square([(RIGHT_LENGTH+2*padding)*PLATE_PLACEHOLDER_SIZE, PLATE_PLACEHOLDER_SIZE]);
            }
        }
    };

    module rotary_knob_cutout() {
        if (KNOB_LOCATION == KNOB_LEFT) {
            translate([-(RIGHT_CENTER_MAX_LENGTH+0.20)*PLATE_PLACEHOLDER_SIZE, (4-0.50)*PLATE_PLACEHOLDER_SIZE,0])
                ky_040(type);
        } else if (KNOB_LOCATION == KNOB_RIGHT) {
            translate([(RIGHT_CENTER_MAX_LENGTH-0.12)*PLATE_PLACEHOLDER_SIZE, (5-0.25)*PLATE_PLACEHOLDER_SIZE,0])
                ky_040(type);
        }
    };

    module base_cutouts() {
        // center right
        translate([0.5 * PLATE_PLACEHOLDER_SIZE, 0, 0])
            rotate(a=[0, 0, ROTATION])
            translate([-(RIGHT_CENTER_MAX_LENGTH) * PLATE_PLACEHOLDER_SIZE, 0, 0]) // Translate bottom right cluster corner to 0,0
            cluster(right_center_cluster, type);

        // right
        translate([-0.64 * PLATE_PLACEHOLDER_SIZE, -0.10*PLATE_PLACEHOLDER_SIZE, 0])
            cluster(right_cluster, type);

        // right floating cluster
        translate([-0.63 * PLATE_PLACEHOLDER_SIZE, -0.08*PLATE_PLACEHOLDER_SIZE, 0])
            cluster(minus_key, type);
        translate([-0.63 * PLATE_PLACEHOLDER_SIZE, -0.14*PLATE_PLACEHOLDER_SIZE, 0])
            cluster(p_key, type);

        // islands
        if (type == TYPE_A) {
            // center right
            translate([0.5 * PLATE_PLACEHOLDER_SIZE, 0, 0])
                rotate(a=[0, 0, ROTATION])
                translate([-0.88*PLATE_PLACEHOLDER_SIZE, PLATE_PLACEHOLDER_SIZE, 0])
                square([1*PLATE_PLACEHOLDER_SIZE, 4*PLATE_PLACEHOLDER_SIZE]);

            // right
            translate([-(0.2)*PLATE_PLACEHOLDER_SIZE, (1-0.05)*PLATE_PLACEHOLDER_SIZE, 0])
                square([1*PLATE_PLACEHOLDER_SIZE, 3*PLATE_PLACEHOLDER_SIZE]);
        }
    };

    module magnet_cutouts() {
        // center right
        translate([0.5 * PLATE_PLACEHOLDER_SIZE, 0, 0])
            rotate(a=[0, 0, ROTATION])
            translate([-RIGHT_CENTER_MAX_LENGTH*PLATE_PLACEHOLDER_SIZE, -padding*PLATE_PLACEHOLDER_SIZE - MAGNET_HEIGHT/2, 0])
            square([MAGNET_LENGTH, MAGNET_WIDTH]);

        translate([0.5 * PLATE_PLACEHOLDER_SIZE, 0, 0])
            rotate(a=[0, 0, ROTATION])
            translate([(-RIGHT_CENTER_MAX_LENGTH+2)*PLATE_PLACEHOLDER_SIZE, (HEIGHT + padding)*PLATE_PLACEHOLDER_SIZE - MAGNET_HEIGHT/2, 0])
            square([MAGNET_LENGTH, MAGNET_WIDTH]);

        // right
        translate([(RIGHT_CENTER_MAX_LENGTH - 2 - padding)*PLATE_PLACEHOLDER_SIZE, -1.25*padding*PLATE_PLACEHOLDER_SIZE - MAGNET_HEIGHT/2, 0]) // TODO: unsure why this one doesn't have 0.75
            square([MAGNET_LENGTH, MAGNET_WIDTH]);

        translate([(RIGHT_CENTER_MAX_LENGTH - 2 - padding)*PLATE_PLACEHOLDER_SIZE, (HEIGHT + padding)*PLATE_PLACEHOLDER_SIZE - MAGNET_HEIGHT/2, 0])
            square([MAGNET_LENGTH, MAGNET_WIDTH]);
    };

    module io_cutout() {
        translate([0.5 * PLATE_PLACEHOLDER_SIZE, 0, 0])
            rotate(a=[0, 0, ROTATION])
            translate([-(RIGHT_CENTER_MAX_LENGTH+2*PADDING)*PLATE_PLACEHOLDER_SIZE, (HEIGHT)*PLATE_PLACEHOLDER_SIZE - IO_HOLE_LENGTH, 0])
            io_hole(type);
    };

    module audio_cutout() {
        if (type == TYPE_B) {
            translate([0.5 * PLATE_PLACEHOLDER_SIZE, 0, 0])
                rotate(a=[0, 0, ROTATION])
                translate([-(RIGHT_CENTER_MAX_LENGTH+2*PADDING)*PLATE_PLACEHOLDER_SIZE, (HEIGHT-1.5)*PLATE_PLACEHOLDER_SIZE - IO_HOLE_LENGTH, 0])
                audio_hole(type);
        } else if (type == TYPE_D) {
            translate([0.5 * PLATE_PLACEHOLDER_SIZE, 0, 0])
                rotate(a=[0, 0, ROTATION])
                translate([-(RIGHT_CENTER_MAX_LENGTH+2*PADDING)*PLATE_PLACEHOLDER_SIZE, (HEIGHT-1.5)*PLATE_PLACEHOLDER_SIZE - IO_HOLE_LENGTH, PLATE_HEIGHT])
                audio_hole(type);
        }
    };

    module case() {
        difference() {
            minkowski() {
                base(padding);
                circle(OUTER_WIDTH);
            };

            if (type == TYPE_A) {
                minkowski() {
                    base_cutouts();
                    circle(INNER_WIDTH);
                }
            } else if (type == TYPE_B) {
                base_cutouts();
            } else if (type == TYPE_C) {
                base(0.5*PADDING);
                /* io_cutout(); */
            }

            rotary_knob_cutout();
        };
    };

    translate([RIGHT_CENTER_MAX_LENGTH * PLATE_PLACEHOLDER_SIZE, RIGHT_PLATE_OFFSET * PLATE_PLACEHOLDER_SIZE, 0])
        rotate(a=[0, 0, -ROTATION])
        if (DEBUG) {
            case();
        } else {
            difference() {
                if (type == TYPE_D) {
                    linear_extrude(height=BASE_HEIGHT)
                        case();
                } else {
                    linear_extrude(height=PLATE_HEIGHT)
                        case();
                }

                if (type == TYPE_B) {
                    translate([0, 0, MAGNET_DISTANCE])
                        linear_extrude(height=MAGNET_HEIGHT)
                        magnet_cutouts();
                    audio_cutout();
                } else if (type == TYPE_C) {
                    translate([0, 0, PLATE_HEIGHT-MAGNET_DISTANCE-MAGNET_HEIGHT])
                        linear_extrude(height=MAGNET_HEIGHT)
                        magnet_cutouts();
                    audio_cutout();
                }
            };
        }
}
