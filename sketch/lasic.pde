#include <Stepper.h>

char InCmd[32];
byte InCmdIndex = 0;
byte InByte = 0;
unsigned long lastTime = 0;
int LaserPIN = 14;
int Ypojezd = 19;
int Xpojezd = 18;

unsigned posX = 0;
unsigned posY = 0;

#define STEPS 200
Stepper stepperX(STEPS, 4, 2, 3, 5);
Stepper stepperY(STEPS, 12, 10, 11, 13);

void setup() {
  Serial.begin(115200);

  stepperX.setSpeed(10);
  stepperY.setSpeed(10);

  pinMode(LaserPIN, OUTPUT);
  digitalWrite(LaserPIN, LOW);
  pinMode(Ypojezd, INPUT);
  digitalWrite(Ypojezd, HIGH);
  pinMode(Xpojezd, INPUT);
  digitalWrite(Xpojezd, HIGH);
}

void loop() {
  while(Serial.available()) {
    lastTime = millis();
    InByte = Serial.read();
    if (InCmdIndex >= sizeof(InCmd)){
      InCmdIndex = 0;
      Serial.println("INPUT COMMAND OVERFLOW");
    } 

    if (InByte == 10 || InByte == 13 ) {
      //Serial.println(sizeof(InCmd),DEC);
      ExeCmd(InCmd);
      for (InCmdIndex++; InCmdIndex>0; InCmdIndex--) {
	      InCmd[InCmdIndex] = 0;
      }
      InCmdIndex = 0;

    }
    else{
      InCmd[InCmdIndex++] = InByte;
    }//		Serial.println(InCmdIndex, DEC);
  }


  if ( (lastTime + 15000) < millis() ) {
    digitalWrite(LaserPIN, LOW);
    digitalWrite(2, LOW);
    digitalWrite(3, LOW);
    digitalWrite(4, LOW);
    digitalWrite(5, LOW);
    digitalWrite(6, LOW);
    digitalWrite(7, LOW);
    digitalWrite(8, LOW);
    digitalWrite(9, LOW);
    digitalWrite(10, LOW);
    digitalWrite(11, LOW);
    digitalWrite(12, LOW);
    digitalWrite(13, LOW);
  }
}

void ExeCmd(char *InCmd){
  byte MotorIndex;
  byte MotorSpeed;
  int MotorSteps;
  byte SeqID;
  byte LaserPower;
  byte SCommand;

  SCommand = 0;	
  LaserPower = 0;
  SeqID = 0;
  MotorSteps = 0;
  MotorSpeed = 0;
  MotorIndex = 0;
  int toX = 0;
  int toY = 0;

  //	for (int i = 0;i<CmdIndex;i++){
  //		Serial.print(InCmd[i]);
  //	}
  //	Serial.println();
  //Serial.println(InCmd[0], DEC);
  switch (InCmd[0]){

  case 'm':
    while (*InCmd != ' ') InCmd++; 
    while (isspace(*InCmd)) InCmd++;
    if (atoi(InCmd) > 0 && atoi(InCmd) < 255){
      MotorIndex = atoi(InCmd);
      //Serial.println(MotorIndex, DEC);
    }
    else{
      Serial.println("Wrong Motor Index (1-254)");
      break;
    }		

    while (*InCmd != ' ') InCmd++; 
    while (isspace(*InCmd)) InCmd++;
    if (atoi(InCmd) > 0 && atoi(InCmd) < 255){
      MotorSpeed = atoi(InCmd);
      //Serial.println(MotorSpeed, DEC);
    }
    else{
      Serial.println("Wrong Motor Speed (1-254)");
      break;
    }

    while (*InCmd != ' ') InCmd++; 
    while (isspace(*InCmd)) InCmd++;
    if (atoi(InCmd) > -10001 && atoi(InCmd) < 10001	){
      MotorSteps = atoi(InCmd);
      //Serial.println(MotorSteps, DEC);
    }
    else{
      Serial.println("Wrong Steps (-10000 - +10000)");
      break;
    }

    while (*InCmd != ' ') InCmd++; 
    while (isspace(*InCmd)) InCmd++;
    if (atoi(InCmd) > 0 && atoi(InCmd) < 255){
      SeqID = atoi(InCmd);
      //Serial.println(SeqID, DEC);
    }
    else{
      Serial.println("Wrong Sequence ID (1-254)");
      break;
    }		

    switch (MotorIndex){

    case 1:
      stepperX.setSpeed(MotorSpeed);
      stepperX.step(MotorSteps);
      posX += MotorSteps;
      break;

    case 2:
      stepperY.setSpeed(MotorSpeed);
      stepperY.step(MotorSteps * 3);
      posY += MotorSteps;
      break;


    }
    Serial.println(SeqID, DEC);
    break;

  case 'l':

    while (*InCmd != ' ') InCmd++; 
    while (isspace(*InCmd)) InCmd++;
    if (atoi(InCmd) >= 0 && atoi(InCmd) < 255){
      LaserPower = atoi(InCmd);
      //Serial.println(LaserPower, DEC);
      if (LaserPower == 254) {
        digitalWrite(LaserPIN, HIGH);
      }
      else{
        digitalWrite(LaserPIN, LOW); 
      }
      //Serial.println(LaserPower, DEC);
    }
    else{
      Serial.println("Wrong Laser Power (0-254)");
      break;
    }		

    while (*InCmd != ' ') InCmd++; 
    while (isspace(*InCmd)) InCmd++;
    if (atoi(InCmd) > 0 && atoi(InCmd) < 255){
      SeqID = atoi(InCmd);
      //Serial.println(SeqID, DEC);
    }
    else{
      Serial.println("Wrong Sequence ID (1-254)");
      break;
    }		

    Serial.println(SeqID, DEC);
    break;

  case 's':

    while (*InCmd != ' ') InCmd++; 
    while (isspace(*InCmd)) InCmd++;
    if (atoi(InCmd) > 0 && atoi(InCmd) < 255){
      SCommand=(atoi(InCmd));
    }
    else{
      Serial.println("Wrong Command Number (1-254)");
      break;
    }



    while (*InCmd != ' ') InCmd++; 
    while (isspace(*InCmd)) InCmd++;
    if (atoi(InCmd) > 0 && atoi(InCmd) < 255){
      SeqID = atoi(InCmd);
      //Serial.println(SeqID, DEC);
    }
    else{
      Serial.println("Wrong Sequence ID (1-254)");
      break;
    } 

    switch (SCommand){
    case 1:
      XYReset();
      Serial.println(SeqID, DEC); 
      break;
    default:
      Serial.print("Unknow Command: ");
      Serial.println(SCommand,DEC );
      break;
    }

    break;

  case 'v':
    while (*InCmd != ' ') InCmd++; 
    while (isspace(*InCmd)) InCmd++;
    if (atoi(InCmd) > 0 && atoi(InCmd) < 255){
      MotorSpeed = atoi(InCmd);
      //Serial.println(MotorSpeed, DEC);
    }
    else{
      Serial.println("Wrong Motor Speed (1-254)");
      break;
    }

    while (*InCmd != ' ') InCmd++; 
    while (isspace(*InCmd)) InCmd++;
    if (atoi(InCmd) >= 0 && atoi(InCmd) < 10001	){
      toX = atoi(InCmd);
      //Serial.println(MotorSteps, DEC);
    }
    else{
      Serial.println("Wrong Steps (0 - +10000)");
      break;
    }

    while (*InCmd != ' ') InCmd++; 
    while (isspace(*InCmd)) InCmd++;
    if (atoi(InCmd) >= 0 && atoi(InCmd) < 10001	){
      toY = atoi(InCmd);
      //Serial.println(MotorSteps, DEC);
    }
    else{
      Serial.println("Wrong Steps (0 - +10000)");
      break;
    }

    while (*InCmd != ' ') InCmd++; 
    while (isspace(*InCmd)) InCmd++;
    if (atoi(InCmd) > 0 && atoi(InCmd) < 255){
      SeqID = atoi(InCmd);
      //Serial.println(SeqID, DEC);
    }
    else{
      Serial.println("Wrong Sequence ID (1-254)");
      break;
    } 

    stepperX.setSpeed(MotorSpeed);
    stepperY.setSpeed(MotorSpeed);
    line(posX, posY, toX, toY);
    Serial.println(SeqID, DEC);
    break;


  case 'h':
    PrintHelp();
    break;

    Serial.println(SeqID, DEC);
    break;
  default:
    Serial.println("WTF?");
    break;	

  }


}

void line(int x1, int y1, int x2, int y2)
{
  int dx, dy, inx, iny, e, stepX, stepY;

  dx = x2 - x1;
  dy = y2 - y1;
  
  stepperX.step(1);
  posX++;
  if(dx*(posY-y1)-(posX-x1)*dy*(dy*dx)>0) {
    stepperX.step(1);
    posX++;
  } else {
    stepperY.step(1);
    posY++;
  }
}

void linebtr(int x1, int y1, int x2, int y2)
{
  int dx, dy, inx, iny, e, stepX, stepY;

  dx = x2 - x1;
  dy = y2 - y1;
  inx = dx > 0 ? 1 : -1;
  iny = dy > 0 ? 1 : -1;
  stepX = 0; 
  stepY = 0; 

  dx = abs(dx);
  dy = abs(dy);

  if(dx >= dy) {
    dy <<= 1;
    e = dy - dx;
    dx <<= 1;
    while (x1 != x2) {
      //			setpixel(x1, y1, color);
      if(e >= 0) {
        y1 += iny;
        stepperY.step(iny);
        e-= dx;
      }
      e += dy; 
      x1 += inx; 
      stepperX.step(inx);
    }
  } 
  else {
    dx <<= 1;
    e = dx - dy;
    dy <<= 1;
    while (y1 != y2) {
      //			setpixel(x1, y1, color);
      if(e >= 0) {
        x1 += inx;
        stepperX.step(inx);
        e -= dy;
      }
      e += dx; 
      y1 += iny; 
      stepperY.step(iny); 
    }
  }

  //	setpixel(x1, y1, color);

  posX = x1;
  posY = y1;
  Serial.println(posX, DEC);
  Serial.println(posY, DEC);
}

void XYReset(){
  posX = 0;
  posY = 0;
  stepperY.setSpeed(75);
  while (digitalRead(Ypojezd)==true){
    stepperY.step(-1);
  }
  stepperY.setSpeed(150);
  stepperY.step(1600);

  stepperX.setSpeed(75);
  while (digitalRead(Xpojezd)==true){
    stepperX.step(-1);
  }
  stepperX.setSpeed(150);
  stepperX.step(600);

}

void PrintHelp(){
  Serial.println("-----------------------------------------"); 
  Serial.println("----------BrmLab Laser Bordel------------"); 
  Serial.println("-----------------------------------------"); 
  Serial.println(); 
  Serial.println("Toto by mela byt napoveda....."); 
  Serial.println("A casem take mozna bude........"); 
  Serial.println(); 
  Serial.println("-----------------------------------------"); 

}




