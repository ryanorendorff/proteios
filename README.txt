Proteios README file
Use monospaced font (Monaco)

===========
= Purpose =
===========

The Proteios program provides a geometrical way of looking at protein sequences. This approach to the primary protein transcript was chosen because we can absorb a large amount of information from a picture, and many people report greater interest and understanding when presented with a interactive, graphical dataset as opposed to raw text.

==============
= How to Run =
==============
To run the program, open "proteios.pde" in the Processing environment. If you do not have the Processing environment, then you can download a copy from http://processing.org/ and follow their instructions on how to install Processing.

At this time, it is not possible to export this application as a stand-alone binary.

==============
= How to use =
==============

The main screen looks like so.

----------------------------------------------------------
| Options                           Current Protein Name |
|                                                        |  
|                                                        |
|                                                        |
|                                                        |
|                          _   The Protein               |
|                        /   \                           |
|                       |     |                          |
| Blue Dot = end   O__ /      |                          |
|                             O  Red Dot = Start         |
|                                                        |
|                                                        |
|                                                        |
|                                             Zoom Level |
----------------------------------------------------------

The protein is the main structure in the middle, while the corners are used to display information about the current settings. The letters that appear in the top left corner are the different options that are currently on. The window can be resized on the bottom right corner or by pressing the maximize button.

There are a few modes.
-------------------------------------------------------------------------------
m  = Magnify Mode    (mouse actions cause magnification)
a  = Amino Acid mode (draws circles at the connection between two lines)
 l = Letter mode     (adds the amino acid letter in to the circle from ^
                      note: only works when amino acid mode is on).
c  = color mode      (uses a color scheme to color the lines and circles)
-------------------------------------------------------------------------------

These modes can be turned on and off by pressing the corresponding lower case key.

A navigator that decrypts the color scheme and provides information as to what amino acid is located in which direction can be activated by pressing n.
-------------------------------------------------------------------------------
n = Turn the Navigator on/off
-------------------------------------------------------------------------------

This navigator is split into five segments. They mean the following
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   Red = Positively charged.
  Blue = Negatively charged.
 Green = Polar but no net charge
Purple = Special groups
Orange = Hydrophobic groups
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Some of the amino acids have multiple properties that overlap. In this case, the most prominent feature was used. An updated version of this program would need the ability to change the navigator to fit these different property schemes.

The protein can be moved around by left clicking anywhere in the application and dragging the mouse to a new location. If Magnify Mode is on, clicking and dragging the mouse causes the protein to become larger or smaller if you drag the mouse to the right or left, respectively. Additionally, there are two key presses to help with orienting the protein
-------------------------------------------------------------------------------
upper case letter O = Fit the protein to the screen
lower case letter o = Center the Red Dot in the middle of the screen
-------------------------------------------------------------------------------

Multiple sequences are loaded into the program by default. To switch between the sequences press the tab key. To go in reverse through the list, press shift+tab.
-------------------------------------------------------------------------------
      tab = Rotate forwards through the available proteins
shift+tab = Rotate backwards through the available protein
-------------------------------------------------------------------------------

The highlighting on the sequences can also be turned between a dim color and a bright color. This is helpful for looking through proteins where the sequence overlaps with itself many times, as the amino acids can be highlighted one at a time to discern how the structure was build.
-------------------------------------------------------------------------------
           left = Dim the last highlighted segment
     shift+left = Dim the last five highlighted segments
 alt+shift+left = Dim the last twenty highlighted segments
          right = Highlight the next segment
    shift+right = Highlight the next five segments
alt+shift+right = Highlight the next twenty segments

             up = Highlight the entire protein
           down = Dim the entire protein
-------------------------------------------------------------------------------


================================
= How to load/unload sequences =
================================

All of the sequences are located in "./data/sequences/". To remove a sequence from the program, simply relocate or delete the file in question.

To add a protein to the program, the python script "protein_to_proteios.py" can be used to take the information out of a GenPept file from the NCBI database and turn it into a format that Proteios understands. To run this program, simply put the GenPept files that you want to convert in the "proteins_to_be_converted" folder and run in the main directory of Proteios

  python protein_to_proteios.py

This generates text files for the sequences that are placed in "./data/sequences/".

The files are simple. The first line of the file is the name of the protein. The second is the sequence and only the sequence (no spaces, numbering, etc). The sequence can be in either upper or lower case; Proteios will automatically convert everything to upper case when it imports the file.