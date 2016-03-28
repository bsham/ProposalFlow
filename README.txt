== Matlab demo code for ProposalFlow v1.0 (2016-03-24) ==

Contributed by Bumsub Ham (bumsub.ham@inria.fr) and Minsu Cho (minsu.cho@inria.fr)

Usage #1: 

- Download VLFeat (http://www.vlfeat.org/) and MatConvNet (http://www.vlfeat.org/matconvnet/).
- Download the following source code of object proposals or other proposal methods you would like to test:
	EdgeBox (https://github.com/pdollar/edges);
	SelectiveSearch (http://koen.me/research/selectivesearch/);
	Randomized Prim’s (https://github.com/smanenfr/rp#rp);
	Multiscale Combinatorial Grouping (https://github.com/jponttuset/mcg);
- Set the file path of these libraries in “set_path.m”. 
- Download a ImageNet Caffe Reference model (http://www.vlfeat.org/matconvnet/pretrained/) in the following directory: 
	“./feature/cnn-model/“
- Run “demo_BM.m” in MATLAB for evaluating sparse and dense ProposalFlow with the RSF dataset.

* main functions
(1) do_prepKP_RSF: load keypoint annotations and save them as a file.
(2) do_ext_proposal: extract object proposals from images.
(3) do_ext_active_proposal: extract valid object proposals (object proposals near object bounding boxes).
(4) do_makeGT: automatically estimate ground-truth matches for valid object proposals using the keypoint annotations and TPS warping.
(5) do_ext_feature: extract feature descriptors for all object proposals.
(6) do_matching: compute proposal flow (matching all object proposals between two images).
(7) do_evaluation: evaluate the PCR and mIoU@k performance of proposal flow.
(8) do_evaluation_avg: evaluate proposal flow (averaging performance per feature).
(9) do_dense_flow: compute dense flow fields using proposal flow.
(10) do_dense_flow_evaluation: evaluating dense flow field (PCK performance).

* others
do_readKP: visualize annotations

Usage #2:

- If you just want to compute dense flow fields such as SIFTFlow,  
- Run “./_demo-DenseFlow/demo_DenseFlow.m” in MATLAB. 

Notes:

* The code is provided for academic use only. Use of the code in any commercial or industrial related activities is prohibited. 
* If you use our code or dataset, please cite the paper. 

@InProceedings{ham2016,
author = {Bumsub Ham and Minsu Cho and and Cordelia Schmid and Jean Ponce},
title = {Robust Image Filtering using Joint Static and Dynamic Guidance},
booktitle = {Proceedings of the IEEE Conference on Computer Vision and Pattern Recognition (CVPR), IEEE},
year = {2016}
}

* This code uses the author provided source codes for generating object proposals: SelectiveSearch, Randomized Prim’s, EdgeBox, Multiscale Combinatorial Grouping, Sliding Window, Uniform Sampling, and Gaussian Sampling.

* For CNN features, this code uses a ImageNet Caffe Reference model: AlexNet trained on ILSVRC 2012, with a minor variation from the version as described in ImageNet classification with deep convolutional neural networks by Krizhevsky et al. in NIPS 2012.
  

If you have any questions, please contact: Bumsub Ham (bumsub.ham@inria.fr).

