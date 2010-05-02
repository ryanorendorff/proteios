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
	String name;
	PVector[] protein_shape_abs;
	PVector[] protein_shape_rel;
	color[] colors_bright;
	color[] colors_dim;
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
		this.colors_bright = new color[this.protein_length];
		this.colors_dim = new color[this.protein_length];
		this.calculatePath();
	} // end Constructor(String sequence)
	
	
	// Creates a PVector[] that holds each node in the sequence
	// Note: all vectors are unit vectors.
	void calculatePath(){
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
	color calculateColors(CharSequence c, String type){
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
		drawAminoAcid(protein_length-1, last_node, #00FFF6);
		
		popStyle();
	
	} // end drawPath(float scale_factor)
	
	void drawAminoAcid(int sequence_index, PVector location){
		drawAminoAcid(sequence_index, location, #FFFFFF);
	}
	
	void drawAminoAcid(int sequence_index, PVector location, color circle_color){
		pushStyle();
	
		if (zoom > 30 && aaOn && lettersOn){
			stroke(brightOrDim(sequence_index));

				
				// Draw circle
					strokeWeight(3);
					fill(circle_color);
					ellipse(location.x*zoom,location.y*zoom, 14,14);
				
				// Add amino acid letter to circle.
				fill(#000000);
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
	
	void reduceSegments(int amount){
		if (this.on_segments - amount < 0) {
			this.on_segments = 0;
		} else {
			this.on_segments -= amount;
		}
	}
	
	void increaseSegments(int amount){
		if (this.on_segments + amount > this.protein_length){
			this.on_segments = this.protein_length;
		} else{
			this.on_segments += amount;
		}
	}
	
	void allSegments(){
		this.on_segments = this.protein_length;
	}
	
	void noSegments(){
		this.on_segments = 0;
	}
	
	color brightOrDim(int index){
		if (colorsOn){
			if (on_segments > index){
				return colors_bright[index];
				
			} else {
				return colors_dim[index];
			}
		}
		
		return #FFFFFF;
	}
	
	
} // end Protein