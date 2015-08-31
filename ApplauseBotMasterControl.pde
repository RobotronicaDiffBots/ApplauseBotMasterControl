// PAN ID for applausebots 34 01

import processing.serial.*;

// Variables for xbee communication.
Serial handController;
int handControllerPort = 3;

XBee xbeeExplorer;
int xbeeExplorerPort = 4;

int baudRate = 57600;

boolean drawAnimator = false;
Animator animatorToDraw;

ApplauseBot[] applauseBots;

Slider slider1;
CheckBox cbLeft;
CheckBox cbRight;

void setup() {
  size(510, 600);
  rectMode(CENTER);
  ellipseMode(CENTER);
  textAlign(CENTER);
  noFill();

  // You will probably have to change the values for xbeeExplorerPort and handControllerPort.
  // Look at the output of the below command to figure out where they are plugged in.
  printArray(Serial.list());
  handController = new Serial(this, Serial.list()[handControllerPort], baudRate);
  handController.buffer(10);

  xbeeExplorer = new XBee(xbeeExplorerPort, baudRate, this);

  // A crude way of storing configuration for the applausebots. The first number is the 
  // id of the robot (written on the chassis). The second and third numbers are the top
  // angles of the left and right wings respectively. The last value is the colour of the 
  // applausebot.
  int[][] applauseBotAngles = {    
    {0,  180, 180, XBee.BLACK    },          // ApplauseBot NONE - just here for testing...
    
    {1,  155, 153, XBee.GREEN    },          // ApplauseBot 1
    {2,  155, 156, XBee.RED      },          // ApplauseBot 2
    {3,  149, 149, XBee.YELLOW   },          // ApplauseBot 3
    {4,  154, 154, XBee.BLUE     },          // ApplauseBot 4
    
    {5,  151, 154, XBee.YELLOW   },          // ApplauseBot 5
    
    {6,  180, 180, XBee.MAGENTA  },          // ApplauseBot 6 - broken

    {7,  148, 144, XBee.CYAN     },          // ApplauseBot 7
    {8,  158, 149, XBee.ORANGE   },          // ApplauseBot 8
    {9,  161, 153, XBee.PURPLE   },          // ApplauseBot 9

    {10, 180, 180, XBee.TURQUOISE},          // ApplauseBot 10 - broken
    {11, 180, 180, XBee.RED      }           // ApplauseBot 11 - broken
  };
    
  // Initialise an array of applausebot objects and lay them out on screen.
  applauseBots = new ApplauseBot[4];
  
  applauseBots[0] = new ApplauseBot(140, 80, 100, 100, 0, applauseBotAngles[1]);
  applauseBots[1] = new ApplauseBot(370, 80, 100, 100, 1, applauseBotAngles[2]);
  applauseBots[2] = new ApplauseBot(140, 300, 100, 100, 3, applauseBotAngles[3]);
  applauseBots[3] = new ApplauseBot(370, 300, 100, 100, 4, applauseBotAngles[4]);

  // Set an initial angle and light for the applausebots.
  for(int i = 0; i < applauseBots.length; i++){
    // Applausebots are unselected by default. 
    applauseBots[i].cb.isChecked = false;
    applauseBots[i].linearTo(0);
    applauseBots[i].activateLight(1);
  }

  // UI elements.
  slider1 = new Slider(width / 2, height - 30, 184, 30, 0, 181, 0);

  cbLeft = new CheckBox(40, height - 40, 32, 32, 0, 0, true);
  cbLeft.label = "Left";

  cbRight = new CheckBox(80, height - 40, 32, 32, 0, 0, true);
  cbRight.label = "Right";
}

//////////////////////////////////////////////////
// Draw loop.
//

void draw() {
  // First process any messages that have been left in the outbox.
  while (outbox.size () > 0) {
    processMsg(outbox.remove(0));
  }

  float ms = millis();
  background(204);

  if (drawAnimator) {
//    println("do draw animator");
    animatorToDraw.drawTable();
    noLoop();
  }

  for (int i = 0; i < applauseBots.length; i++) {
    applauseBots[i].update(ms);
    applauseBots[i].draw();
  }

  slider1.draw();
  cbLeft.draw();
  cbRight.draw();
}

//////////////////////////////////////////////////
// Event handlers.
//

void mouseClicked() {

  if (slider1.testClick(mouseX, mouseY)) {
    for (int i = 0; i < applauseBots.length; i++) {
      applauseBots[i].linearTo(slider1.value);
    }
  } else if (cbLeft.processClick(mouseX, mouseY)) {
    for (int i = 0; i < applauseBots.length; i++) {
      applauseBots[i].leftEnabled = cbLeft.isChecked;
    }
  } else if (cbRight.processClick(mouseX, mouseY)) {
    for (int i = 0; i < applauseBots.length; i++) {
      applauseBots[i].rightEnabled = cbRight.isChecked;
    }
  } else {
    for (int i = 0; i < applauseBots.length; i++) {
      if (applauseBots[i].processClick(mouseX, mouseY)) {
        break;
      }
    }
  }
}

void keyPressed() {
  for (int i = 0; i < applauseBots.length; i++) {
    applauseBots[i].processKey(key);
  }
}


