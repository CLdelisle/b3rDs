/*
b3rDs
Colby DeLisle
2016
*/

// Separation: ~1/r^2 repulsion
// Cohesion: center of mass of neighbors gives direction of steering vector - subtract agent velocity from this
// Alignment: avg velocity vector of neighbors is "desired velocity" - subtract agent velocity from this

// Obstacle avoidance: also 1/r^2 ?

//////////////////////////////
// GLOBAL VARIABLES
//////////////////////////////

float XBOUND = 500, YBOUND = 500, ZBOUND = 500;

PVector pos, dir;
PVector up,right,downleft;
float berdSize = 40.0;

//////////////////////////////
// FUNCTION DEFS
//////////////////////////////

void init(){
  pos = new PVector(XBOUND/2, YBOUND/2, 0);
  dir = PVector.random3D();
  up = new PVector(0,-1.0,0);
  right = new PVector(-1.0,0,0);
  downleft = new PVector(1.0,1.0,0);
  downleft.normalize();
}

void drawBerd(PVector pos, PVector dir) {
  dir.normalize();
  PVector axis = dir.cross(up);
  axis.normalize();
  float dotProd = dir.dot(up);
  float theta = acos(dotProd);
  pushMatrix();
  fill(0,255,0);
  translate(pos.x, pos.y, pos.z);
  rotate(-theta, axis.x, axis.y, axis.z);
  sphereDetail(1,4); 
  sphere(berdSize);
  popMatrix();
}

PVector enforceTorus(PVector pos) {
  if(pos.x > XBOUND) {
    pos.x = 0;
  }
  else if (pos.x < 0) {
    pos.x = XBOUND; 
  }
  
  if(pos.y > YBOUND) {
    pos.y = 0;
  }
  else if (pos.y < 0) {
    pos.y = YBOUND; 
  }
  
  return pos;
}

//////////////////////////////
// SETUP (once)
//////////////////////////////

void setup() {
  size(500,500,P3D);
  background(255);
  stroke(0);
  fill(0,255,0);
  lights();
  init();
}

//////////////////////////////
// DRAW CALL (each frame)
//////////////////////////////

void draw() {
   background(255);
   PVector direction = new PVector(mouseX-pos.x, mouseY-pos.y, 0.0);
   //PVector direction = new PVector(1.0,1.0,0);
   float r = direction.mag();
   direction.normalize();
   float velocity = 2.0;
   pos.add(direction.mult(velocity));
   pos = enforceTorus(pos);
   drawBerd(pos,direction);
}