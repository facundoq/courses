import numpy as np

from cs231n.layers import *
from cs231n.fast_layers import *
from cs231n.layer_utils import *


class ThreeLayerConvNet(object):
  """
  A three-layer convolutional network with the following architecture:

  conv - relu - 2x2 max pool - affine - relu - affine - softmax

  The network operates on minibatches of data that have shape (N, C, H, W)
  consisting of N images, each with height H and width W and with C input
  channels.
  """

  def __init__(self, input_dim=(3, 32, 32), num_filters=32, filter_size=7,
               hidden_dim=100, num_classes=10, weight_scale=1e-3, reg=0.0,
               dtype=np.float32):
    """
    Initialize a new network.

    Inputs:
    - input_dim: Tuple (C, H, W) giving size of input data
    - num_filters: Number of filters to use in the convolutional layer
    - filter_size: Size of filters to use in the convolutional layer
    - hidden_dim: Number of units to use in the fully-connected hidden layer
    - num_classes: Number of scores to produce from the final affine layer.
    - weight_scale: Scalar giving standard deviation for random initialization
      of weights.
    - reg: Scalar giving L2 regularization strength
    - dtype: numpy datatype to use for computation.
    """
    self.params = {}
    self.reg = reg
    self.dtype = dtype
    self.conv_param = {'stride': 1, 'pad': (filter_size - 1) / 2}

    # pass pool_param to the forward pass for the max-pooling layer
    self.pool_param = {'pool_height': 2, 'pool_width': 2, 'stride': 2}

    ############################################################################
    # TODO: Initialize weights and biases for the three-layer convolutional    #
    # network. Weights should be initialized from a Gaussian with standard     #
    # deviation equal to weight_scale; biases should be initialized to zero.   #
    # All weights and biases should be stored in the dictionary self.params.   #
    # Store weights and biases for the convolutional layer using the keys 'W1' #
    # and 'b1'; use keys 'W2' and 'b2' for the weights and biases of the       #
    # hidden affine layer, and keys 'W3' and 'b3' for the weights and biases   #
    # of the output affine layer.                                              #
    ############################################################################
    C,H,W=input_dim
    w1_shape=(num_filter,C,filter_size,filter_size)
    w1=np.random.randn(w1_shape)*weight_scale
    b1=np.zeros(num_filter)
    #conv output size
    conv_pad=self.conv_param['pad']
    conv_stride=self.conv_param['stride']
    conv_size=(num_filter,C,1+(H+2*conv_pad-filter_size)/stride,1+(W+2*conv_pad-filter_size)/stride)
    #max pool output size
    pool_height=self.pool_param['pool_height']
    pool_width=self.pool_param['pool_width']
    pool_stride=self.pool_param['stride']
    maxpool_height=(conv_size[2]-pool_height)/stride+1
    maxpool_width=(conv_size[3]-pool_width)/stride+1
    maxpool_size=(conv_size[0],conv_size[1],maxpool_height,maxpool_width)
    #affine 2
    w2=np.random.randn(np.prod(maxpool_size),hidden_dim)*weight_scale
    b2=np.zeros(hidden_dim)

    # affine 3
    w3=np.random.randn(hidden_dim,num_classes)*weight_scale
    b3=np.zeros(num_classes)

    self.params['W1']=w1
    self.params['b1']=b1
    self.params['W2']=w2
    self.params['b2']=b2
    self.params['W3']=w3
    self.params['b3']=b3

    ############################################################################
    #                             END OF YOUR CODE                             #
    ############################################################################

    for k, v in self.params.iteritems():
      self.params[k] = v.astype(dtype)


  def loss(self, X, y=None):
    """
    Evaluate loss and gradient for the three-layer convolutional network.

    Input / output: Same API as TwoLayerNet in fc_net.py.
    """
    W1, b1 = self.params['W1'], self.params['b1']
    W2, b2 = self.params['W2'], self.params['b2']
    W3, b3 = self.params['W3'], self.params['b3']

    # pass conv_param to the forward pass for the convolutional layer
    filter_size = W1.shape[2]
    conv_param = {'stride': 1, 'pad': (filter_size - 1) / 2}

    # pass pool_param to the forward pass for the max-pooling layer
    pool_param = {'pool_height': 2, 'pool_width': 2, 'stride': 2}

    scores = None
    ############################################################################
    # TODO: Implement the forward pass for the three-layer convolutional net,  #
    # computing the class scores for X and storing them in the scores          #
    # variable.                                                                #
    ############################################################################
    #conv - relu - 2x2 max pool - affine - relu - affine - softmax
    out1,cache1=conv_forward_naive(X, W1, b1, self.conv_param)
    out2,cache2=relu_forward(out1)
    out3,cache3=max_pool_forward_naive(out2,self.pool_param)
    out4,cache4=affine_forward(out3,W2,b2)
    out5,cache5=relu_forward(out4)
    out6,cache6=affine_forward(out5,W3,b3)

    scores=out6

    ############################################################################
    #                             END OF YOUR CODE                             #
    ############################################################################

    if y is None:
      return scores

    loss, grads = 0, {}
    ############################################################################
    # TODO: Implement the backward pass for the three-layer convolutional net, #
    # storing the loss and gradients in the loss and grads variables. Compute  #
    # data loss using softmax, and make sure that grads[k] holds the gradients #
    # for self.params[k]. Don't forget to add L2 regularization!               #
    ############################################################################
    loss,dout=softmax_loss(scores,y)
    ############################################################################
    #                             END OF YOUR CODE                             #
    ############################################################################

    return loss, grads


pass
