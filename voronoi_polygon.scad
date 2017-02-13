// This is the helper function using the original Voronoi script
// licensed under the terms of the GNU GPL version 3 (or later)

use <voronoi.scad>

//
// The voronoi_polygon() function fills an arbitrary polygon with a Voronoi pattern.
// Unfortunately, the bounding box has to be provided as a parameter since bboxing is not a trivial
// OpenSCAD topic. Please see http://forum.openscad.org/Bounding-box-td20220.html
//
// Parameters:
//   border (required) ... polygon to be filled by a Voronoi pattern (array of [x, y] pairs, no holes)
//   bbox (required)   ... bounding box of the border polygon parameter: [[minX, minY], [maxX, maxY]]
//   n                 ... number of nuclei sites to be generated (density, complexity: O(n^2) )
//   thickness         ... the thickness of the lines between cells
//   round             ... the radius applied to corners (fillet in CAD terms)
//   edging            ... the width of the border, set 0 for no border
//   seed              ... seed for the random generator (random if undefined)
//
module voronoi_polygon(border, bbox, n=30, thickness=1.7, round=1.0, edging=3.0, seed=undef) {

    // tolerate unordered bounding boxes, rename
    min_x = min(bbox[0][0], bbox[1][0]);
    min_y = min(bbox[0][1], bbox[1][1]);
    max_x = max(bbox[0][0], bbox[1][0]);
    max_y = max(bbox[0][1], bbox[1][1]);

    // compute sizes, centers and scaling
    size_x = max_x - min_x;
    size_y = max_y - min_y;
    L = max(size_x, size_y);
    scale_voro = [ size_x / L, size_y / L ];
    center_poly = [(min_x + max_x) / 2, (min_y + max_y) / 2];
    center_voro = [L/2, L/2];

    // subtract Voronoi pattern from a polygon
    difference() {
        polygon(border);
        translate(center_poly - center_voro) scale(scale_voro)
            random_voronoi(n = n, nuclei = false, L = L, thickness = thickness,
                  round = round, min = 0, max = L, seed = seed, center = false);
    }

    // add border if required
    if (edging) {
        difference() {
            polygon(border);
            offset(delta = -edging) polygon(border);
        }
    }
}

//
// Examples
// (render more times to see random effects)
//

// a complex red shape far from the coordinates origin
border1 = [[362.13, 35.7], [388.01, 47.59], [409.81, 58.66], [427.16, 68.73],
           [439.78, 77.62], [447.43, 85.19], [450.0, 91.29], [447.43, 95.84],
           [439.78, 98.75], [427.16, 99.96], [409.81, 99.47], [388.01, 97.27],
           [362.13, 93.41], [350.0, 60.5]];
bounding_box1 = [[350.0, 35.7], [450.0, 99.96]];
color([1,0,0]) linear_extrude(height = 1)
    voronoi_polygon(border1, bounding_box1);

// negative blue box with no edging and some settings
border2 = [[0,0], [-20,0], [-20,-20], [0,-20]];
bounding_box2 = [[-20, 0], [0, -20]]; // unordered bbox tolerated
color([0,0,1]) linear_extrude(height = 2)
    voronoi_polygon(border2, bounding_box2, thickness=0.2, round=0.5, edging=0, seed=42);

// longer green shape
border3=[[0,8],[20,178],[40,178],[60,8]];
bounding_box3=[[0,8],[178,178]];
color([0,1,0]) linear_extrude(height = 10)
    voronoi_polygon(border3, bounding_box3, n=50);
