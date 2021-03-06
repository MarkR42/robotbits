// This document uses MILLIMETRES as a unit.

// Set $fs (smallest arc fragment) to lower value than default 2.0
$fs = 0.6; // millimetres
$fa = 4;

/*
 Melty brain spinner cannot have a diameter of much more than
 100mm because of the size of the cube. It is technically theoretically
 possible to increase this a little by using the "inner diagnonal"
 if the robot is not too high.
*/

outer_diameter = 104.0;
inner_diameter = 58.0;
// Height must not be too high, so our tyres can stick out the top/
// bottom.
overall_height = 17.0; 
outer_height = 17.0;

inner_radius = inner_diameter / 2;
outer_radius = outer_diameter / 2;
chamfer = 1.0;
wall_thick = 3.0;
wall_thick_inner = 2.0;
base_thick = 3.0;

bolt_r1 = 34;
bolt_r2 = 46;

bolt_ang = 38;
bolt_x1 = sin(bolt_ang);
bolt_y1 = cos(bolt_ang);

bolt_holes_xy = [
    [bolt_x1 * bolt_r1,bolt_y1 * bolt_r1],
    [bolt_x1 * bolt_r2,bolt_y1 * bolt_r2]
];

module walls_outline()
{
        polygon(points = [
            [inner_radius+chamfer, 0],
            [inner_radius, chamfer],            
            [inner_radius, overall_height-chamfer],
            [inner_radius+chamfer, overall_height],

            [inner_radius+wall_thick_inner - chamfer, overall_height],
            [inner_radius+wall_thick_inner, overall_height - chamfer],
            [inner_radius+wall_thick_inner, base_thick],
            [outer_radius-wall_thick, base_thick],
            [outer_radius-wall_thick, outer_height - chamfer],
            [outer_radius-wall_thick + chamfer, outer_height],

            [outer_radius-chamfer, outer_height],
            [outer_radius, outer_height-chamfer],
            [outer_radius, chamfer],
            [outer_radius-chamfer, 0]
            ], convexity=3);
}

module shell_limits()
{
    rotate_extrude() {
        polygon(points = [
            [inner_radius, 0],
            [inner_radius, overall_height],
            [outer_radius, overall_height],
            [outer_radius, 0]
            ], convexity=3);
    }
}

motor_cutout_w = 44;

module motor_cutouts()
{
    // Cut down the wall and base for the motor mount
    translate([inner_radius-10.0, - (motor_cutout_w/2), -1.0]) {
        cube([10.5, motor_cutout_w, overall_height + 2]);
    }
    // Cut a bit more off.
    translate([inner_radius-10.0, -12, base_thick])
        cube([13, 24, overall_height + 2]);
}

motor_mount_width = 44;
motor_mount_height = overall_height;
motor_mount_thickness = 1.5;
motor_mount_offset = 28; // offset from centre

module cylinder_x(r, h)
{
    rotate([0,90,0]) {
        cylinder(h, r);
    }
}

module triangle_mount()
{
    mount_width = 8.0;
    mount_depth = 8.0;
    mount_height_rear = 12.0;
    t1 = 2.0; // thickness of mount front.
    translate([0,-mount_width/2, 0])
    difference()
    {
        hull() {
            cube([t1, mount_width, overall_height]);
            cube([mount_depth, mount_width, mount_height_rear]);
        }
        // Screw hole.
        translate([-1,mount_width/2,overall_height/2])
            cylinder_x(r=1.5, h=20); 
    }
}

module mirror_y()
{
    children();
    mirror([0,1,0]) children();
}

module mirror_x()
{
    children();
    mirror([1,0,0]) children();
}

module motor_mounts()
{
    translate([motor_mount_offset,0,0]) {
        triangle_y_offset = 18;

        translate([0,-(motor_mount_width/2), 0])
        %cube([motor_mount_thickness, motor_mount_width, motor_mount_height]);
        // Motor diameter=15.0 length=11 exclude shaft
        // Include wheel+tyre
        translate([0, 0, overall_height/2])
            % rotate([0,-90,0]) cylinder(r=11, h=11);
        // Triangle mounts at each end of the plate.
        union()
        {
            translate([motor_mount_thickness,-triangle_y_offset, 0]) 
                triangle_mount();
            translate([motor_mount_thickness,triangle_y_offset, 0]) 
                triangle_mount();
            // Piece which sticks the triangle mount on to the inner wall.
            // Less than full height; the wires need to go over.
            mirror_y() {
                translate([-8.5,triangle_y_offset+4,2.0])
                    linear_extrude(height=11.0) {
                        polygon([[0,0],[12,0], [10,2], [0,2]]);
                    }
            }
        }
    }
}

module battery_cutouts()
{
    // This is kind of weird cylindrical cutout
    // for the battery to sit in, ideally fairly tightly.
    mirror_y() {
        translate([0,inner_radius + 3.5,7.0]) 
            rotate([0,90,0])
            cylinder(r=4.0, h=30, center=true);
    }
}

module bolt_holes()
{
    mirror_x()
    mirror_y()
    {
        translate([0,0,-1])
        for (xy = bolt_holes_xy) {
            translate([xy[0], xy[1]]) {
                cylinder(r=1.1, h=50);
            }
        }
    }
}

module bolt_holders()
{
    // Need to have enough radius to hold threaded
    // inserts.
    mirror_x()
    mirror_y()
    {
        translate([0,0,base_thick - 0.5])
        for (xy = bolt_holes_xy) {
            translate([xy[0], xy[1]]) {
                cylinder(r=2.5, h=3.5);
            }
        }
    }
}

module weapon_cutout()
{
    weapon_width = 8.0;
    weapon_thickness = 2.0;
    rotate([0,0,90-bolt_ang]) {
        cube([outer_diameter + 10, weapon_width + 0.4, weapon_thickness * 2],
            center=true);
    }
}

module main()
{
    difference() {
        union()
        {
            rotate_extrude(convexity=4) {
                walls_outline();
            }
            bolt_holders();
        }
        motor_cutouts();
        mirror([1,0,0]) motor_cutouts();
        battery_cutouts();
        bolt_holes();
        weapon_cutout();
    }
    motor_mounts();
    mirror([1,0,0]) motor_mounts();
    
    // "The cube"
    /* % union() {
        translate([0,0,outer_height/2])
        rotate([-35.3,0,0]) // 35.3 = atan(1/sqrt(2)) degrees
        rotate([0,0,45])
        cube([100,100,100],center=true);
    }
    */
}

main();

