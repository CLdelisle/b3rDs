/*
b3rDs
Colby DeLisle
2016
*/

/* 
"Ever make mistakes in life?
Let's make them [berds]. Yeah, they're [berds] now."
*/

// THREE GOALS:
// Separation: ~1/r^2 repulsion
// Cohesion: center of mass of neighbors gives direction of steering vector - subtract agent velocity from this
// Alignment: avg velocity vector of neighbors is "desired velocity" - subtract agent velocity from this

// Obstacle avoidance: also 1/r^2 ?

//////////////////////////////
// GLOBAL VARIABLES
//////////////////////////////

float XBOUND = 500, YBOUND = 500, ZBOUND = 500;
int NUM_BERDS = 5;

PVector pos, dir;
PVector up,right,downleft;

ArrayList<Berd> Flock; // Test group -- put in Class?
//Berd b; // Test individual

//////////////////////////////
// BERD
//////////////////////////////
class Berd {
  // Attributes
  PVector pos, dir;
  float size = 40.0;
  float velocity = 2.0;
  float radius = size; // Radius in which to search for neighbors
  
  // Methods
  Berd(){
    this.pos = PVector.random3D();
    this.dir = PVector.random3D();
  }
  Berd(PVector p, PVector d){
    this.pos = new PVector(p.x, p.y, p.z);
    this.dir = new PVector(d.x, d.y, d.z);
  }
  
  void updatePos(){
    ArrayList<Berd> neighborList = this.findNeighbors();
    this.pos.add(this.dir.mult(this.velocity));
    this.pos = enforceTorus(this.pos);
  }
  // Please note here that velocity is constant for now. 
  // Will implement the bonafide vector calculus version soon,
  // after confirming core functionality
  void updateDir(){
    this.dir.set(mouseX-pos.x, mouseY-pos.y, 0.0);
  }
  
  void drawBerd(){
    this.updatePos();
    this.updateDir();
    this.dir.normalize();
    PVector axis = this.dir.cross(up);
    axis.normalize();
    float dotProd = this.dir.dot(up);
    float theta = acos(dotProd);
    pushMatrix();
    fill(0,255,0);
    translate(this.pos.x, this.pos.y, this.pos.z);
    rotate(-theta, axis.x, axis.y, axis.z);
    sphereDetail(1,4); 
    sphere(this.size);
    popMatrix();
  }
  
  ArrayList<Berd> findNeighbors() {
    // Using exhaustive search for now.
    // If performance requires it, I'll use 
    // something more sophisticated later.
    
    ArrayList<Berd> neighborList = new ArrayList();
    
    for (Berd p : Flock) {
      // The following calculation (two lines) will need done again
      // maybe find a way to only do it once? 
      // don't make findNeighbors() its own method?
      PVector sep = new PVector();
      PVector.sub(this.pos,p.pos,sep);
      float dist = sep.mag();
      if(dist < this.radius){
        neighborList.add(new Berd(p.pos, p.dir));
      }
    }
    
    return neighborList;
  }
}

//////////////////////////////
// FUNCTION DEFS
//////////////////////////////

void init(){
  // this function initializes the logic state
  // the setup() function I reserve for Processing environment calls.
  pos = new PVector(XBOUND/2, YBOUND/2, 0);
  dir = PVector.random3D();
  
  // Generate berds
  //b = new Berd(pos, dir);
  generateFlock(NUM_BERDS);
  
  
  up = new PVector(0,-1.0,0);
  right = new PVector(-1.0,0,0);
  downleft = new PVector(1.0,1.0,0);
  downleft.normalize();
}

void generateFlock(int n){
    // Generates a random flock of size n
    Flock = new ArrayList();
    
    PVector tempPos = new PVector(random(XBOUND),random(YBOUND), 0.0);
    PVector tempDir = new PVector(random(XBOUND),random(YBOUND), 0.0);
    tempDir.normalize();
    for(int i= 0; i < n; i++){
      Flock.add(new Berd(tempPos, tempDir));
      tempPos.set(random(XBOUND),random(YBOUND), 0.0);
      tempDir.set(random(XBOUND),random(YBOUND), 0.0);
      tempDir.normalize();
    }
}


// Generalize to arbitrary topo?
PVector enforceTorus(PVector pos) {
  // This gives the space the topology of a torus, though right now only in x,y directions
  // May want to do the same for z but seems like the visuals would be confusing
  
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
  // Initialize Processing
  size(500,500,P3D);
  background(255);
  stroke(0);
  fill(0,255,0);
  lights();
  
  // Initialize logic
  init();
}

//////////////////////////////
// DRAW CALL (each frame)
//////////////////////////////

void draw() {
   background(255);
  
   //test individual
   //b.drawBerd();
   
   //test flock
   for (int i = 0; i < Flock.size(); i++) {
     Flock.get(i).drawBerd();
   }
}