// Format: #u, count
keycaps = [[1, 60], [1.25, 7], [1.5, 2], [1.75, 2],
           [2, 0],  [2.25, 1], [2.5, 0], [2.75, 1], [3, 0]];

function sum(row, i = 0, sum_so_far = 0) = len(row) == i ? sum_so_far : sum(row, i+1, sum_so_far+row[i]);

function mask_keys_matching(clusters, key_width) =
    [for (cluster = clusters)
       for (row = cluster)
           for (key_index = [1:len(cluster)-1])
               (row[key_index] == key_width) ? 1 : 0];

function check_constraints(clusters) =
    let (counts = [ for (keycap_count = keycaps)
                        let (key_width = keycap_count[0],
                             matches = mask_keys_matching(clusters, key_width))
                            sum(matches)])
        [ for (i = [0:len(keycaps)-1]) assert(keycaps[i][1] >= counts[i], str("Keycap size ", keycaps[i][0], ": ", "Found ", counts[i], " but only have ", keycaps[i][1], "."))];
