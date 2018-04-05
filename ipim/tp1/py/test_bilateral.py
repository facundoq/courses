#!/bin/python

from pylab import *
from math import exp, sqrt
from image import *
from filters import *
from nibabel import load


def exp2d():
    R = 50
    I = circle_image3(300, 300, 1, R)

    S = []
    R = []
    kernel_radius = array([2, 2, 0])
    for sigma in linspace(1, 11, 5):
        I1 = add_gaussian_noise(I, sigma)
        gaussian_kernel_matrix = gaussian_kernel(kernel_radius, sigma)
        #print "filtering gaussian with kernel_radius %s" % kernel_radius
        J = filter_image_kernel(I, gaussian_kernel_matrix)
        similarity = image_similarity(I, J)
        regularity = image_regularity(J[:, :, 0])
        S.append(similarity)
        R.append(regularity)
        print "Finished sigma %f - (S,R)= (%f,%f)" % (sigma, similarity, regularity)
    subplot(311)
    imshow(I[:, :, 0])
    subplot(312)
    plot(S)
    subplot(313)
    plot(R)
    show()


def exp_bilateral():
    data = load("../report/img/300/T1w_acpc_dc_restore_1.25.nii.gz")
    i = data.get_data()
    i = i[:, :, 50]
    i=rescale_grayscale_image(i)
    #i=circle_image(300,300,50)
    save_image_png(i,'original' )
    sigma_noise=2
    i = add_gaussian_noise(i, sigma_noise)
    save_image_png(i,'noise_'+str(sigma_noise) )
    #i=rescale_grayscale_image(i).astype(float32)
    sigma=1
    j = gaussian_filter(i, sigma)
    save_image_png(j,'gaussian_%.2f' % sigma)

    sigmaD,sigmaR=(1,200)
    k = bilateral_filter(i, sigmaD, sigmaR)
    save_image_png(k,'bilateral_d%.2f,_r%.2f' % (sigmaD,sigmaR))

##    gray()
##
##    imshow(i)
##    mng = plt.get_current_fig_manager()
##    mng.window.state('zoomed')
##
##    figure()
##    imshow(j)
##    mng = plt.get_current_fig_manager()
##    mng.window.state('zoomed')
##
##    figure()
##    imshow(k)
##    mng = plt.get_current_fig_manager()
##    mng.window.state('zoomed')
##
##    show()

def mm_to_voxel(mm, M):
    ''' M: streching coefficients '''
    return M.dot(mm)


def kernel_for_sigma(s):
    return (s * 3).astype(int)


def streching_coefficients_mm(im):
    a = im.get_affine()
    return np.absolute(a[:3, :3])


def exp_images():
    data = load("data/T1w_acpc_dc_restore_1.25.nii.gz")
    affine = abs(data.get_affine()[:3, :3])

    sizes = array([0.5, 0.5, 0.5]) * 4

    kernel_size = kernel_for_sigma(mm_to_voxel(sizes, affine))
    kernel_size = array([2, 2, 2])
    sigmaD_gaussian = 0.35
    sigmaD = 2
    sigmaR = 0.2
    ims = data.get_data()[50:100, 50:100, :50]
    #ims=circle_image3(50,50,50,12.5)

    kernel_function = bilateral_kernel(kernel_size, sigmaD, sigmaR)
    print "filtering bilateral with kernel size %s" % kernel_size
    i_bilateral = filter_image_function(ims, kernel_function, kernel_size)
    print "done filtering with kernel size %s" % kernel_size

    gaussian_kernel_matrix = gaussian_kernel(kernel_size, sigmaD_gaussian)
    print "filtering gaussian with kernel size %s" % kernel_size
    i_gaussian = filter_image_kernel(ims, gaussian_kernel_matrix)
    print "done filtering gaussian with kernel size %s" % kernel_size

    ss, rs, ms = (image_similarity(ims, ims), image_regularity(ims), ims.mean())
    sb, rb, mb = (image_similarity(ims, i_bilateral), image_regularity(i_bilateral), i_bilateral.mean())
    sg, rg, mg = (image_similarity(ims, i_gaussian), image_regularity(i_gaussian), i_gaussian.mean())
    print "Self Similarity: %f / reg: %0.2f / mean: %f" % (ss, rs, ms)
    print "Similarity to bilateral: %f / reg: %0.2f / mean: %0.2f " % (sb, rb, mb)
    print "Similarity to gaussian: %f / reg: %0.2f / mean: %0.2f" % (sg, rb, mg)

    image_to_show = 25
    text_pos = 7
    topo = 220
    subplot(topo + 1)
    imshow(ims[:, :, image_to_show])
    colorbar()
    title("Original")
    text(text_pos, text_pos, "$reg=%0.2f$ \n $\mu=%0.2f$" % (rs, ms))

    title("Original")
    text(text_pos, text_pos, "$reg=%0.2f$ \n $\mu=%0.2f$" % (rs, ms))

    subplot(topo + 2)
    imshow(i_bilateral[:, :, image_to_show])
    colorbar()
    title("Bilateral:\n $\mathcal{R}$=%s,$\sigma_d$=%.2f,$\sigma_r$=%.2f" % (str(kernel_size), sigmaD, sigmaR))
    text(text_pos, text_pos, "$sim=%0.2f,reg=%0.2f$\n $\mu=%0.2f$" % (sb, rb, mb))

    subplot(topo + 3)
    imshow(i_gaussian[:, :, image_to_show])
    colorbar()
    title("Gaussian:\n $\mathcal{R}$=%s,$\sigma_d$=%.2f" % (str(kernel_size), sigmaD_gaussian))
    text(text_pos, text_pos, "$sim=%0.2f,reg=%0.2f$\n $\mu=%0.2f$" % (sg, rg, mg))

    print image_regularity(ims)
    print image_regularity3(ims)
    show()


if __name__ == "__main__":
    set_printoptions(precision=4, linewidth=150, suppress=True)
    #exp_images()
    exp_bilateral()
    #exp2d()