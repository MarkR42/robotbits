#!/usr/bin/env python3
import struct
import os
import time
import collections

ControlPosition = collections.namedtuple('ControlPosition',
    ['x', 'y', 'flip', 'signal']
    )
NO_SIGNAL = ControlPosition(0,0,False,False)

InputEvent = collections.namedtuple('InputEvent', ['tv_sec', 'tv_usec','type', 'code', 'value'])

# Constants from linux/input-event-codes.h

EV_SYN=0
EV_KEY=1
EV_REL=2
EV_ABS=3

AXES_X = (2,) # Ignore left hand stick X axis.
AXES_Y = (1,3)
# Buttons for "flip" - X, and all the shoulder buttons.
BUTTONS_FLIP =  (0x12e, 0x128, 0x129, 0x12a, 0x12b)

input_dev = '/dev/input/event0'

#long int, long int, unsigned short, unsigned short, unsigned int
FORMAT = 'llHHi'
EVENT_SIZE = struct.calcsize(FORMAT)

def read_event(fd):
    d = fd.read(EVENT_SIZE)
    if d is None:
        return None
    fields = struct.unpack(FORMAT, d)
    return InputEvent(*fields)

input_dev_fd = None # Global
input_state_flip = False
# State of input axes:
input_axes = collections.defaultdict(int)
  
def read_controller():
    global input_dev_fd
    global input_state_flip
    if input_dev_fd is None:
        try:
            fd = open(input_dev, 'rb')
            os.set_blocking(fd.fileno(), 0)
            input_dev_fd = fd
        except OSError:
            return NO_SIGNAL
    # we have an open input dev now...
    while True:
        try:
            e = read_event(input_dev_fd)
        except OSError: # Signal lost?
            input_dev_fd.close()
            input_dev_fd = None
            return NO_SIGNAL
        if e:
            if e.type == EV_ABS:
                input_axes[e.code] = e.value
            if e.type == EV_KEY and e.code in BUTTONS_FLIP:
                input_state_flip = bool(e.value)
        else:
            break
    # Find the sum of the x and y:
    x = sum([ input_axes[axis] for axis in AXES_X] )
    y = sum([ input_axes[axis] for axis in AXES_Y] )
    x = min(x,128)
    x = max(x,-128)
    y = min(y,128)
    y = max(y,-128)
    return ControlPosition(x, y, input_state_flip, True)
        
 
def main(): 
    while True:
        print(str(read_controller()))
        time.sleep(0.05)

if __name__ == '__main__':
    main()    
