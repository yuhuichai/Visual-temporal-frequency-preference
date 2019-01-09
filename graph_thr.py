#!/usr/bin/env python
import numpy as np
import nws_tools
import scipy.io as scio
data = scio.loadmat('graph.mat')
nws = data['mean_graph_all']
nws_tools.thresh_nws(nws,span_tree=True)

