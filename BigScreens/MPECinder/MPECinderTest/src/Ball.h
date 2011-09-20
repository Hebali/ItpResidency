#pragma once

#include "cinder/app/AppBasic.h"
#include "cinder/gl/gl.h"
#include "cinder/Rand.h"

using namespace ci;
using namespace ci::app;
using namespace std;

class Ball {
public:
    Ball(float _x, float _y, float _mWidth, float _mHeight) {
        x = _x;
        y = _y;
        xDir = Rand::randInt(-5,5);
        yDir = Rand::randInt(-5,5);
        d = 10;
        mWidth  = _mWidth;
        mHeight = _mHeight;
    }
    
    //--------------------------------------
    // Moves and changes direction if it hits a wall.
    void calc() {
        if (x < 0 || x > mWidth)  xDir *= -1;
        if (y < 0 || y > mHeight) yDir *= -1;
        x += xDir;
        y += yDir;
    }
    
    //--------------------------------------
    void draw() {
        gl::color(Color(1.0,1.0,1.0));
        gl::drawSolidCircle(Vec2f(x,y),d);
    }
    
private:
    float x; 
    float y; 
    float xDir;
    float yDir;
    float d;
    float mWidth;
    float mHeight;
    
};
