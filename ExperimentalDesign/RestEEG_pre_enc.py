from rusocsci import buttonbox
from psychopy import prefs
prefs.general['audioLib'] = ['pyo']
from psychopy import sound
from psychopy import core, visual, event, sound
win = visual.Window([800,600], fullscr=True, winType='pyglet',allowGUI=False)

#!!! REST EEG BEFORE ENCODING!!!

EEG = 1
if EEG == 1:
    bb = buttonbox.Buttonbox()

number_blocks = 4
block_dur = 60.0
tone = sound.Sound(700,secs=0.5)
c = []

message = visual.TextStim(win,text="Welkom. \n\nWe beginnen met een rustmeting van het EEG signaal. Blijft u rustig zitten en volg de instructies op het scherm (sluiten/open uw ogen). Als de instructies veranderen, wordt u gewaarschuwd door een geluid.")
message.draw()
win.flip()
event.waitKeys()

bb.sendMarker(val=1)
core.wait(0.01)
bb.sendMarker(val=0)

startTime = core.getTime()
endTime = startTime + (number_blocks*block_dur)


for block in range(1,number_blocks+1):
    tone.play()
    if block%2 != 0: #blocks 1 and 3
        if block == 1:
            bb.sendMarker(val=2)
            core.wait(0.001)
            bb.sendMarker(val=0)
        elif block == 3:
            bb.sendMarker(val=2)
            core.wait(0.001)
            bb.sendMarker(val=0)
        while core.getTime() > (startTime+((block-1)*block_dur)) and core.getTime() < (startTime+(block*block_dur)) and c == []:
            message = visual.TextStim(win, text="Open uw ogen")
            message.draw()
            win.flip()
            core.wait(1.0)
            c = event.getKeys(['escape'])
    elif block%2 == 0: #blocks 2 and 4
        if block == 2:
            bb.sendMarker(val=3)
            core.wait(0.001)
            bb.sendMarker(val=0)
        elif block == 4:
            bb.sendMarker(val=3)
            core.wait(0.001)
            bb.sendMarker(val=0)
        while core.getTime() > (startTime+((block-1)*block_dur)) and core.getTime() < (startTime+(block*block_dur)) and c == []:
            message = visual.TextStim(win, text="Sluit uw ogen")
            message.draw()
            win.flip()
            core.wait(1.0)
            c = event.getKeys(['escape'])
        if block == 4:
            tone.play()
            message = visual.TextStim(win,text="Open uw ogen. Dit is het einde van de rustmeting.")
            message.draw()
            win.flip()
            core.wait(5.000)

bb.sendMarker(val=9)
core.wait(0.001)
bb.sendMarker(val=0)
print(core.getTime()- startTime)
