/*  Cinder BigScreens   */
/* Patrick Hebron, 2011 */

#include "CinderAppWrap.h"

CinderAppWrap::CinderAppWrap() {
    isRunning = false;
}

void CinderAppWrap::setup() {
    isRunning = true;
    
    if(isRunning) {        
    }
}

void CinderAppWrap::update() {
    if(isRunning) {
    }
}

void CinderAppWrap::draw() {
    if(isRunning) {
        gl::clear(Color(0.0,0.0,0.0));
        gl::setMatricesWindow(Vec2i(200,200));
        
        gl::enableAlphaBlending(false);
        
        gl::color(Color(1.0,1.0,1.0));
        gl::drawString("Testing...",Vec2f(50,50));
    }
}

void CinderAppWrap::resize(ResizeEvent event) {
    if(isRunning) {
    }
}

void CinderAppWrap::shutdown() {
    if(isRunning) {
    }
    isRunning = false;
}