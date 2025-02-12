/*
* SCAD Bowling Ball Holder with Text © 2025 by Matthew Cordaro is licensed under CC BY-NC-SA 4.0 
*/


/* [Text] */
// Text to show
TEXT_STRING = "Your Text";

// Fixed width fonts only
TEXT_FONT = "Consolas"; // ["Cascadia Mono", "Consolas", "Courier New", "Lucida Console"]

// Height, in cm
TEXT_HEIGHT = 1.5;  // [0.15:0.02:12]

// Separation of characters, in degrees
DEGREES_PER_CHARACTER = 10;  // [2:0.1:40]

// Depth of cut & pop out of the text, in cm
TEXT_DEPTH = 0.1;  // [0.05:0.01:0.2]


/* [Shape] */
// Radius of the Base, in cm
BASE_RADIUS = 8.0;  // [2.4:0.1:10]

// Radius of the Brim, in cm
BRIM_OUTER_RADIUS = 6.7;  // [2.3:0.1:9]

// Radius of the Hole, in cm
HOLE_RADIUS = 2.5; // [1:0.1:5]

// Upper Lip thickness, in cm
BRIM_THICKNESS = 0.15;  // [0.1:0.01:0.4]

// Thickness of the shell, in cm
SHELL_THICKNESS = 0.5;  // [0.35:0.05:0.8]

// The distance to raise the bowling ball from the floor, in cm
CUP_BOTTOM_LIFT = 0.3;  // [0.2:0.05:0.8]


/* [Quality] */
// Lower is better performance; Higher is better quality
FACETS = 50; // [50:1500]


/* [3D Exporting] */
// Select Extruder Number for exporting (0 is all extruders)
SHOW_EXTRUDER_NUMBER = 0;  // [0:2]  


/*
* Multicolor Extrusion
* Sets which extruder to draw and with what color.
*/
module Extruder(number){            
    if (!SHOW_EXTRUDER_NUMBER || number == SHOW_EXTRUDER_NUMBER)
    color(
        number == 1 ? "grey"  : 
        number == 2 ? "white" : 
        number == 3 ? "blue"  : 
        number == 4 ? "red"   :
        number == 5 ? "yellow":
        "green")  // otherwise
    children();
}


/*
*   Assertions
*/
assert(
    BASE_RADIUS >= BRIM_OUTER_RADIUS,
    "Safety Error: Base needs to be bigger than the brim.");
assert(
    BRIM_OUTER_RADIUS >= HOLE_RADIUS + BRIM_THICKNESS + 0.4,
    "Minimum of 4mm space between the brim and the hole.");
assert(
    BRIM_OUTER_RADIUS >= 2,
    "Safety Error: Minimum size for the brim is 2cm.");
assert(
    SHELL_THICKNESS >= TEXT_DEPTH/2,
    "shell not thick enough for TEXT_STRING punch. increase shell thickness or decrease text depth");
assert(
    FACETS >= 50,
    "Too few facets");
assert(
    CUP_BOTTOM_LIFT >= 0.2,
    "Ball will hit the ground");

    
/* Hide following variables from customizer */
if(false){}  


/*
* Constants
*/
INCH_TO_CM = 2.54;
USBC_MAX_DIAMETER_INCH = 8.595;  // United States Bowling Congress Spec Max Diameter
BALL_RADIUS = ( USBC_MAX_DIAMETER_INCH * INCH_TO_CM) / 2;

// Use the Pythagoras to calculate the holder height (calculating the chord radius in a circle)
// a is the brim's inner radius 
// c is the ball's radius
// so b is Ball's radius + the height - the cup's bottom lift
HOLDER_HEIGHT = BALL_RADIUS - pythag_b(BRIM_OUTER_RADIUS - BRIM_THICKNESS, BALL_RADIUS) + CUP_BOTTOM_LIFT ;

// Pythagoras
function pythag_b(a, c) = sqrt(pow(c, 2) - pow(a, 2));
function pythag_c(a, b) = sqrt(pow(a, 2) + pow(b, 2));


/*
* Basic Holder
*/
module Basic_Holder_Shape(){
    difference(){
        cylinder(
            h = HOLDER_HEIGHT,
            r1 = BASE_RADIUS,
            r2 = BRIM_OUTER_RADIUS,
            $fn = FACETS
        );
        
        // Cut out the bowling ball
        translate([0, 0, BALL_RADIUS + CUP_BOTTOM_LIFT])
        sphere(r = BALL_RADIUS,$fn = FACETS);
    }
}


/*
* Text for the Side
*/
module Side_Text(){
    
    // Wrap text around
    char_rot_y = 90;  // move text to be relative to the cone's surface
    char_rot_z_deg = DEGREES_PER_CHARACTER;
    
    // Distance of text from origin, 
    translate_z = BASE_RADIUS - TEXT_DEPTH;
    
    // Text Rotation
    rotate_x = atan(HOLDER_HEIGHT /(BASE_RADIUS - BRIM_OUTER_RADIUS))-90;  // lean letter to match cone surface
    rotate_z = 90;  // rotate to align letter upright
    
    // How far to extrude. x2 is to deal with inny and outty
    text_extrude_distance = TEXT_DEPTH * 2;  
    
    // Where the baseline should be
    exterior_face_height = pythag_c(BASE_RADIUS - BRIM_OUTER_RADIUS, HOLDER_HEIGHT);
    text_bottom = (exterior_face_height - TEXT_HEIGHT) / 2;
    
    // Place each character
    for (i = [0:len(TEXT_STRING)-1]) {
        rotate([0, char_rot_y, i * char_rot_z_deg])
        translate([0, 0, translate_z])
        rotate([rotate_x, 0, rotate_z])
        translate([0, text_bottom, 0])
        linear_extrude(height = text_extrude_distance)
        text(
            TEXT_STRING[i],
            size = TEXT_HEIGHT,
            font = TEXT_FONT,
            valign = "baseline",
            halign = "center",
            $fn = FACETS
        );
    }
}


/*
* The Bowling Ball Holder
*/
module Bowling_Ball_Holder() {
    Extruder(1)
    difference(){
        Basic_Holder_Shape();
        
        // Cut out the shell if large enough
        if (SHELL_THICKNESS + 0.5 < HOLDER_HEIGHT)
        translate([0, 0, -SHELL_THICKNESS]) // Naturally makes wall thicker when cone is steeper
        Basic_Holder_Shape();

        // Cut out hole in middle
        OVER_CUT = 1;
        translate([0, 0, -OVER_CUT/2])  // Translate down by half the over-cut
        cylinder(
            h = HOLDER_HEIGHT + OVER_CUT,  // Make taller by the over-cut
            r = HOLE_RADIUS,
            $fn = FACETS
        );
        
        if(TEXT_STRING)
        Side_Text();
    }
    
    if(TEXT_STRING)
    Extruder(2)
    Side_Text();
}

/*
* Render the Bowling Ball Holder
*/
scale([10, 10, 10])  // Adjust to mm for export
Bowling_Ball_Holder();
