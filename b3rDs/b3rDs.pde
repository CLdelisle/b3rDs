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

// Craig Reynolds : Steer = Desired - Velocity

// Obstacle avoidance: also 1/r^2 ?

//////////////////////////////
// GLOBAL VARIABLES
//////////////////////////////

float XBOUND = 700, YBOUND = 700, ZBOUND = 500;
int NUM_BERDS = 40;
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
  
  PVector separation, cohesion, alignment;
  float separationWeight = 1.5, cohesionWeight = 1.0, alignmentWeight = 1.0;
  
  PVector desiredSep;
  ArrayList<Berd> neighbors;
  float size = 20.0;
  float maxSpeed = 3.0, maxForce = 0.02;
  float radius = 50.0; // Radius in which to search for neighbors (tentative)
  float desiredDist = 25.0; // Desired separation from neighbors
  
  // Methods
  Berd(int id){
    this.id = id;
    
    this.pos = new PVector(random(XBOUND), random(YBOUND), 0.0);
    this.dir = new PVector(random(XBOUND), random(YBOUND), 0.0);
    this.vel = new PVector(random(XBOUND), random(YBOUND), 0.0);
    this.acc = new PVector(0.0, 0.0, 0.0);
    
    this.separation = new PVector(0.0, 0.0, 0.0);
    this.cohesion = new PVector(0.0, 0.0, 0.0);
    this.alignment = new PVector(0.0, 0.0, 0.0);
    
    this.desiredSep = new PVector(0.0, 0.0, 0.0);
    this.neighbors = new ArrayList();
  }
  Berd(PVector p, PVector d, int id){
    this.id = id;
    
    this.pos = new PVector(p.x, p.y, p.z);
    this.dir = new PVector(d.x, d.y, d.z);
    this.vel = new PVector();
    PVector.mult(this.dir, this.maxSpeed, this.vel);
    this.acc = new PVector(0.0, 0.0, 0.0);
    
    this.separation = new PVector(0.0, 0.0, 0.0);
    this.cohesion = new PVector(0.0, 0.0, 0.0);
    this.alignment = new PVector(0.0, 0.0, 0.0);
    
    this.desiredSep = new PVector(0.0, 0.0, 0.0);
    this.neighbors = new ArrayList();
  }
  
  void updateAcc() {
    this.acc.set(0.0,0.0,0.0); // clear accel
    this.forces(); // build it back up with forces
    this.acc.add(this.separation);
    this.acc.add(this.cohesion);
    this.acc.add(this.alignment);
  }
  
  void updateVel() {
    this.vel.add(this.acc); // add acceleration vector
    this.vel.limit(this.maxSpeed); // limit to maximum speed
    
    // CAREFUL
    //this.vel.z = 0.0;
  }
  
  void updatePos(){
    this.pos.add(this.vel); // add velocity vector
    this.pos = enforceTorus(this.pos); // enforce boundary conditions
  }

  void updateDir(){
    //this.dir.set(mouseX-pos.x, mouseY-pos.y, 0.0);
    this.dir.set(this.vel.x, this.vel.y, this.vel.z);
    this.dir.normalize();
    
  }
  
  void drawBerd(){
    this.updateAcc();
    this.updateVel();
    this.updatePos();
    this.updateDir();
    
    // rotate Berd to "dir" direction
    PVector axis = this.dir.cross(up);
    axis.normalize();
    float dotProd = this.dir.dot(up);
    float theta = acos(dotProd);
    
    pushMatrix();
    fill(0,255,0);
    fill(0,random(255),random(155));
    translate(this.pos.x, this.pos.y, this.pos.z);
    rotate(-theta, axis.x, axis.y, axis.z);
    sphereDetail(1,4); 
    sphere(this.size);
    popMatrix();    
  }
  
  void forces() {
    // Using exhaustive search for now.
    // If performance requires it, I'll use 
    // something more sophisticated later.
    
    this.neighbors.clear();
    
    // simultaneously find avg separation here
    this.desiredSep.set(0.0,0.0,0.0); // clear it
    
    int numNeighbors = 0;
    
    PVector separationSteering = new PVector(0.0, 0.0, 0.0);
    
    PVector avgPos = new PVector(0.0, 0.0, 0.0);
    PVector avgVel = new PVector(0.0, 0.0, 0.0);
    
    for (Berd p : Flock) {
      if(p.id != this.id){
        PVector sep = new PVector();
        PVector.sub(this.pos,p.pos,sep);
        float dist = sep.mag();
                
        if(dist > 0 && dist < this.radius){
          // Berd p contributes to behavior of this Berd
          this.neighbors.add(new Berd(p.pos, p.dir, p.id));
          
          // SEPARATION
          sep.div(dist);
          separationSteering.add(sep);
          
          // COHESION
          avgPos.add(p.pos);
          
          // ALIGNMENT
          avgVel.add(p.vel);
          
          
          float weight = 1.0/(dist*dist + distance_softening);
          this.desiredSep.add(sep.mult(weight));
                    
          numNeighbors++;
        }
      }
    }
    
    if(numNeighbors != 0) {
      
      // Separation
      separationSteering.div((float)numNeighbors);
      if(separationSteering.mag() > 0) {
        separationSteering.setMag(this.maxSpeed);
        separationSteering.sub(this.vel);
        separationSteering.limit(this.maxForce);
        separationSteering.mult(this.separationWeight);
      }
      
      // COHESION
      avgPos.div((float)numNeighbors);
      PVector desiredPos = PVector.sub(avgPos, this.pos);
      desiredPos.setMag(this.maxSpeed);
      PVector cohesionSteering = PVector.sub(desiredPos, this.vel);
      cohesionSteering.limit(this.maxForce);
      
      // ALIGNMENT
      avgVel.div((float)numNeighbors);
      avgVel.setMag(this.maxSpeed);
      PVector alignSteering = PVector.sub(avgVel, this.vel);
      alignSteering.limit(this.maxForce);
      alignSteering.mult(this.alignmentWeight);
      this.alignment.set(alignSteering.x, alignSteering.y, alignSteering.x);
      
      
    }
    else {
      this.separation.set(0.0, 0.0, 0.0);
      this.alignment.set(0.0, 0.0, 0.0);
      this.cohesion.set(0.0, 0.0, 0.0);
    }
  }
  
  // Steering
  
  
  
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
    PVector tempDir = new PVector(random(-XBOUND),random(YBOUND), 0.0);
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
  background(0);
  stroke(255);
  fill(0,255,0);
  lights();
  
  // Initialize logic
  init();
}

//////////////////////////////
// DRAW CALL (each frame)
//////////////////////////////

void draw() {
   //background(255);
   background(0);
   //test individual
   //b.drawBerd();
   
   //test flock
   for (int i = 0; i < Flock.size(); i++) {
     Flock.get(i).drawBerd();
   }
}