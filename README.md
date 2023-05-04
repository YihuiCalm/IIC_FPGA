# IIC_FPGA
IIC implementation using Verilog on Vivado, based on ARTY-7 35T FPGA and AT24C02 EEPROM.

Chipscope Waveform below shows writting data 0xAC to memory address 0x00 of an EEPROM with device address of 0b1010000:
![Screenshot (12)](https://user-images.githubusercontent.com/96307958/236342786-536b01b7-ae4b-4570-8de1-343c6671abeb.png)

Chipscope Waveform below shows reading data 0xAC from memory address 0x00 of an EEPROM with device address of 0b1010000:
![Screenshot (13)](https://user-images.githubusercontent.com/96307958/236342851-05d936fd-f816-44c2-bd01-053d2b4590d8.png)
