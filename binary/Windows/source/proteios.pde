//  Note: use tab size 2

//  proteios.pde
//  Proteios -- COMP 150-04
//  
//  Created by Ryan Orendorff on 2010-04-15.
//  Copyright 2010 RDO Designs. All rights reserved.

//  www:     http://www.rdodesigns.com
//  github:  http://github.com/proteios 
//  email:   ryan.orendorff@gmail.com
//  Twitter: RDO_Designs

//  This file is part of Proteios.
//  
//  Proteios is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  Proteios is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with Proteios. If not, see the GNU website for a copy.

// import fullscreen.*;
// SoftFullScreen fs;

// Vectors for positions of grid related to the screen.
PVector held_pos = new PVector(0,0);
PVector grid_pos = new PVector(0,0);
float zoom = 1;

// Use custom cursor for magnify mode. 
PImage resize_cursor;
PFont aa_font;

int time_display_choices = 0;
int time_display_choices_max = 60; 

// Different modes of operation.
boolean locked = false;
boolean magnifyMode = false;
boolean navigatorOn = false;
boolean aaOn = true;
boolean lettersOn = true;
boolean colorsOn = true;

// angle from one amino acid to next.
static final float angle_inc	= 360/21;
 
ArrayList proteins = new ArrayList();
int protein_selected = 0;

// Amino Acids, sorted by type.						//	Type:				Color:
static final String aa_pos	= "RHK"; 			//	Positive		Red
static final String aa_neg	= "DE"; 			//	Negative		Blue
static final String aa_pol	= "STNQ"; 		//	Polar				Green
static final String aa_spe	= "CUGP"; 		//	Special			Purple
static final String aa_pho	= "AILMFWYV"; //	Hydrophobic	Orange
static final String aa			= "RHKDESTNQCUGPAILMFWYV";
																//	Red			 Blue			Green		 Purple		Orange
static final color[] aa_colors_bright = { #E41A1C, #377EB8, #4DAF4A, #984EA3, #FF7F00 };
static final color[] aa_colors_dim = { #460009, #00283C, #003915, #3B1337, #441500 };
// Note: These finals are called in some classes (ex: Protein)

void setup(){
	size(1280,720);
	frameRate(30);
	
	// Is resizable. Useful, so that 600x600 is not limiting.
	frame.setResizable(true);
	frame.setTitle("Proteios - Protein Visualization");
	
	// Fullscreen mode. Note that it takes on the size of the window
	// and makes everything else black (so, a 600x600 window is just
	// centered and surrounded by black instead of resized)
	// fs = new SoftFullScreen(this);
	// fs.setShortcutsEnabled(true);
	// fs.setResolution(x, y)
	
	smooth();
	
	// in data folder
	resize_cursor = loadImage("resize_cursor.png");
	
	// load two proteins of silk. Will replace with search function.
	String[] protein_list = loadStrings("sequences.txt");

	for (int i = 0; i < protein_list.length; i+=2){
		proteins.add(new Protein(protein_list[i], protein_list[i+1].toUpperCase()));
	}
	
	aa_font = loadFont("Monaco-10.vlw");
	textSize(12);

} // end setup


void draw(){
	Protein p = (Protein) proteins.get(protein_selected);
	
	background(0);
	fill(#FFFFFF);
	
	
	// Draws letter on top left of screen when a mode is on.
	drawModes();
	
	// Draw the name of the protein in the upper right.
	pushStyle();
		textAlign(RIGHT);
			if (time_display_choices < time_display_choices_max){
				for (int i=0; i < proteins.size(); i++){
					Protein temp_p = (Protein) proteins.get(i);
					if (i == protein_selected){
						fill(#FFFFFF);
					} else{
						fill(#999999);
					}
					text(temp_p.name, width - 10, 12*(i+1) + 4*i);
				}
				time_display_choices++;
			} else {
				text(p.name, width - 10, 12);
			}
			fill(#FFFFFF);
			text(zoom+"x", width-10, height-10);
	popStyle();

	// Make the middle of the screen (0,0). Note going up is the negative y.
	translate(width/2, height/2);
	
	// Draw the protein selected. Select proteins with the number keys.
	pushStyle();
	stroke(#FFFFFF);
	strokeWeight(1);
	
		pushMatrix();
			translate(grid_pos.x, grid_pos.y);			
			p.drawPath(zoom);
		popMatrix();
		
	popStyle();
	
	if (navigatorOn){
		pushMatrix();
			translate(0, 0);
			drawNavigator();
		popMatrix();
	}
	
	
} // end draw

// Loads a protein. Note that the text file is only the protein sequence.
void loadProteinSequence(String protein_file){
	String[] file = loadStrings(protein_file);
	String sequence = file[1];
	
	proteins.add(new Protein(file[0], sequence.toUpperCase()));
} // end loadProteinSequence

// Outputs a String[] of the files in a directory.
// note: sketchPath variable holds location of sketch.
String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
} // end listFileNames

// Draws the Navigator circle. Turn on/off with the 'n' key.
void drawNavigator(){
	pushStyle();
	textAlign(CENTER);
	pushMatrix();
	
	// Gray letters.
	fill(#999999);
	// Draw the letters for the navigator
	for (int i = 0; i < 21; i++){
			text(aa.charAt(i), 200*cos(radians(angle_inc*i)), 200*sin(radians(angle_inc*i)));
	}
	
	// Draw center of navigator.
	noFill();
	strokeWeight(1);
	stroke(#C3000A);
	ellipse(0,0,8,8);

	// Draw the arcs for the navigator
	stroke(aa_colors_bright[0]);
	arc(0,0, 370, 370, 0, radians(angle_inc*2));
	stroke(aa_colors_bright[1]);
	arc(0,0, 370, 370, radians(angle_inc*3), radians(angle_inc*4));
	stroke(aa_colors_bright[2]);
	arc(0,0, 370, 370, radians(angle_inc*5), radians(angle_inc*8));
	stroke(aa_colors_bright[3]);
	arc(0,0, 370, 370, radians(angle_inc*9), radians(angle_inc*12));
	stroke(aa_colors_bright[4]);
	arc(0,0, 370, 370, radians(angle_inc*13), radians(angle_inc*20));
		
	// Reset
	popMatrix();
	popStyle();
}




void mousePressed(){
	
	// Use a different icon for the magnification to emphasize the
	// current mode.
	if (magnifyMode){
		cursor(resize_cursor, 16, 16); 
	} else {
		cursor(MOVE);
	}
	
	// Does not work at the moment. Need to find the vector to the location
	// on the model.
	if(!locked) {
		held_pos.x = mouseX;
		held_pos.y = mouseY;
				
		locked = true;
	}
} // end mousePressed

void mouseReleased(){
	locked = false;
	
	cursor(ARROW);
} // end mouseReleased

void mouseDragged(){
	
	if(magnifyMode){
		cursor(resize_cursor, 16, 16);
		
		float old_zoom = zoom;
		zoom += mouseX - pmouseX;
		if (zoom < 1) zoom = 1;
		
		// zoom relative to current view
		grid_pos.mult(zoom/old_zoom);
		
	} else {
		cursor(MOVE);
		grid_pos.x += mouseX - pmouseX;
		grid_pos.y += mouseY - pmouseY;
	}
} // end mouseDragged()



void keyPressed(){

	int modifiers = keyEvent.getModifiersEx() ;
	
	//// Used to find the value of each modiefier key (ex: SHIFT = 64, SHIFT+ALT = 576)
	//// Thank you Mr. Fry. http://processing.org/discourse/yabb2/YaBB.pl?num=1128189621 
	// String keyString = "key code = " + keyCode + " (" + KeyEvent.getKeyText(keyCode) + ")" + " and keyChar = " + key ;
	// 		println(keyString) ;
	// 	
	// 		// warning, getModifiersEx() requires java 1.4
	// 		// (will break on mac with firefox or ie)
	// 	
	// 	String modString = "modifiers = " + modifiers ;
	// 	String tmpString = KeyEvent.getModifiersExText(modifiers) ;
	// 	if (tmpString.length() > 0)
	// 	{
	// 		modString += " (" + tmpString + ")" ;
	// 	}
	// 	else
	// 	{
	// 		modString += " (no modifiers)" ;
	// 	}
	// 	println(modString) ;
	// 	
	// 	println("action key? " + (keyEvent.isActionKey() ? "YES" : "NO")) ;
	
	if				(key == 'm'){ // Turn on magnification mouse movements
			magnifyMode = magnifyMode ? false : true;
	} else if	(key == 'O'){ // return to the origin
			grid_pos.x = 0;
			grid_pos.y = 0;
	} else if (key == 'o'){ // Center and maximize the protein.
			drawProteinToFit();
	} else if	(key == 'n'){ // turn the navigator whel on/off
			navigatorOn = navigatorOn ? false : true;
	} else if	(key == 'a'){ // turn on the amino acid circles on the protein path
			aaOn = aaOn ? false : true;
	} else if (key == 'c'){ // turn the colors of the protein path on/off
			colorsOn = colorsOn ? false : true;
	} else if (key == 'l') {
			lettersOn = lettersOn ? false : true;
	} else if (key == TAB){
			if (modifiers == 64){
				if (protein_selected == 0){
					protein_selected = proteins.size()-1;
				} else {
					protein_selected = (protein_selected -1) % proteins.size();
				}
			} else {
				protein_selected = (protein_selected +1) % proteins.size();
			}
			time_display_choices = 0;
			drawProteinToFit();
			
			Protein p = (Protein) proteins.get(protein_selected);
			p.allSegments();
	} else if (key == 'h'){
		// Display help (need to write this)
	}
	
	
	if(key == CODED) { 
		Protein p = (Protein) proteins.get(protein_selected);
		
		if (keyCode == LEFT){
			if (modifiers == 576) {
				p.reduceSegments(20);
			} else if (modifiers == 64) {
				p.reduceSegments(5);
			} else {
				p.reduceSegments(1);
			}
		} else if (keyCode == RIGHT){
			if (modifiers == 576) {
				p.increaseSegments(20);
			} else if (modifiers == 64) {
				p.increaseSegments(5);
			} else {
				p.increaseSegments(1);
			}
		} else if (keyCode == UP){
			p.allSegments();
		} else if (keyCode == DOWN)
			p.noSegments();
	}
	
} // end keyPressed()

// Draws the letters at the top left of the screen.
void drawModes(){
	pushStyle();
	textSize(18);
	textAlign(LEFT);
	
	if (magnifyMode){
			fill(#D35806);
			text("m", 10, 16);
	}
	
	if (aaOn){
			fill(#2F9416);
			text("a", 30, 16);
			if (lettersOn){
				pushStyle();
					textSize(10);
					text("L", 40, 20);
				popStyle();
			}
	}
	
	if (colorsOn){
			fill(#2F9416);			
			text("c", 50, 16);
	}
	
	popStyle();
} // end drawModes()

void drawProteinToFit(){
	Protein p = (Protein) proteins.get(protein_selected);

	float zoom_x = floor(width / p.protein_width);
	float zoom_y = floor(height / p.protein_height);

	zoom = zoom_x >= zoom_y ? zoom_y : zoom_x;
	zoom -= floor(zoom/25);
	grid_pos.x = -p.center.x*zoom;
	grid_pos.y = -p.center.y*zoom;
}
