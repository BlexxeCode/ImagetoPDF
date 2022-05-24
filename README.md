# ServerPDFMailer
A conbination of a server and client through TCP that communite with each other in order to take a picture of a document, warp the perspective into a PDF, and mail to a specifed email.

The Server is run on Python and has three functionalities: 
1. Taking a picture a doucument. Using OpenCV, multiple imaging techniques are performed, such as graying, blurring and and canny edge detection, whiich is happening in real time. On the window,(or on the app), the page will be contoured with the four present edge points, which are found adcordance to the pixel location. Once the image is taken with the visible contours, the end result will be a warped image that ommits the background and centers directly on the document
2. Converting that warped image into a searchable PDF. This is done with the use of pytesseract with the eng language dataset. The quality and accuracy of the PDF greatly depends on the quality of the warped image.
3. Mailing the final PDF to an email using SMTP along with SSL. This uses an already set up email account to send the PDF to another email. While testing this, I used outlook, so .startttls() was used instead of SMTP_SSL(). 


The client an application written in Dart with Flutter that connects to the server and recieves a live video feed of the scanners camera through TCP packets. The home screen consists of multiple features:
1. The video previre screen that shows a live feed ofthe scanners camera. on the buttom are three buttons that controls the scanners functionalities mentioned above. How this works is that each button is tied to a string that, when pressed, is encoded and sent the scanner, in whic the scanner will decode it and compare it with the three options.
2. (Work in progress) - A camera feature that was from the earlier implementation of the current video preview. Could be turned into a QR scanner based on previous feedback
3. Email feedback - On this screen, sggestion can be given to better improve the experiance of the app.
4. IP text box - This is used in order to change the address to whatever the app wants to connect to. This will be saved until another IP is typed. 


C++ version in progress. At the beginning, this was originally written in C++, but during the halfway point, the switch to Python was decided. Since working on the Python version, I am intersted in getting the C++ version of this working. Right now only a small section is working and I am now currently implementing TCP connection.
