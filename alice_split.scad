/* 1u = 1mm */
$fn = 50;

// CONSTANTS
PLATE_PLACEHOLDER_SIZE = 19.05;
SWITCH_SIZE = 14;
ROTATION = 10; // degrees

// https://cdn.matt3o.com/uploads/2018/05/keycap-size-diagram.png
module key(width=1) {
    translate([width*PLATE_PLACEHOLDER_SIZE/2, PLATE_PLACEHOLDER_SIZE/2])
        difference() {
            square([width*PLATE_PLACEHOLDER_SIZE, PLATE_PLACEHOLDER_SIZE], center=true); // keycap placeholder space
            square([SWITCH_SIZE, SWITCH_SIZE], center=true);
        }
}

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
                    key(size);
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

left_center_cluster = [
[0.5, 1, 1, 1, 1],
[0,   1, 1, 1, 1],
[0.25, 1, 1, 1, 1],
[0.75, 1, 1, 1, 1],
[0.75, 1.5, 2, 1]
];

// #2
/* key(1); */

cluster(left_cluster);
translate([4.5*PLATE_PLACEHOLDER_SIZE, 0, 0])
    rotate(a=[0, 0, -1 * ROTATION])
    translate([-0.75*PLATE_PLACEHOLDER_SIZE, 0, 0])
    cluster(left_center_cluster);

