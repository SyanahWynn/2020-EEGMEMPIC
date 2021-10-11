#!/usr/bin/env python
# -*- coding: utf-8 -*-
# My functions.

from psychopy import core, visual, event, clock
import csv, os, time
from psychopy import prefs
prefs.general['audioLib'] = ['pyo']
from psychopy import sound
from random import shuffle
import random

## Function section
def getCharacter(window, question="Press any key to continue"):
	message = visual.TextStim(window, text=question)
	message.draw()
	window.flip()
	c = event.waitKeys()
	if c:
		return c[0]
	else:
		return ''



def introScreen(window, question="Press any key to continue"):
    message = visual.TextStim(window, text=question)
    message.draw()
    window.flip()
    core.wait(3.000)
    c = event.waitKeys()
    if c:
        return c[0]
    else:
        return ''



def blankScreen(window, wait = 1.0, text = ""):
	"""Wait for a specified amount of seconds."""
	message = visual.TextStim(window, text=text)
	message.draw()
	window.flip()
	c = event.waitKeys(maxWait=wait, keyList = [])


def restEEG(window, waitTime, nrtimes):
     ## VARIABLES ##
    waitTime = 2.000 # 1 min
    loops = 2 # amount of eyes opene eyes closed loops

    # loop over the loops
    for loop in xrange(nrtimes):
        # show instruction to participant for a certain amount of seconds
        tone = sound.Sound(value='C', secs=0.5, octave=4, sampleRate=44100, bits=16)
        tone.setVolume(0.5)
        tone.play()
        message = visual.TextStim(window, text="open uw ogen")
        message.draw()
        window.flip()
        core.wait(waitTime)
        # show instruction to participant for a certain amount of seconds
        message = visual.TextStim(window, text="sluit uw ogen")
        message.draw()
        window.flip()
        core.wait(waitTime)


def openDataFile(ppn=0):
	"""open a data file for output with a filename that nicely uses the current date and time"""
	directory= "data"
	if not os.path.isdir(directory):
		os.mkdir(directory)
	try:
		filename="{}/{}_{}.dat".format(directory, ppn, time.strftime('%Y-%m-%dT%H:%M:%S')) # ISO compliant
		datafile = open(filename, 'wb')
	except Exception as e:
		filename="{}/{}_{}.dat".format(directory, ppn, time.strftime('%Y-%m-%dT%H.%M.%S')) #for MS Windows
		datafile = open(filename, 'wb')
	return datafile

def openCSVFile(ppn=0):
	"""open a data file for output with a filename that nicely uses the current date and time"""
	directory= "data"
	if not os.path.isdir(directory):
		os.mkdir(directory)
	try:
		filename="{}/{}_{}.csv".format(directory, ppn, time.strftime('%Y-%m-%dT%H:%M:%S')) # ISO compliant
		datafileCSV = open(filename, 'wb')
	except Exception as e:
		filename="{}/{}_{}.csv".format(directory, ppn, time.strftime('%Y-%m-%dT%H.%M.%S')) #for MS Windows
		datafileCSV = open(filename, 'wb')
	return datafileCSV


def getYN(window, question="Y or N"):
	"""Wait for a maximum of two seconds for a y or n key."""
	message = visual.TextStim(window, text=question)
	message.draw()
	window.flip()
	c = event.waitKeys(maxWait=2.0, keyList = ['y', 'n'])
	if c:
		return c[0]
	else:
		return ''

def getString(window, question="Type: text followed by return"):
	string = ""
	while True:
		message = visual.TextStim(window, text=question+"\n"+string)
		message.draw()
		window.flip()
		c = event.waitKeys()
		if c[0] == 'return':
			return string
		else:
			string = string + c[0]

lookup = {
          'space': ' ',
    'exclamation': '!',
    'doublequote': '"',
          'pound': '#',
         'dollar': '$',
        'percent': '%',
      'ampersand': '&',
     'apostrophe': '\'',
      'parenleft': '(',
     'parenright': ')',
       'asterisk': '*',
           'plus': '+',
          'comma': ',',
          'minus': '-',
         'period': '.',
          'slash': '/',
          'colon': ':',
      'semicolon': ';',
           'less': '<',
          'equal': '=',
        'greater': '>',
       'question': '?',
             'at': '@',
    'bracketleft': '[',
      'backslash': '\\',
   'bracketright': ']',
    'asciicircum': '^',
     'underscore': '_',
      'quoteleft': '`',
      'braceleft': '{',
            'bar': '|',
     'braceright': '}',
     'asciitilde': '~',
   'num_multiply': '*',
        'num_add': '+',
  'num_separator': ',',
   'num_subtract': '-',
    'num_decimal': '.',
     'num_divide': '/',
          'num_0': '0',
          'num_1': '1',
          'num_2': '2',
          'num_3': '3',
          'num_4': '4',
          'num_5': '5',
          'num_6': '6',
          'num_7': '7',
          'num_8': '8',
          'num_9': '9',
      'num_equal': '=',
}

def getString2(window, question="Type: text followed by return"):
	"""Return a string typed by the user, much improved version."""
	string = ''
	capitalizeNextCharacter = False
	while True:
		message = visual.TextStim(window, text=question+"\n"+string)
		message.draw()
		window.flip()
		c = event.waitKeys()[0]
		if len(c)==1:
			# add normal characters (charcters of length 1) to the string
			if capitalizeNextCharacter:
				string += c.capitalize()
				capitalizeNextCharacter = False
			else:
				string += c
		elif c == 'backspace' and len(string)>0:
			# shorten the string
			string = string[:-1]
		elif c == 'escape':
			# return no string
			return ''
		elif c == 'lshift' or  c == 'rshift':
			# pressing shift will cause precise one character to be capitalized
			capitalizeNextCharacter = True
		elif c == 'return' or c == 'num_enter':
			# return the string typed so far
			return string
		elif c in lookup.keys():
			# add special characters to the string
			string += lookup[c]
		else:
			# ignore other special characters
			pass


def showText(window, inputText="Text"):
	message = visual.TextStim(window, alignHoriz="center", text=inputText)
	message.draw()
	window.flip()




def getStimulusInputFile(fileName):
	"""Return a list of trials. Each trial is a list of values."""
	# prepare a list of rows
	rows = []
	# open the file
	inputFile = open(fileName, 'rb')
	# connect a csv file reader to the file
	reader = csv.reader(inputFile, delimiter=',')
	# discard the first row, containing the column labels
	reader.next()
	# read every row as a list of values and append it to the list of rows
	for row in reader:
		rows.append(row)
	inputFile.close()
	return rows

def getStimulusInputFileDict(fileName):
	"""Return a list of trials. Each trial is a dict."""
	# prepare a list of rows
	rows = []
	# open the file
	inputFile = open(fileName, 'rb')
	# connect a csv dict file reader to the file
	reader = csv.DictReader(inputFile, delimiter=';')
	# read every row as a dict and append it to the list of rows
	for row in reader:
		rows.append(row)
	inputFile.close()
	return rows


def debugLog(text):
	tSinceMidnight = clock.getTime()%86400
	tSinceWholeHour = tSinceMidnight % 3600
	minutes = tSinceWholeHour / 60
	hours = tSinceMidnight / 3600
	seconds = tSinceMidnight % 60
	#print("log {:02d}:{:02d}:{:2.3f}: {}".format(int(hours), int(minutes), seconds, text))
	print("log {:02d}:{:02d}:{:f}: {}".format(int(hours), int(minutes), seconds, text))


def MakeStimList(ppn):
    directory= "data"
    if not os.path.isdir(directory):
        os.mkdir(directory)
    images = os.listdir('C:/Users/s4621956/Python/pics/Resized_all')
    shuffle(images)
    prac_images = os.listdir('C:/Users/s4621956/Python/pics/prac')
    shuffle(prac_images)
    prac_enc = prac_images[:20]
    prac_ret = prac_images[10::]
    shuffle(prac_ret)
    shuffle(prac_enc)
    pracenc = open('%s/%s_prac_enc.csv' %(directory,ppn),'w')
    for item in prac_enc:
        pracenc.write("%s\n" % item)
    pracenc.close()
    pracret = open('%s/%s_prac_ret.csv' %(directory,ppn),'w')
    for item in prac_ret:
        pracret.write("%s\n" % item)
    pracret.close()

    trials = len(images)/2
    imagelist_old = images[:trials]
    imagelist_new = images[trials::]
    #make list old
    imagelist = open('%s/%s_imagelist_old.csv' %(directory,ppn),'w')
    for item in imagelist_old:
        imagelist.write("%s\n" % item)
    imagelist.close()
    #make list new
    imagelist = open('%s/%s_imagelist_new.csv' %(directory,ppn), 'w')
    for item in imagelist_new:
        imagelist.write("%s\n" % item)
    imagelist.close()
    totalimages_enc = prac_enc + imagelist_old
    #return imagelist_old, prac_enc, totalimages_enc
    return totalimages_enc, imagelist_old


def RetrieveAdd(fileName1,fileName2,fileName3):
    with open(fileName1,'r') as input:
        prac_ret = []
        for row in input:
            prac_ret.append(row[:-1])
    input.close()
    with open(fileName2,'r') as input:
        images_old = []
        for row in input:
            images_old.append(row[:-1])
    input.close()
    with open(fileName3,'r') as input:
        images_new = []
        for row in input:
            images_new.append(row[:-1])
    input.close()

    totalimages_ret = images_old + images_new
    shuffle(totalimages_ret)
    shuffle(totalimages_ret)
    for i in range(3,len(totalimages_ret)-1):
        accept = 0
        j = 0
        if totalimages_ret[i-1] in images_old and totalimages_ret[i-2] in images_old and totalimages_ret[i-3] in images_old:
            if totalimages_ret[i] in images_old:
                while accept != 1:
                    if totalimages_ret[i+j] in images_new:
                        a = totalimages_ret[i]
                        totalimages_ret[i] = totalimages_ret[i+j]
                        totalimages_ret[i+j] = a
                        accept = 1
                    else:
                        accept = 0
                        j += 1
            if totalimages_ret[i] in images_new:
                pass
        if totalimages_ret[i-1] in images_new and totalimages_ret[i-2] in images_new and totalimages_ret[i-3] in images_new:
            if totalimages_ret[i] in images_new:
                while accept != 1:
                    if totalimages_ret[i+j] in images_old:
                        a = totalimages_ret[i]
                        totalimages_ret[i] = totalimages_ret[i+j]
                        totalimages_ret[i+j] = a
                        accept = 1
                    else:
                        accept = 0
                        j += 1
            if totalimages_ret[i] in images_old:
                pass
        else:
            pass


    totalimages_ret = prac_ret + totalimages_ret
    return totalimages_ret, images_old, images_new
