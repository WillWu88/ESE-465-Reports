import serial
from Tkinter import *


def serialConfig(comPort):
    port_addr = "COM" + str(comPort)
    sp = serial.Serial(port=port_addr, baudrate = 9600)
    return sp

# example config: 20 00 20 00 20 00 20 00 20 00 20 00 20 00 20 00 20 00 20 00 20 00 20 00 20 00
# bit position:    0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25

# input: 16-bit coeff in 2.14
def ParseInput(bandAtten):
    byte_1 = chr(bandAtten / 100)
    byte_2 = chr(bandAtten % 100)
    return [byte_1, byte_2]

# input: fraction
def fractionConv(atten):
    return atten * 16384

class Application(Frame):
    
    def say_hi(self):
        print "hi there, everyone!"
    
    def reset_slider(self):
        for slider in self.sliders:
            slider.set(50)
            
    def set_quiet(self):
        for slider in self.sliders:
            slider.set(5)
            
    def set_loud(self):
        for slider in self.sliders:
            slider.set(100)
            
    def base_boost(self):
        for idx, slider in enumerate(self.sliders):
            if idx < 3:
                slider.set(100)
            else:
                slider.set(25)

    def createWidgets(self):
        self.sliders = []
        for num in range(13):
            newSlider = Scale(self, from_=100, to=0, length=200)
            newSlider.pack({"side": "left"})
            newSlider.set(50)
            self.sliders.append(newSlider)
        
        self.RESET = Button(self)
        self.RESET["command"] = self.reset_slider
        self.RESET["text"] = "Reset Sliders"
        self.RESET.pack({"side": "left"})
        
        self.GETVAL = Button(self)
        self.GETVAL["command"] = self.sendValues
        self.GETVAL["text"] = "Send"
        self.GETVAL.pack()
        
        self.BASEBOOST = Button(self)
        self.BASEBOOST["command"] = self.base_boost
        self.BASEBOOST["text"] = "!BASE!"
        self.BASEBOOST.pack({"side": "bottom"})
        
        self.ALLBOOST = Button(self)
        self.ALLBOOST["command"] = self.set_loud
        self.ALLBOOST["text"] = "!LOUD!"
        self.ALLBOOST.pack({"side":"bottom"})
        
        self.QUIET = Button(self)
        self.QUIET["command"] = self.set_quiet
        self.QUIET["text"] = "~shhh~"
        self.QUIET.pack({"side":"bottom"})
        
    def get_values(self):
        for idx, slider in enumerate(self.sliders):
            if len(self.slider_val) < 13:
                self.slider_val.append(float(slider.get())/100)
            else:
                self.slider_val[idx] = float(slider.get())/100

    def serialConfig(self, comPort):
        port_addr = "COM" + str(comPort)
        self.sp = serial.Serial(port=port_addr, baudrate = 9600)
        
    def round_values(self, atten):
        value = int(atten * 16384)
        if atten > 0.02:
            value = hex(value)
            byte_1 = chr(int(value[2:4],16))
            byte_2 = chr(int(value[4:6],16))
        else:
            byte_1 = ("\x00")
            byte_2 = ("\x00")
        return [byte_1, byte_2]
        
    def prep_values(self):
        self.get_values()
        if len(self.slider_val) >= 13:
            for idx, number in enumerate(self.slider_val):
                rounded_vals = self.round_values(number)
                self.send_vals[idx * 2] = rounded_vals[0]
                self.send_vals[idx * 2 + 1] = rounded_vals[1]
        print(self.send_vals)
        
    def sendValues(self):
        self.prep_values()
        print("Sending")
        if (self.sp.is_open):
            print("Serial Port is open. Writing....")
            for idx in range(32):
                if idx < 26:
                    self.sp.write(self.send_vals[idx])
                else:
                    self.sp.write("\x00")
        else:
            print("Serial Port not open!")
        print("Done")
        
    def __init__(self, master=None):
        Frame.__init__(self, master)
        self.slider_val = []
        self.send_vals = range(26)
        self.pack()
        self.createWidgets()
        self.serialConfig(20)
        

root = Tk()
app = Application(master=root)
app.mainloop()
root.destroy()