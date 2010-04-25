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
	color[] colors;
	int protein_length;
	
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
	} // end Constructor
	
	
	// ============================================================
	// = Creates a PVector[] that holds each node in the sequence =
	// ============================================================
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
			
			// println(new_x + "," + new_y);
		}
	} // end calculatePath
	
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
	} // end calculateColors
	
	
	
	void drawPath(){
		this.drawPath(1.0);
	}
	
	// void drawPath(float scale_factor){
	// 	pushStyle();
	// 		fill(#C3000A);
	// 		noStroke();
	// 		ellipse(0,0, 
	// 						dot_size,dot_size);
	// 
	// 		fill(#1C8FF2);
	// 		ellipse(protein_shape_abs[protein_length].x*scale_factor,
	// 						protein_shape_abs[protein_length].y*scale_factor, 
	// 						dot_size,dot_size);
	// 		
	// 	popStyle();
	// 					
	// 	for (int i = 0; i < protein_length; i++){
	// 		PVector first_node	= protein_shape_abs[i];
	// 		PVector second_node	= protein_shape_abs[i+1];
	// 		
	// 		float x1 = first_node.x * scale_factor;
	// 		float y1 = first_node.y * scale_factor;
	// 		float x2 = second_node.x * scale_factor;
	// 		float y2 = second_node.y * scale_factor;
	// 		
	// 		if (colorsOn) stroke(colors[i]);
	// 		line(x1, y1, x2, y2);
	// 		
	// 		if (zoom > 20 && aaOn){
	// 			pushStyle();
	// 				textAlign(CENTER, CENTER);
	// 				textSize(12);
	// 				
	// 				fill(#FFFFFF);
	// 				ellipse(x2,y2, 12,12);
	// 				
	// 				fill(#000000);
	// 				text(sequence.charAt(i), x2-0.4,y2-1);
	// 				// text(sequence.charAt(i), x1+(x2-x1)*1.02, y1+(y2-y1)*1.02);
	// 			popStyle();
	// 		}
	// 	}
	// 
	// } // end drawPath
	
	
	void drawPath(float scale_factor){
		pushStyle();
			fill(#C3000A);
			noStroke();
			ellipse(0,0, 
							dot_size,dot_size);

			fill(#1C8FF2);
			ellipse(protein_shape_abs[protein_length].x*scale_factor,
							protein_shape_abs[protein_length].y*scale_factor, 
							dot_size,dot_size);
			
		popStyle();
		
		PVector first_vector = protein_shape_abs[1];
		
		if (colorsOn) stroke(colors[0]);
		line(0,0, first_vector.x*zoom, first_vector.y*zoom);
						
		for (int i = 1; i < protein_length; i++){
			PVector first_node	= protein_shape_abs[i];
			PVector second_node	= protein_shape_abs[i+1];
			
			float x1 = first_node.x * scale_factor;
			float y1 = first_node.y * scale_factor;
			float x2 = second_node.x * scale_factor;
			float y2 = second_node.y * scale_factor;
			
			if (colorsOn) stroke(colors[i]);
			line(x1, y1, x2, y2);
			
			if (zoom > 20 && aaOn){
				pushStyle();
					if (colorsOn) stroke(colors[i-1]);
					textAlign(CENTER, CENTER);
					textSize(12);
					
					strokeWeight(2);
					fill(#FFFFFF);
					ellipse(x1,y1, 14,14);
					
					fill(#000000);
					text(sequence.charAt(i-1), x1-0.4,y1-1);
				popStyle();
			}
		}
	
	} // end drawPath
	
} // end Protein