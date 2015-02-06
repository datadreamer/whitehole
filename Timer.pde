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
