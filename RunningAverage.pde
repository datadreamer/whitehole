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
