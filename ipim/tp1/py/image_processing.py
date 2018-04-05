from pylab import *
from math import exp, sqrt
from utils import *
import numpy as np

# This module contains functions to perform thresholding and Otsu's method


# calculate the histogram form image I, with as many bins as bin_count
# value_range is a tuple with which to specify the maximum and minimum
# intensities of the image, if desired

def histogram(image, bin_count, value_range=None):
    if value_range == None:
        b = float(image.min())
        m = float(image.max()) - b
    else:
        m, b = value_range

    bins = zeros(bin_count)
    bin_division = bins.size - 1
    for p in array_iterator(image):
        bin_index = (float(image[p]) - b) / m
        bin_index = int(bin_index * bin_division)
        bins[bin_index] += 1
    indexes = np.linspace(b, m, bin_count)
    return (bins, indexes)

# return the result of thresholding an image with Otsu's algorithm
# and the threshold value calculated
def threshold_otsu(image, bin_count):
    t = otsu(image, bin_count)
    return threshold(image, t), t

# threshold an image in place with level t
def threshold_in_place(image, t):
    for p in array_iterator(image):
        image[p] = 255 if image[p] > t else 0

# return the result of thresholding an image with level t
def threshold(image, t):
    result = zeros(image.shape)
    for p in array_iterator(image):
        result[p] = 255 if image[p] > t else 0
    return result

# given an image and a bin_count for the histogram function,
# return the optimum threshold value as calculted by Otsu's method
def otsu(image, bin_count):
    bins, indexes = histogram(image, bin_count)
    p = bins / np.sum(bins);
    mt = np.dot(p, indexes)
    max_bw, max_i = (0, -1)
    wb, sum_b = (0, 0)
    for i in xrange(0, p.size):
        wb += p[i]
        wf = 1 - wb
        if (wb == 0): continue
        if (wf == 0): break
        sum_b += indexes[i] * p[i]
        mb = sum_b / wb
        mf = (mt - sum_b) / wf
        bw = wb * wf * ((mb - mf) ** 2)
        if (bw > max_bw):
            max_bw = bw
            max_i = i
    return indexes[max_i]
