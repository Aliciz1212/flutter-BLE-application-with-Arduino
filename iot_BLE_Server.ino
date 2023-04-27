#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <Stepper.h>
#include <AccelStepper.h>

const int stepsPerRevolution = 2048;  // change this to fit the number of steps per revolution

// ULN2003 Motor Driver Pins
#define IN1 19
#define IN2 18
#define IN3 5
#define IN4 17

// initialize the stepper library
AccelStepper stepper (AccelStepper::FULL4WIRE, 19, 5, 18, 17);

BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic_1 = NULL;
BLECharacteristic* pCharacteristic_2 = NULL;
BLECharacteristic* pCharacteristic_3 = NULL;

bool deviceConnected = false;
bool oldDeviceConnected = false;




// https://www.uuidgenerator.net/

#define SERVICE_UUID          "e5d9a464-ce19-4e3d-8579-f7683c3d997f"
#define CHARACTERISTIC_UUID_1 "7b97c134-8c9b-4ed0-b789-1ab5a88572dd"
#define CHARACTERISTIC_UUID_2 "813cc091-674d-45ad-96a9-379514b30dbc"
#define CHARACTERISTIC_UUID_3 "5857e892-ff33-4193-a686-b012f96bf98a"



class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
    }
};
int state=0;
class Characteristic1_Callback:public BLECharacteristicCallbacks{
  void onWrite(BLECharacteristic *pChar) override{
  
    std::string mode= pChar->getValue();
    String _mode=String(mode.c_str());
    if(_mode=="400"){
    Serial.println("400nm");
    stepper.moveTo(0);
    }
    if(_mode=="500"){
    Serial.println("500nm");
    stepper.moveTo(200);

    }
    if(_mode=="600"){
    Serial.println("600nm");
    stepper.moveTo(400);
    }
    if(_mode=="700"){
    Serial.println("700nm");
    stepper.moveTo(600);
    }

    if(_mode=="reset"){
      Serial.println("reset");
      stepper.moveTo(0);
    }
 
  }
};

class Characteristic2_Callback:public BLECharacteristicCallbacks{
  void onWrite(BLECharacteristic *pChar) override{

      
        int value;
        float analogOut = 43.2; 
        //operation
         value = int(analogOut);
        pCharacteristic_2->setValue(value); 
        
        Serial.println("measuring");


    
  }
};
class Characteristic3_Callback:public BLECharacteristicCallbacks{
  void onWrite(BLECharacteristic *pChar) override{


    std::string position= pChar->getValue();
    String str_position=String(position.c_str());

    int int_position=str_position.toInt();


    Serial.println("Moving to "+ str_position+ " position ....");
    stepper.moveTo(int_position);


 
  }
};


void setup() {
   // set the speed at 5 rpm



  Serial.begin(115200);
  stepper.setMaxSpeed(100);
  stepper.setAcceleration(20);

  // Create the BLE Device
  BLEDevice::init("myESP32");

  // Create the BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create the BLE Service
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Create a BLE Characteristic
 pCharacteristic_1 = pService->createCharacteristic(
                      CHARACTERISTIC_UUID_1,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  
       
                    );
pCharacteristic_2 = pService->createCharacteristic(
                      CHARACTERISTIC_UUID_2,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  
           
                    );
  pCharacteristic_3 = pService->createCharacteristic(
                      CHARACTERISTIC_UUID_3,
                     BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  
                
           
                    );

  // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.descriptor.gatt.client_characteristic_configuration.xml
  // Create a BLE Descriptor
  pCharacteristic_1->addDescriptor(new BLE2902());
  pCharacteristic_2->addDescriptor(new BLE2902());
  pCharacteristic_3->addDescriptor(new BLE2902());
  pCharacteristic_1->setCallbacks(new  Characteristic1_Callback());
   pCharacteristic_2->setCallbacks(new  Characteristic2_Callback());
      pCharacteristic_3->setCallbacks(new  Characteristic3_Callback());

  // Start the service
  pService->start();

  // Start advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x0);  // set value to 0x00 to not advertise this parameter
  BLEDevice::startAdvertising();
  Serial.println("Waiting for App connection ...");
}

void loop() {
    // notify changed value
    
    if (deviceConnected) {
      //analog output and voltage operation
      while(stepper.distanceToGo()!=0){
        stepper.run();
      }
      delay(10); 
// bluetooth stack will go into congestion, if too many packets are sent, in 6 hours test i was able to go as low as 3ms
    }
    // disconnecting
    if (!deviceConnected && oldDeviceConnected) {
        delay(500); // give the bluetooth stack the chance to get things ready
        pServer->startAdvertising(); // restart advertising
        Serial.println("start advertising");
        oldDeviceConnected = deviceConnected;
    }
    // connecting
    if (deviceConnected && !oldDeviceConnected) {
        // do stuff here on connecting
        oldDeviceConnected = deviceConnected;
    }
}