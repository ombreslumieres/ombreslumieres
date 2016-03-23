#!/usr/bin/env python
from tkColorChooser import askcolor
from twisted.internet import reactor
from twisted.internet import tksupport
import Tkinter
from txosc import osc
from txosc import dispatch
from txosc import async

button = None
OSC_SEND_PORT = 31337
OSC_SEND_HOST = 'localhost'
osc_sender = None

class UDPSenderApplication(object):
    """
    Example that sends UDP messages.
    """
    def __init__(self, port, host="127.0.0.1"):
        self.port = port
        self.host = host
        self.client = async.DatagramClientProtocol()
        self._client_port = reactor.listenUDP(0, self.client)

    def _send(self, element):
        # This method is defined only to simplify the example
        self.client.send(element, (self.host, self.port))
        print("Sent %s to %s:%d" % (element, self.host, self.port))
        
    def send_color(self, red, green, blue):
        self._send(osc.Message("/color", red, green, blue))


def set_color():
    global button
    global osc_sender
    (triple, hexstr) = askcolor()
    if hexstr:
        print(hexstr)
        button.config(bg=hexstr, activebackground=hexstr,
                activeforeground='#ffcccc')
        r, g, b = triple
        osc_sender.send_color(r, g, b)


def run():
    global button
    global osc_sender
    osc_sender = UDPSenderApplication(OSC_SEND_PORT, OSC_SEND_HOST)
    root = Tkinter.Tk()
    root.wm_title("Color picker osc.udp://%s:%s" % (OSC_SEND_HOST, OSC_SEND_PORT))
    button = Tkinter.Button(root, text='Set Background Color',
            command=set_color)
    button.config(height=3, font=('times', 20, 'bold'))
    button.pack(expand=Tkinter.YES, fill=Tkinter.BOTH)
    tksupport.install(root)
    reactor.run()
    # root.mainloop()


if __name__ == "__main__":
    run()
