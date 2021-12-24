include <const.scad>;

/* 1u = 1mm */
$fn = 50;
$fa = 5;
$fs = 0.1;

// VARIABLES
KNOB_LOCATION = KNOB_LEFT;

// CONSTANTS
PLATE_PLACEHOLDER_SIZE = 19.05;
SWITCH_SIZE = 14; // Change to 18 to see keycap clearance
ROTATION = 10; // degrees
RIGHT_PLATE_OFFSET = 7;

// Thicknesses: 5 5 5 3
PLATE_HEIGHT = 5;
BASE_HEIGHT = 3;
OUTER_WIDTH = 3;
INNER_WIDTH = 1;

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
        circle(6.4/2);
    } else if (type == TYPE_A) {
        circle(16/2);
    }
}

// LEFT CLUSTER
esc_cluster = [[0.5, 1], [0.25, 1], [0, 1], [0, 0], [0, 0]];

//        PAD  ESC PAD   MODS KEY
left_cluster = [[1.5,  0.25, 1,    1],
                [1.25, 0.25, 1.5,  1],
                [1,    0.25, 1.75, 1],
                [1,             2.25, 1],
                [1,          1.25]];

left_center_cluster = [[0.5,  1,   1, 1, 1],
                       [0,    1,   1, 1, 1],
                       [0.25, 1,   1, 1, 1],
                       [0.75, 1,   1, 1, 1],
                       [0.50, 1.5, 2, 1.25]];

right_center_cluster = [[0.75, 1,   1, 1, 1],
                        [0.25, 1,   1, 1, 1],
                        [0.5,  1,   1, 1, 1],
                        [0,    1,   1, 1, 1],
                        [0,    2.75, 1.5]];

right_cluster = [[1.25,   1, 1, 1],
                 [1,   1, 1, 1.5],
                 [0.5,    1, 1, 2.25],
                 [0.25,   1, 1, 1.75, 1],
                 [3, 1.5]];

minus_key = [[0.25, 1], [0, 0], [0, 0], [0, 0], [0, 0]];
p_key = [[0, 0], [0, 1], [0, 0], [0, 0], [0, 0]];

LEFT_CENTER_OFFSET = left_center_cluster[len(left_center_cluster) - 1][0];

WIDTH = 9;
HEIGHT = 5;
PADDING = 0.25;

module left(type, padding=PADDING) {
    LEFT_CENTER_LENGTH = sum(left_center_cluster[len(left_center_cluster) - 1]);

    module base() {
        difference() {
            union() {
                // left
                translate([-padding*PLATE_PLACEHOLDER_SIZE, -padding*PLATE_PLACEHOLDER_SIZE, 0])
                    square([(4.5+LEFT_CENTER_OFFSET+padding)*PLATE_PLACEHOLDER_SIZE, (HEIGHT+2*padding)*PLATE_PLACEHOLDER_SIZE]);

                // middle left
                translate([4*PLATE_PLACEHOLDER_SIZE, 0.05*PLATE_PLACEHOLDER_SIZE, 0])
                    rotate(a=[0, 0, -ROTATION])
                    translate([-LEFT_CENTER_OFFSET*PLATE_PLACEHOLDER_SIZE, -padding*PLATE_PLACEHOLDER_SIZE, 0])
                    square([(LEFT_CENTER_LENGTH+padding)*PLATE_PLACEHOLDER_SIZE, (HEIGHT+2*padding)*PLATE_PLACEHOLDER_SIZE]);
            };

            union() {
                // Scuffed: Take out top triangle
                translate([0, (HEIGHT+padding)*PLATE_PLACEHOLDER_SIZE, 0])
                    square([(LEFT_CENTER_LENGTH+1)*PLATE_PLACEHOLDER_SIZE, PLATE_PLACEHOLDER_SIZE]);

                // Scuffed: Take out center left triangle
                translate([4*PLATE_PLACEHOLDER_SIZE, 0.05*PLATE_PLACEHOLDER_SIZE, 0])
                    rotate(a=[0, 0, -ROTATION])
                    translate([-LEFT_CENTER_OFFSET*PLATE_PLACEHOLDER_SIZE, (HEIGHT+padding)*PLATE_PLACEHOLDER_SIZE, 0])
                    square([(LEFT_CENTER_LENGTH+1)*PLATE_PLACEHOLDER_SIZE, PLATE_PLACEHOLDER_SIZE]);
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
        translate([4*PLATE_PLACEHOLDER_SIZE, 0.05*PLATE_PLACEHOLDER_SIZE, 0])       // Move object to appropriate position
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
            translate([4*PLATE_PLACEHOLDER_SIZE, 0.05*PLATE_PLACEHOLDER_SIZE, 0])
                rotate(a=[0, 0, -ROTATION])
                translate([-LEFT_CENTER_OFFSET*PLATE_PLACEHOLDER_SIZE, PLATE_PLACEHOLDER_SIZE, 0])
                square([1*PLATE_PLACEHOLDER_SIZE, 4*PLATE_PLACEHOLDER_SIZE]);
        }
    };

    difference() {
        minkowski() {
            base();
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
        } else {
            base_cutouts();
            esc_cluster_cutout();
        }
    };
}

module right(type, padding=PADDING) {
    RIGHT_CENTER_MAX_LENGTH = sum(right_center_cluster[0]);
    RIGHT_LENGTH = sum(right_cluster[len(right_cluster) - 2]);

    module base() {
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
            translate([-(RIGHT_CENTER_MAX_LENGTH+0.08)*PLATE_PLACEHOLDER_SIZE, (4-0.15)*PLATE_PLACEHOLDER_SIZE,0])
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
        translate([-0.54 * PLATE_PLACEHOLDER_SIZE, -0.12*PLATE_PLACEHOLDER_SIZE, 0])
            cluster(right_cluster, type);

        // right floating cluster
        translate([-0.50 * PLATE_PLACEHOLDER_SIZE, -0.05*PLATE_PLACEHOLDER_SIZE, 0])
            cluster(minus_key, type);
        translate([-0.53 * PLATE_PLACEHOLDER_SIZE, -0.10*PLATE_PLACEHOLDER_SIZE, 0])
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

    translate([RIGHT_CENTER_MAX_LENGTH * PLATE_PLACEHOLDER_SIZE, RIGHT_PLATE_OFFSET * PLATE_PLACEHOLDER_SIZE, 0])
        rotate(a=[0, 0, -ROTATION])
        difference() {
            minkowski() {
                base();
                circle(OUTER_WIDTH);
            };

            if (type == TYPE_A) {
                minkowski() {
                    base_cutouts();
                    circle(INNER_WIDTH);
                }
            } else {
                base_cutouts();
            }

            rotary_knob_cutout();
        };
}
