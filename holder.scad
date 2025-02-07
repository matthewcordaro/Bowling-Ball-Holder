/*
* SCAD Bowling Ball Holder with Text © 2025 by Matthew Cordaro is licensed under CC BY-NC-SA 4.0 
*/

/* [Text] */
// ONLY USE UPPERCASE
Text_String = "TEXT";

// Text is inny or outty (cut/pop)
Text_Inny = false;  // [true:Inny, false:Outty]

// Distance between edge and text
Text_Height_Offset = 0.6;  // [0.15:0.02:2.5]

// This changes separation of characters (Works by feel)
Character_Separation = 10;  // [2:0.1:40]

// how far in to cut/pop the text out of the cone in cm
Text_Depth = 0.1;  // [0.05:0.01:0.2]

/* [Shape] */
// How wide to extend the holder's base in CM
Bottom_Radius_Offset = 2.5;  // [1.0:0.1:4.0]

// Holder's height in cm
Holder_Height = 3.0;  // [2:0.1:5]

// Thickness of the shell in cm
Shell_Thickness = 0.5;  // [0.3:0.05:0.8]

// Upper Lip thickness in cm
Lip_Offset = 0.3;  // [0.2:0.01:0.4]

// Hole at bottom in cm
Punch_Hole_Radius = 3.5;  // [2:0.1:5]

// The distance to raise the bowling ball from the floor in cm
Cup_Bottom_Lift = 0.3;  // [0.2:0.05:0.8]

/* [Quality] */
// Lower is better performance; Higher is better quality
Facets = 150; // [50:400]


/*
*   Assertions
*/
if (Text_Inny){
    assert(Shell_Thickness >= Text_Depth + 0.2, "shell not thick enough for Text_String punch. increase shell thickness or decrease text depth");
}
assert(Facets <= 400, "Too many facets");
assert(Facets >= 50, "Too few facets");
assert(Bottom_Radius_Offset >= 1, "Not a wide enough base");
assert(Cup_Bottom_Lift >= 0.2, "Ball will hit the ground");


/*
* Constants
*/
INCH_TO_CM = 2.54;
USBC_MAX_DIAMETER_INCH = 8.595;  // United States Bowling Congress Spec Max Diameter

/*
*   Calculated Dimensions
*/
Ball_Radius = ( USBC_MAX_DIAMETER_INCH * INCH_TO_CM) / 2;

// The "small circle" of the ball (sphere) which is created by the plane defined by the top of the holder
Side_A_Squared = pow(Ball_Radius - Holder_Height + Cup_Bottom_Lift, 2);
Side_B_Squared = pow(Ball_Radius, 2); 
Small_Circle_Radius = sqrt(Side_B_Squared - Side_A_Squared);

// Cone Radii
Top_Radius = Small_Circle_Radius + Lip_Offset;
Bottom_Radius = Top_Radius + Bottom_Radius_Offset;

// Distance of the text from the Z Axis
Text_Distance_From_Z = (Bottom_Radius + Top_Radius)/2;


/*
* Basic Holder
*/
module basic_holder_shape (){
    difference(){
        cylinder(
            h = Holder_Height,
            r1 = Bottom_Radius,
            r2 = Top_Radius,
            $fn = Facets
        );
        
        // Cut out the bowling ball
        translate([0, 0, Ball_Radius + Cup_Bottom_Lift])
        sphere(r = Ball_Radius,$fn = Facets);
    }
}


/*
* Text for the Side
*/
module side_text(){
    translate_x = -Holder_Height / 2;  // move text to the center of the cone
    translate_z = Text_Distance_From_Z - Text_Depth; // adjust depth of text
    
    floor_delta = Bottom_Radius - Top_Radius - Lip_Offset;
    
    // Text Height relative to side of cone
    text_height = sqrt(pow(floor_delta, 2) + pow(Holder_Height, 2)) - 2 * Text_Height_Offset;
    
    // Text Rotation
    rotate_x = atan(Holder_Height/(floor_delta + Lip_Offset))-90;  // lean letter to match cone surface
    rotate_z = 90;  // rotate to align letter upright
    
    
    Character_Shift_Degrees = Character_Separation / Text_Height_Offset;
    
    text_extrude_distance = Text_Depth * 2;  // x2 is to deal with inny and outty
    
    // Iterate through the characters
    for (i = [0:len(Text_String)-1]) {
        rotate([
            0,
            90, // move text to be relative to the cone's surface
            i * Character_Shift_Degrees // rotate around Z axis for each char
        ])
        
        translate([translate_x, 0, translate_z])
        
        rotate([rotate_x, 0, rotate_z])
        
        linear_extrude(height = text_extrude_distance)
        
        text(
            Text_String[i],
            size=text_height,
            font="Courier",
            valign = "center",
            halign = "center",
            $fn = Facets
        );
    }
}

/*
* The Bowling Ball Holder
*/
module bowling_ball_holder() {
    color("DarkSlateGray")  // Dark grey
    difference(){
        basic_holder_shape();
        
        // Cut out the shell
        translate([0, 0, -Shell_Thickness]) // Naturally makes wall thicker when cone is steeper
        basic_holder_shape();

        // Cut out hole in middle
        Over_Cut = 1;
        translate([0, 0, -Over_Cut/2])  // Translate down by half the over-cut
        cylinder(
            h = Holder_Height + Over_Cut,  // Make taller by the over-cut
            r = Punch_Hole_Radius,
            $fn = Facets
        );
        
        // Cut text if it's inny
        if (Text_Inny) side_text();
    }
    
    // Outty Text
    if (!Text_Inny) {
        color("DarkGoldenrod")
        side_text();
    }
}

/*
* Render the Bowling Ball Holder
*/
scale([10, 10, 10])  // Adjust to mm for export
bowling_ball_holder();
