#!/usr/bin/env python

from decimal import *

getcontext().prec = 2

f = open( '/proc/sys/fs/file-nr' )

contents = f.read()

f.close()

metrics = contents.split("\t")

total_used = Decimal(metrics[0].strip()) - Decimal(metrics[1].strip())
percent_used = ( total_used / Decimal(metrics[2].strip()) ) * 100

if percent_used > 90:
    check = "err"
    msg = "failure imminent"
if percent_used > 70:
    check = "warn"
    msg = "dangerously high"
else:
    check = "ok"
    msg = "okay"

print "status %s %s" % ( check, msg )
print "metric used int %s" % metrics[0].strip()
print "metric freeable int %s" % metrics[1].strip()
print "metric max int %s" % metrics[2].strip()
print "metric percent_used int %s" % percent_used
