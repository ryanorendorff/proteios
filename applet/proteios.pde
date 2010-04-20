// 
//  proteios.pde
//  Proteios -- COMP 150-04
//  
//  Created by Ryan Orendorff on 2010-04-15.
//  Copyright 2010 RDO Designs. All rights reserved.
// 

Protein protein;

String file = "sequence.txt";

float speed = 0.2;
float acc = 0.2;

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



void setup(){
	size(600,600);
	
	resize_cursor = loadImage("resize_cursor.png");
	
	String file = "sequence.txt";
	
	grid_pos_x = width/2;
	grid_pos_y = height/2;
	
	protein = new Protein(loadProteinSequence());
	background(0);

} // end setup




void draw(){
	background(0);
	fill(#FFFFFF);
	
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
	stroke(#FFFFFF);
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


String loadProteinSequence(){
	String[] sequence = loadStrings(file);
	return sequence[0];
} // end loadProteinSequence

void drawNavigator(){
	pushStyle();
	textAlign(CENTER);
	pushMatrix();
	
		for (int i = 0; i < 21; i++){
			text(aa.charAt(i), 200*cos(radians(angle_inc*i)), 200*sin(radians(angle_inc*i)));
		}
	
	popMatrix();
	popStyle();
}

void mousePressed(){
	
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

void mouseReleased(){
	locked = false;
	
	cursor(ARROW);
} // end mouseReleased

void mouseDragged(){
	
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

void keyPressed(){
	if				(key == 'm'){
		magnifyMode = magnifyMode ? false : true;
	} else if	(key == 'c'){
		grid_pos_x = width/2;
		grid_pos_y = height/2;
	} else if	(key == 'n'){
		navigatorOn = navigatorOn ? false : true;
	}
	
	
} // end keyPressed
