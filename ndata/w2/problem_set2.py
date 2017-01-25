#
#  NAME
#    problem_set2_solutions.py
#
#  DESCRIPTION
#    Open, view, and analyze action potentials recorded during a behavioral
#    task.  In Problem Set 2, you will write create and test your own code to
#    create tuning curves.
#

#Helper code to import some functions we will use
import numpy as np
import matplotlib.pylab as plt
import matplotlib.mlab as mlab
from scipy import optimize
from scipy import stats


def load_experiment(filename):
    """
    load_experiment takes the file name and reads in the data.  It returns a
    two-dimensional array, with the first column containing the direction of
    motion for the trial, and the second column giving you the time the
    animal began movement during thaht trial.
    """
    data = np.load(filename)[()];
    return np.array(data)

def load_neuraldata(filename):
    """
    load_neuraldata takes the file name and reads in the data for that neuron.
    It returns an arary of spike times.
    """
    data = np.load(filename)[()];
    return np.array(data)
    
def bin_spikes(trials, spk_times, time_bin):
    """
    bin_spikes takes the trials array (with directions and times) and the spk_times
    array with spike times and returns the average firing rate for each of the
    eight directions of motion, as calculated within a time_bin before and after
    the trial time (time_bin should be given in seconds).  For example,
    time_bin = .1 will count the spikes from 100ms before to 100ms after the 
    trial began.
    
    dir_rates should be an 8x2 array with the first column containing the directions
    (in degrees from 0-360) and the second column containing the average firing rate
    for each direction
    """
    #print trials.shape
    #print spk_times.shape
    #print time_bin
    direction_count=8
    direction_separation=45

    directions=trials[:,0]
    directions=np.round(np.round(directions)/direction_separation);

    times=trials[:,1]

    dir_rates=np.zeros( (direction_count,2) )
    dir_rates[:,0]=np.array(range(direction_count))*direction_separation
    direction_rates_count= np.zeros( (direction_count) )
    for i in range(len(directions)):
        t=times[i]
        direction=directions[i]
        count=  np.count_nonzero( np.logical_and( spk_times>= t-time_bin,spk_times<= t+time_bin))
        rate=count/(time_bin*2)
        dir_rates[direction,1]=dir_rates[direction,1]+rate;
        direction_rates_count[direction]=direction_rates_count[direction]+1
    for i in range(len(direction_rates_count)):
        if (direction_rates_count[i]>0):
            dir_rates[i,1]=dir_rates[i,1]/direction_rates_count[i]
    return dir_rates
    
def plot_tuning_curves(direction_rates, title):
    """
    This function takes the x-values and the y-values  in units of spikes/s 
    (found in the two columns of direction_rates) and plots a histogram and 
    polar representation of the tuning curve. It adds the given title.
    """
    plt.subplot(2,2,1)
    plt.bar(direction_rates[:,0],direction_rates[:,1],width=45)
    plt.xlabel('Direction of motion (degrees)')
    plt.ylabel('Time varying firing rate (spikes/s)')
    #plt.xticks( np.array(range(8))*45)
    plt.subplot(2,2,2,polar=True)
    directions_radians= (direction_rates[:,0]*np.pi*2)/360
    #directions_radians[9,0]=360
    directions_radians=np.append(directions_radians,np.pi*2)
    values=direction_rates[:,1]
    #values[9]=values[0]
    values=np.append(values,values[0])
    plt.polar(directions_radians,values,label='Firing rate (spikes/s)')
    plt.xticks(np.array(range(8))*45*np.pi*2/360)
    plt.title(title)
    plt.show()

    
def roll_axes(direction_rates):
    """
    roll_axes takes the x-values (directions) and y-values (direction_rates)
    and return new x and y values that have been "rolled" to put the maximum
    direction_rate in the center of the curve. The first and last y-value in the
    returned list should be set to be the same. (See problem set directions)
    Hint: Use np.roll()
    """
    x=direction_rates[:,0]
    y=direction_rates[:,1]
    n=len(y)
    middle=np.round(n/2)
    max_y=np.argmax(y)
    roll=middle-max_y
    roll_degrees=roll*45
    
    new_xs=np.roll(x,roll)#-roll_degrees
    new_ys=np.roll(y,roll)
    
    new_ys=np.append(new_ys,new_ys[0])
    new_xs=np.append(new_xs,new_xs[0])
    if (roll>=0):
        new_xs[:roll]= new_xs[:roll]-360
    else:
        new_xs[roll:]= new_xs[roll:]+360
    return new_xs, new_ys, roll_degrees    
    

def normal_fit(x,mu, sigma, A):
    """
    This creates a normal curve over the values in x with mean mu and
    variance sigma.  It is scaled up to height A.
    """
    n = A*mlab.normpdf(x,mu,sigma)
    return n

def fit_tuning_curve(centered_x,centered_y):
    """
    This takes our rolled curve, generates the guesses for the fit function,
    and runs the fit.  It returns the parameters to generate the curve.
    """
    max_y = np.amax(centered_y) 
    max_x = x[np.argmax(centered_y)] 
    sigma = 90
    p, cov = optimize.curve_fit(normal_fit,centered_x, centered_y, p0=[max_x, sigma,
    max_y])
    return p
    


def plot_fits(direction_rates,fit_curve,title):
    """
    This function takes the x-values and the y-values  in units of spikes/s 
    (found in the two columns of direction_rates and fit_curve) and plots the 
    actual values with circles, and the curves as lines in both linear and 
    polar plots.
    """
    

def von_mises_fitfunc(x, A, kappa, l, s):
    """
    This creates a scaled Von Mises distrubition.
    """
    return A*stats.vonmises.pdf(x, kappa, loc=l, scale=s)


    
def preferred_direction(fit_curve):
    """
    The function takes a 2-dimensional array with the x-values of the fit curve
    in the first column and the y-values of the fit curve in the second.  
    It returns the preferred direction of the neuron (in degrees).
    """
  
    return pd
    
        
##########################
#You can put the code that calls the above functions down here    
if __name__ == "__main__":
    trials = load_experiment('trials.npy')   
    spk_times = load_neuraldata('example_spikes.npy') 
    #print(trials[0:100,:])
    bin_size=0.1
    direction_rates= bin_spikes(trials,spk_times,bin_size)
    #plot_tuning_curves(direction_rates,'Direction rates plot')
    centered_x,centered_y, roll_degrees  = roll_axes(direction_rates)
    plt.bar(centered_x,centered_y,width=45, align="center")
    plt.xticks(centered_x)
    print centered_x
    plt.show()
    p=fit_tuning_curve(centered_x,centered_y)
    

