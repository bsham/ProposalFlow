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

## Setup & Run
  - Set the file path of these libraries in `set_path.m`, and run
  
  ```
  ./demo.m
  ```

# Usage #2: Dense Flow Fiels
  If you just want to compute dense flow fields such as SIFTFlow [2], run

  ```
  ./_demo-DenseFlow/demo_DenseFlow.m
  ```


# Main functions
  - `do_prepKP_RSF.m`: load keypoint annotations and save them as a file.
  - `do_ext_proposal.m`: extract object proposals from images.
  - `do_ext_active_proposal.m`: extract valid object proposals (object proposals near object bounding boxes).
  - `do_makeGT.m`: automatically estimate ground-truth matches for valid object proposals using the keypoint annotations and TPS warping.
  - `do_ext_feature.m`: extract feature descriptors for all object proposals.
  - `do_matching.m`: compute proposal flow (matching all object proposals between two images).
  - `do_evaluation.m`: evaluate the PCR and mIoU@k performance of proposal flow.
  - `do_evaluation_avg.m`: evaluate proposal flow (averaging performance per feature).
  - `do_dense_flow.m`: compute dense flow fields using proposal flow.
  - `do_dense_flow_evaluation.m`: evaluating dense flow field (PCK performance).

### Others
  - `do_readKP.m`: visualize annotations.
  
  
# Notes

  - The code is provided for academic use only. Use of the code in any commercial or industrial related activities is prohibited. 
  - If you use our code or dataset, please cite the paper. 

```
@InProceedings{ham2016,
author = {Bumsub Ham and Minsu Cho and and Cordelia Schmid and Jean Ponce},
title = {Robust Image Filtering using Joint Static and Dynamic Guidance},
booktitle = {Proceedings of the IEEE Conference on Computer Vision and Pattern Recognition (CVPR), IEEE},
year = {2016}
}
```

  - This code uses the author provided source codes for generating object proposals: SelectiveSearch, Randomized Prim’s, EdgeBox, Multiscale Combinatorial Grouping, [Sliding Window, Uniform Sampling, and Gaussian Sampling] (https://github.com/hosang/detection-proposals).

  - For CNN features, this code uses a ImageNet Caffe Reference model: AlexNet trained on ILSVRC 2012, with a minor variation from the version as described in ImageNet classification with deep convolutional neural networks by Krizhevsky et al. in NIPS 2012.


  
# References

[1] B. Ham, M. Cho, C. Schmid, and J. Ponce,  "Proposal Flow", *IEEE Conference on Computer Vision and Pattern Recognition* (CVPR), 2016.

[2] C. Liu, J. Yuen, and A. Torralba, "Sift flow: Dense correspondence across scenes and its applications", *IEEE Trans. Pattern Anal. Mach. Intell.* (TPAMI), 2011.
