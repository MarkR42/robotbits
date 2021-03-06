set -e
set -x

# Generate flat1_tinyholes.dxf with very small holes, for
# drilling out mechanically.

# We can laser etch the outline and the holes, so that the drill can be guided.
mkdir -p output
openscad flat1.scad -D override_hole_r=0.5 -o output/flat1_tinyholes.dxf
openscad flat1.scad -D override_hole_r=0.5 -o output/flat1_tinyholes.svg

# mount plate
# openscad mount_plate.scad -o output/mount_plate.dxf

# Wheel

openscad wheel_with_insert.scad -o output/wheel_with_insert.stl

# Flipper attach
openscad flipper.scad -D generate_flipper_main=false -o output/flipper_attach.stl
openscad flipper.scad -o output/flipper.stl

# Motor mount
openscad motor_mount_cutout.scad -o output/motor_mount_cutout.stl -D base_height_main=0
openscad motor_mount_correct.scad -o output/motor_mount45.stl -D base_height_main=4.5
openscad motor_mount_minimal.scad -o output/motor_mount_minimal.stl


# 3d printed base piece instead of flat1.
openscad base3.scad -o output/base3.stl
