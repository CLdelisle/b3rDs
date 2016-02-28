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
// Cohesion: center of mass of neighbors gives direction of steering vector - subtract agent maxSpeed from this
// Alignment: avg maxSpeed vector of neighbors is "desired maxSpeed" - subtract agent maxSpeed from this

// Obstacle avoidance: also 1/r^2 ?

//////////////////////////////
// GLOBAL VARIABLES
//////////////////////////////

float XBOUND = 500, YBOUND = 500, ZBOUND = 500;
int NUM_BERDS = 10;
float distance_softening = 0.01;

PVector pos, dir;
PVector up,right,downleft;

ArrayList<Berd> Flock; // Test group -- put in Class?
//Berd b; // Test individual

//////////////////////////////
// FLOCK
//////////////////////////////
class Flock {
  // Attributes
  
  
  // Methods
  Flock() {
  }
}

//////////////////////////////
// BERD
//////////////////////////////
class Berd {
  // Attributes
  int id;
  PVector pos, dir;
  PVector vel, acc;
  PVector weightedSep;
  ArrayList<Berd> neighbors;
  float size = 20.0;
  float mass = 1.5;
  float maxSpeed = 3.0;
  float radius = size*5; // Radius in which to search for neighbors (tentative)
  
  // Methods
  Berd(int id){
    this.id = id;
    
    this.pos = PVector.random3D();
    this.dir = PVector.random3D();
    this.vel = PVector.random3D();
    this.acc = new PVector(0.0, 0.0, 0.0);
    
    this.weightedSep = new PVector(0.0, 0.0, 0.0);
    this.neighbors = new ArrayList();
  }
  Berd(PVector p, PVector d, int id){
    this.id = id;
    
    this.pos = new PVector(p.x, p.y, p.z);
    this.dir = new PVector(d.x, d.y, d.z);
    this.vel = new PVector();
    PVector.mult(this.dir, this.maxSpeed, this.vel);
    this.acc = new PVector(0.0, 0.0, 0.0);
    
    this.weightedSep = new PVector(0.0, 0.0, 0.0);
    this.neighbors = new ArrayList();
  }
  
  void updateAcc() {
    this.acc.set(this.weightedSep.x, this.weightedSep.y, this.weightedSep.z);
    this.acc.mult(this.mass * this.mass);
  }
  
  void updateVel() {
    this.vel.add(this.acc);
    this.vel.limit(this.maxSpeed);
  }
  
  void updatePos(){
    this.findNeighbors();
    //this.pos.add(this.dir.mult(this.maxSpeed));
    this.pos.add(this.vel);
    this.pos = enforceTorus(this.pos);
  }
  // Please note here that maxSpeed is constant for now. 
  // Will implement the bonafide vector calculus version soon,
  // after confirming core functionality
  void updateDir(){
    //this.dir.set(mouseX-pos.x, mouseY-pos.y, 0.0);
    //this.dir.set(this.weightedSep.x, this.weightedSep.y, this.weightedSep.z);
    this.dir.set(this.vel.x, this.vel.y, this.vel.z);
    this.dir.normalize();
  }
  
  void drawBerd(){
    this.updateAcc();
    this.updateVel();
    this.updatePos();
    this.updateDir();
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
  
  void findNeighbors() {
    // Using exhaustive search for now.
    // If performance requires it, I'll use 
    // something more sophisticated later.
    
    this.neighbors.clear();
    
    // simultaneously find avg separation here
    this.weightedSep.set(0.0,0.0,0.0); // clear it
    
    int numNeighbors = 0;
    
    for (Berd p : Flock) {
      if(p.id != this.id){
        // The following calculation (two lines) will need done again
        // maybe find a way to only do it once? 
        // don't make findNeighbors() its own method?
        PVector sep = new PVector();
        PVector.sub(this.pos,p.pos,sep);
        float dist = sep.mag();
                
        if(dist < this.radius){
          this.neighbors.add(new Berd(p.pos, p.dir, p.id));
          
          float weight = 1.0/(dist*dist + distance_softening);
          this.weightedSep.add(sep.mult(weight));
                    
          numNeighbors++;
        }
      }
    }
    
    if(numNeighbors != 0) this.weightedSep.mult(1.0/numNeighbors);
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
      Flock.add(new Berd(tempPos, tempDir, i));
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