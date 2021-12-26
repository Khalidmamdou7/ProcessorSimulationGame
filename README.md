# ProcessorSimulationGame
A two player’s processor simulation game made by assembly language.

# Environment
To run this game, you need to install [DosBox](https://www.dosbox.com/download.php?main=1) (x86 emulator) on your PC.
After running dosBox, you need to configure it using the following lines of code
```
mount c [Game directory path]
c: 
```
then, if there are .exe files ready to run you just type its name in order to run it. 
If the files are still in .asm extension you need to do the following
```
masm [file name].asm
link [file name].obj
[file name].exe
```

# Serial port communication
This is a two player's game, so we need to connect two PC's using the serial port communication, you can do that using the serial_ethernet_connector program and connecting the two PC's by a modem cable. 
If you want to simulate the game on one PC, you can use the same program to simulate a server-client connection on two ports and running two dosBoxes terminals. To do that follow the following steps.
1. Open the serial-ethernet-connctor program and create a test connection, each on a different port (COM1 and COM2)
2. Search in the windows bar for DosBox options, and open it
3. It opens a config file, search for "serial". scroll till you find this line
```
serial1= dummy
```
4. change it to 
```
serial1= directserial realport:COM1
```
5. save the file and run dosbox, you will notice the following in the dosBox
```
DOSBox version 0.74-3
Copyright 2002-2019 DOSBox Team, published under GNU GPL.
---
CONFIG:Loading primary settings from config file C:\Users\khali\AppData\Local\DOSBox\dosbox-0.74-3.conf
MIDI:Opened device:win32
Serial1: Opening COM1
```
6. Repeat steps from 2 to 5 but by making step 4 COM2 instead of COM1.
7. Now you have two terminals of dosboxes opened on two different ports connected using the virtual ports of serial-ethernet-connector program. You can run two different programs on both terminals

