#!/usr/bin/python
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os

email = 'XXXXXXXXXXXX'
password = 'XXXXXX'
send_to_email = 'XXXXXX'
subject = (os.environ["subject"])
message = (os.environ["message"])


msg = MIMEMultipart()
msg['From'] = email
msg['To'] = send_to_email
msg['Subject'] = subject

 # Attach the message to the MIMEMultipart object
msg.attach(MIMEText(message, 'plain'))

server = smtplib.SMTP('smtp.XXXX.XX', 587)
server.starttls()
server.login(email, password)
text = msg.as_string() # You now need to convert the MIMEMultipart object to a string to send
server.sendmail(email, send_to_email, text)
server.quit()

