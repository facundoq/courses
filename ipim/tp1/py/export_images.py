#!/bin/python

import Image
from pylab import *
from math import exp, sqrt
from image import *
from image_processing import *
from filters import *
from nibabel import load

#def my_save_fig(filename):
#save_fig(filename)

image_index = 10


def export_dataset(im):
    save_image_png(im[50, :, :], 'mri1')
    save_image_png(im[:, 50, :], 'mri2')
    save_image_png(im[:, :, 50], 'mri3')


def export_examples(im):
    save_image_png(im[:, :, image_index], 'mri_original')
    #im=add_gaussian_noise(im,2)

    print 'Starting Gaussian Filtering...'

    sigmaD_gaussian = 0.5
    gaussian = gaussian_filter(im, sigmaD_gaussian)
    save_image_png(gaussian[:, :, image_index], 'mri_gaussian')

    print 'Starting Bilateral Filtering...'
    sigmaD = 0.5
    sigmaR = 50
    for sigmaR in [1, 10, 50, 100, 1000]:
        bilateral = bilateral_filter(im, sigmaD, sigmaR)
        save_image_png(bilateral[:, :, image_index], 'mri_bilateral_' + str(sigmaR))


def export_histogram(im):
    data = rescale_grayscale_image(im[:, :, 50]).flatten()
    hist(data, 100, histtype='bar', rwidth=0.5)
    xlabel('Intensity value')
    ylabel('Pixel count')
    figure()
    hist(data, 100, normed=1, histtype='bar', rwidth=0.5)
    xlabel('Intensity value')
    ylabel('Pixel frequency')
    show()


def export_threshold(im):
    i = im[:, :, 50]
    i = rescale_grayscale_image(i)
    thresolded_mri, t = threshold_otsu(i, 256);
    save_image_png(thresolded_mri, 'thresolded_mri')

    for t in [10, 20, 30, 40, 100, 150, 240]:
        thresolded_mri = threshold(i, t);
        save_image_png(thresolded_mri, 'otsu/thresolded_mri_' + str(t))


def export_mri_images():
    data = load("data/T1w_acpc_dc_restore_1.25.nii.gz")
    im_original = data.get_data()
    #im=circle_image3(50,50,50,20)
    im = im_original[:, :, 40:60]

    im = rescale_grayscale_image(im)

    gray()
    #export_dataset(im)
    #export_histogram(im)
    export_threshold(im_original)
    #export_examples(im)


if __name__ == '__main__':
    set_printoptions(precision=4, linewidth=150, suppress=True)
    export_mri_images()
    print 'Finished.'
