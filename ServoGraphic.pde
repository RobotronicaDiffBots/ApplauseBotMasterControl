/**
 *
 * This class is for keeping track of where the servos should be - accounting for 
 * the lag between writing to the servo and it actually moving to a position. 
 * It is not used to control the servos on the applausebot directly, but rather
 * to calculate the drawing of the wings of the servo on the UI.
 *
 * To controll the servos, the Animator class is used. 
 *
 **/

class ServoGraphic{
  float x;
  float y;
  int topAngle;

  float direction = 1;              // Clockwise = 1, Anticlockwise = -1
  float maxSpeed =  180 / 1000.0;      // Speed measured in degrees per ms.
  float currentPosition;
  float _targetPosition;
  float rawTarget;
  float lastMs;
  
  ServoGraphic(float x, float y, int topAngle){
    this.x = x;
    this.y = y;
    this.topAngle = topAngle;
    
    lastMs = millis();
  }

  void targetPosition(float newTarget){
    if(newTarget != _targetPosition){
      _targetPosition = newTarget;
      rawTarget = rawTarget;
    }  
  }
  
  void update(float ms){
    // TODO - think about integer overflow here?
    float elapsedMs = ms - lastMs;
    
    float rotationAmt = maxSpeed * elapsedMs;
    
    // Constrain so we don't overshoot.
    rotationAmt = min(rotationAmt, abs(currentPosition - _targetPosition));
    
    // Determine if it's positive or negative rotation
    if(currentPosition > _targetPosition){
      rotationAmt = -rotationAmt;    
    }
  
    // Update the current position.
    currentPosition += rotationAmt;
    
    lastMs = ms;  
  }
  
  void draw(){
    pushMatrix();
    pushStyle();
    
    translate(x, y);

    fill(255, 0, 0);
    if(_targetPosition == currentPosition){
      fill(50);
    }
    ellipse(0, 0, 5, 5);
    fill(20);

    textSize(8);
    
//    int rawCurrent = 
    
    if(direction == 1){
      text(int(currentPosition), 10, 12);
    }
    else {
      text(int(currentPosition), -10, 12);    
    }

    textSize(12);
    
    popStyle();
    popMatrix();    
  }
  
  // Set the transformation matrix so I can draw something controlled by the servo.
  void setMatrix(){
    translate(x, y);
    scale(direction, 1);
    
    // Adjust the displayed current position to account for the fact that in the program
    // we set the servos in range 0...180, but in reality they go from 0...topAngle.
    float mappedCurrentPosition = map(currentPosition, 0, topAngle, 0, 180);
    
    rotate(radians(mappedCurrentPosition));    
  }

}
