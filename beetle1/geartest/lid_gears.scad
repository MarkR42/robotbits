use <gears.scad>;

tooth_modulus = 2.4;
pressure_angle = 20;
helix_angle = 30;

gears_thickness = 20.0;

module motorgear() {
    num_teeth = 12;
    splodgefactor = 0.25; // Diam.
    bore = 4 + splodgefactor; // Diameter (not radius) of centre hole
    /* Herringbone_gear; uses the module "spur_gear"
    modul = Height of the Tooth Tip beyond the Pitch Circle
    tooth_number = Number of Gear Teeth
    width = tooth_width
    bore = Diameter of the Center Hole
    pressure_angle = Pressure Angle, Standard = 20° according to DIN 867. Should not exceed 45°.
    helix_angle = Helix Angle to the Axis of Rotation, Standard = 0° (Spur Teeth)
    optimized = Holes for Material-/Weight-Saving */

    union() {
        herringbone_gear (tooth_modulus, num_teeth, gears_thickness, bore, 
            pressure_angle=pressure_angle, helix_angle=helix_angle);
        // For d-shaft.
        // Need a ~ 0.5mm flat which does not go all the way.
        linear_extrude(gears_thickness - 3.0) {
            translate([1.5,-5]) {
                square([3,10]);
            }
        }
    }
}


lidgear_angle = 100;

module lidgear() {
    num_teeth = 65;
    bore = 24.0; // Diameter of bore (not radius)

    difference() {        
        intersection() {
            herringbone_gear (tooth_modulus, num_teeth, gears_thickness, bore, 
                pressure_angle=pressure_angle, helix_angle=-helix_angle,
                optimized=false);
            a1 = 90 - (lidgear_angle/2);
            // Cut off the parts we do not need.
            rotate([0,0,0]) 
                translate([-100,0,0]) cube([200,200,200], center=true);
            rotate([0,0,-a1*2]) 
                translate([-100,0,0]) cube([200,200,200], center=true);
        }
        // Screw holes....
        for (n=[20,40,60]) {
            translate([0,n,gears_thickness/2])
                rotate([0,90,0])
                    cylinder(r=lid_hole_radius, h=40, center=true);
        }
        
        lid_hole_radius = 2.5;
        translate([0,0,-1])
        linear_extrude(100) {
            intersection() {
                circle(r=60);                
                translate([-15,15])
                    mirror([1,0])
                    square([100,100]);
            };
        }
    }
}

centre_distances = 93.0;

module main() {
    translate([-centre_distances,0,0]) motorgear();
    lidgear();
}

main();
