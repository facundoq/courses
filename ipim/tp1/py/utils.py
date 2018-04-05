from numpy import *
import itertools
from pylab import *

# Returns an iterator over the positions of an array with shape s
def shape_iterator(s):
    ranges = [xrange(0, n) for n in s]
    return itertools.product(*ranges)

# Returns an iterator over the positions of array a
# useful for implementing algorithms for multidimensional images.
def array_iterator(a):
    s = a.shape
    ranges = [xrange(0, n) for n in s]
    return itertools.product(*ranges)

# Returns an iterator over the positions of array a, avoiding the edges or borders.
# Edges are considered to have a size of edge_sizes ( a tuple with sizes for each dimension)
# useful for implementing filtering for multidimensional images
def array_iterator_avoiding_edges(a, edge_sizes):
    s = a.shape
    ranges = []
    for i in xrange(len(s)):
        edge_size = edge_sizes[i]
        n = s[i]
        ranges.append(xrange(edge_size, n - edge_size))
    return itertools.product(*ranges)


def savepngfig(name):
  savefig(name+'.png',bbox_inches='tight',dpi=200,pad_inches=0)

if __name__ == '__main__':
    #test
    a = arange(5 * 5 * 5)
    a = a.reshape((5, 5, 5))
    i = array_iterator(a)
    edges = [1, 2, 1]
    j = array_iterator_avoiding_edges(a, edges)
