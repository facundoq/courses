


from pylab import *
from math import exp, sqrt
from image import *
from filters import *
from nibabel import load
import numpy
import image_processing
import image as img

import os
from tp import C

# Generate test images

def new_image():
  return zeros((300,300),dtype=numpy.uint8)

def gradient_square(image,center,side,intensity_range):
  cx,cy=center
  start_x,start_y=(cx-side,cy-side)
  end_x,end_y=(cx+side,cy+side)
  w,h=image.shape
  x, y = numpy.mgrid[:w, :h]
  positions_x=logical_and(x>=start_x,x<=end_x)
  positions_y=logical_and(y>=start_y,y<=end_y)
  positions=logical_and(positions_x,positions_y)

  start_i,end_i=intensity_range
  dx, dy = numpy.mgrid[:w, :h]
  scale=float(end_i)/float(end_x)
  dx= numpy.multiply(dx,scale)
  dx=dx+ (float(start_i)/float(end_x))
  #dx[logical_not(positions)]=0
  image[positions]=dx[positions]

def draw_square(image,center,side,thickness,intensity):
  cx,cy=center
  x,y=(cx-side,cy-side)
  end_x,end_y=(cx+side,cy+side)
  image[x:x+thickness,y:end_y]=intensity
  image[end_x-thickness:end_x,y:end_y]=intensity
  image[x:end_x,y:y+thickness]=intensity
  image[x:end_x,end_y-thickness:end_y]=intensity

def draw_circle(image,center,radius,thickness,intensity):
  cx,cy=center
  w,h=image.shape
  x, y = numpy.mgrid[:w, :h]
  circle_squared=(x-cx)**2+(y-cy)**2
  circle_outside= circle_squared >= (radius-thickness)**2
  circle_inside = circle_squared <= radius **2
  circle_positions= logical_and(circle_outside,circle_inside)
  image[circle_positions]=intensity

def gradient(intensity_range):
  image=new_image()+255
  draw_square(image,(150,150),100,10,0)
  gradient_square(image,(150,150),90,intensity_range)
  return image


def borders():
  image=new_image()
  draw_square(image,(50,50),20,2,255)
  draw_circle(image, (200,50),20,3,150)
  return image

def main():
  save_image_png(gradient((0,180)),C.input_dir+'gradient1')
  save_image_png(gradient((200,255)),C.input_dir+'gradient2')
  #save_image_png(borders(),C.input_dir+'borders')


if __name__ == '__main__':
    main()
