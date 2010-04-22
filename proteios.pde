// 
//  proteios.pde
//  Proteios -- COMP 150-04
//  
//  Created by Ryan Orendorff on 2010-04-15.
//  Copyright 2010 RDO Designs. All rights reserved.
// 
import fullscreen.*;
SoftFullScreen fs;

Protein protein;
Protein[] proteins = new Protein[2];

int protein_selected = 0;

String file = "sequence.txt";

float speed = 0.2;
float acc = 0.2;

PVector held_pos = new PVector(0,0);

PVector grid_pos = new PVector(0,0);

float zoom = 1;

PImage resize_cursor;

boolean locked = false;
boolean magnifyMode = false;
boolean navigatorOn = false;
boolean aaOn = false;

boolean first_run = true;

static final float angle_inc	= 360/21;
static final float dot_size		= 6;

static final String aa_pos	= "RHK";
static final String aa_neg	= "DE";
static final String aa_pol	= "STNQ";
static final String aa_spe	= "CUGP";
static final String aa_pho	= "AILMFWYV";
static final String aa			= "RHKDESTNQCUGPAILMFWYV";



void setup(){
	size(600,600);
	
	fs = new SoftFullScreen(this);
	// fs.enter();
	fs.setShortcutsEnabled(true);
	
	frame.setResizable(true);
	frame.setTitle("Proteios - Protein Visualization");
	
	resize_cursor = loadImage("resize_cursor.png");
	
	String file = "sequence.txt";

	
	proteins[0] = new Protein(loadProteinSequence("sequence_heavy.txt"));
	proteins[1] = new Protein(loadProteinSequence("sequence_light.txt"));
	background(0);
	

} // end setup


void draw(){
	
	background(0);
	fill(#FFFFFF);
	
	if (magnifyMode){
		pushStyle();
			textAlign(LEFT);
			fill(#D35806);
			
			textSize(18);
			text("M", 10, 16);
		popStyle();
	}
	
	if (aaOn){
		pushStyle();
			textAlign(LEFT);
			fill(#2F9416);
			
			textSize(18);
			text("A", 30, 16);
		popStyle();
	}
	
	
	pushStyle();
		textAlign(RIGHT);
		if (protein_selected == 0){
			text("Silk Heavy Chain", width - 10, 10);
		} else if (protein_selected == 1) {
			text("Silk Light Chain", width - 10, 10);
		}
		
		text(zoom+"x", width-10, height-10);
	popStyle();

	translate(width/2, height/2);
	
	pushStyle();
	stroke(#FFFFFF);
	strokeWeight(1);
	
		pushMatrix();
			translate(grid_pos.x, grid_pos.y);
			proteins[protein_selected].drawPath(zoom);
		popMatrix();
		
	popStyle();
	
	if (navigatorOn){
		pushMatrix();
			translate(0, 0);
			drawNavigator();
		popMatrix();
	}
	
	
} // end draw


String loadProteinSequence(){
	return loadProteinSequence(file);
} // end loadProteinSequence

String loadProteinSequence(String protein_file){
	String[] sequence = loadStrings(protein_file);
	return sequence[0].toUpperCase();
} // end loadProteinSequence




void drawNavigator(){
	pushStyle();
	textAlign(CENTER);
	pushMatrix();
	
		for (int i = 0; i < 21; i++){
			text(aa.charAt(i), 200*cos(radians(angle_inc*i)), 200*sin(radians(angle_inc*i)));
		}
	
	noFill();
	strokeWeight(1);
	stroke(#C3000A);
	ellipse(0,0,8,8);

	
	arc(0,0, 370, 370, 0, radians(angle_inc*2));
	arc(0,0, 370, 370, radians(angle_inc*3), radians(angle_inc*4));
	arc(0,0, 370, 370, radians(angle_inc*5), radians(angle_inc*8));
	arc(0,0, 370, 370, radians(angle_inc*9), radians(angle_inc*12));
	arc(0,0, 370, 370, radians(angle_inc*13), radians(angle_inc*20));
		
	
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
		
		grid_pos.mult(zoom/old_zoom);
		
	} else {
		cursor(MOVE);
		grid_pos.x += mouseX - pmouseX;
		grid_pos.y += mouseY - pmouseY;
	}
} // end mouseDragged




void keyPressed(){
	if				(key == 'm'){
			magnifyMode = magnifyMode ? false : true;
	} else if	(key == 'c'){
			grid_pos.x = 0;
			grid_pos.y = 0;
	} else if	(key == 'n'){
			navigatorOn = navigatorOn ? false : true;
	} else if	(key == 'a'){
			aaOn = aaOn ? false : true;
	} else if	(key == '1'){
			protein_selected = 0;
	}	else if	(key == '2'){
			protein_selected = 1;
	}
	
	
} // end keyPressed