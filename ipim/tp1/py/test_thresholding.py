from pylab import *
from math import exp, sqrt
from image import *
from filters import *
from nibabel import load
import numpy
import image_processing
import image as img


def exp2d():
    R = 100
    image = circle_image2(300, 300, R)
    image = imread('data/cell.jpg').astype(float) / 255
    image = img.rgb2gray(image)
    #image=add_gaussian_noise(image,0.05)
    #saturate_values(image,0,1)
    bin_count = 255
    histogram, indexes = image_processing.histogram(image, bin_count)
    binary_image = numpy.copy(image)
    t = image_processing.otsu(binary_image, bin_count)
    print "Threshold " + str(t)
    image_processing.threshold(binary_image, t)
    #print image_similarity(image,binary_image)
    topology = 220
    subplot(topology + 1)
    imshow(image, cmap=gray())
    subplot(topology + 2)
    imshow(binary_image, cmap=gray())
    subplot(topology + 3)
    plot(indexes, histogram / histogram.sum())
    show()


def main():
    exp2d()


if __name__ == '__main__':
    main()
