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
