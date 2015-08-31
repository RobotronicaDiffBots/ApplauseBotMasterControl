class ApplauseBot {

  // The id of the first applausebot robot.
  byte baseRId = byte(1);

  float x;
  float y;
  float w;
  float h;
  int idx;           // Index of this UI element in the array of applausebot objects.
  byte rId;          // ID of the applausebot robot we want to control (1...11).

  byte colour = 1;
  boolean isColoured = false;

  int topAngleLeft;      // Angle at which the wings *just* touch above the head.
  int topAngleRight;      // Angle at which the wings *just* touch above the head.

  // Checkbox - enables / disables updating of this applausebot.  
  CheckBox cb;

  // Animator objects for the left and right servos. These generate the timings for various movements.
  Animator leftAnimator;
  Animator rightAnimator;

  boolean leftEnabled = true;
  boolean rightEnabled = true;

  // Graphic objects to simulate how a servo moves and draw that to screen (accounting for lag of servos).  
  ServoGraphic leftServoGraphic;
  ServoGraphic rightServoGraphic;

  /**
   * Applause box constructor
   * float x: x position on screen (0 = top-middle)
   * float y: y position on screen (0 = top)
   * float w: width
   * float h: height
   * int idx: index of this object in global array.
   **/
  ApplauseBot(float x, float y, float w, float h, int idx, int[] applauseBotConfig) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.idx = idx;
    this.rId = byte(applauseBotConfig[0]);
    this.colour = byte(applauseBotConfig[3]);

    this.topAngleLeft = applauseBotConfig[1];
    this.topAngleRight = applauseBotConfig[2];

    // Checkbox for enabling/disabling updates goes beneath the applausebot graphic.
    cb = new CheckBox(0, h + 24, 32, 32, x, y, true);

    // Initialise left and right animators.
    leftAnimator = new Animator();
    rightAnimator = new Animator();

    // Add left and right servo graphics. Make the right one anti-clockwise.    
    leftServoGraphic = new ServoGraphic(w * -0.25, 0, topAngleLeft);
    rightServoGraphic = new ServoGraphic(w * 0.25, 0, topAngleRight);
    rightServoGraphic.direction = -1;
  }

  //////////////////////////////////////////////////
  // Update and draw functions.
  //

  /**
   * Update the applause bot. This consists of using the animator to seek to 
   * the next position, updating the servo graphics accordingly, and sending
   * any necessary commands to the xbee.
   **/
  void update(float ms) {

    boolean leftAnimatorChanged = leftEnabled && leftAnimator.update();
    boolean rightAnimatorChanged = rightEnabled && rightAnimator.update();

    // If we have seeked to a new position, then send a message to the servos
    if (leftAnimatorChanged || rightAnimatorChanged) {
      moveServos(leftAnimator.currentPosition, rightAnimator.currentPosition);
    }

    leftServoGraphic.update(ms);
    rightServoGraphic.update(ms);
  }

  /**
   * Draw the applausebot to the screen.
   **/
  void draw() {
    pushMatrix();
    translate(x, y);
    fill(getColor());

    drawBody();
    drawWing(leftServoGraphic);
    drawWing(rightServoGraphic);

    leftServoGraphic.draw();
    rightServoGraphic.draw();
    cb.draw();

    popMatrix();
  }

  /**
   * Draw the appausebot body to the screen.
   **/
  void drawBody() {
    beginShape();

    // Left side of body. Top to bottom.
    vertex(w * -0.25, 0);    
    vertex(w * -0.45, h * 0.8);
    vertex(w * -0.5, h * 0.8);
    vertex(w * -0.5, h);

    // Right side of body. Bottom to top.
    vertex(w * 0.5, h);
    vertex(w * 0.5, h * 0.8);
    vertex(w * 0.45, h * 0.8);
    vertex(w * 0.25, 0);
    endShape(CLOSE);
  }

  /**
   * Draw the wing of the applausebot
   * ServoGraphic sg: which servo graphic we are drawing for (left/right).
   **/
  void drawWing(ServoGraphic sg) {
    pushMatrix();

    // Use the setMarix function of the servo graphic object to 
    // determine the angle that the wing should be drawn at and
    // the rotation.
    sg.setMatrix();

    beginShape();

    // Pivot point, out, down to tip and back.
    vertex(0, 0);  
    vertex(w * -0.2, h * 0.8);
    vertex(w * -0.25, h * 0.8);
    vertex(w * -0.25, 0);  
    endShape(CLOSE);
    popMatrix();
  }

  //////////////////////////////////////////////////
  // Event handlers.
  //

  boolean processClick(float clickX, float clickY) {
    return cb.processClick(clickX - x, clickY - y);
  }

  void processKey(int key) {
    if (key >= '0' && key <= '9') {
      int keyIdx = (int(key) + 1) % applauseBots.length;
      if (keyIdx == idx) {
        cb.isChecked = !cb.isChecked;
      }
    } else if (key == 't') {
      cb.isChecked = !cb.isChecked;
    }

    if (!cb.isChecked) {
      return;
    }

    if (key == 'c') {
      clap();
    } else if (key == ' ') {
      pause();
    } else if (key == ']') {
      upOne();
    } else if (key == '[') {
      downOne();
    } else if (key == 'd') {
      down();
    } else if (key == 'u') {
      up();
    } else if (key == 'w') {
      wave();
    } else if (key == 'q') {
      semaphore();
    } else if (key == 's') {
      sinusoid();
    } else if (key == 'b') {
      breathe();
    } else if (key == 'c') {
      clap();
    } else if (key == 'o') {
      lightsOff();
    } else if (key == 'z') {
      toggleColour();
    } 
  }

  //////////////////////////////////////////////////
  // Movement methods.
  //

  void moveServos(int s1Target, int s2Target) {
    if (cb.isChecked) {
      // Figure out the average height and map the light intensity on to this.
      float lightIntensity = map(s1Target + s2Target, 0, 360, 1, 100);
      activateLight(int(lightIntensity));


      // First map the range 0...180 to the range 0...topAngle, which is what our servos will use.
      int s1AdjustedTarget = int(map(s1Target, 0, 180, 0, topAngleLeft));
      int s2AdjustedTarget = int(map(s2Target, 0, 180, 0, topAngleRight));

      //      println("s1:" + s1Target + ",s1A:" + s1AdjustedTarget);

      if (leftEnabled) {
        leftServoGraphic.targetPosition(s1AdjustedTarget);  // leftAnimator.currentPosition);
      }
      if (rightEnabled) {
        rightServoGraphic.targetPosition(s2AdjustedTarget); // rightAnimator.currentPosition);
      }

      xbeeExplorer.sendMsg(rId, XBee.MOVE_SERVOS, byte(s1AdjustedTarget), byte(s2AdjustedTarget), byte(0), byte(0));
    }
  }

  void linearTo(int newAngle) {
    leftAnimator.linear(newAngle);
    rightAnimator.linear(newAngle);
  }

  void easeInTo(int newAngle) {
    leftAnimator.easeIn(newAngle, 5, 0.2);
    rightAnimator.easeIn(newAngle, 5, 0.2);
  }

  void easeOutTo(int newAngle) {
    leftAnimator.easeOut(newAngle, 5, 0.2);
    rightAnimator.easeOut(newAngle, 5, 0.2);
  }

  void easeInOutTo(int newAngle) {
    leftAnimator.easeInOut(newAngle, 15, 0.5);
    rightAnimator.easeInOut(newAngle, 15, 0.5);
  }

  void pause() {
    leftAnimator.linear(leftAnimator.currentPosition);
    rightAnimator.linear(rightAnimator.currentPosition);
  }

  void upOne() {
    int newPosition1 = leftAnimator.currentPosition + 1;
    int newPosition2 = rightAnimator.currentPosition + 1;

    leftAnimator.linear(newPosition1);
    rightAnimator.linear(newPosition2);
  }

  void downOne() {    
    int newPosition1 = leftAnimator.currentPosition - 1;
    int newPosition2 = rightAnimator.currentPosition - 1;

    leftAnimator.linear(newPosition1);
    rightAnimator.linear(newPosition2);
  }

  void down() {
    leftAnimator.speed(1);
    leftAnimator.linear(0);
    leftAnimator.defaultSpeed();
    
    rightAnimator.speed(1);
    rightAnimator.linear(0);
    rightAnimator.defaultSpeed();
  }

  void up() {
    leftAnimator.linear(180);
    rightAnimator.linear(180);
  }  

  //////////////////////////////////////////////////
  // Periodic movement methods.
  //

  void wave() {  
    leftAnimator.wave();
    rightAnimator.wave();
    rightAnimator.delay(1000);
  }

  void semaphore() {
    leftAnimator.semaphore();
    rightAnimator.semaphore();
  }  

  void sinusoid() {
    leftAnimator.sinusoid();
    rightAnimator.sinusoid();
  }

  void breathe() {
    float randomDelay = random(1000);
    leftAnimator.breathe();
    leftAnimator.delay(randomDelay);
    rightAnimator.breathe(); 
    rightAnimator.delay(randomDelay + 200);
  }

  void clap() {
    leftAnimator.clap();
    rightAnimator.clap();
  }

  // Light Methods
  void toggleColour(){
    isColoured = !isColoured;
  }

  void activateLight(int brightness) {
    if(brightness < 0 || brightness > 100){
      println("Invalid brightness");
      return;
    }    
    
    byte lightColour = XBee.WHITE;
    if(isColoured){
      lightColour = colour;
    }
    
    // d1 = colour from table, d2 = X, d3 = brightness, d4 = fadeTime
    xbeeExplorer.sendMsg(rId, XBee.FADE_COLOUR, lightColour, byte(0), byte(brightness), byte(1));
  }
  
  void lightsOff(){
    activateLight(0);
  }
  
  color getColor(){
    byte lightColour = XBee.WHITE;
    if(isColoured){
      lightColour = colour;    
    }
    
    return color(colours[lightColour][0], colours[lightColour][1], colours[lightColour][2], 200); 
  }
}

