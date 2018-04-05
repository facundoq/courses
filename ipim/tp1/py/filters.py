from pylab import *
from math import exp, sqrt
from utils import *

# This module contains implementations of gaussian and bilateral kernels,
# as well as generic filtering functions
# The implementations work for d-dimensional grayscale images.

# applies a gaussian filter with standard deviation sigma to image im.
# The kernel_radius parameter sets the shape of the kernel matrix.
# If kernel_radius is not set, it is calculated according to
# the function square_kernel_shape_for_sigma
def gaussian_filter(im, sigma, kernel_radius=None):
    if kernel_radius == None:
        kernel_radius = square_kernel_shape_for_sigma(sigma, im)
    gaussian_kernel_matrix = gaussian_kernel(kernel_radius, sigma)
    return filter_image_kernel(im, gaussian_kernel_matrix)

# applies a gaussian filter with domain standard deviation sigmaD and
# range standard deviation sigmaR to image im.
# The kernel_radius parameter sets the shape of the kernel matrix.
# If kernel_radius is not set, it is calculated according to
# the function square_kernel_shape_for_sigma

def bilateral_filter(im, sigmaD, sigmaR, kernel_radius=None):
    if kernel_radius == None:
        kernel_radius = square_kernel_shape_for_sigma(sigmaD, im)
    kernel_function = bilateral_kernel(kernel_radius, sigmaD, sigmaR)
    return filter_image_function(im, kernel_function, kernel_radius)



def function_kernel(kernel_radius, fn):
    f = zeros(kernel_radius * 2 + 1)
    for p in array_iterator(f):
        f[p] = fn(kernel_radius, p)
    f = f / f.sum()
    return f

# Returns a kernel function to use with filter_image_function
# The returned function generates a filtered value for an image at given position
# according to the bilateral filtering formulation
def bilateral_kernel(kernel_radius, sigmaD, sigmaR):
    domain_kernel = gaussian_kernel(kernel_radius, sigmaD) #precalculate domain_kernel
    f = lambda im, pos: bilateral_kernel_function(kernel_radius, domain_kernel, sigmaR, im, pos)
    return f


# This function actually performs bilateral filtering on image im,
# with a domain kernel, a range kernel with sigmaR and size kernel_radius,
# for a position p of the image
def bilateral_kernel_function(kernel_radius, domain_kernel, sigmaR, im, p):
    sigmaR_squared = 2 * sigmaR * sigmaR
    v = im[p]
    neighbourhood_slice = [slice(i - r, i + r + 1) for i, r in itertools.izip(p, kernel_radius)]
    neighbourhood = im[neighbourhood_slice]
    #distances = np.square(neighbourhood - v) doesn't work
    distances = np.square(neighbourhood - (np.zeros(neighbourhood.shape)+v))
    exponente=-distances / sigmaR_squared
    distances = np.exp(exponente)
    range_kernel = distances #/ sum(distances)
    kernel = np.multiply(range_kernel, domain_kernel)
    kernel = kernel / sum(kernel)
    return sum(np.multiply(neighbourhood, kernel))

# filters image I with kernel function f
# f receives two parameters:
# 1) the image to filter
# 2) the position for which a new filtered value must be calculated,
# and returns this new value.
def filter_image_function(I, f, kernel_radius):
    J = np.copy(I) #copy the original, else the borders will be black in the resulting image
    for p in array_iterator_avoiding_edges(J, kernel_radius):
        J[p] = f(I, p)
    return J

# filters image I with kernel matrix f
def filter_image_kernel(I, f):
    ''' Restrictions: sum(f)=1, f.shape[0]=f.shape[1], odd(f.shape[0]) '''
    kernel_radius = (array(f.shape) - 1) / 2
    J = np.copy(I) #copy the original, else the borders will be black in the resulting image
    for p in array_iterator_avoiding_edges(J, kernel_radius):
        neighbourhood_slice = [slice(i - r, i + r + 1) for i, r in itertools.izip(p, kernel_radius)]
        neighbourhood = I[neighbourhood_slice]
        J[p] = sum(np.multiply(neighbourhood, f))
    return J

# generates the kernel matrix to perform gaussian filtering
# with standard deviation sigma
# To be used with filter_image_kernel
def gaussian_kernel(kernel_radius, sigma):
    sigma_squared = 2 * sigma * sigma
    f = zeros(kernel_radius * 2 + 1)
    center = kernel_radius
    for p in array_iterator(f):
        d = array(p) - center
        d = np.dot(d, d)
        #d=np.dot(d,d)
        f[p] = math.exp(-d / sigma_squared)
    f = f / f.sum()
    return f

# generate a square kernel shape for the given image's shape
# to implement a gaussian kernel with sigma standard deviation
def square_kernel_shape_for_sigma(sigma, image):
    return square_kernel_shape_for_image(kernel_radius_for_sigma(sigma), image)

# return the kernel radius for a given sigma
# Here we use the trick that for a gaussian kernel values
# 2 sigma away from the center of the kernel are mostly 0
def kernel_radius_for_sigma(sigma):
    return int(math.ceil(sigma * 2))

# return the kernel shape of a given radius for the given image
# the image is needed to get it's shape (ie, 2D, 3D, etc)
def square_kernel_shape_for_image(radius, image):
    return array([radius] * len(image.shape))