# ImageRecognitionApp

This is an iOS app that works according to the following steps
1. User selects image from image library
2. Image sent via POST request to Microsoft Cognitive Services for image recognition
3. Data from HTTP response is displayed
  - Mainly just a description of the image and the confidence in that description (all from the Microsoft Vision API).
