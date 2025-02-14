/*
* SCAD Bowling Ball Holder with Text © 2025 by Matthew Cordaro is licensed under CC BY-NC-SA 4.0 
*/


/* [Text] */
TEXT_STRING = "Your Text";

TEXT_FONT = "Arial";  // ["Arial", "Calibri", "Candara", "Comic Sans MS", "Consolas", "Courier New", "Georgia", "Impact", "Lucida Console", "Lucida Sans Unicode", "Palatino Linotype", "Segoe Print", "Segoe Script", "Segoe UI", "Tahoma", "Times New Roman", "Trebuchet MS", "Verdana"]

TEXT_HEIGHT = 1.5;  // [0.15:0.01:4.75]

// Depth of cut & pop out, in cm
TEXT_DEPTH = 0.1;  // [0.05:0.01:0.2]


/* [Shape] */
// Radius of the Base, in cm
BASE_RADIUS = 8.0;  // [2.4:0.1:10]

// Radius of the Brim, in cm
BRIM_OUTER_RADIUS = 6.7;  // [2.3:0.1:9.5]

// Radius of the Hole, in cm
HOLE_RADIUS = 2.5;  // [1:0.1:8]

// Upper Lip thickness, in cm
BRIM_THICKNESS = 0.15;  // [0.1:0.01:0.4]

// Thickness of the shell, in cm
SHELL_THICKNESS = 0.5;  // [0.35:0.05:0.8]

// The distance to raise the bowling ball from the floor, in cm
CUP_BOTTOM_LIFT = 0.3;  // [0.2:0.05:0.8]


/* [3D Exporting] */
// Max this before rendering
FACETS = 50;  // [50:750]
$fn = FACETS;

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
assert (CONE_FACE_LENGTH > TEXT_HEIGHT,
    "Text too big for the face.");

    
/* Hide following variables from customizer */
if(false){}


/*
* Constants
*/
TAU = 2 * PI;
INCH_TO_CM = 2.54;
USBC_MAX_DIAMETER_INCH = 8.595;  // United States Bowling Congress Spec Max Diameter
BALL_RADIUS = ( USBC_MAX_DIAMETER_INCH * INCH_TO_CM) / 2;

// Use the Pythagoras to calculate the holder height (calculating the chord radius in a circle)
// a is the brim's inner radius 
// c is the ball's radius
// so b is Ball's radius + the height - the cup's bottom lift
HOLDER_HEIGHT = BALL_RADIUS - pythag_a(BRIM_OUTER_RADIUS - BRIM_THICKNESS, BALL_RADIUS) + CUP_BOTTOM_LIFT ;

// Length of the cone's face from the base to the brim.
CONE_FACE_LENGTH = pythag_c(BASE_RADIUS - BRIM_OUTER_RADIUS, HOLDER_HEIGHT);

/*
* Functions
*/
// Sum a list between i & j. i & j are inclusive.
function sum_between_indices(list, i, j) = 
    i > j ? 0 :
    i < 0 || j >= len(list) ? "Index out of bounds" :
    list[i] + sum_between_indices(list, i + 1, j);

// Pythagoras
function pythag_a(b, c) = sqrt(pow(c, 2) - pow(b, 2));
function pythag_c(a, b) = sqrt(pow(a, 2) + pow(b, 2));

// Calculate character width using textmetrics()
function char_width(char) =
    char == " " ? TEXT_HEIGHT/3 :
    textmetrics(text=char, size=TEXT_HEIGHT, font=TEXT_FONT).size.x;

// Calculate rotation angle for a character
function char_rot_z(char) =
    (char_width(char) * 360) / 
    (TAU * BRIM_OUTER_RADIUS);

// Generate a list of rotations between each letter pair (i,j).
// This is to calculate the placement location of j relative to i
function char_rot_z_list() = [
        0,
        for (i = [1 : len(TEXT_STRING) - 1])
            (char_rot_z(TEXT_STRING[i-1]) + char_rot_z(TEXT_STRING[i])) / 2
];

// Function to accumulate rotation angles
function cumulative_z(i) = 
        sum_between_indices(char_rot_z_list(), 0, i);

/*
* Basic Holder
*/
module Basic_Holder_Shape(){
    difference(){
        cylinder(
            h = HOLDER_HEIGHT,
            r1 = BASE_RADIUS,
            r2 = BRIM_OUTER_RADIUS
        );
        
        // Cut out the bowling ball
        translate([0, 0, BALL_RADIUS + CUP_BOTTOM_LIFT])
        sphere(BALL_RADIUS);
    }
}


/*
* Text for the Side
*/
module Side_Text(){
    
    // Wrap text around
    char_rot_y = 90;  // move text to be relative to the cone's surface
    
    // Distance of text from origin, 
    translate_z = BASE_RADIUS - TEXT_DEPTH;
    
    // Text Rotation
    rotate_x = atan(HOLDER_HEIGHT /(BASE_RADIUS - BRIM_OUTER_RADIUS))-90;  // lean letter to match cone surface
    rotate_z = 90;  // rotate to align letter upright
    
    // How far to extrude. x2 is to deal with inny and outty
    text_extrude_distance = TEXT_DEPTH * 2;  
    
    // Where the baseline should be
    text_bottom = (CONE_FACE_LENGTH - TEXT_HEIGHT) / 2;
    
    // Place each character
    for (i = [0:len(TEXT_STRING)-1]) {
        rotate([0, char_rot_y, cumulative_z(i)])
        translate([0, 0, translate_z])
        rotate([rotate_x, 0, rotate_z])
        translate([0, text_bottom, 0])
        linear_extrude(height = text_extrude_distance)
        text(
            TEXT_STRING[i],
            size = TEXT_HEIGHT,
            font = TEXT_FONT,
            valign = "baseline",
            halign = "center"
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
            r = HOLE_RADIUS
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
