#!/bin/bash
# g++ -o out showcamera.cpp `pkg-config --libs --cflags opencv`
g++ -o out videocap.cpp `pkg-config --libs --cflags opencv`

