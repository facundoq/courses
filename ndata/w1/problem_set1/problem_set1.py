#
#  NAME
#    problem_set1.py
#
#  DESCRIPTION
#    Open, view, and analyze raw extracellular data
#    In Problem Set 1, you will write create and test your own spike detector.
#

import numpy as np
import matplotlib.pylab as plt




def load_data(filename):
    """
    load_data takes the file name and reads in the data.  It returns two 
    arrays of data, the first containing the time stamps for when they data
    were recorded (in units of seconds), and the second containing the 
    corresponding voltages recorded (in units of microvolts - uV)
    """
    data = np.load(filename)[()];
    return np.array(data['time']), np.array(data['voltage'])
    
def bad_AP_finder(time,voltage):
    """
    This function takes the following input:
        time - vector where each element is a time in seconds
        voltage - vector where each element is a voltage at a different time
        
        We are assuming that the two vectors are in correspondance (meaning
        that at a given index, the time in one corresponds to the voltage in
        the other). The vectors must be the same size or the code
        won't run
    
    This function returns the following output:
        APTimes - all the times where a spike (action potential) was detected
         
    This function is bad at detecting spikes!!! 
        But it's formated to get you started!
    """
    
    #Let's make sure the input looks at least reasonable
    if (len(voltage) != len(time)):
        print "Can't run - the vectors aren't the same length!"
        APTimes = []
        return APTimes
    
    numAPs = np.random.randint(0,len(time))//10000 #and this is why it's bad!!
 
    # Now just pick 'numAPs' random indices between 0 and len(time)
    APindices = np.random.randint(0,len(time),numAPs)
    
    # By indexing the time array with these indices, we select those times
    APTimes = time[APindices]
    
    # Sort the times
    APTimes = np.sort(APTimes)
    
    return APTimes

def smooth(y,window_size):

    r=y
    for i in range(window_size,len(y)-window_size):
        r[i]= np.mean(y[i-window_size:i+window_size])
    return r


class Interval:

    def __init__(self,begin,end,dv):
        self.begin=begin
        self.end=end
        self.dv=dv
    def __str__(self):
        return "Interval[%d,%d,%f]" % (self.begin,self.end,self.dv) 

class Peak:
    #kinds of peaks
    MAXIMUM=1
    MINIMUM=2

    def __init__(self,begin,end,peak,kind):
        self.begin=begin
        self.end=end
        self.peak=peak
        self.kind= kind
    def __str__(self):
        if (self.kind == Peak.MAXIMUM):
            kind="MAXIMUM"
        else:
            kind="MINIMUM"

        return ("Peak[%d,%d,%f,%s]" % (self.begin,self.end,self.peak,kind) )
    
def gradient(x,y):
    dy= np.empty_like(y)
    for i in range(0,len(x)-1):
        dy[i+1]= (y[i+1]-y[i])/(x[i+1]-x[i])
    dy[0]=y[0]
    return dy

def divide_into_intervals(x,y,eps):
    dy=gradient(x,y)
    dy[dy>eps]=1
    dy[dy<-eps]=-1
    dy[abs(dy)<=eps]=0

    intervals=[]
    i=0
    while i<len(y):
        begin=i
        if abs(dy[i])<=eps:
            while(i<len(y) and abs(dy[i])<=eps):
                i=i+1
            end=i
            intervals.append(Interval(begin,end,np.mean(dy[begin:end])))
        elif dy[i]<-eps:
            while(i<len(y) and dy[i]<-eps):
                i=i+1
            end=i
            intervals.append(Interval(begin,end,np.mean(dy[begin:end])))
        else:
            while(i<len(y) and dy[i]>eps ):
                i=i+1
            end=i
            intervals.append(Interval(begin,end,np.mean(dy[begin:end])))
    return intervals


#possibilities
        # I P I NO
        # I P D MAX
        # I D P MAX
        # I D I MAX

        # P I D NOTHING
        # P D I NOTHING
        # P I P NOTHING
        # P D P NOTHING

        #D I P MIN
        #D P I MIN
        #D I D MIN
        #D P D NO
def detect_peaks(intervals,x,y,eps):
    peaks=[]
    i=0
    while i<len(intervals)-2:
        p,c,n=intervals[i:i+3] # previous current next trio
        peak = None
        # see if a INCRESING-PLATEAU-DECREASING or  INCRESING-PLATEAU-DECREASING trio was found
        if (p.dv>eps and n.dv<-eps ) and abs(c.dv)<=eps:
            peak_index = int(y[p.begin:n.end].argmax()+p.begin)
            peak = Peak(p.begin,n.end,peak_index,Peak.MAXIMUM)
            i=i+2
        elif (p.dv<-eps and n.dv>eps ) and abs(c.dv)<=eps:
            peak_index = int(y[p.begin:n.end].argmax()+p.begin)
            peak = Peak(p.begin,n.end,peak_index,Peak.MINIMUM)
            i=i+2
        # see if a INCRESING-DECREASING or  INCRESING-DECREASING pair was found
        elif (p.dv<-eps and c.dv>eps ):
            peak_index = int(y[p.begin:c.end].argmax()+p.begin)
            peak = Peak(p.begin,c.end,peak_index,Peak.MINIMUM)
            i=i+1
        elif (p.dv>eps and c.dv<-eps ):
            peak_index = int(y[p.begin:c.end].argmax()+p.begin)
            peak = Peak(p.begin,c.end,peak_index,Peak.MAXIMUM)
            i=i+1
        else:
            i=i+1
        if (peak != None):
            peaks.append(peak)
    return peaks

def filter_close_peaks(peaks,x,y,min_distance_x):
    if (len(peaks)==0):
        return []
        
    result = [peaks[0]]
    for i in range(1,len(peaks)):
        last_peak=peaks[i-1]
        p=peaks[i]
        if ( abs(x[last_peak.end-1] - x[p.begin]) < min_distance_x ):
            continue
        result.append(p)
    return result

def filter_peaks(peaks,x,y,min_dy,min_dx,max_dx):
    result = []
    
    for p in peaks:
        #print "End: %d/%d" % (p.end,len(x))
        if ( x[p.end-1] - x[p.begin] < min_dx ):
            continue
        if ( x[p.end-1] - x[p.begin] > max_dx ):
            continue
        if ( abs(y[p.end-1] - y[p.peak])<min_dy and abs(y[p.peak] - y[p.begin])<min_dy):
            continue
        #if ( abs(y[p.peak] - y[p.begin])<min_dy):
        #    continue
        result.append(p)
    return result

def merge_intervals(intervals,eps):
    result=list(intervals)
    #delete intervals at the end with slope 0
    i=len(result)-1
    while i>=0 and abs(result[i].dv)<=eps:
        del result[i]
        i=i-1
    #delete intervals at the beginning with slope 0
    i=0
    while i<len(result) and abs(result[i].dv)<=eps:
        del result[i]
    # merge non useful trios
    while i<len(result)-2:
        p,c,n=result[i:i+3] # previous current next trio
        # see if a INCRESING-PLATEAU-INCREASING or  DECRESING-PLATEAU-DECREASING trio was found
        if ((p.dv<-eps and n.dv<-eps) or (p.dv>eps and n.dv>eps) ) and abs(c.dv)<=eps :
            new_dv= (p.dv+c.dv+n.dv)/3
            new_interval=Interval(p.begin,n.end,new_dv)
            result[i]=new_interval
            del result[i+2]
            del result[i+1]
        else:
            i=i+1
    return result


def plot_intervals(x,y,intervals,max_slope):
    last_x,last_y=(0,0)
    for i in range(0,len(intervals)):
        interval= intervals[i]
        if (abs(interval.dv)<=max_slope):
            color ='y'
        elif interval.dv > max_slope:
            color='g'
        else:
            color='m'
        interval_x=np.concatenate( ([last_x], x[interval.begin:interval.end]) )
        interval_y=np.concatenate(([last_y], y[interval.begin:interval.end]) )
        plt.plot(interval_x,interval_y,"-",markersize=0.5,color=color)
        plt.plot(last_x,last_y,"bo",markersize=1)
        last_x=x[interval.end-1]
        last_y=y[interval.end-1]
    plt.title('Intervals detected')    
    plt.xlabel('Time (s)')
    plt.ylabel('Voltage (mV)')
    #dy=gradient(x,y)
    #dy[dy>max_slope]=1
    #dy[dy<-max_slope]=-1
    #dy[abs(dy)<=max_slope]=0
    #plt.plot(x,dy,'r--')
    plt.show()

def good_AP_finder(time,voltage):
    """
    This function takes the following input:
        time - vector where each element is a time in seconds
        voltage - vector where each element is a voltage at a different time
        
        We are assuming that the two vectors are in correspondance (meaning
        that at a given index, the time in one corresponds to the voltage in
        the other). The vectors must be the same size or the code
        won't run
    
    This function returns the following output:
        APTimes - all the times where a spike (action potential) was detected
    """
 
    APTimes = []
       
    #Let's make sure the input looks at least reasonable
    if (len(voltage) != len(time)):
        print "Can't run - the vectors aren't the same length!"
        return APTimes
    voltage=np.copy(voltage)

    voltage=voltage-voltage.mean()

    max_voltage=voltage.var()  #max(abs(voltage))
    voltage=voltage/max_voltage

    std = voltage.std()
    min_amplitude=3*std
    voltage[voltage<min_amplitude]=0

    voltage=smooth(voltage,5)
    #voltage=smooth(voltage,30)
    std = voltage.std()
    

    #min_amplitude=5
    #voltage[abs(voltage)<min_amplitude]=0
    
    

    max_slope=0.01
    intervals = divide_into_intervals(time,voltage,max_slope)
    
    #intervals = merge_intervals(intervals,max_slope)
    #plot_intervals(time,voltage,intervals,max_slope)

    peaks = detect_peaks(intervals,time,voltage,max_slope)
    min_dy=std*2
    min_dx=0
    max_dx=0.008

    peaks = filter( lambda p: p.kind == Peak.MAXIMUM, peaks)

    peaks = filter_peaks(peaks,time,voltage,min_dy,min_dx,max_dx)
    print(len(peaks))
    min_distance_x=0.00000
    peaks = filter_close_peaks(peaks,time,voltage,min_distance_x)
    print(len(peaks))
    min_height=std*2
    peaks  = filter( lambda p: voltage[p.peak]>=min_height, peaks )
    
    # print "filtered"
    # for i in peaks:
    #     print i
    
    # print "max"
    # for i in peaks:
    #     print i
    APTimes = map( lambda p: time[p.peak], peaks )
    #plot_spikes(time,voltage,APTimes,'Spikes on preprocessed signal')
    return APTimes
    

def get_actual_times(dataset):
    """
    Load answers from dataset
    This function takes the following input:
        dataset - name of the dataset to get answers for

    This function returns the following output:
        APTimes - spike times
    """    
    return np.load(dataset)
    
def detector_tester(APTimes, actualTimes):
    """
    returns percentTrueSpikes (% correct detected) and falseSpikeRate
    (extra APs per second of data)
    compares actual spikes times with detected spike times
    This only works if we give you the answers!
    """
    
    JITTER = 0.025 #2 ms of jitter allowed
    
    #first match the two sets of spike times. Anything within JITTER_MS
    #is considered a match (but only one per time frame!)
    
    #order the lists
    detected = np.sort(APTimes)
    actual = np.sort(actualTimes)
    
    #remove spikes with the same times (these are false APs)
    temp = np.append(detected, -1)
    detected = detected[plt.find(plt.diff(temp) != 0)]
 
    #find matching action potentials and mark as matched (trueDetects)
    trueDetects = [];
    for sp in actual:
        z = plt.find((detected >= sp-JITTER) & (detected <= sp+JITTER))
        if len(z)>0:
            for i in z:
                zz = plt.find(trueDetects == detected[i])
                if len(zz) == 0:
                    trueDetects = np.append(trueDetects, detected[i])
                    break;
    percentTrueSpikes = 100.0*len(trueDetects)/len(actualTimes)
    
    #everything else is a false alarm
    totalTime = (actual[len(actual)-1]-actual[0])
    falseSpikeRate = (len(APTimes) - len(actualTimes))/totalTime
    detected_total = len(APTimes)
    tp = len(trueDetects)
    fp = len(APTimes) - len(trueDetects)
    fn = len(actualTimes) - len(trueDetects)

    print 'Action Potential Detector Performance performance: '
    print '     Correct number of action potentials = ' + str(len(actualTimes))
    print '     Percent True Spikes = ' + str(percentTrueSpikes)
    print '     False Spike Rate = ' + str(falseSpikeRate) + ' spikes/s'
    print '     Detected: %d -  TP: %d/%d -  FP: %d/%d - FN: %d/%d   spikes' % (detected_total,tp,detected_total,fp,detected_total,fn,len(actualTimes))
    print 
    return {'Percent True Spikes':percentTrueSpikes, 'False Spike Rate':falseSpikeRate}
    

def robust_max(y,sigmas=4):
    m=y.mean()
    y=y-m
    max_y= sigmas*y.var()+m
    return max_y


    
def plot_spikes(time,voltage,APTimes,titlestr):
    """
    plot_spikes takes four arguments - the recording time array, the voltage
    array, the time of the detected action potentials, and the title of your
    plot.  The function creates a labeled plot showing the raw voltage signal
    and indicating the location of detected spikes with red tick marks (|)
    """
    plt.figure()
    
    ##Your Code Here    
    
    plt.plot(time,voltage)
    plt.ylabel('Voltage (mV)')
    plt.xlabel('Time (s)')
    plt.title(titlestr)
    
    max_voltage= robust_max(voltage)
    max_voltage=np.max(voltage)
    delta_pos=0.1*max_voltage
    delta_height=delta_pos+0.05*max_voltage
    
    #for t in APTimes:
    #    plt.vlines(t,max_voltage+delta_pos, max_voltage+delta_height,color='r',linewidth=2)
    plt.show()
    


def plot_waveforms(time,voltage,APTimes,titlestr):
    """
    plot_waveforms takes four arguments - the recording time array, the voltage
    array, the time of the detected action potentials, and the title of your
    plot.  The function creates a labeled plot showing the waveforms for each
    detected action potential
    """
   
    plt.figure()
    plt.ylabel('Voltage (mV)')
    plt.xlabel('Time (s)')
    plt.title(titlestr)
    for i in range(0,len(APTimes)):
    #for i in range(7,8):
        t=APTimes[i]
        index=np.where(time==t)[0]
        delta_i=40
        i_start = max(index-delta_i,0)
        i_end = min(index+delta_i,time.size)
        x=time-t
        plt.xlim(-0.003,0.003)
        plt.plot(x[i_start:i_end],voltage[i_start:i_end])
    plt.show()
    

        
##########################
#You can put the code that calls the above functions down here    
if __name__ == "__main__":
    #dataset='easy_practice'
    #dataset='example'
    dataset='hard_practice'
    t,v = load_data('spikes_%s.npy' % (dataset))    
    i_start,i_end=0,len(v)
    plt.plot(range(i_start,i_end),-v[i_start:i_end])
    #plt.plot(t[i_start:i_end],-v[i_start:i_end])
    #plt.show()

    actualTimes = get_actual_times('spikes_%s_answers.npy' % (dataset))
    #APTime = bad_AP_finder(t,v)
    APTime = good_AP_finder(t,v)
    print "Dataset %s." % (dataset)
    detector_tester(APTime,actualTimes)
    #plot_spikes(t,v,APTime,"Action potentials in raw signal (dataset %s )" % (dataset))
    #plot_waveforms(t,v,APTime,'Waveforms (dataset %s )' % (dataset))
    plot_waveforms(t,-v,actualTimes,'Waveforms (dataset %s )' % (dataset))

    
    
    #print np.where(abs(t-0.3)<0.001 )


