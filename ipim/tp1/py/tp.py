from pylab import *
from math import exp, sqrt
from image import *
from filters import *
from nibabel import load
import numpy
import image_processing
import image as img

import os

# This module generates

class C:
    #a Config class, just a collection of constants
    output_dir = '../report/img/results/'
    input_dir = '../report/img/input/'
    output_dir_plots = '../report/img/plots/'

    # algorithm parameters to generate Sim and Reg plots
    noise_levels = [0, 0.25, 0.5,1,2,3,5] # noise levels to distort the images
    gaussian_sigmas = [0.5,1,2]
    bilateral_sigmaDs = [0.5,1,2]
    bilateral_sigmaRs = [2,20]

    # plot configuration variables
    column_names=['sim','reg','e','noise']
    colors=['g','r','c','m','y','b'] # for different sigmaD
    markers=['<','>','v','^'] # for different sigmaR
    lines=['-',''] # for different typtes of algorithms

    # algorithm parameters to generate result images
    default_noise_level = 1.5
    default_noise_level_mri = 1.5
    default_gaussian_sigma = 1
    default_gaussian_sigma_noise = 1.5
    default_bilateral_sigma = (1, 7)
    default_bilateral_sigma_noise = (1.5, 7)
    default_number_of_bins = 256

# generate the plot for filtering algorithms
def generate_plot_filtering(results,name,column_y):
    xlabel('Noise ($\sigma$)')
    for sigma in C.gaussian_sigmas:
        gaussian = results['gaussian']
        gaussian = gaussian[gaussian[:, 4] == sigma]
        label = 'Gaussian, $\sigma=%.2f$' % sigma
        style='o'+C.colors[C.gaussian_sigmas.index(sigma)]+'--'
        plot(gaussian[:, 3], gaussian[:, column_y], style,label=label)
        legend(loc=2)

    for sigmaD in C.bilateral_sigmaDs:
        for sigmaR in C.bilateral_sigmaRs:
            bilateral= results['bilateral']
            bilateral = bilateral[bilateral[:, 4] == sigmaD]
            bilateral = bilateral[bilateral[:, 5] == sigmaR]
            label = 'Bilateral, $\sigma_d=%.2f$, $\sigma_r=%.2f$' % (sigmaD,sigmaR)
            style=C.markers[C.bilateral_sigmaRs.index(sigmaR)]+C.colors[C.bilateral_sigmaDs.index(sigmaD)]+'-'
            plot(bilateral[:, 3], bilateral[:, column_y],style,label=label )
            legend(loc=2)
    savepngfig(C.output_dir_plots+name+'_filtering_'+C.column_names[column_y])

# generate the plot for otsu's algorithm, with and without noise and different
# types of filters
def generate_plot_otsu(results,name,column_y):
    xlabel('Noise ($\sigma$)')
    otsu = results['otsu']
    plot(otsu[:, 3], otsu[:, column_y],'-.', label='otsu')
    legend(loc=2)
    for sigma in C.gaussian_sigmas:
        otsu = results['otsu_gaussian']
        otsu = otsu[otsu[:, 4] == sigma]
        label = 'Otsu with gaussian, $\sigma=%.2f$' % sigma
        style='o'+C.colors[C.gaussian_sigmas.index(sigma)]+'--'
        plot(otsu[:, 3], otsu[:, column_y], style,label=label)
        legend(loc=1)

    for sigmaD in C.bilateral_sigmaDs:
        for sigmaR in C.bilateral_sigmaRs:
            otsu = results['otsu_bilateral']
            otsu = otsu[otsu[:, 4] == sigmaD]
            otsu = otsu[otsu[:, 5] == sigmaR]
            label = 'Otsu with bilateral, $\sigma_d=%.2f$, $\sigma_r=%.2f$' % (sigmaD,sigmaR)
            style=C.markers[C.bilateral_sigmaRs.index(sigmaR)]+C.colors[C.bilateral_sigmaDs.index(sigmaD)]+'-'
            plot(otsu[:, 3], otsu[:, column_y],style, label=label)
            legend(loc=1)
    savepngfig(C.output_dir_plots+name+'_otsu_'+C.column_names[column_y])

# Generate all the plot images according to the results dictionary
# for image with given name
def generate_plot_images(results, name):
    for k in results:
        results[k] = array(results[k])

    functions=[generate_plot_otsu,generate_plot_filtering]
    labels=[(0,'$Sim(I,J)$'),(1,'$Reg(J)$')]
    for f in functions:
        for (column_y,label) in labels:
            figure()
            ylabel(label)
            f(results,name,column_y)
            xlim(0,C.noise_levels[-1]*1.5)

# generate a dictionary with Sim, Reg and E values for every combination of the
# algorithm parameters in class C, for a given image with a certain name
def generate_plots(image, name):
    results = {}
    results['otsu'] = []
    results['otsu_bilateral'] = []
    results['otsu_gaussian'] = []
    results['bilateral'] = []
    results['gaussian'] = []
    otsu, t = image_processing.threshold_otsu(image, C.default_number_of_bins)

    for noise in C.noise_levels:
        print 'Image %s, Noise %.2f ' % (name, noise)
        image_with_noise = add_gaussian_noise(image, noise)

        print 'Image %s, otsu ' % (name)
        otsu_noise, t = image_processing.threshold_otsu(image_with_noise, C.default_number_of_bins)
        s, r, e = transformation_energy(otsu, otsu_noise)
        results['otsu'].append([s, r, e, noise])

        for sigma in C.gaussian_sigmas:
            print 'Image %s, gaussian s=%.2f ' % (name, sigma)
            gaussian = gaussian_filter(image_with_noise, sigma)
            s, r, e = transformation_energy(image, gaussian)
            results['gaussian'].append([s, r, e, noise, sigma])
            if (sigma<2):
              otsu_gaussian, t = image_processing.threshold_otsu(gaussian, C.default_number_of_bins)
              s, r, e = transformation_energy(otsu, otsu_gaussian)
              results['otsu_gaussian'].append([s, r, e, noise, sigma])

        for sigmaD in C.bilateral_sigmaDs:
            for sigmaR in C.bilateral_sigmaRs:
                print 'Image %s, bilateral sd=%.2f, sr=%.2f ' % (name, sigmaD,sigmaR)
                bilateral = bilateral_filter(image_with_noise, sigmaD, sigmaR)
                s, r, e = transformation_energy(image, bilateral)
                results['bilateral'].append([s, r, e, noise, sigmaD, sigmaR])

                otsu_bilateral, t = image_processing.threshold_otsu(bilateral, C.default_number_of_bins)
                s, r, e = transformation_energy(otsu, otsu_bilateral)
                results['otsu_bilateral'].append([s, r, e, noise, sigmaD, sigmaR])
    print 'Generating plot images...'
    generate_plot_images(results, name)

# Generate the images that will be visually inspected
# For the given image, calculate:
#  1) Bilateral, gaussian and otsu's without noise
#  2) Bilateral, gaussian and otsu's with noise
#  3) Otsu's with noise, but after applying Bilateral, gaussian filtering
# Result images are saved with the given name as a prefix
def generate_result_images(image, name):
    image = add_gaussian_noise(image, 0)
    print 'Processing image %s' % name
    save_image_png(image, C.output_dir + name)
    if (name.startswith('mri')):
        noise = C.default_noise_level_mri
    else:
        noise = C.default_noise_level

    image_with_default_noise = add_gaussian_noise(image, noise)
    save_image_png(image_with_default_noise, C.output_dir + name + '_noise')

    print 'Image %s: bilateral' % name
    (sigmaD, sigmaR) = C.default_bilateral_sigma
    bilateral = bilateral_filter(image, sigmaD, sigmaR)
    save_image_png(bilateral, C.output_dir + name + '_bilateral')

##    for sigmaR in [1,2,3,4,5,7,8,9,10,11,12,13,14,15,17,18]:
##      bilateral = bilateral_filter(image, sigmaD, sigmaR)
##      if (sigmaR<10):
##        n='0'+str(sigmaR)
##      else:
##        n=str(sigmaR)
##      save_image_png(bilateral, C.output_dir + name + '_bilateral_'+n)

    print 'Image %s: bilateral noise' % name
    (sigmaD, sigmaR) = C.default_bilateral_sigma_noise
    bilateral_noise = bilateral_filter(image_with_default_noise, sigmaD, sigmaR)
    save_image_png(bilateral_noise, C.output_dir + name + '_noise_bilateral')

    print 'Image %s: gaussian' % name
    sigma = C.default_gaussian_sigma
    gaussian = gaussian_filter(image, sigma)
    save_image_png(gaussian, C.output_dir + name + '_gaussian')

    print 'Image %s: gaussian noise' % name
    sigma = C.default_gaussian_sigma_noise
    gaussian_noise = gaussian_filter(image_with_default_noise, sigma)
    save_image_png(gaussian_noise, C.output_dir + name + '_noise_gaussian')

    print 'Image %s: Otsu' % name
    otsu, t = image_processing.threshold_otsu(image, C.default_number_of_bins)
    save_image_png(otsu, C.output_dir + name + '_otsu')

    print 'Image %s: Otsu noise' % name
    otsu_noise, t = image_processing.threshold_otsu(image_with_default_noise, C.default_number_of_bins)
    save_image_png(otsu_noise, C.output_dir + name + '_otsu_noise')

    print 'Image %s: Otsu noise bilateral' % name
    otsu_bilateral_noise, t = image_processing.threshold_otsu(bilateral_noise, C.default_number_of_bins)
    save_image_png(otsu_bilateral_noise, C.output_dir + name + '_otsu_noise_bilateral')

    print 'Image %s: Otsu noise gaussian' % name
    otsu_gaussian_noise, t = image_processing.threshold_otsu(gaussian_noise, C.default_number_of_bins)
    save_image_png(otsu_gaussian_noise, C.output_dir + name + '_otsu_noise_gaussian')

# reads an image with a given extension from C.input_dir
def read_image(filename,extension):
    if (extension=='gz'):
      data = load(C.input_dir+ filename + '.'+extension)
      image = data.get_data()
    else:
      image = imread(C.input_dir + filename + '.'+extension)
    s = image.shape
    if len(s) > 2 and s[2] in [3, 4]: # "detect" rgb images
        image = img.rgb2gray(image)
        #image= img.rgb2gray_color_preserving(image)
    image=rescale_grayscale_image(image)

    return image


def main():

    set_printoptions(precision=4, linewidth=150, suppress=True) # print values with less precision
    params = {'legend.fontsize': 8,
          'legend.linewidth': 1,
          'legend.labelspacing':0.2,
          'legend.loc':2}
    rcParams.update(params) # change global plotting parameters
    if not os.path.exists(C.output_dir_plots):# generate output_dir_plots
        os.makedirs(C.output_dir_plots)
    if not os.path.exists(C.output_dir):# generate output_dir
        os.makedirs(C.output_dir)
    #image sets
    synthetic_images=[('borders','png'),
            ('borders_contrast','png'),
            ('gradient1','png'),
            ('gradient2','png'),]
    mri_images=[('mri1','png'),
            ('mri2','png'),
            ('mri3','png')]
    mri_image=[('T1w_acpc_dc_restore_1.25.nii','gz')]
    # select image set
    #images=synthetic_images+mri_images
    #images = mri_image
    images=synthetic_images

    # for each image, read it, and generate the resulting plots
    # for each image, read it, and generate the resulting images
    for filename,extension in images:
        image = read_image(filename,extension)
        #generate_result_images(image,filename)
        generate_plots(image, filename)

if __name__ == '__main__':
    main()
