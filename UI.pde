class Slider{

  float x;
  float y;
  float w;
  float h; 
  int minValue;
  int maxValue;
  int value;
  
  Slider(float x, float y, float w, float h, int minValue, int maxValue, int currValue){
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.minValue = minValue;
    this.maxValue = maxValue;
    this.value = value;
  }

  boolean testClick(float clickX, float clickY){
    boolean isClicked = clickX > x - (w / 2.0) && clickX < x + (w / 2.0) &&
      clickY > y - (h / 2.0) && clickY < y + (h / 2.0);
      
    if(isClicked){
      float rawValue = clickX - (x - (w / 2.0));
      float newValue = map(rawValue, 0, w, minValue, maxValue);
      newValue = constrain(newValue, minValue, maxValue);
      value = int(newValue);
    }
    
    return isClicked;
  }

  void draw(){
    pushMatrix();
    translate(x, y);
    fill(255, 100);
    rect(0, 0, w, h);
    
    fill(0);
    text(int(minValue), -w / 2, (-h / 2) - 10);  
    text(int(maxValue), w / 2, (-h / 2) - 10);
    
    // Draw some division markers.
    line(0, -h / 2.0, 0, h / 2.0);
    line(-w * 0.25, -h / 2.0, -w * 0.25, h / 2.0);
    line(w * 0.25, -h / 2.0, w * 0.25, h / 2.0);

    // Display the current value;
    text(int(value), 0, (-h / 2) - 10);

    popMatrix();
  }

}

class CheckBox {

  float x;
  float y;
  float w;
  float h;
  float parentX;
  float parentY;
  boolean isChecked;
  String label = "";

  CheckBox(float x, float y, float w, float h, float parentX, float parentY, boolean isChecked) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.parentX = parentX;
    this.parentY = parentY;
    this.isChecked = isChecked;
  }

  void draw() {
    pushStyle();
    if (isChecked) {
      fill(0, 255, 0, 100);
    }
    else {
      fill(255);
    }

    rect(x, y, w, h);    

    if (isChecked) {
      line(x - (w / 2) + 4, y - (h / 2) + 4, x + (w / 2) - 4, y + (h / 2) - 4);
      line(x + (w / 2) - 4, y - (h / 2) + 4, x - (w / 2) + 4, y + (h / 2) - 4);
    }

    fill(0);
    
    text(label, x, y + h);
    
    popStyle();
  }  

  boolean processClick(float clickX, float clickY) {
    boolean wasClicked = (x - (w / 2.0) < clickX && clickX < x + (w / 2.0) &&
      y - (h / 2.0) < clickY && clickY < y + (h / 2.0));

    if (wasClicked) {
      isChecked = ! isChecked;
    }
    return wasClicked;
  }
}

