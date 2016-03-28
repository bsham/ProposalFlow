% Compile mex functions
mex -O features.cc
mex -O resize.cc
mex -O reduce.cc
mex -O fconv.cc -o fconv
