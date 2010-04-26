// 
//  Protein.pde
//  Proteios -- COMP 150-04
//  
//  Created by Ryan Orendorff on 2010-04-19.
//  Copyright 2010 RDO Designs. All rights reserved.
// 

//  Code available under the GPLv3.

class Protein{
	String sequence;
	PVector[] protein_shape_abs;
	PVector[] protein_shape_rel;
	color[] colors;
	int protein_length;
	
	// size of beginning and ending dot.
	static final float dot_size		= 6;
	
	
	// ===============
	// = Constructor =
	// ===============
	Protein(String sequence){
		this.sequence = sequence;
		
		this.protein_length = sequence.length();
		this.protein_shape_abs = new PVector[this.protein_length+1];
		this.protein_shape_rel = new PVector[this.protein_length+1];
		this.colors = new color[this.protein_length];
		this.calculatePath();
	} // end Constructor(String sequence)
	
	
	// Creates a PVector[] that holds each node in the sequence
	// Note: all vectors are unit vectors.
	void calculatePath(){
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
			
			protein_shape_abs[i] = PVector.add(previous_node, protein_shape_rel[i]);
			
			colors[i-1] = calculateColors(sequence.subSequence(i-1, i));
		}
	} // end calculatePath()
	
	// Calculate the color of each line segment beforehand. Reduces computation
	// per draw cycle (but increases memory slightly)
	color calculateColors(CharSequence c){
		if (aa_pos.contains(c)){
			return aa_colors[0];
		} else if (aa_neg.contains(c)){
			return aa_colors[1];
		} else if (aa_pol.contains(c)){
			return aa_colors[2];
		} else if (aa_spe.contains(c)){
			return aa_colors[3];
		} else if (aa_pho.contains(c)){
			return aa_colors[4];
		}
		
		return color(#FFFFFF);
	} // end calculateColors(CharSequence c)
	
	
	
	void drawPath(){
		this.drawPath(1.0);
	} // end drawPath()
	
	// Draws the protein shape from the calculatePath()
	void drawPath(float scale_factor){
		pushStyle();
		
			// Create the dots at the start and stop of the protein.
			// Start protein dot
			fill(#C3000A); // Red
			noStroke();
			ellipse(0,0, 
							dot_size,dot_size);
			// End protein dot				
			fill(#1C8FF2); // Blue
			ellipse(protein_shape_abs[protein_length].x*scale_factor,
							protein_shape_abs[protein_length].y*scale_factor, 
							dot_size,dot_size);
			
		popStyle();
		
		// Set style for lines.
		pushStyle();
		textFont(aa_font);
		textAlign(CENTER, CENTER);
		textSize(12);
		strokeWeight(2);
		
		// Draw the first amino acid line.
		PVector first_vector = protein_shape_abs[1];
		if (colorsOn) stroke(colors[0]);
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
			
			if (colorsOn) stroke(colors[i]);
			line(x1, y1, x2, y2);
			
			// Draw ellipse for amino acid after drawing the line to the next one
			// so that the line is not on top of the circle.
			if (zoom > 30 && aaOn){
					if (colorsOn) stroke(colors[i-1]);

					
					// Draw circle
					pushStyle();
						strokeWeight(3);
						fill(#FFFFFF);
						ellipse(x1,y1, 14,14);
					popStyle();
					
					// Add amino acid letter to circle.
					fill(#000000);
					text(sequence.charAt(i-1), x1,y1);
			} else if (zoom > 10 && aaOn){ // else just draw the circle.
					if (colorsOn){
						stroke(colors[i-1]);
						fill(colors[i-1]);
					} 
					
					// Draw circle
					strokeWeight(3);
					ellipse(x1,y1, 4,4);
					
			}
		}
		popStyle();
	
	} // end drawPath(float scale_factor)
	
} // end Protein