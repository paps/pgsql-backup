#!/usr/bin/env python3

import smtplib
import sys
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

def send_mail(subject, contentFilePath, login, password, mailFrom, mailTo):
    contentFile = open(contentFilePath, encoding='utf-8')
    html = '<html><head></head><body><pre style="font-family: Monaco, monospace; font-size: 90%;">'
    html += contentFile.read();
    html += '</pre></body></html>'
    contentFile.close()

    msg = MIMEMultipart('alternative')
    msg['Subject'] = subject
    msg['From'] = mailFrom
    msg['To'] = mailTo
    msg.attach(MIMEText(html, 'html', 'utf-8'))

    s = smtplib.SMTP('smtp.sendgrid.net', 587)
    s.login(login, password)
    s.sendmail(mailFrom, mailTo, msg.as_string())
    s.quit()

def usage():
    print('Usage: sendgrid.py subject contentFilePath login password mailFrom mailTo')

if __name__ == '__main__':
    if len(sys.argv) < 7:
        usage()
        exit()
    send_mail(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6])
