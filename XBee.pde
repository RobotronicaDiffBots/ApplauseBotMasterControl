class XBee {
  // Consts for xbee types.
  static final byte FADE_COLOUR = 120;
  static final byte MOVE_SERVOS = 123;

  static final byte BLACK     = 0;
  static final byte WHITE     = 1;
  static final byte RED       = 2;
  static final byte GREEN     = 3;
  static final byte BLUE      = 4;
  static final byte YELLOW    = 5;
  static final byte MAGENTA   = 6;
  static final byte CYAN      = 7;
  static final byte ORANGE    = 8;
  static final byte PURPLE    = 9;
  static final byte TURQUOISE = 10;
  static final byte LIME      = 11;

  // Global variable sent & incremeneted with each xBee message.
  byte seqno;
//  Serial serial;

  XBee(int xbeePort, int baudRate, PApplet sketch) {
    // Set up serial object for xbee communication.
    // use 'printArray(Serial.list())' to find xbee port number.
//    serial = new Serial(sketch, Serial.list()[xbeePort], baudRate);
  }

  void sendMsg(byte rId, byte type, byte d1, byte d2, byte d3, byte d4) {
    seqno++;

    byte[] msg = {
      byte(170), byte(85), rId, type, d1, d2, d3, d4, seqno, 0
    };

    // Calculate a crc for the message. This will be included as the last byte.
    byte crc = 0;
    for (int i = 0; i < msg.length - 1; i++) {
      crc ^= msg[i];
    }
    msg[msg.length - 1] = crc;

//    serial.write(msg);
  }

  // Retransmit message received from hand controller. We need to 
  // add a new seqno and recalculate the crc.
  void relayMsg(byte[] msg) {
    // type, byte d1, byte d2, byte d3, byte d4) {

    //    printMsg(msg);  

    byte button = msg[7];

    // Check for movement or rotation
    if (button == byte(0)) {
      // Rotation
      if (msg[4] != msg[5]) {
        relayRotation(msg);
      }
      // Ignore movement
      else {
        relayMovement(msg);
      }
    } 
    // Left-Out button
    else if (button == byte(1)) {
      relayLightUp();
    } 
    // Left-Middle button
    else if (button == byte(2)) {
      relayUnchanged(msg);
//      println("L-M");
    }
    // Left-In button
    else if (button == byte(4)) {
      relayUnchanged(msg);
//      println("L-I");
    }
    // Left-Shoulder button
    else if (button == byte(8)) {
//      println("L-S");
    } else {
      // Ignore the rest.
    }
    //    // Right-In button
    //    else if (button == byte(16)) {
    //      println("R-I");
    //    }
    //    // Right-Middle button
    //    else if (button == byte(32)) {
    //      println("R-M");
    //    }
    //    // Right-Out button
    //    else if (button == byte(64)) {
    //      println("R-O");
    //    }
    //    // Right-Shoulder button
    //    else if (button == byte(128)) {
    //      println("R-S");
    //    }
  }

  void relayRotation(byte[] msg) {
    seqno++;
    msg[msg.length - 2] = seqno;
    byte crc;
    byte lVel = msg[4];
    byte rVel = msg[5];

    for (int i = 0; i < applauseBots.length; i++) {
      if (applauseBots[i].cb.isChecked) {
        msg[2] = applauseBots[i].rId;

        // Swap rotation for right half of the stage.
        if (i >= applauseBots.length / 2) {
          msg[4] = rVel;
          msg[5] = lVel;
        }

        crc = generateCrc(msg);
        msg[msg.length - 1] = crc;
//        serial.write(msg);
      }
    }
  }

  void relayMovement(byte[] msg) {
    seqno++;
    msg[msg.length - 2] = seqno;
    byte crc = generateCrc(msg);
    msg[msg.length - 1] = crc;
//    serial.write(msg);
  }
  
  void relayLightUp(){
    for(int i = 0; i < applauseBots.length; i++){
      applauseBots[i].activateLight(100);
    }  
  }
  
  void relayUnchanged(byte[] msg){
    seqno++;
    msg[msg.length - 2] = seqno;
    byte crc = generateCrc(msg);
    msg[msg.length - 1] = crc;
//    serial.write(msg);
  }
}

