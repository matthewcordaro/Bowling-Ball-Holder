/*
SCAD Bowling Ball Holder with Text © 2025 by Matthew Cordaro is licensed under CC BY-NC-SA 4.0 
*/

// ONLY UPPERCASE FOR NAME
name = "TEXT"; 

// Distance between edge and text in cm
text_height_offset = 1.25;

// how far in to cut/pop the text out of the cone in cm
text_depth = 0.2;

// Should text cut/pop (inny/outty
text_inny = false;

// This is an estimate that effects seperation of characters. Needs to be adjusted with other variables for preference.
text_factor = 20; 

// How smooth to make the model (>50, <400) quality vs. performance
facets = 200;

// Thickness of the shell in cm
shell_thickness = 0.6;

// Holder's height in cm
holder_height = 4.5;

// Hole at bottom in cm
punch_hole_radius = 2.5;

// Upper Lip thickness in cm
lip_offset = 0.4;

// The distance to raise the bowling ball from the floor in cm
cup_bottom_lift = 0.4;

// Assertions
if (text_inny){
    assert(shell_thickness >= text_depth + 0.2, "shell not thick enough for name punch. increase shell thickness or decrease text depth");
}
assert(facets <= 400, "Too many facets");
assert(facets >= 50, "Too few facets");

// Calculated Dimensions
//
// The radius of the bowling ball to be used in all calculations
// Per USBC Regulations 8.595 inch diameter
ball_radius = ( 8.595 * 2.54) / 2;

// The "small circle" of the ball (sphere) which is created by
// the plane defined by the top of the holder
pythag_a = ball_radius-holder_height+cup_bottom_lift;
small_circle_radius = sqrt(pow(ball_radius, 2) - pow(pythag_a, 2)); // b (pythagoras)

// Cone Radii
holder_bottom_radius = ball_radius + 2;  // 2 is arbitrarly set for balance
holder_top_radius = small_circle_radius + lip_offset;



// Text distance from z
text_distance_from_z = (holder_bottom_radius + holder_top_radius)/2;

module cone(){
    cylinder(h = holder_height,
             r1 = holder_bottom_radius,
             r2 = holder_top_radius,
             $fn = facets);
}

module cup(){
    translate([0,
               0,
               ball_radius + cup_bottom_lift])
    sphere(r = ball_radius,
           $fn = facets);
}

module side_text(){
    // Text Height relative to side of cone
    floor_delta = holder_bottom_radius - holder_top_radius - lip_offset;
    text_height = sqrt(pow(floor_delta, 2) + pow(holder_height, 2)) - 2 * text_height_offset;
    lean_angle = atan(holder_height/(floor_delta + lip_offset))-90;
    
    
    degrees_per_character = text_factor / text_height_offset;
    
    for (i = [0:len(name)-1]) {
        // move text to be relative to the cone's surface and
        // rotate around Z axis for each char
        rotate([0, 90, i * degrees_per_character])
        
        translate([-holder_height /2, // move to center of cone
                   0,
                   text_distance_from_z - text_depth]) // adjust depth of text
        
        rotate([lean_angle, // lean letter to match cone surface
                0,
                90]) // rotate to align letter upright
        
        linear_extrude(height = text_depth * 2)  // x2 is to deal with inny and outty
        
        text(name[i],
             size=text_height,
             font="Courier",
             valign = "center",
             halign = "center",
             $fn = facets);
    }
}

// Create the holder
module bowling_ball_holder() {
    
    difference() {
        // Basic Holder: cone - cup
        cone();
        cup();

        // Punch out hole in middle
        translate([0, 0, -1])
        cylinder(h = holder_height + 2, r = punch_hole_radius, $fn = facets);
        
        // Cut out the shell
        translate([0, 0, -shell_thickness]){
            difference() {
                cone();
                cup();
            }
        }
        
        // Cut out text
        if (text_inny) side_text();
    }
    
    if (!text_inny) side_text();
}

// Render the holder
bowling_ball_holder();
