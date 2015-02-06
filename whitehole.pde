ArrayList<Particle> particles;
ArrayList<Particle> deadParticles;
Hole hole;
int particleCount = 1;
int totalParticles = 500;
float gravity = 0.001;
float gaussRadius = 15;
float gaussForce = 0.01;
float noiseForce = 0.01;
int mouseRadius = 30;
RunningAverage mouseVecX, mouseVecY;
Timer particleSpawnTimer = new Timer(50);

void setup(){
  size(500,500);
  frameRate(60);
  particles = new ArrayList<Particle>();
  deadParticles = new ArrayList<Particle>();
  hole = new Hole(width/2, height/2, 200);
  noStroke();
  mouseVecX = new RunningAverage(10);
  mouseVecY = new RunningAverage(10);
  particleSpawnTimer.start();
}

void draw(){
  background(0);
  
  for(Particle p : particles){
    p.applyGravity(width/2, height/2, gravity);  // gravity/anti-gravity
    p.applyNoise(noiseForce);                    // vector noise
    p.applyForces(gaussRadius, gaussForce);      // magnetic repulsion
    p.applyRotation(0.01);                       // rotation force away from hole
    p.applyForce(mouseX, mouseY, mouseRadius, mouseVecX.getAverage(), mouseVecY.getAverage());  // mouse interaction
  }
  
  for(Particle p : particles){
    p.move();                                    // apply vector to position
    p.draw();                                    // render
    if(p.remove){                                // if particle is dead...
      deadParticles.add(p);                      // prepare it for removal.
    }
  }
  
  for(Particle p : deadParticles){
    particles.remove(p);                         // remove dead particles
  }
  deadParticles.clear();
  
  if(particleSpawnTimer.isFinished()){           // spawn a new particle
    particleCount++;
    float angle = random(TWO_PI);
    float xpos = (cos(angle) * 90) + width/2;
    float ypos = (sin(angle) * 90) + height/2;
    particles.add(new Particle(particleCount, xpos, ypos));
    particleSpawnTimer.start();
  }
  
  mouseVecX.addValue((mouseX-pmouseX) * 0.1);    // check for mouse interaction
  mouseVecY.addValue((mouseY-pmouseY) * 0.1);
}

void mousePressed(){
  mouseRadius = 100;
}

void mouseReleased(){
  mouseRadius = 30;
}
