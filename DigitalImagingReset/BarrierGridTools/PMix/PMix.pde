///////////////////////////////////////
// BARRIER GRID TOOLS FOR PROCESSING //
//          IMAGE MIXER v003         //
//                 BY                //
//  ERIC ROSENTHAL & PATRICK HEBRON  //
///////////////////////////////////////

import java.awt.*;
import java.io.*;

ImageMan imageMan;

void setup() {
  int border = 100;
  imageMan = new ImageMan(border);
  imageMan.setup();
}

void draw() {
  background(0);
  imageMan.draw();
}

void mousePressed() {
  imageMan.handleMouse();
}


/*

NOTES FOR NEXT REVISION:

PMix:
- Add fine and course shifting
- Remove the per-layer scaling
- Allow user to scale the final image (simple rescale)
- Add crop marks (user editable) and default version, which is the set of pixels where every src image has an active pixel
- create printout of the generation settings
- Add movie i/o

PGrid:
- Create display and ui so that user can see settings. 640x480 is the most important size, but should also allow other sizes.

(http://hackduino.org/mapblog/)

GLmulti view:
- Make app that can define multiple cam positions in a GL view and interlace them in realtime.


Can you make the LRUD shift coarse if the shift key is pressed 
and fine like it is now if the shift key is not pressed.

Once the images are aligned the images need to be cropped so that the 
only image that remains is the image area that is common to all images after alignment.

Once the cropping is accomplished and you press generate we need to be able to save that
as a new image so that it can be resized using a zoom function so that the image can then 
match the barrier grid applied to the display.

Once the zoom is accomplished we need to be able to store this newly sized image 
so that we can just display it on the screen with the barrier grid overlay and it 
should display correctly.

*/

