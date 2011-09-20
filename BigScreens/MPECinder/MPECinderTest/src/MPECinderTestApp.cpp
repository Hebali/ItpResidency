#include "cinder/app/AppBasic.h"
#include "cinder/gl/gl.h"

#include "mpeClientTCP.h"
#include "Ball.h"

using namespace ci;
using namespace ci::app;
using namespace std;

class MPECinderTestApp : public AppBasic {
  public:
	void setup();
	void mouseDown(MouseEvent event);	
	void update();
	void draw();
};

void MPECinderTestApp::setup() {
}

void MPECinderTestApp::mouseDown(MouseEvent event) {
}

void MPECinderTestApp::update() {
}

void MPECinderTestApp::draw() {
	gl::clear(Color(0,0,0)); 
}


CINDER_APP_BASIC( MPECinderTestApp, RendererGl )
