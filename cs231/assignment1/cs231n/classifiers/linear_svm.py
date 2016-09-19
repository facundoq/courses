import numpy as np
from random import shuffle

def svm_loss_naive(W, X, y, reg):
  """
  Structured SVM loss function, naive implementation (with loops).

  Inputs have dimension D, there are C classes, and we operate on minibatches
  of N examples.

  Inputs:
  - W: A numpy array of shape (D, C) containing weights.
  - X: A numpy array of shape (N, D) containing a minibatch of data.
  - y: A numpy array of shape (N,) containing training labels; y[i] = c means
    that X[i] has label c, where 0 <= c < C.
  - reg: (float) regularization strength

  Returns a tuple of:
  - loss as single float
  - gradient with respect to weights W; an array of same shape as W
  """
  dW = np.zeros(W.shape) # initialize the gradient as zero

  # compute the loss and the gradient
  num_classes = W.shape[1]
  num_train = X.shape[0]
  loss = 0.0
  for i in xrange(num_train):
    scores = X[i].dot(W)
    correct_class_score = scores[y[i]]
    for j in xrange(num_classes):
      if j == y[i]:
        continue
      margin = scores[j] - correct_class_score + 1 # note delta = 1
      if margin > 0:
        loss += margin
        dW[:,j]+=X[i]
        dW[:,y[i]]-=X[i]

  # Right now the loss is a sum over all training examples, but we want it
      # to be an average instead so we divide by num_train.
  loss /= num_train
  dW /= num_train
    
  # Add regularization to the loss.
  loss += 0.5 * reg * np.sum(W * W)

  #############################################################################
  # TODO:                                                                     #
  # Compute the gradient of the loss function and store it dW.                #
  # Rather that first computing the loss and then computing the derivative,   #
  # it may be simpler to compute the derivative at the same time that the     #
  # loss is being computed. As a result you may need to modify some of the    #
  # code above to compute the gradient.                                       #
  #############################################################################
  dW+=reg*W

  return loss, dW


def svm_loss_vectorized(W, X, y, reg):
  """
  Structured SVM loss function, vectorized implementation.

  Inputs and outputs are the same as svm_loss_naive.
  """
  loss = 0.0
  dW = np.zeros(W.shape) # initialize the gradient as zero

  #############################################################################
  # TODO:                                                                     #
  # Implement a vectorized version of the structured SVM loss, storing the    #
  # result in loss.                                                           #
  #############################################################################
  n=len(y)
  # X is N x D
  classes=W.shape[1]
  scores=X.dot(W) # N x C
  correct_class_scores=scores[xrange(n),y] # N x 1
  deltas=(scores.T-correct_class_scores).T+1 
  loss_sample_class=np.maximum(0,deltas) # N x C
  loss_sample_class[xrange(n),y]=0
  loss_sample= sum(loss_sample_class,1)
  loss = sum(loss_sample)
  loss /=n
  
  loss += 0.5 * reg * np.sum(W * W)
  #############################################################################
  #                             END OF YOUR CODE                              #
  #############################################################################


  #############################################################################
  # TODO:                                                                     #
  # Implement a vectorized version of the gradient for the structured SVM     #
  # loss, storing the result in dW.                                           #
  #                                                                           #
  # Hint: Instead of computing the gradient from scratch, it may be easier    #
  # to reuse some of the intermediate values that you used to compute the     #
  # loss.                                                                     #
  #############################################################################
  samples_classes_with_positive_loss = loss_sample_class>0 # N x C
  positive_contributions=X.T.dot(samples_classes_with_positive_loss) # D x C

  incorrectly_classified_count=np.sum(samples_classes_with_positive_loss,1)
  incorrectly_classified_matrix=np.zeros(samples_classes_with_positive_loss.shape)
  incorrectly_classified_matrix[xrange(n),y]=incorrectly_classified_count
  negative_contributions = X.T.dot(incorrectly_classified_matrix) # D x C
  #select_correct[y, range(num_train)] = np.sum(select_wrong, axis=0)
    
  dW=positive_contributions-negative_contributions
  dW/=n
  dW+=reg*W
  #############################################################################
  #                             END OF YOUR CODE                              #
  #############################################################################

  return loss, dW
