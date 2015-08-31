class Animator {
  static final int NONE      = 0;
  static final int LINEAR    = 1;
  static final int EASE_IN   = 2;

  static final int CLAPPING  = 3;
  static final int SINUSOID  = 4;
  static final int WAVING    = 5;
  static final int SEMAPHORE = 6;
  static final int BREATHE   = 7;
  
  static final float DEFAULT_SPEED = 10;

  int currentPosition = 0;
  int targetPosition = 0;

  int currentState = NONE;
  int nextState = NONE;

  int totalRotation = 0;
  int direction = 0;

  float msPerDegree = DEFAULT_SPEED;

  int idx = 0;

  FloatList times; 
  IntList angles;

  Animator() {
    // Initialise an empty array list for storing the movement table.
    // Each element will be a PVector, with x = degree, and y = time.
    times = new FloatList();
    angles = new IntList();
  }

  boolean update() {
    float msNow = millis();
    boolean didMove = false;
    int seekIdx = 0;

    // Find the first element that has ms > msNow.
    while (times.size () > 0 && times.get(0) < msNow) {
      times.remove(0);
      currentPosition = int(angles.remove(0));
      didMove = true;
    }

    if (didMove && times.size() == 0) {
      checkNextState();
    }

    // TODO: We should only actually move if we need to...
    return didMove;
  }  

  void checkNextState() {
    if (nextState == NONE) {
      return;
    } else if (nextState == WAVING) {
      wave();
    } else if (nextState == SEMAPHORE) {
      semaphore();
    } else if (nextState == SINUSOID) {
      sinusoid();
    } else if (nextState == BREATHE) {
      breathe();
    } else if (nextState == CLAPPING) {
       clap(); 
    }
  }

  void speed(float spd){
    msPerDegree = spd;
  }
  
  void defaultSpeed(){
    msPerDegree = DEFAULT_SPEED;
  }

  void reset() {
    times.clear();
    angles.clear();
    currentState = NONE;
    nextState = NONE;
  }

  void printTable() {
    println("");
    for (int i = 0; i < angles.size (); i++) {
      print("[a:" + angles.get(i) + ", t:" + times.get(i) + "],");
    }
  }

  boolean checkRotation(int finalTarget) {
    // Constrain final target to be in range 0...180
    if (finalTarget < 0 || finalTarget > 180) {
      // TODO: Throw an exception here...
      println("finalTarget out of range");
      return false;
    }

    totalRotation = finalTarget - currentPosition;
    direction = 1;
    if (totalRotation < 0) {
      direction = -1;
    }
    return true;
  }

  //////////////////////////////////////////////////
  // Linear.
  //

  void linear(int finalTarget) {
    float msStart = millis();

    reset();
    currentState = LINEAR;
    nextState = NONE;

    if (!checkRotation(finalTarget)) {
      return;
    }

    for (int i = 0; i <= abs (totalRotation); i++) {
      angles.append(currentPosition + (i * direction)); 
      times.append(msStart + (i * msPerDegree));
    }

    targetPosition = finalTarget;
  }

  //////////////////////////////////////////////////
  // Ease In.
  //

  void easeIn(int finalTarget, int easingDegrees, float easingAmount) {
    float msNow = millis();
    float easing = 0;
    float timeBefore = msNow;

    reset();
    currentState = EASE_IN;
    nextState = NONE;

    if (!checkRotation(finalTarget)) {
      return;
    }

    for (int i = 0; i < abs (totalRotation); i++) {
      easing = getInEasing(i, easingDegrees, easingAmount);

      if (i > 0) {
        timeBefore = times.get(i - 1);
      }

      angles.append(currentPosition + (i * direction));       
      times.append(timeBefore + msPerDegree + easing);
    }
    targetPosition = finalTarget;
  }

  //////////////////////////////////////////////////
  // Ease Out.
  //

  void easeOut(int finalTarget, int easingDegrees, float easingAmount) {
    float msNow = millis();
    float easing = 0;
    float timeBefore = msNow;

    reset();
    currentState = EASE_IN;
    nextState = NONE;

    if (!checkRotation(finalTarget)) {
      return;
    }

    for (int i = 0; i < abs (totalRotation); i++) {
      // Make it move a bit slower (easing) at end.
      easing = getOutEasing(i, easingDegrees, easingAmount);

      if (i > 0) {
        timeBefore = times.get(i - 1);
      }

      angles.append(currentPosition + (i * direction));       
      times.append(timeBefore + msPerDegree + easing);
    }
    targetPosition = finalTarget;
  }

  //////////////////////////////////////////////////
  // Ease In & Out.
  //

  void easeInOut(int finalTarget, int easingDegrees, float easingAmount) {
    float msNow = millis();
    float easing = 0;
    float timeBefore = msNow;

    reset();
    currentState = EASE_IN;
    nextState = NONE;

    if (!checkRotation(finalTarget)) {
      return;
    }

    if (abs(totalRotation) < 2 * easingDegrees) {
      easingDegrees = totalRotation / 2;
    }

    for (int i = 0; i < abs (totalRotation); i++) {
      // Make it move a bit slower (easing) at end.
      easing = max(
      getInEasing(i, easingDegrees, easingAmount), 
      getOutEasing(i, easingDegrees, easingAmount)
        );

      if (i > 0) {
        timeBefore = times.get(i - 1);
      }

      angles.append(currentPosition + (i * direction));       
      times.append(timeBefore + msPerDegree + easing);
    }

    targetPosition = finalTarget;
  }

  //////////////////////////////////////////////////
  // Wave.
  //

  void wave() {
    int waveTo = 150; // int(random(110, 120));
    if (currentPosition < 160) {
      waveTo = 170; //int(random(20, 30));
    }

    checkRotation(waveTo);

    speed(30);
    easeInOut(waveTo, totalRotation / 3, 0.05);
    defaultSpeed();
    
    nextState = WAVING;
  }
  
  //////////////////////////////////////////////////
  // Semaphore.
  //

  void semaphore() {
    int semaphoreAngle = 30 + int(random(4)) * 30;
    if (semaphoreAngle == currentPosition) {
      if (semaphoreAngle > 90) {
        semaphoreAngle -= 30;
      } else {
        semaphoreAngle += 30;
      }
    }
    easeIn(semaphoreAngle, 10, 0.5);
    nextState = SEMAPHORE;
  }

  //////////////////////////////////////////////////
  // Sinusoidal.
  //

  void sinusoid() {
    sinusoid(60, 120, 35);
  }

  void sinusoid(int rangeStart, int rangeEnd, float easing) {
    float msNow = millis();
    float timeBefore = msNow;

    reset();
    currentState = SINUSOID;
    nextState = SINUSOID;

    int finalTarget = rangeStart;
    if (abs(rangeStart - currentPosition) < abs(rangeEnd - currentPosition)) {
      finalTarget = rangeEnd;
    }

    if (!checkRotation(finalTarget)) {
      return;
    }

    for (int i = 0; i <= abs (totalRotation); i++) {
      float mappedAngle = map(i, 0, abs(totalRotation), 0, 180);
      float thisSin = cos(radians(mappedAngle));

      angles.append(currentPosition + (i * direction));       
      float thisTime = timeBefore + msPerDegree + (abs(thisSin) * easing);
      times.append(thisTime);
      timeBefore = thisTime;
    }

    targetPosition = finalTarget;
  }

  /////////////////////////
  // Breathe
  void breathe() {
    int rangeStart = 5;
    int rangeEnd = 15;

    sinusoid(rangeStart, rangeEnd, 100);
    currentState = BREATHE;
    nextState = BREATHE;
  }  
 
  /////////////////////////
  // Clap
  void clap(){
    if(currentState != CLAPPING){
      easeIn(165, 5, 0.2);
    }  
    else {
      reset();

      int finalTarget = 180;
      if(currentPosition == 180){
        finalTarget = 160;
      }
    
      float msNow = millis();
      float timeBefore = msNow;
      
      speed(10);
      linear(finalTarget);      
      defaultSpeed();
      
    }
    currentState = CLAPPING;
    nextState = CLAPPING;      
  }

  /////////////////////////
  // Helper functions

  // Delay the whole animation by the provided amount
  void delay(float delayAmt) {
    for (int i = 0; i < times.size (); i++) {
      times.set(i, times.get(i) + delayAmt);
    }
  }

  float getInEasing(int i, int easingDegrees, float easingAmount) {
    float easing = 0;

    // Make it move a bit slower (easing) at start.
    if (i < easingDegrees) {
      easing = (easingDegrees - i) * (msPerDegree * easingAmount);
    }
    return easing;
  }

  float getOutEasing(int i, int easingDegrees, float easingAmount) {
    float easing = 0;
    if (abs(totalRotation) - i < easingDegrees) {
      int degreesToEnd = easingDegrees - (abs(totalRotation) - i);
      easing = degreesToEnd * (msPerDegree * easingAmount);
    } 
    return easing;
  }

  void triggerDrawTable() {
    drawAnimator = true;
    animatorToDraw = this;
  }

  void drawTable() {   
//    println("graphTable"); 
    pushMatrix();
    pushStyle();
    translate(0, height);
    scale(1, -1);

    float startTime = times.get(0);
    float endTime = times.get(times.size() - 1);
    float totalTime = endTime - startTime;

//    println("totalTime: " + totalTime + ", startTime: " + startTime + ", endTime: " + endTime);
//    println("");

    for (int i = 0; i < times.size (); i++) {
      float thisTime = times.get(i);

//      println("thisTime: " + thisTime);

      float mappedTime = map(thisTime, startTime, endTime, 0, width);
      float mappedAngle = map(i, 0, angles.size(), 0, height);

      fill(255, 0, 0);
      noStroke();

//      println("t:" + mappedTime + ", a:" + mappedAngle);

      ellipse(mappedTime, mappedAngle, 3, 3);
    }

    popStyle();
    popMatrix();
  }
}

