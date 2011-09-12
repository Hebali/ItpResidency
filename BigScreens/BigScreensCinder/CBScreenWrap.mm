/*    BigScreens for Cinder    */
/* ITP Residency Code Projects */
/*  Patrick Hebron, 2011-2012  */
/*    patrick.hebron@nyu.edu   */

#include "CBScreenWrap.h"

CBScreenWrap::CBScreenWrap() {
    isRunning = false;
}

void CBScreenWrap::setup() {
    isRunning = true;
    if(isRunning) {     
        //cout << "app setup.\n";
    }
}

void CBScreenWrap::update() {
    if(isRunning) {
        //cout << "app update.\n";
    }
}

void CBScreenWrap::draw() {
    if(isRunning) {
        //cout << "app draw.\n";
        
        gl::clear(Color(0.0,0.0,0.0));
        gl::setMatricesWindow(Vec2i(200,200));
        
        gl::enableAlphaBlending(false);
        
        gl::color(Color(1.0,1.0,1.0));
        gl::drawString("Testing...",Vec2f(50,50));
    }
}

void CBScreenWrap::resize(ResizeEvent event) {
    if(isRunning) {
    }
}

void CBScreenWrap::shutdown() {
    if(isRunning) {
    }
    isRunning = false;
}