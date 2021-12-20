/* 1u = 1mm */
$fn = 50;
$fa = 5;
$fs = 0.1;

// CONSTANTS
PLATE_PLACEHOLDER_SIZE = 19.05;
SWITCH_SIZE = 14; // Change to 18 to see keycap clearance
ROTATION = 10; // degrees
RIGHT_PLATE_OFFSET = 6.5;

PLATE_HEIGHT = 5;

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

module cluster(keys) { // 2d array
    for (row_index = [0:len(keys)-1]) {
        row_lengths = accumulate_lengths(keys[row_index]);

        for (col_index = [1:len(keys[row_index])-1]) {
            x_offset = row_lengths[col_index];
            y_offset = len(keys)-1-row_index;
            size = keys[row_index][col_index];

            if (size >= 1) {
                translate([x_offset * PLATE_PLACEHOLDER_SIZE, y_offset * PLATE_PLACEHOLDER_SIZE, 0])
                    switch(size); // TODO: change back to switch()
            }
        }
    }
}

// LEFT CLUSTER
//        PAD  ESC PAD   MODS KEY
left_cluster = [[0.5,  1, 0.25, 1,    1],
                [0.25, 1, 0.25, 1.5,  1],
                [0,    1, 0.25, 1.75, 1],
                [1,             2.25, 1],
                [1.25,          1.25]];

left_center_cluster = [[0.5,  1,   1, 1, 1],
                       [0,    1,   1, 1, 1],
                       [0.25, 1,   1, 1, 1],
                       [0.75, 1,   1, 1, 1],
                       [0.75, 1.5, 2, 1]];

right_center_cluster = [[0.75, 1,   1, 1, 1],
                        [0.25, 1,   1, 1, 1],
                        [0.5,  1,   1, 1, 1],
                        [0,    1,   1, 1, 1],
                        [0,    2.75, 1.5]];

right_cluster = [[0.25,   1, 1, 1, 1],
                 [0,   1, 1, 1, 1.5],
                 [0.5,    1, 1, 2.25],
                 [0.25,   1, 1, 1.75, 1],
                 [2.5, 1.5]];

LEFT_CENTER_OFFSET = left_center_cluster[len(left_center_cluster) - 1][0];

WIDTH = 9;
HEIGHT = 5;
RADIUS = 0.25;
PADDING = 0.25;

// Left Plate
LEFT_CENTER_LENGTH = sum(left_center_cluster[len(left_center_cluster) - 1]);

linear_extrude(height=PLATE_HEIGHT, center=true)
difference() {
    union() {
        translate([-PADDING*PLATE_PLACEHOLDER_SIZE, -PADDING*PLATE_PLACEHOLDER_SIZE, 0])
            square([(4.5+LEFT_CENTER_OFFSET+PADDING)*PLATE_PLACEHOLDER_SIZE, (HEIGHT+2*PADDING)*PLATE_PLACEHOLDER_SIZE]);

        translate([4.5*PLATE_PLACEHOLDER_SIZE, 0, 0])
            rotate(a=[0, 0, -ROTATION])
            translate([-LEFT_CENTER_OFFSET*PLATE_PLACEHOLDER_SIZE, -PADDING*PLATE_PLACEHOLDER_SIZE, 0])
            square([(LEFT_CENTER_LENGTH+PADDING)*PLATE_PLACEHOLDER_SIZE, (HEIGHT+2*PADDING)*PLATE_PLACEHOLDER_SIZE]);
    };

    union() {
        cluster(left_cluster);
        translate([4.5*PLATE_PLACEHOLDER_SIZE, 0, 0])       // Move object to appropriate position
            rotate(a=[0, 0, -ROTATION])                 // Apply rotation, centered on bottom left key
            translate([-LEFT_CENTER_OFFSET*PLATE_PLACEHOLDER_SIZE, 0, 0]) // Translate bottom left cluster corner to 0,0
            cluster(left_center_cluster);

        // #2
        translate([3.75*PLATE_PLACEHOLDER_SIZE, 4.07*PLATE_PLACEHOLDER_SIZE, 0])
            switch(1);

        // Scuffed: Take out top triangle
        translate([0, (HEIGHT+PADDING)*PLATE_PLACEHOLDER_SIZE, 0])
            square([(LEFT_CENTER_LENGTH+PADDING)*PLATE_PLACEHOLDER_SIZE, PLATE_PLACEHOLDER_SIZE]);

        // Scuffed: Take out center left triangle
        translate([4.5*PLATE_PLACEHOLDER_SIZE, 0, 0])
            rotate(a=[0, 0, -ROTATION])
            translate([-LEFT_CENTER_OFFSET*PLATE_PLACEHOLDER_SIZE, (HEIGHT+PADDING)*PLATE_PLACEHOLDER_SIZE, 0])
            square([(LEFT_CENTER_LENGTH+PADDING)*PLATE_PLACEHOLDER_SIZE, PLATE_PLACEHOLDER_SIZE]);
    };
};

// Right Plate

RIGHT_CENTER_LENGTH = sum(right_center_cluster[len(right_center_cluster) - 1]);
RIGHT_CENTER_MAX_LENGTH = sum(right_center_cluster[0]); // TODO: cleanup

RIGHT_LENGTH = sum(right_cluster[len(right_cluster) - 2]);

linear_extrude(height=PLATE_HEIGHT, center=true)
difference(){
    union() {
        translate([(0.5+RIGHT_CENTER_MAX_LENGTH) * PLATE_PLACEHOLDER_SIZE, RIGHT_PLATE_OFFSET*PLATE_PLACEHOLDER_SIZE, 0])
            rotate(a=[0, 0, ROTATION])
            translate([-(RIGHT_CENTER_MAX_LENGTH + PADDING)*PLATE_PLACEHOLDER_SIZE, -PADDING*PLATE_PLACEHOLDER_SIZE, 0])
            square([(RIGHT_CENTER_MAX_LENGTH + 4*PADDING)*PLATE_PLACEHOLDER_SIZE, (HEIGHT+2*PADDING)*PLATE_PLACEHOLDER_SIZE]);

        translate([(0.1+RIGHT_CENTER_MAX_LENGTH-PADDING)*PLATE_PLACEHOLDER_SIZE, (RIGHT_PLATE_OFFSET-PADDING)*PLATE_PLACEHOLDER_SIZE, 0])
            square([(RIGHT_LENGTH+2*PADDING)*PLATE_PLACEHOLDER_SIZE, (HEIGHT+2*PADDING)*PLATE_PLACEHOLDER_SIZE]);
    }

    union() {
        translate([(0.5+RIGHT_CENTER_MAX_LENGTH) * PLATE_PLACEHOLDER_SIZE, RIGHT_PLATE_OFFSET*PLATE_PLACEHOLDER_SIZE, 0])
            rotate(a=[0, 0, ROTATION])
            translate([-(RIGHT_CENTER_MAX_LENGTH) * PLATE_PLACEHOLDER_SIZE, 0, 0]) // Translate bottom right cluster corner to 0,0
            cluster(right_center_cluster);

        translate([(0.1+RIGHT_CENTER_MAX_LENGTH) * PLATE_PLACEHOLDER_SIZE, RIGHT_PLATE_OFFSET*PLATE_PLACEHOLDER_SIZE, 0])
            cluster(right_cluster);

        translate([(0.5+RIGHT_CENTER_MAX_LENGTH) * PLATE_PLACEHOLDER_SIZE, RIGHT_PLATE_OFFSET*PLATE_PLACEHOLDER_SIZE, 0])
            rotate(a=[0, 0, ROTATION])
            translate([-(RIGHT_CENTER_MAX_LENGTH + PADDING)*PLATE_PLACEHOLDER_SIZE, (HEIGHT+PADDING)*PLATE_PLACEHOLDER_SIZE, 0])
            square([(RIGHT_CENTER_MAX_LENGTH + 4*PADDING)*PLATE_PLACEHOLDER_SIZE, PLATE_PLACEHOLDER_SIZE]);

        translate([(0.1+RIGHT_CENTER_MAX_LENGTH-PADDING)*PLATE_PLACEHOLDER_SIZE, (RIGHT_PLATE_OFFSET+HEIGHT+PADDING)*PLATE_PLACEHOLDER_SIZE, 0])
            square([(RIGHT_LENGTH+2*PADDING)*PLATE_PLACEHOLDER_SIZE, PLATE_PLACEHOLDER_SIZE]);
    }
}
