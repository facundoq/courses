from pylab import *
from math import exp, sqrt
import numpy
import Image

# return the energy measure of the transformation from image I to J.
# Works for d-dimensional images I and J
def transformation_energy(I, J):
    s = image_similarity(I, J)
    r = image_regularity(J)
    return (s, r, s + r)


# return the similarity between image I and J. Works for d-dimensional images
def image_similarity(I, J):
    return ((I - J) ** 2).mean()


# return the regularity of image I. Works for d-dimensional images
def image_regularity(I):
    G = gradient(I)
    sum_of_G = sum([g ** 2 for g in G], 0)
    return (sum_of_G).mean()


def image_regularity3(I):
    gx, gy, gz = gradient(I)
    return (gx ** 2 + gy ** 2 + gz ** 2).mean()


# add gaussian white noise to image I with random values taken from
# a gaussian distribution with mean 0 and sigma standard deviation
def add_gaussian_noise(I, sigma):
    random=(randn(*I.shape) *sigma)
    result=I + random
    result=rescale_grayscale_image(result)
    return result

# rescale an image to the 0..255 interval, and convert it to int8
def rescale_grayscale_image(i):
    i=i - i.min()
    scale=255.0 / i.max()
    return ( i*scale ).astype(uint8)

# save image i with filename and extension
def save_image(i, filename, extension):
    rescaled = rescale_grayscale_image(i)
    im = Image.fromarray(rescaled)
    im.save(filename + '.' + extension)


def save_image_png(i, filename):
    save_image(i, filename, 'png')


def rgb2gray_color_preserving(rgb):
    r, g, b = rgb[:, :, 0], rgb[:, :, 1], rgb[:, :, 2]
    gray = 0.2989 * r + 0.5870 * g + 0.1140 * b
    return gray


def rgb2gray(rgb):
    r, g, b = rgb[:, :, 0], rgb[:, :, 1], rgb[:, :, 2]
    gray = (r + g + b) / 3
    return gray


def saturate_values(image, min_value, max_value):
    image[image < min_value] = min_value
    image[image > max_value] = max_value

def circle_image2(w, h, radius):
    x, y = mgrid[-w / 2:w / 2, -h / 2:h / 2]
    return array(((x ** 2 + y ** 2) <= radius ** 2).astype(int))


def circle_image3(w, h, d, radius):
    x, y, z = mgrid[-w / 2:w / 2, -h / 2:h / 2, -d / 2:d / 2]
    return ((x ** 2 + y ** 2 + z ** 2) <= radius ** 2).astype(int)

