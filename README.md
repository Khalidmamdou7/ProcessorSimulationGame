# ProcessorSimulationGame
A two player’s processor simulation game and a chatting module made by assembly x86 language. This project was assigned to us during Microprocessor-I course. It was aimed after the completion of this project that we will be able to:
- Learn how microprocessor work and its internal structure
- Learn text parsing in assembly
- Working in a relatively big project and how to deal with large lines of code
- Learn about serial communication

# Table of Contents

1. [More about the game](#more-about-the-game)
2. [Environment and tools used](#environment-and-tools-used)
3. [Installation and usage](#installation-and-usage)
4. [Serial port communication](#serial-port-communication)
5. [Contributers](#contributers)
6. [License](#license)

# More about the game
The users should be able to play a two player's processor simulation game. The final target for each player is to put certain value in one of the opponent registers. Players take turns writing assembly commands, and they could use special types of power up to prevent the opponent from reaching the required value.
The users should be able to communicate with each other using serial communication. The game supported five addressing modes and five errors handling. More about the project in its [document](MP_Project%20DescriptionA_Fall_2021.pdf).

# Environment and tools used
While developing this project, we have written x86 assembly and ran it using [DosBox](https://www.dosbox.com/download.php?main=1). We used serial connection software to simulate the serial connection between two PCs, more in that in the [Serial Connection section](#Serial-port-communication).

# Installation and usage
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


## Contributers
Contributers in the project:
- [Anas Elkheshn](https://github.com/Femton02)
- [Seif Albaghdady](https://github.com/seifAlbaghdady)
- [Khalid Mamdouh](https://github.com/Khalidmamdou7)
- [Ahmed Maher](https://github.com/AhmedMaher309)
- [Shadi Gamal](https://github.com/Shadi-Gamal-Hassan)

## License
MIT License

Copyright (c) [2021] [Ahmed Maher, Anas Elkeshn, Seif Albaghdady,  Shadi Gamal, Khaled Mamdouh]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Processor Simulation game"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

