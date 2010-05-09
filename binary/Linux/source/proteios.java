import processing.core.*; 
import processing.xml.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class proteios extends PApplet {

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
static final int[] aa_colors_bright = { 0xffE41A1C, 0xff377EB8, 0xff4DAF4A, 0xff984EA3, 0xffFF7F00 };
static final int[] aa_colors_dim = { 0xff460009, 0xff00283C, 0xff003915, 0xff3B1337, 0xff441500 };
// Note: These finals are called in some classes (ex: Protein)

public void setup(){
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


public void draw(){
	Protein p = (Protein) proteins.get(protein_selected);
	
	background(0);
	fill(0xffFFFFFF);
	
	
	// Draws letter on top left of screen when a mode is on.
	drawModes();
	
	// Draw the name of the protein in the upper right.
	pushStyle();
		textAlign(RIGHT);
			if (time_display_choices < time_display_choices_max){
				for (int i=0; i < proteins.size(); i++){
					Protein temp_p = (Protein) proteins.get(i);
					if (i == protein_selected){
						fill(0xffFFFFFF);
					} else{
						fill(0xff999999);
					}
					text(temp_p.name, width - 10, 12*(i+1) + 4*i);
				}
				time_display_choices++;
			} else {
				text(p.name, width - 10, 12);
			}
			fill(0xffFFFFFF);
			text(zoom+"x", width-10, height-10);
	popStyle();

	// Make the middle of the screen (0,0). Note going up is the negative y.
	translate(width/2, height/2);
	
	// Draw the protein selected. Select proteins with the number keys.
	pushStyle();
	stroke(0xffFFFFFF);
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
public void loadProteinSequence(String protein_file){
	String[] file = loadStrings(protein_file);
	String sequence = file[1];
	
	proteins.add(new Protein(file[0], sequence.toUpperCase()));
} // end loadProteinSequence

// Outputs a String[] of the files in a directory.
// note: sketchPath variable holds location of sketch.
public String[] listFileNames(String dir) {
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
public void drawNavigator(){
	pushStyle();
	textAlign(CENTER);
	pushMatrix();
	
	// Gray letters.
	fill(0xff999999);
	// Draw the letters for the navigator
	for (int i = 0; i < 21; i++){
			text(aa.charAt(i), 200*cos(radians(angle_inc*i)), 200*sin(radians(angle_inc*i)));
	}
	
	// Draw center of navigator.
	noFill();
	strokeWeight(1);
	stroke(0xffC3000A);
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




public void mousePressed(){
	
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

public void mouseReleased(){
	locked = false;
	
	cursor(ARROW);
} // end mouseReleased

public void mouseDragged(){
	
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



public void keyPressed(){

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
public void drawModes(){
	pushStyle();
	textSize(18);
	textAlign(LEFT);
	
	if (magnifyMode){
			fill(0xffD35806);
			text("m", 10, 16);
	}
	
	if (aaOn){
			fill(0xff2F9416);
			text("a", 30, 16);
			if (lettersOn){
				pushStyle();
					textSize(10);
					text("L", 40, 20);
				popStyle();
			}
	}
	
	if (colorsOn){
			fill(0xff2F9416);			
			text("c", 50, 16);
	}
	
	popStyle();
} // end drawModes()

public void drawProteinToFit(){
	Protein p = (Protein) proteins.get(protein_selected);

	float zoom_x = floor(width / p.protein_width);
	float zoom_y = floor(height / p.protein_height);

	zoom = zoom_x >= zoom_y ? zoom_y : zoom_x;
	zoom -= floor(zoom/25);
	grid_pos.x = -p.center.x*zoom;
	grid_pos.y = -p.center.y*zoom;
}
// 
//  Protein.pde
//  Proteios -- COMP 150-04
//  
//  Created by Ryan Orendorff on 2010-04-19.
//  Copyright 2010 RDO Designs. All rights reserved.
// 

//  Code available under the GPLv3. See proteios.pde and gpl3.txt for full license information.

class Protein{
	String sequence;
	String name;
	PVector[] protein_shape_abs;
	PVector[] protein_shape_rel;
	int[] colors_bright;
	int[] colors_dim;
	int protein_length;
	int on_segments;
	
	PVector top_left_corner;
	PVector bottom_right_corner;
	PVector center;
	float protein_width;
	float protein_height;
	// size of beginning and ending dot.
	static final float dot_size		= 6;
	
	
	// ===============
	// = Constructor =
	// ===============
	Protein(String name, String sequence){
		this.name = name;
		this.sequence = sequence;
		
		this.protein_length = sequence.length();
		this.on_segments = this.protein_length;
		this.protein_shape_abs = new PVector[this.protein_length+1];
		this.protein_shape_rel = new PVector[this.protein_length+1];
		this.colors_bright = new int[this.protein_length];
		this.colors_dim = new int[this.protein_length];
		this.calculatePath();
	} // end Constructor(String sequence)
	
	
	// Creates a PVector[] that holds each node in the sequence
	// Note: all vectors are unit vectors.
	private void calculatePath(){
		protein_shape_abs[0] = new PVector(0,0);
		protein_shape_rel[0] = new PVector(0,0);

		top_left_corner			= new PVector(0,0);
		bottom_right_corner	= new PVector(0,0);
		
		for (int i = 1; i < this.protein_length+1; i++){
			PVector previous_node = protein_shape_abs[i-1];
			
			// from 0 to 20
			int pos_on_circle = aa.indexOf(sequence.charAt(i-1));
			// println(pos_on_circle);
			
			float hor = cos(radians(angle_inc * pos_on_circle));
			float ver = sin(radians(angle_inc * pos_on_circle));
			
			protein_shape_rel[i] = new PVector(hor, ver);
			
			protein_shape_abs[i] = PVector.add(previous_node, protein_shape_rel[i]);
			
			colors_bright[i-1] = calculateColors(sequence.subSequence(i-1, i), "bright");
			colors_dim[i-1] = calculateColors(sequence.subSequence(i-1, i), "dim");
		
		
			// update the bounding box of the protein.
			if ( hor < 0 ){
				if (protein_shape_abs[i].x < top_left_corner.x) top_left_corner.x = protein_shape_abs[i].x; 
			} else {
				if (protein_shape_abs[i].x > bottom_right_corner.x) bottom_right_corner.x = protein_shape_abs[i].x; 
			}
			
			if ( ver < 0 ){
				if (protein_shape_abs[i].y < top_left_corner.y) top_left_corner.y = protein_shape_abs[i].y; 
			} else {
				if (protein_shape_abs[i].y > bottom_right_corner.y) bottom_right_corner.y = protein_shape_abs[i].y;
			}
		
		}
		
		protein_width	 = bottom_right_corner.x - top_left_corner.x;
		protein_height = bottom_right_corner.y - top_left_corner.y;
		
		center = new PVector(bottom_right_corner.x - (protein_width/2), bottom_right_corner.y - (protein_height/2)); 
	} // end calculatePath()
	
	// Calculate the color of each line segment beforehand. Reduces computation
	// per draw cycle (but increases memory slightly)
	private int calculateColors(CharSequence c, String type){
		if (aa_pos.contains(c)){
			if (type == "bright") return aa_colors_bright[0];
			if (type == "dim") return aa_colors_dim[0];
		} else if (aa_neg.contains(c)){
			if (type == "bright") return aa_colors_bright[1];
			if (type == "dim") return aa_colors_dim[1];
		} else if (aa_pol.contains(c)){
			if (type == "bright")	return aa_colors_bright[2];
			if (type == "dim") return aa_colors_dim[2];
		} else if (aa_spe.contains(c)){
			if (type == "bright") return aa_colors_bright[3];
			if (type == "dim") return aa_colors_dim[3];
		} else if (aa_pho.contains(c)){
			if (type == "bright")return aa_colors_bright[4];
			if (type == "dim") return aa_colors_dim[4];
		}
		
		return color(0xffFFFFFF);
	} // end calculateColors(CharSequence c)
	
	
	
	public void drawPath(){
		this.drawPath(1.0f);
	} // end drawPath()
	
	// Draws the protein shape from the calculatePath()
	public void drawPath(float scale_factor){
		pushStyle();
		
			// Create the dots at the start and stop of the protein.
			// Start protein dot
			fill(0xffC3000A); // Red
			noStroke();
			ellipse(0,0, 
							dot_size,dot_size);
			// End protein dot				
			fill(0xff1C8FF2); // Blue
			ellipse(protein_shape_abs[protein_length].x*scale_factor,
							protein_shape_abs[protein_length].y*scale_factor, 
							dot_size,dot_size);
			
		popStyle();
		
		// Set style for lines.
		pushStyle();
		textFont(aa_font);
		textAlign(CENTER, CENTER);
		textSize(10);
		strokeWeight(2);
		
		// Draw the first amino acid line.
		PVector first_vector = protein_shape_abs[1];
		stroke(brightOrDim(0));
				
		line(0,0, first_vector.x*zoom, first_vector.y*zoom);
		
		// Draw the rest of the lines
		for (int i = 1; i < protein_length; i++){
			PVector first_node	= protein_shape_abs[i];
			PVector second_node	= protein_shape_abs[i+1];
			
			// Calculate the line
			float x1 = first_node.x		* scale_factor;
			float y1 = first_node.y		* scale_factor;
			float x2 = second_node.x	* scale_factor;
			float y2 = second_node.y	* scale_factor;
			
			stroke(brightOrDim(i));
			line(x1, y1, x2, y2);
			
			// Draw ellipse for amino acid after drawing the line to the next one
			// so that the line is not on top of the circle.
			drawAminoAcid(i-1, first_node);
		}
		
		PVector last_node = protein_shape_abs[protein_length];
		drawAminoAcid(protein_length-1, last_node, 0xff00FFF6);
		
		popStyle();
	
	} // end drawPath(float scale_factor)
	
	private void drawAminoAcid(int sequence_index, PVector location){
		drawAminoAcid(sequence_index, location, 0xffFFFFFF);
	}
	
	private void drawAminoAcid(int sequence_index, PVector location, int circle_color){
		pushStyle();
	
		if (zoom > 30 && aaOn && lettersOn){
			stroke(brightOrDim(sequence_index));

				
				// Draw circle
					strokeWeight(3);
					fill(circle_color);
					ellipse(location.x*zoom,location.y*zoom, 14,14);
				
				// Add amino acid letter to circle.
				fill(0xff000000);
				text(sequence.charAt(sequence_index), location.x*zoom,location.y*zoom);
		} else if (zoom > 10 && aaOn){ // else just draw the circle.
				if (colorsOn){
					stroke(brightOrDim(sequence_index));
					fill(brightOrDim(sequence_index));
				} 
				
				// Draw circle
				strokeWeight(3);
				ellipse(location.x*zoom,location.y*zoom, 4,4);
				
		}
		popStyle();
	}
	
	public void reduceSegments(int amount){
		if (this.on_segments - amount < 0) {
			this.on_segments = 0;
		} else {
			this.on_segments -= amount;
		}
	}
	
	public void increaseSegments(int amount){
		if (this.on_segments + amount > this.protein_length){
			this.on_segments = this.protein_length;
		} else{
			this.on_segments += amount;
		}
	}
	
	public void allSegments(){
		this.on_segments = this.protein_length;
	}
	
	public void noSegments(){
		this.on_segments = 0;
	}
	
	private int brightOrDim(int index){
		if (colorsOn){
			if (on_segments > index){
				return colors_bright[index];
				
			} else {
				return colors_dim[index];
			}
		}
		
		return 0xffFFFFFF;
	}
	
	
} // end Protein

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#FFFFFF", "proteios" });
  }
}
