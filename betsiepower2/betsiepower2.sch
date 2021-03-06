EESchema Schematic File Version 4
LIBS:betsiepower2-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "Betsie Power board 2"
Date "2018-11-09"
Rev ""
Comp "Mark Robson"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Regulator_Linear:AZ1117-5.0 U1
U 1 1 5BE49AE9
P 2950 4050
F 0 "U1" H 2950 4292 50  0000 C CNN
F 1 "AZ1117-5.0" H 2950 4201 50  0000 C CNN
F 2 "TO_SOT_Packages_SMD:SOT-223" H 2950 4300 50  0001 C CIN
F 3 "https://www.diodes.com/assets/Datasheets/AZ1117.pdf" H 2950 4050 50  0001 C CNN
	1    2950 4050
	1    0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x02_Male J1
U 1 1 5BE49BC0
P 1550 4000
F 0 "J1" H 1656 4178 50  0000 C CNN
F 1 "Conn_01x02_Male" H 1656 4087 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02_Pitch2.54mm" H 1550 4000 50  0001 C CNN
F 3 "~" H 1550 4000 50  0001 C CNN
	1    1550 4000
	1    0    0    -1  
$EndComp
Wire Wire Line
	1750 4000 2150 4000
Wire Wire Line
	2650 4050 2450 4050
Wire Wire Line
	2150 4050 2150 4000
Wire Wire Line
	2100 4100 2100 4350
Wire Wire Line
	2100 4350 2450 4350
$Comp
L Device:C C1
U 1 1 5BE49D98
P 2450 4200
F 0 "C1" H 2565 4246 50  0000 L CNN
F 1 "10uF" H 2565 4155 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805_HandSoldering" H 2488 4050 50  0001 C CNN
F 3 "~" H 2450 4200 50  0001 C CNN
	1    2450 4200
	1    0    0    -1  
$EndComp
Connection ~ 2450 4050
Wire Wire Line
	2450 4050 2150 4050
Connection ~ 2450 4350
Wire Wire Line
	2450 4350 2600 4350
Text GLabel 2450 3850 1    50   Input ~ 0
VBAT
Wire Wire Line
	2450 3850 2450 4050
Wire Wire Line
	2950 4350 3200 4350
Connection ~ 2950 4350
Wire Wire Line
	3250 4050 3550 4050
$Comp
L Device:C C2
U 1 1 5BE4A034
P 3550 4200
F 0 "C2" H 3665 4246 50  0000 L CNN
F 1 "47uF" H 3665 4155 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206_HandSoldering" H 3588 4050 50  0001 C CNN
F 3 "~" H 3550 4200 50  0001 C CNN
	1    3550 4200
	1    0    0    -1  
$EndComp
Wire Wire Line
	3550 4050 4200 4050
$Comp
L power:GND #PWR01
U 1 1 5BE4A0C2
P 2950 4350
F 0 "#PWR01" H 2950 4100 50  0001 C CNN
F 1 "GND" H 2955 4177 50  0000 C CNN
F 2 "" H 2950 4350 50  0001 C CNN
F 3 "" H 2950 4350 50  0001 C CNN
	1    2950 4350
	1    0    0    -1  
$EndComp
Wire Wire Line
	1750 4100 2100 4100
$Comp
L Connector:Conn_01x05_Male J2
U 1 1 5BE4B052
P 3100 2550
F 0 "J2" H 3206 2928 50  0000 C CNN
F 1 "Conn_01x05_Male" H 3206 2837 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x05_Pitch2.54mm" H 3100 2550 50  0001 C CNN
F 3 "~" H 3100 2550 50  0001 C CNN
	1    3100 2550
	1    0    0    -1  
$EndComp
Text Notes 3050 2050 0    50   ~ 0
Power out, weapon control
Text Notes 1500 3750 0    50   ~ 0
Power in\n
Text GLabel 3300 2350 2    50   Input ~ 0
VLOGIC
$Comp
L power:GND #PWR03
U 1 1 5BE4B3AC
P 4250 2450
F 0 "#PWR03" H 4250 2200 50  0001 C CNN
F 1 "GND" H 4255 2277 50  0000 C CNN
F 2 "" H 4250 2450 50  0001 C CNN
F 3 "" H 4250 2450 50  0001 C CNN
	1    4250 2450
	1    0    0    -1  
$EndComp
Wire Wire Line
	4250 2450 3300 2450
Text GLabel 3300 2650 2    50   Input ~ 0
WEAPON_UP
Text GLabel 3300 2750 2    50   Input ~ 0
WEAPON_DOWN
Text GLabel 7300 4050 0    50   Input ~ 0
WEAPON_UP
Text GLabel 7300 3950 0    50   Input ~ 0
WEAPON_DOWN
$Comp
L power:GND #PWR05
U 1 1 5BE4BFC1
P 6150 4950
F 0 "#PWR05" H 6150 4700 50  0001 C CNN
F 1 "GND" H 6155 4777 50  0000 C CNN
F 2 "" H 6150 4950 50  0001 C CNN
F 3 "" H 6150 4950 50  0001 C CNN
	1    6150 4950
	1    0    0    -1  
$EndComp
Text Notes 2750 3750 0    50   ~ 0
KIA1117-5.0 pin compatible
Text Notes 1350 4250 0    50   ~ 0
Max 10V (2S)
Connection ~ 3550 4050
Text GLabel 3550 3550 1    50   Input ~ 0
VLOGIC
Wire Wire Line
	3600 3550 3550 3550
Wire Wire Line
	3550 4050 3550 3550
$Comp
L Device:LED D1
U 1 1 5BE50E5B
P 4200 4200
F 0 "D1" V 4238 4083 50  0000 R CNN
F 1 "LED" V 4147 4083 50  0000 R CNN
F 2 "LEDs:LED_0805" H 4200 4200 50  0001 C CNN
F 3 "~" H 4200 4200 50  0001 C CNN
	1    4200 4200
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R1
U 1 1 5BE50F1A
P 4200 4500
F 0 "R1" H 4270 4546 50  0000 L CNN
F 1 "68" H 4270 4455 50  0000 L CNN
F 2 "Resistors_SMD:R_0805_HandSoldering" V 4130 4500 50  0001 C CNN
F 3 "~" H 4200 4500 50  0001 C CNN
	1    4200 4500
	1    0    0    -1  
$EndComp
$Comp
L Device:R R2
U 1 1 5BE50FC9
P 4200 4800
F 0 "R2" H 4270 4846 50  0000 L CNN
F 1 "68" H 4270 4755 50  0000 L CNN
F 2 "Resistors_SMD:R_0805_HandSoldering" V 4130 4800 50  0001 C CNN
F 3 "~" H 4200 4800 50  0001 C CNN
	1    4200 4800
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR02
U 1 1 5BE51007
P 4200 4950
F 0 "#PWR02" H 4200 4700 50  0001 C CNN
F 1 "GND" H 4205 4777 50  0000 C CNN
F 2 "" H 4200 4950 50  0001 C CNN
F 3 "" H 4200 4950 50  0001 C CNN
	1    4200 4950
	1    0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x02_Male J3
U 1 1 5BE516BA
P 9300 4050
F 0 "J3" H 9273 3930 50  0000 R CNN
F 1 "Conn_01x02_Male" H 9273 4021 50  0000 R CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02_Pitch2.54mm" H 9300 4050 50  0001 C CNN
F 3 "~" H 9300 4050 50  0001 C CNN
	1    9300 4050
	-1   0    0    1   
$EndComp
Text Notes 8750 3850 0    50   ~ 0
Weapon power out
$Comp
L power:GNDPWR #PWR0102
U 1 1 5BE538A4
P 2600 4350
F 0 "#PWR0102" H 2600 4150 50  0001 C CNN
F 1 "GNDPWR" H 2604 4196 50  0000 C CNN
F 2 "" H 2600 4300 50  0001 C CNN
F 3 "" H 2600 4300 50  0001 C CNN
	1    2600 4350
	1    0    0    -1  
$EndComp
Connection ~ 2600 4350
Wire Wire Line
	2600 4350 2950 4350
$Comp
L power:PWR_FLAG #FLG0101
U 1 1 5BE53907
P 2150 4000
F 0 "#FLG0101" H 2150 4075 50  0001 C CNN
F 1 "PWR_FLAG" H 2150 4174 50  0000 C CNN
F 2 "" H 2150 4000 50  0001 C CNN
F 3 "~" H 2150 4000 50  0001 C CNN
	1    2150 4000
	1    0    0    -1  
$EndComp
Connection ~ 2150 4000
$Comp
L power:PWR_FLAG #FLG0102
U 1 1 5BE4BCFF
P 3200 4350
F 0 "#FLG0102" H 3200 4425 50  0001 C CNN
F 1 "PWR_FLAG" H 3200 4524 50  0000 C CNN
F 2 "" H 3200 4350 50  0001 C CNN
F 3 "~" H 3200 4350 50  0001 C CNN
	1    3200 4350
	-1   0    0    1   
$EndComp
Connection ~ 3200 4350
Wire Wire Line
	3200 4350 3550 4350
Wire Wire Line
	6150 4950 6150 4550
$Comp
L hbridge:RZ7899 U2
U 1 1 5BE5501F
P 7900 3950
F 0 "U2" H 7800 4315 50  0000 C CNN
F 1 "RZ7899" H 7800 4224 50  0000 C CNN
F 2 "Housings_SOIC:SOIC-8_3.9x4.9mm_Pitch1.27mm" H 7850 3950 50  0001 C CNN
F 3 "" H 7850 3950 50  0001 C CNN
	1    7900 3950
	1    0    0    -1  
$EndComp
Wire Wire Line
	7300 4150 6150 4150
Text GLabel 6850 4250 0    50   Input ~ 0
VWEAPON
Wire Wire Line
	6850 4250 6950 4250
$Comp
L Device:C C3
U 1 1 5BE56BBA
P 6950 4400
F 0 "C3" H 7065 4446 50  0000 L CNN
F 1 "47uF" H 7065 4355 50  0000 L CNN
F 2 "Capacitors_SMD:C_1206_HandSoldering" H 6988 4250 50  0001 C CNN
F 3 "~" H 6950 4400 50  0001 C CNN
	1    6950 4400
	1    0    0    -1  
$EndComp
Connection ~ 6950 4250
Wire Wire Line
	6950 4250 7300 4250
Wire Wire Line
	6950 4550 6150 4550
Connection ~ 6150 4550
Wire Wire Line
	6150 4550 6150 4150
Wire Wire Line
	9100 3950 8450 3950
Wire Wire Line
	8300 4050 8450 4050
Wire Wire Line
	8450 4050 8450 3950
Connection ~ 8450 3950
Wire Wire Line
	8450 3950 8300 3950
Wire Wire Line
	8300 4150 8450 4150
Wire Wire Line
	8650 4150 8650 4050
Wire Wire Line
	8650 4050 9100 4050
Wire Wire Line
	8300 4250 8450 4250
Wire Wire Line
	8450 4250 8450 4150
Connection ~ 8450 4150
Wire Wire Line
	8450 4150 8650 4150
$Comp
L Connector:Conn_01x03_Male J4
U 1 1 5BE590A4
P 9300 2900
F 0 "J4" H 9273 2830 50  0000 R CNN
F 1 "Conn_01x03_Male" H 9273 2921 50  0000 R CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x03_Pitch2.54mm" H 9300 2900 50  0001 C CNN
F 3 "~" H 9300 2900 50  0001 C CNN
	1    9300 2900
	-1   0    0    1   
$EndComp
Text Notes 9000 2700 0    50   ~ 0
Power boost
$Comp
L power:GND #PWR04
U 1 1 5BE5922D
P 8950 3000
F 0 "#PWR04" H 8950 2750 50  0001 C CNN
F 1 "GND" H 8955 2827 50  0000 C CNN
F 2 "" H 8950 3000 50  0001 C CNN
F 3 "" H 8950 3000 50  0001 C CNN
	1    8950 3000
	1    0    0    -1  
$EndComp
Text GLabel 8350 2800 0    50   Input ~ 0
VWEAPON
Text GLabel 9100 2900 0    50   Input ~ 0
VBAT
Wire Wire Line
	9100 3000 8950 3000
Wire Wire Line
	9100 2800 8450 2800
$Comp
L power:PWR_FLAG #FLG0103
U 1 1 5BE5C697
P 8450 2800
F 0 "#FLG0103" H 8450 2875 50  0001 C CNN
F 1 "PWR_FLAG" H 8450 2974 50  0000 C CNN
F 2 "" H 8450 2800 50  0001 C CNN
F 3 "~" H 8450 2800 50  0001 C CNN
	1    8450 2800
	1    0    0    -1  
$EndComp
Connection ~ 8450 2800
Wire Wire Line
	8450 2800 8350 2800
NoConn ~ 3300 2550
$EndSCHEMATC
