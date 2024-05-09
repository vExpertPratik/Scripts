#This Python script will help you show the current time details of network device

import paramiko
ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect('<IP_Address>',username='<Username>',password='<password>')
stdin, stdout, stderr=ssh.exec_command("show clock")
print(stdin)
stdout.readlines()