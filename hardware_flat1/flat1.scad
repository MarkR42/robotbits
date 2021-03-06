// Set $fs (smallest arc fragment) to lower value than default 2.0
$fs = 0.8; // millimetres

include <inc/defs.scad>;
include <inc/utils.scad>;

wheel_width = 9.0;
wheelslot_w = wheel_width + 4.0;
wheelslot_d = 35;

bolthole_r = 1.25;

module wheel_cutout(override_hole_r) {
    hole_r = override_hole_r > 0  ? override_hole_r : bolthole_r;
    // Single wheel cutout, centred around the wheel itself.
    translate([10,0,0])
        rounded_rect(wheelslot_w + 20, wheelslot_d, wheelslot_w / 2);
    // Cutouts for the motor mount holes.
    // Motor mount holes are 14mm apart in Y axis
    // Motor holes should be some distance from the slot, because the
    // gearbox is ~ 8mm wide
    for (x = [-24, -18]) {
        for (y = [-7.5, 7.5]) {
            translate([x,y])
                circle(r=hole_r);
        }
    }
    
}

module wheel_cutouts(override_hole_r) {
    mirror_x() {
        translate([wheel_x_rear,wheel_y_rear]) wheel_cutout(override_hole_r);
        // Cut out the back
        translate([wheel_x_rear + 10, wheel_y_rear - 5]) {
            square([wheelslot_w + 20, wheelslot_d], center=true);
        }
        translate([wheel_x_front,wheel_y_front]) wheel_cutout(override_hole_r);
    }
}

module front_corner_cutouts() {
    mirror_x() {
        translate([body_w/2, body_d / 2]) {
            rotate([0,0,45]) 
                square([6,6], center=true);
        }
    }
}

module other_holes(hole_r=0) {
    body_hole_r = hole_r>0 ? hole_r : bolthole_r;
    mirror_x() {
        // Rear holes
        for (x=[body_w / 6, body_w_half - 4, 7.5]) {
            y = -body_d_half + 4;
            translate([x,y]) 
            circle(r=body_hole_r);
        }
        // Side holes
        translate([body_w_half - 4, -14])
            circle(r=body_hole_r);
        translate([body_w_half - 4, 6])
            circle(r=body_hole_r);
        translate([body_w_half - 4, body_d_half -5])
            circle(r=body_hole_r);
    }
    // For the raspberry pi board - these will be used for cable
    // ties or wrap, not bolts.
    // we need a pair of holes on each side.
    // Just forward of the rear wheels
    pi_hole_radius = hole_r > 0 ? hole_r : 1.375; // 2.5mm bolts; 2.75mm drilled
    pi_hole_distance_x = 58; // x distance between holes, 
    pi_hole_distance_y = 24; // y distance between holes, 
    mirror_x() {
        translate([pi_hole_distance_x / 2,pi_y,0])
        {
            translate([0,-pi_hole_distance_y/2 ])
                circle(r=pi_hole_radius);
            translate([0,pi_hole_distance_y/2 ])
                circle(r=pi_hole_radius);
        }
    }    
}

override_hole_r = 0; // Set this with -D to override hole size.

module main(holes=true) {
    difference() {
        rounded_rect(body_w, body_d, 2);
        wheel_cutouts(override_hole_r);
        front_corner_cutouts();
        if(holes) {
            other_holes(override_hole_r);
        }
    }
}

main();
