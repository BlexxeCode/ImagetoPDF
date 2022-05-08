import cv2
import numpy as np
import pytesseract as py
import os
import ssl
import smtplib
import socket
import threading
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication

i = 0
###########################
frameWidth = 840
frameHeight = 960
###########################
cap = cv2.VideoCapture(1)
cap.set(3, frameWidth)
cap.set(4, frameHeight)
cap.set(10, 150)

py.pytesseract.tesseract_cmd = 'C://Program Files//Tesseract-OCR//tesseract.exe'
TESSDATA_PREFIX = 'C://Program Files//Tesseract-OCR'
tessdata_dir_config = '--tessdata-dir "C://Program Files//Tesseract-OCR//tessdata"'

context = ssl.create_default_context()

## Set up inital message with sender and sendee
mail = MIMEMultipart('mixed')
mail['From'] = 'sender@outlook.com'
mail['TO'] = ''
mail['CC'] = ''
mail['Subject'] = 'PDF SCAN'

Content = 'Here is your PDF Scan'
body = MIMEText(Content, 'html')
mail.attach(body)

## Set up server socket with port
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
host_name = socket.gethostname()
host_ip = ''
print('HOST IP:', host_ip)
port = 10050
socket_address = (host_ip, port)
print('Socket Created')

server_socket.bind(socket_address)
server_socket.listen(5)
print('Listening')


def preProcessing(Image):
    imgGray = cv2.cvtColor(Image, cv2.COLOR_BGR2GRAY)
    imgBlur = cv2.GaussianBlur(imgGray, (5, 5), 1)
    imgCanny = cv2.Canny(imgBlur, 50, 65)
    kernel = np.ones((5, 5))
    imgDial = cv2.dilate(imgCanny, kernel, iterations=2)
    imgThres = cv2.erode(imgDial, kernel, iterations=1)

    return imgThres


def getContours(Image):
    biggest = np.array([])
    maxArea = 0
    contours, hierarchy = cv2.findContours(imgThres, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
    for cnt in contours:
        area = cv2.contourArea(cnt)
        if area > 50000:
            cv2.drawContours(imgCon, cnt, -1, (455, 0, 0), 5)
            peri = cv2.arcLength(cnt, True)
            approx = cv2.approxPolyDP(cnt, 0.02 * peri, True)
            if area > maxArea and len(approx) == 4:
                biggest = approx
                maxArea = area
    cv2.drawContours(imgCon, biggest, -1, (255, 0, 0), 20)
    return biggest


def reorder(points):
    points = points.reshape((4, 2))
    pointsn = np.zeros((4, 1, 2), np.int32)
    add = points.sum(1)
    # print("add",add)

    pointsn[0] = points[np.argmin(add)]
    pointsn[3] = points[np.argmax(add)]
    # print("Newp", points )
    diff = np.diff(points, axis=1)
    pointsn[1] = points[np.argmin(diff)]
    pointsn[2] = points[np.argmax(diff)]
    return pointsn


def getWarp(Image, biggest):
    biggest = reorder(biggest)
    print(biggest)
    pts1 = np.float32(biggest)
    pts2 = np.float32([[0, 0], [frameWidth, 0], [0, frameHeight], [frameWidth, frameHeight]])
    matrix = cv2.getPerspectiveTransform(pts1, pts2)
    imout = cv2.warpPerspective(Image, matrix, (frameWidth, frameHeight))

    return imout


def sharp(Image):
    kernel = np.array([[0, -1, 0],
                       [-1, 5, -1],
                       [0, -1, 0]])
    imgShar = cv2.filter2D(src=Image, ddepth=-1, kernel=kernel)

    return imgShar


while True:
    client_socket, addr = server_socket.accept()
    print('Connection from', addr)  ## waits for connection from client
    if client_socket:
        while cap.isOpened():
            try:
                success, Image = cap.read()
                imgCon = Image.copy()
                imgThres = preProcessing(Image)
                biggest = getContours(imgThres)
                print(biggest)
                cv2.imshow("Result Final", imgCon)

                _, buf = cv2.imencode('.jpg', imgCon)
                bufby = buf.tobytes()
                client_socket.sendall(bufby)

                key = cv2.waitKey(1)
                if key == 13:
                    client_socket.close()
                client_socket.settimeout(0.01)
                packet = client_socket.recv(4 * 1024).decode()
                if packet == 'Scan':
                    print("Image Taken")
                    try:
                        cv2.imwrite("Before.png", Image)
                        Pic = cv2.imread("Before.png")
                        imgwar = getWarp(Pic, biggest)
                        imgShar = sharp(imgwar)
                        #cv2.imshow("Result Final", imgShar)
                        if os.path.exists(cv2.imwrite("After%s.png" % i, imgShar)):
                            if os.stat("text.txt").st_size == 0:
                                with open('text.txt', 'w') as g:
                                    g.write("After%s.png" % i)
                            else:
                                with open('text.txt', 'a') as f:
                                    f.write("\nAfter%s.png" % i)
                            i += 1
                    except ValueError:
                        print("No Page Detected")
                        continue
                if packet == 'PDF':
                    print('PDF conversion')
                    try:
                        inputT = "C://Users//andki//PycharmProjects//Documents//text.txt"
                        img = cv2.imread(inputT, 1)
                        result = py.image_to_pdf_or_hocr(inputT, lang="eng", config=tessdata_dir_config)
                        Final = open("C://Users//andki//PycharmProjects//Documents//Search1.pdf", "w+b")
                        Final.write(bytearray(result))
                        Final.close()
                        with open("text.txt", 'r+') as f:
                            f.truncate(0)
                        for images in os.listdir('C://Users//andki//PycharmProjects//Documents'):
                            if images.endswith('.png'):
                                os.remove(os.path.join('C://Users//andki//PycharmProjects//Documents', images))
                    except py.pytesseract.TesseractError:
                        ## if there are no image taken
                        print('No Image Was Taken')
                        with open("C://Users//andki//PycharmProjects//Documents//text.txt", 'r+') as f:
                            f.truncate(0)
                        for images in os.listdir('C://Users//andki//PycharmProjects//Documents'):
                            if images.endswith('.png'):
                                os.remove(os.path.join('C://Users//andki//PycharmProjects//Documents', images))
                        continue
                if packet == 'Mail':
                    print('Mailing')
                    filename = "C://Users//andki//PycharmProjects//Documents//Search1.pdf"  ##directory of PDF
                    try:
                        with open(filename, "rb") as attachment:
                            # attaches PDF to mail
                            p = MIMEApplication(attachment.read(), _subtype="pdf")
                            p.add_header('Content-Disposition', "attachment; filename= %s" %
                                     filename.split("\\")[-1])
                            mail.attach(p)
                    except Exception as e:
                        print(str(e))
                    msg_full = mail.as_string()
                    server = smtplib.SMTP("smtp-mail.outlook.com", 587)  ##configures smtp server
                    server.starttls(context=context)
                    server.login("sender@outlook.com", "password")
                    server.sendmail("sender@outlook.com",  # sender
                                "recipient goes here",  # recipient
                                msg_full)
                    server.quit()

                cv2.imshow("Result", imgThres)
                # cv2.imshow("Result3", Image)
                # cv2.imshow("Result2", imgCon)
            except socket.timeout as st:
                continue
            except (ConnectionResetError, BrokenPipeError) as e:  # breaks out of for loop into while loop, in order to reconnect
                print('Client left')
                with open("C://Users//andki//PycharmProjects//Documents//text.txt", 'r+') as f:
                    f.truncate(0)
                for images in os.listdir('C://Users//andki//PycharmProjects//Documents'):
                    if images.endswith('.png'):
                        os.remove(os.path.join('C://Users//andki//PycharmProjects//Documents', images))

                client_socket.close()
                break
