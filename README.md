# Perception [![build status](https://gitlab.com/sashimiapp-public/Perception/badges/master/build.svg)](https://gitlab.com/sashimiapp-public/Perception/commits/master) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Perception is a set of OpenCV routines made available in Objective-C. This framework mostly exists because Swift doesn't support calling to C++. 

No particular attention is paid to maximising data marshalling performance – NSArrays of NSNumbers are used like an animal (mostly because of laziness and because the data marshalling is a small fraction of runtime of the methods made available here).

### How the embedded OpenCV binary was built

The following steps were roughly speaking involved in building the OpenCV macOS binary that's statically linked into this framework, not automated at the moment to any extent:

1. git clone git@github.com:opencv/opencv.git
   - The commit built is d8425d88816ef7dbc9c8e5fa4cce407c7cf7a64e (this specific commit in the 3.2.0 development series adds some APIs I needed).

2. git clone git@github.com:opencv/opencv_contrib.git
   - The tag built is 3.2.0.

3. Build opencv:

```
cd opencv
mkdir build
cmake -DBUILD_SHARED_LIBS=OFF -DWITH_IPP=OFF -DOPENCV_ENABLE_NONFREE=ON -DOPENCV_EXTRA_MODULES_PATH=/Users/mz2/Projects/opencv_contrib/modules ../
```

4. Copy libraries and include directories in place.
