#This Python script will help you backup the network device to FTP server
from napalm import get_network_driver

driver = get_network_driver('gaiaos')
device = driver('<IP_Address>', '<Username>', '<password>')
device.open()

output = device.send_clish_cmd('show backups')
#output = device.send_clish_cmd('add backup ftp ip <FTP_IP> path / username <username> password <password>')
print(output)