# Perception [![build status](https://gitlab.com/sashimiapp-public/Perception/badges/master/build.svg)](https://gitlab.com/sashimiapp-public/Perception/commits/master) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Perception is a set of OpenCV routines made available in Objective-C. This framework mostly exists because Swift doesn't support calling to C++. 

No particular attention is paid to maximising data marshalling performance – NSArrays of NSNumbers are used like an animal (mostly because of laziness and because the data marshalling is a small fraction of runtime of the methods made available here).
