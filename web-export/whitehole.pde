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
  size(window.innerWidth,window.innerHeight);
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
class Hole{
  
  float x, y, size;
  
  Hole(float x, float y, float size){
    this.x = x;
    this.y = y;
    this.size = size;
  }
  
  void draw(){
    ellipse(x, y, size, size);
  }
  
}
class Particle{
  
  int id;
  float x, y;
  float xvel, yvel;
  float xdiff, ydiff, xvec, yvec, hypo;
  float size = 5;
  float friction = 0.99;
  float alpha = 0;
  Timer lifeTimer;
  Timer fadeTimer;
  boolean fading = false;
  boolean remove = false;
  
  Particle(int id, float x, float y){
    this.id = id;
    this.x = x;
    this.y = y;
    xvel = 0;
    yvel = 0;
    lifeTimer = new Timer(10000);
    lifeTimer.start();
    fadeTimer = new Timer(2000);
  }

  void applyGravity(float gravityX, float gravityY, float gravityStrength){
    xdiff = gravityX - x;
    ydiff = gravityY - y;
    hypo = sqrt(sq(xdiff)+sq(ydiff));
    xvec = xdiff / hypo;
    yvec = ydiff / hypo;
    xvel += xvec * gravityStrength;
    yvel += yvec * gravityStrength;
  }
  
  void applyForce(float xpos, float ypos, float forceRadius, float xForce, float yForce){
    xdiff = xpos - x;
    ydiff = ypos - y;
    hypo = sqrt(sq(xdiff)+sq(ydiff));
    if(hypo < forceRadius){
      xvel -= (xdiff / hypo) * (1 - hypo / forceRadius) * xForce;
      yvel -= (ydiff / hypo) * (1 - hypo / forceRadius) * yForce;
    }
  }
  
  void applyForces(float gaussRadius, float gaussForce){
    for(Particle p : particles){
      if(p.id != this.id){
        xdiff = p.x - x;
        ydiff = p.y - y;
        hypo = sqrt(sq(xdiff)+sq(ydiff));
        if(hypo < gaussRadius){
           xvel -= (xdiff / hypo) * (1 - hypo / gaussRadius) * gaussForce;
           yvel -= (ydiff / hypo) * (1 - hypo / gaussRadius) * gaussForce;
        }
      }
    }
  }
  
  void applyNoise(float strength){
    xvel += random(0-strength, strength);
    yvel += random(0-strength, strength);
  }
  
  void applyRotation(float force){
    // applies a force perpindicular to vector with hole
    xdiff = x - hole.x;
    ydiff = y - hole.y;
    hypo = sqrt(sq(xdiff)+sq(ydiff));
    if(hypo <= hole.size/2 + size/2){
      xvec = xdiff / hypo;
      yvec = ydiff / hypo;  
      xvel += ((xvec * cos(HALF_PI)) - (yvec * sin(HALF_PI))) * force;
      yvel += ((xvec * sin(HALF_PI)) + (yvec * cos(HALF_PI))) * force;
    }
  }
  
  void fadeOut(){  
    fadeTimer.start();
    fading = true;
  }
  
  void move(){
    // check for collision against hole
    xdiff = x - hole.x;
    ydiff = y - hole.y;
    hypo = sqrt(sq(xdiff)+sq(ydiff));
    if(hypo > hole.size/2){
      alpha = (hypo - hole.size/2) * 25;
      if(alpha > 255){
        alpha = 255;
      } else if(alpha < 0){
        alpha = 0;
      }
    }
    
    // apply vector to position
    xvel *= friction;
    yvel *= friction;
    x += xvel;
    y += yvel;
    
    // check lifespan
    if(lifeTimer.isFinished() && !fading){
      fading = true;
      fadeTimer.start();
    }
    
    // fade out before setting object to be removed
    if(fading){
      if(fadeTimer.isFinished()){
        alpha = 0;
        remove = true;
      }
    }
  }
  
  void draw(){
    if(fading){
      fill(alpha * (1-fadeTimer.progress()));
    } else {
      fill(alpha);
    }
    ellipse(x, y, size, size);
  }

}
class RunningAverage{
  
  ArrayList<Float> values;
  int size;
  
  RunningAverage(int size){
    this.size = size;
    values = new ArrayList<Float>();
  }
  
  void addValue(float val){
    values.add(val);
    if(values.size() > size){
      values.remove(0);
    }
  }
  
  float getAverage(){
    float avg = 0;
    for(Float val : values){
      avg += val;
    }
    return avg/values.size();
  }
}
class Timer{
  
  float duration;
  long startTime;
  
  Timer(float duration){
    this.duration = duration;
  }
  
  void start(){
    startTime = millis();
  }
  
  boolean isFinished(){
    if(progress() >= 1){
      return true;
    }
    return false;
  }
  
  float progress(){
    return (millis() - startTime) / duration;
  }
}

