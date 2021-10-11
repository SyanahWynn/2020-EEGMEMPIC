#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
FamRecEEG task details

Encoding stimuli: 450 pictures
Encoding blocks: 2
Encoding stimulus time: 2 sec
Encoding fixation time: 1 sec
Encoding total duration: min 23.5 min
Retrieval stimuli: 900 words (450 old, 450 new)
Retrieval blocks: 3
Retrieval stimulus time: 2 sec
Retrieval fixation time: 1 sec
Retrieval confidence judgement time: 1.5 sec
Retrieval total duration: min 69 min
"""

from psychopy import core, clock, visual, event, sound
import csv, random
import my # import my own functions
import pip
import os
from rusocsci import buttonbox
from psychopy import prefs
prefs.general['audioLib'] = ['pyo']
from psychopy import sound

## Setup Section
win = visual.Window([800,600], fullscr=True, monitor="testMonitor", units='cm',allowGUI=False)
#win = visual.Window([800,600], fullscr=False, monitor="testMonitor")
EEG = 0
if EEG == 1:
    bb = buttonbox.Buttonbox()


#fixation cross
fixation = visual.ShapeStim(win,
    vertices=((0, -0.3), (0, 0.3), (0,0), (-0.3,0), (0.3, 0)),
    lineWidth=2,
    closeShape=False,
    lineColor='white'
)

# open data output file
ppn = my.getString(win, "Please enter participant number:")
gender = my.getString(win, "Please enter participant gender:")
age = my.getString(win, "Please enter participant age:")
datafile = my.openDataFile(ppn + "_ret")
datafileCSV = my.openCSVFile(ppn + "_ret")
libraryfile = my.openDataFile(ppn + "_ret" + "_library")
# connect it with a csv writer
writer = csv.writer(datafile, delimiter=";")
writerCSV = csv.writer(datafileCSV, delimiter=",")
tempwriter = csv.writer(libraryfile, delimiter=";")
# create output file header
writerCSV.writerow([
    "ppn",
    "gender",
    "age",
    "image",
    "OldNew_Classification",
    "OldNew_Response",
    "OldNew_RT",
    "OldNew_Accuracy",
    "Confidence_Response",
    "Confidence_RT",
    "Confidence_Rating",
    "fixationTime",
    ])
writer.writerow([
    "ppn",
    "gender",
    "age",
    "word",
    "Retrieval_Jitter",
    "OldNew_Classification",
    "OldNew_Response",
    "OldNew_RT",
    "OldNew_Accuracy",
    "Confidence_Response",
    "Confidence_RT",
    "Confidence_Rating",
    "fixationTime",
    ])
tempwriter.writerow([__file__])
for pkg in pip.get_installed_distributions():
    tempwriter.writerow([pkg.key, pkg.version])


#load allimages
totalimages_ret, images_old, images_new = my.RetrieveAdd('data/%s_prac_ret.csv' %ppn,'data/%s_imagelist_old.csv' %ppn,'data/%s_imagelist_new.csv' %ppn)

## Experiment Section
# show welcome screen
my.introScreen(win, "U krijgt straks weer woorden te zien op het scherm. Heeft u het woord in het eerste deel gezien (oud), drukt u op het pijltje naar links, heeft u het woord niet in het eerste deel gezien (nieuw), drukt u op het pijltje naar rechts. \n\noud <--\nnieuw -->")
my.introScreen(win, "Na het woord verschijnt een nieuw scherm. Op dit scherm wordt u gevraagd aan te geven hoe zeker u bent van uw voorgaande 'oud/nieuw' keuze. \n\nniet zeker   links\nbeetje zeker   beneden \nheel zeker   rechts")
startTime = clock.getTime() # clock is in seconds
i=0
while i < len(totalimages_ret):
    if i == 0 and EEG == 1:
        print("start practice")
        bb.sendMarker(val=99)
        core.wait(0.001)
        bb.sendMarker(val=0)
    if i == 20:
        my.blankScreen(win)
        answer = my.getCharacter(win, "Dit is het einde van het oefenblok, wilt u nog een keer oefenen? [j/n]")
        if answer[0] == "j":
            i=0
        elif answer[0] == "n" and EEG == 1:
            bb.sendMarker(val=50)
            core.wait(0.001)
            bb.sendMarker(val=0)
            core.wait(1.000)
    if i == 180 or i == 360 or i == 540 or i == 720:
        if EEG == 1:
            bb.sendMarker(val=90)
            core.wait(0.001)
            bb.sendMarker(val=0)
        my.blankScreen(win, wait = 60.000, text = "Pauze!")
        my.getCharacter(win, "druk op een knop om door te gaan")
        if EEG == 1:
            bb.sendMarker(val=91)
            core.wait(0.001)
            bb.sendMarker(val=0)


    # present fixation
    fixation.draw()
    win.flip()
    if EEG == 1 and i>19:
        bb.sendMarker(val=80)
        core.wait(0.001)
        bb.sendMarker(val=0)
    fixationTime = clock.getTime()
    core.wait(0.993) # note how the real time will be very close to a multiple of the refresh time


    if i < 20:
        imageStim = visual.SimpleImageStim(win, 'pics/prac/%s' %(totalimages_ret[i]))
    else:
        imageStim = visual.SimpleImageStim(win, 'pics/Resized_all/%s' %(totalimages_ret[i]))
    imageStim.draw()

    if totalimages_ret[i] in images_old:
       marker = 53
       classif = 1
    elif totalimages_ret[i] in images_new:
       marker = 55
       classif = 2
    else:
        classif = 0
    win.flip()
    if EEG == 1 and i>19:
        bb.sendMarker(val=marker)
        core.wait(0.001)
        bb.sendMarker(val=0)
    textTime = clock.getTime()
    key = event.waitKeys(2.00, keyList=['left', 'right','escape'])  #how long to wait for response?
    if key != None:
        responseTime = clock.getTime()
        if EEG == 1 and key[0] == 'left':
            marker = 63
        elif EEG == 1 and key[0] == 'right':
            marker = 65
    else:
        responseTime = textTime
        if EEG == 1:
            marker = 68
    if EEG == 1 and i>19:
        bb.sendMarker(val=marker)
        core.wait(0.001)
        bb.sendMarker(val=0)
    while clock.getTime() < (textTime + 2.00):
        pass
    oldNewTime = clock.getTime()

    #present confidence judgement screen if there was an old/new response
    if key != None:
        visual.TextStim(win, text="Hoe zeker?").draw()
        win.flip()
        if EEG == 1 and i>19:
            bb.sendMarker(val=70)
            core.wait(0.001)
            bb.sendMarker(val=0)
        conf = event.waitKeys((1.500), keyList=['left', 'down', 'right', 'escape'])
        if conf != None:
            conf_rt = clock.getTime()
            if EEG == 1 and conf[0] == 'left':
                marker = 73
            if EEG == 1 and conf[0] == 'down':
                marker = 75
            elif EEG == 1 and conf[0] == 'right':
                marker = 77
        else:
            conf_rt = oldNewTime
            if EEG == 1:
                marker = 78
        if EEG == 1 and i>19:
            bb.sendMarker(val=marker)
            core.wait(0.001)
            bb.sendMarker(val=0)
        while clock.getTime() < (oldNewTime+ 1.500):
            pass
    else:
        conf = []
        conf.append("")
        conf_rt = oldNewTime

    # write result to data file
    if key==None:
        key=[]
        key.append("")
    if conf==None:
        conf=[]
        conf.append("")



    if ((totalimages_ret[i] in images_old) and key[0] == 'left'): #old & old
        acc = 11 #hit
    elif ((totalimages_ret[i] in images_old) and key[0] == 'right'): #old & new
        acc = 12 #miss
    elif ((totalimages_ret[i] in images_new) and key[0] == 'left'): #new & old
        acc = 21 # false alarm
    elif ((totalimages_ret[i] in images_new) and key[0] == 'right'): #new & new
        acc = 22 #correct rejection
    else:
        acc = 99 # no response

    if (key[0] == 'left' and conf[0] == 'left'): #old & 1
        Confidence_Rating = 11 #not sure old
    elif (key[0] == 'left' and conf[0] == 'down'): #old & 2
        Confidence_Rating = 12 #bit sure old
    elif (key[0] == 'left' and conf[0] == 'right'): #old & 3
        Confidence_Rating = 13 # very sure old
    elif (key[0] == 'right' and conf[0] == 'left'): #new & 1
        Confidence_Rating = 21 #not sure new
    elif (key[0] == 'right' and conf[0] == 'down'): #new & 2
        Confidence_Rating = 22 #bit sure new
    elif (key[0] == 'right' and conf[0] == 'right'): #new & 3
        Confidence_Rating = 23 # very sure new
    else:
        Confidence_Rating = 99 # no response


    print("{}, image: {},{}, key: {} {} {} {} acc: {} {}".format( i, totalimages_ret[i], classif,  key, responseTime - textTime, conf, conf_rt - oldNewTime, acc, Confidence_Rating) )


    writer.writerow([
        ppn,
        gender,
        age,
        totalimages_ret[i],
        classif,
        key[0],
        "{:.3f}".format(responseTime - textTime),
        acc,
        conf[0],
        "{:.3f}".format(conf_rt - oldNewTime),
        Confidence_Rating,
        "{:.3f}".format(fixationTime - startTime),
        ])
    writerCSV.writerow([
        ppn,
        gender,
        age,
        totalimages_ret[i],
        classif,
        key[0],
        "{:.3f}".format(responseTime - textTime),
        acc,
        conf[0],
        "{:.3f}".format(conf_rt - oldNewTime),
        Confidence_Rating,
        "{:.3f}".format(fixationTime - startTime),
        ])

    if key[0]=='escape' or conf[0] == 'escape':
        break
    i = i+1
datafile.close()
datafileCSV.close()

if EEG == 1:
    bb.sendMarker(val=93)
    core.wait(0.001)
    bb.sendMarker(val=0)

# show goodbye screen
my.showText(win, "Einde van het experiment \n\nBedankt voor het meedoen!")
core.wait(2.000)

## Closing Section
win.close()
core.quit()
