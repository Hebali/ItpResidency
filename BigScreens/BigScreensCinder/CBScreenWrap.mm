/*    BigScreens for Cinder    */
/* ITP Residency Code Projects */
/*  Patrick Hebron, 2011-2012  */
/*    patrick.hebron@nyu.edu   */

#include "CBScreenWrap.h"

CBScreenWrap::CBScreenWrap() {
    isRunning = false;
}

void CBScreenWrap::setup() {
    if(!isRunning) {   
        mCam.lookAt( Vec3f( 3, 2, -3 ), Vec3f::zero() );
        mCubeRotation.setToIdentity();
        
        glEnable( GL_TEXTURE_2D );
        gl::enableDepthRead();
        gl::enableDepthWrite();	
        
        //cout << "app setup.\n";
        isRunning = true;
    }
}

void CBScreenWrap::update() {
    if(isRunning) {
        // Rotate the cube by .03 radians around an arbitrary axis
        mCubeRotation.rotate( Vec3f( 1, 1, 1 ), 0.03f );
        
        //cout << "app update.\n";
    }
}

void CBScreenWrap::draw() {
    if(isRunning) {
        /*
         gl::clear(Color(0.0,0.0,0.0));
         gl::setMatricesWindow(Vec2i(200,200));
         gl::enableAlphaBlending(false);
         gl::color(Color(1.0,1.0,1.0));
         gl::drawString("Testing...",Vec2f(50,50));
        */
        
        gl::clear( Color::black() );
        glPushMatrix();
		gl::multModelView( mCubeRotation );
		gl::drawStrokedCube( Vec3f::zero(), Vec3f( 2.0f, 2.0f, 2.0f ) );
        glPopMatrix();
        
        //cout << "app draw.\n";
    }
}

void CBScreenWrap::resize(ResizeEvent event) {
    if(isRunning) {
        // now tell our Camera that the window aspect ratio has changed
        mCam.setPerspective( 60, event.getAspectRatio(), 1, 1000 );
        // and in turn, let OpenGL know we have a new camera
        gl::setMatrices( mCam );
    }
}

void CBScreenWrap::shutdown() {
    if(isRunning) {
    }
    isRunning = false;
}