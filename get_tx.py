#!/usr/bin/python
#coding=utf-8

import sys

fname = sys.argv[1]
start = int(sys.argv[2]) * 60 
running = int(sys.argv[3]) * 60 
sleep = int(sys.argv[4]) * 60

try:
    f = open(fname)
    
    isRounded = 0

    addUpTime = start

    for line in f:
        sp = line.split(',')
        time = int(sp[0])

        if time == 5:
            isRounded = isRounded + 1

        if isRounded >= 2 and time == 5:
            addUpTime = addUpTime + running + sleep

        time = time + addUpTime
        if int(sp[1].split(' ')[2]) != 0 :
            printString=str(time)
            for s in sp[1:]:
                printString = printString + "," + s
            print(printString)

    f.close()

except IOError:
    print >> sys.stderr, "Fail to read file %s" % (fname)
