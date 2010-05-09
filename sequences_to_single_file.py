#!/usr/bin/env python
# encoding: utf-8
"""
sequences_to_single_file.py
Proteios -- COMP 150-04

Created by Ryan Orendorff on 2010-05-02.
Copyright (c) 2010 RDO Designs. All rights reserved.

Code available under the GPLv3. See proteios.pde and gpl3.txt for full license information.

GenPept files from
http://www.ncbi.nlm.nih.gov/protein/
"""

import sys
import os
import re

# Grab the file names
genpept_file_list = os.listdir("./proteins_to_be_processed/")

write_string = ""

for genpept_name in genpept_file_list:
	
	genpept_file = open('./proteins_to_be_processed/' + genpept_name, 'r')
	m = re.search('DEFINITION  (?P<desc>.*?)\..*?ORIGIN (?P<sequence>.*?)//', genpept_file.read(), re.S)
	
	protein_name = m.group('desc')
	sequence = re.sub('\d|\s', '', m.group('sequence'))
	
	write_string += protein_name+'\n'
	write_string += sequence.upper()+'\n'

print write_string.rstrip()
	
write_file_loc = './data/sequences.txt'
g = open(write_file_loc, 'w')
g.write(write_string)