# ProposalFlow

> Version 1.0 (28 Mar 2016)
>
> Contributed by Bumsub Ham (bumsub.ham@inria.fr) and Minsu Cho (minsu.cho@inria.fr).

This code is written in MATLAB, and implements the ProposalFlow and its benchmark in [1]. For the RSF dataset, see our project page: 

# Usage #1: Benchmark for ProposalFlow
  We use the RSF dataset (included) to evaluate sparse and dense versions of ProposalFlow.

## Dependencies
  - Download [VLFeat] (http://www.vlfeat.org/) and [MatConvNet] (http://www.vlfeat.org/matconvnet/).
  - Download the following source codes of object proposal or other proposal methods you would like to test:
    - [EdgeBox] (https://github.com/pdollar/edges);
    - [SelectiveSearch] (http://koen.me/research/selectivesearch/);
    - [Randomized Prim’s] (https://github.com/smanenfr/rp#rp);
    - [Multiscale Combinatorial Grouping] (https://github.com/jponttuset/mcg);
  - Download a ImageNet [Caffe Reference model] (http://www.vlfeat.org/matconvnet/pretrained/) in `./feature/cnn-model/`. 

## Setup
  - Set the file path of these libraries in `set_path.m`.
  
## Run  
  
  demo.m;

### Main functions
  
  
  

  
# References

[1] B. Ham, M. Cho, C. Schmid, and J. Ponce,  "Proposal Flow", IEEE Conference on Computer Vision and Pattern Recognition (CVPR), 2016.
