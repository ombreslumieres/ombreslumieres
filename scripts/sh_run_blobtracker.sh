#!/bin/bash
PROCESSINGDIR=~/soft/processing-3.0.2
PROCESSINGBIN=${PROCESSINGDIR}/processing-java
PROJECTDIR=~/src/encreslumieres
SKETCH=${PROJECTDIR}/prototypes/camtest
OUTPUTDIR=/tmp/processing-${USER}
${PROCESSINGBIN} --sketch=${SKETCH} --output=${OUTPUTDIR} --force --build
${PROCESSINGBIN} --sketch=${SKETCH} --output=${OUTPUTDIR} --force --run
