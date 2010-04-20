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

// 
//  proteios.pde
//  Proteios -- COMP 150-04
//  
//  Created by Ryan Orendorff on 2010-04-15.
//  Copyright 2010 RDO Designs. All rights reserved.
// 

Protein protein;

String file = "sequence.txt";

float speed = 0.2f;
float acc = 0.2f;

int held_pos_x;
int held_pos_y;

int grid_pos_x;
int grid_pos_y;

float zoom = 20;

PImage resize_cursor;

boolean locked = false;
boolean magnifyMode = false;
boolean navigatorOn = false;

static final float angle_inc	= 360/21;
static final float dot_size		= 4;

static final String aa_pos	= "RHK";
static final String aa_neg	= "DE";
static final String aa_pol	= "STNQ";
static final String aa_spe	= "CUGP";
static final String aa_pho	= "AILMFWYV";
static final String aa			= "RHKDESTNQCUGPAILMFWYV";



public void setup(){
	size(600,600);
	
	resize_cursor = loadImage("resize_cursor.png");
	
	String file = "sequence.txt";
	
	grid_pos_x = width/2;
	grid_pos_y = height/2;
	
	protein = new Protein(loadProteinSequence());
	background(0);

} // end setup




public void draw(){
	background(0);
	fill(0xffFFFFFF);
	
	if (magnifyMode){
		pushStyle();
			textAlign(LEFT);
			text("M", 10, 10);
		popStyle();
	}
		pushStyle();
			textAlign(RIGHT);
			text("AAB31861.1", width - 10, 10);
		popStyle();

	
	pushStyle();
	stroke(0xffFFFFFF);
	strokeWeight(1);
	
		pushMatrix();
			translate(grid_pos_x, grid_pos_y);
			protein.drawPath(zoom);
		popMatrix();
	popStyle();
	
	if (navigatorOn){
		pushMatrix();
			translate(width/2, height/2);
			drawNavigator();
		popMatrix();
	}
	
	
} // end draw


public String loadProteinSequence(){
	String[] sequence = loadStrings(file);
	return sequence[0];
} // end loadProteinSequence

public void drawNavigator(){
	pushStyle();
	textAlign(CENTER);
	pushMatrix();
	
		for (int i = 0; i < 21; i++){
			text(aa.charAt(i), 200*cos(radians(angle_inc*i)), 200*sin(radians(angle_inc*i)));
		}
	
	popMatrix();
	popStyle();
}

public void mousePressed(){
	
	if (magnifyMode){
		cursor(resize_cursor, 16, 16); 
	} else {
		cursor(MOVE);
	}
	
	if(!locked) {
		held_pos_x = mouseX;
		held_pos_y = mouseY;
		
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
		zoom += mouseX - pmouseX;
		if (zoom < 1) zoom = 1;
	} else {
		cursor(MOVE);
		grid_pos_x += mouseX - pmouseX;
		grid_pos_y += mouseY - pmouseY;
	}
} // end mouseDragged

public void keyPressed(){
	if				(key == 'm'){
		magnifyMode = magnifyMode ? false : true;
	} else if	(key == 'c'){
		grid_pos_x = width/2;
		grid_pos_y = height/2;
	} else if	(key == 'n'){
		navigatorOn = navigatorOn ? false : true;
	}
	
	
} // end keyPressed
// 
//  Protein.pde
//  Proteios -- COMP 150-04
//  
//  Created by Ryan Orendorff on 2010-04-19.
//  Copyright 2010 RDO Designs. All rights reserved.
// 

class Protein{
	String sequence;
	PVector[] protein_shape_abs;
	PVector[] protein_shape_rel;
	int protein_length;
	
	// ===============
	// = Constructor =
	// ===============
	Protein(String sequence){
		this.sequence = sequence;
		
		this.protein_length = sequence.length();
		this.protein_shape_abs = new PVector[this.protein_length+1];
		this.protein_shape_rel = new PVector[this.protein_length+1];
		this.calculatePath();
	} // end Constructor
	
	
	// ============================================================
	// = Creates a PVector[] that holds each node in the sequence =
	// ============================================================
	// Note: all vectors are unit vectors.
	public void calculatePath(){
		protein_shape_abs[0] = new PVector(0,0);
		protein_shape_rel[0] = new PVector(0,0);

		for (int i = 1; i < this.protein_length+1; i++){
			PVector previous_node = protein_shape_abs[i-1];
			
			// from 0 to 20
			int pos_on_circle = aa.indexOf(sequence.charAt(i-1));
			// println(pos_on_circle);
			
			float hor = cos(radians(angle_inc * pos_on_circle));
			float ver = sin(radians(angle_inc * pos_on_circle));
			
			protein_shape_rel[i] = new PVector(hor, ver);
			
			float new_x = previous_node.x + hor;
			float new_y = previous_node.y + ver;
			protein_shape_abs[i] = new PVector(new_x, new_y);
			
			// println(new_x + "," + new_y);
		}
	} // end calculatePath
	
	public void drawPath(){
		this.drawPath(1);
	}
	
	public void drawPath(float scale_factor){
		pushStyle();
			fill(0xffC3000A);
			noStroke();
			ellipse(0,0, 
							dot_size,dot_size);

			fill(0xff3152B4);
			ellipse(protein_shape_abs[protein_length].x*scale_factor,
							protein_shape_abs[protein_length].y*scale_factor, 
							dot_size,dot_size);
		popStyle();
		
		for (int i = 0; i < protein_length; i++){
			PVector first_node	= protein_shape_abs[i];
			PVector second_node	= protein_shape_abs[i+1];
			
			float x1 = first_node.x * scale_factor;
			float y1 = first_node.y * scale_factor;
			float x2 = second_node.x * scale_factor;
			float y2 = second_node.y * scale_factor;
			
			line(x1, y1, x2, y2);
		}
	
	} // end drawPath
	
} // end Protein

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#FFFFFF", "proteios" });
  }
}
