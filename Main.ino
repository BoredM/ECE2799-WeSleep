
// test code for Grove - Sound Sensor
// loovee @ 2016-8-30

#include <Wire.h>
#include <Adafruit_MLX90614.h>

#define soundTH 300
#define tempTH 33.00
Adafruit_MLX90614 mlx = Adafruit_MLX90614();

const int pinAdc = A0;
int incomingByte = 0;
unsigned long printTime = 0;
unsigned long motorTime = 0;
char counter = 0;
char cried = 0;
char crying = 0;
char motorOn = 0;
char cryAlert = 0;
char cryAlertSent = 0;
char highTemp = 0;
char highTempSent = 0;
char swinged = 0;
char reset = 0;
char swingOn = 0;
unsigned long sum = 0;

void setup()
{
    Serial.begin(9600);
    mlx.begin();
    pinMode(7, 1);
    pinMode(9, 1);
    pinMode(8, 1);
    digitalWrite(7, 0);
    analogWrite(9, 0);
    digitalWrite(8, 0);
}

void loop()
{
    double temp = 0;
    long noise = 0;

    //obtain sound level reading
    for(int i=0; i<32; i++)
    {
        noise += analogRead(pinAdc);
    }
    noise >>= 5;

    //Serial.println(noise);
    delay(10);

    if(noise > soundTH){
      digitalWrite(7, 1);
    }else{
      digitalWrite(7, 0);
    }

    //detect cry. test with LED
    if(cryDetect(noise)||swingOn){
      motorOn = 1;
      crying = 1;
      cried = 1;
      swingOn = 0;
      analogWrite(9, 192);
      motorTime = millis();
    }

    if(motorOn == 1){
      if(millis() > (motorTime + 30000)){
        motorOn = 0;
        crying = 0;
        swinged = 1;
        analogWrite(9, 0);
      }
    }

    if((swinged == 1)&&(cried == 1)&&cryDetect(noise)){
      cryAlert = 1;
    }
    
    //obtain temp reading
    temp = mlx.readObjectTempC();
    
    //detect high temp. test with LED
    if(tempAlert(temp)){
      highTemp = 1;
      digitalWrite(8, 1);
    }

    //Serial.println(temp);
    allReset();
    sCommunication(temp);
}

boolean cryDetect(long noise)
{
    if(crying == 0){
      sum = sum + noise;
      counter = counter + 1;   
 
      if(counter >= 16){
        sum = sum >> 4;
        //Serial.println(sum);
        if(sum > soundTH){
          return true;  
        }
        sum = 0;
        counter = 0;
      }
    }
    return false;
}

boolean tempAlert(double temp)
{
    if(highTemp == 0){
      if(temp >= tempTH){
        return true;
      }
    }

    return false;
}

void allReset()
{
    if(reset == 1){
      //reset all the flags
      cried = 0;
      motorOn = 0;
      highTemp = 0;
      highTempSent = 0;
      cryAlert = 0;
      cryAlertSent = 0;
      swingOn = 0;
      crying = 0;
      swinged = 0;
      reset = 0;

      //toggle pins to low
      digitalWrite(7, 0);
      analogWrite(9, 0);
      digitalWrite(8, 0);
    }
}

void sCommunication(double temp){
    if(Serial.available() > 0){
        incomingByte = Serial.read();

        if((incomingByte - 48) == 1){
          reset = 1;  
        }

        if((incomingByte - 48) == 2){
          swingOn = 1;  
        }
    }
    
    if(millis() >= (printTime + 500)){
        Serial.println(temp);
        
        if(cryAlert && (cryAlertSent == 0)){
          Serial.println(4);
          cryAlertSent = 1;
        }

        if(highTemp && (highTempSent == 0)){
          Serial.println(2);
          highTempSent = 1;
        }
        printTime = millis();
    }
}



