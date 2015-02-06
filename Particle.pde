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
