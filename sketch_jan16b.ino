#include <WiFi.h>
#include <HTTPClient.h>

const char* ssid = "azrniot";
const char* password = "wkwkwkwk";
const char* serverUrl = "http://192.168.1.10:3000/updateData"; // Ganti dengan alamat dan port Node.js server

void setup() {
    Serial.begin(115200);
    WiFi.begin(ssid, password);

    while (WiFi.status() != WL_CONNECTED) {
        delay(1000);
        Serial.println("Connecting to WiFi...");
    }
    Serial.println("Connected to WiFi");
}

void loop() {

  if (Serial.available() > 1) {
    String serialData = Serial.readStringUntil('\n');
    // String serialData = Serial.read();

    HTTPClient http;
    http.begin(serverUrl);
    http.addHeader("Content-Type", "application/x-www-form-urlencoded");

    // String data = ;
    int httpResponseCode = http.POST(serialData);

    if (httpResponseCode > 0) {
        Serial.print("HTTP Response code: ");
        Serial.println(httpResponseCode);
    } else {
        Serial.print("Error in HTTP request. Code: ");
        Serial.println(httpResponseCode);
    }
        Serial.println(serialData);

    http.end();

    // delay(1000); // Kirim data setiap 1 detik
 }
}
