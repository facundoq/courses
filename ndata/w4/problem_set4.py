#
#  NAME
#    problem_set4.py
#
#  DESCRIPTION
#    In Problem Set 4, you will classify EEG data into NREM sleep stages and
#    create spectrograms and hypnograms.
#
from __future__ import division
import numpy as np
import matplotlib.pylab as plt
import matplotlib.mlab as m
import scipy.signal as ss

def load_examples(filename):
    """
    load_examples takes the file name and reads in the data.  It returns an
    array containing the 4 examples of the 4 stages in its rows (row 0 = REM;
    1 = stage 1 NREM; 2 = stage 2; 3 = stage 3 and 4) and the sampling rate for
    the data in Hz (samples per second).
    """
    data = np.load(filename)
    return data['examples'], int(data['srate'])

def load_eeg(filename):
    """
    load_eeg takes the file name and reads in the data.  It returns an
    array containing EEG data and the sampling rate for
    the data in Hz (samples per second).
    """
    data = np.load(filename)
    return data['eeg'], int(data['srate'])

def load_stages(filename):
    """
    load_stages takes the file name and reads in the stages data.  It returns an
    array containing the correct stages (one for each 30s epoch)
    """
    data = np.load(filename)
    return data['stages']

def plot_examples(example,rate):
    """
    This function creates a figure with 4 lines to show the overall psd for 
    the four sleep examples. (Recall row 0 is REM, rows 1-3 are NREM stages 1,
    2 and 3/4)
    """
    plt.figure()
    titles=['REM',"NREM 1","NREM 2","NREM 3/4"]
    for i in range(example.shape[0]):
        plt.subplot(2,2, (i+1) % 4)
        y=example[i,:]
        x=range(len(y))
        x=np.array(x)/rate
        plt.plot(x,y)
        plt.title(titles[i])
        plt.xlabel('Time (s)')
        plt.ylabel('Amplitude')
    plt.show()
    ##YOUR CODE HERE    
    
    return

def plot_example_psds(example,rate):
    """
    This function creates a figure with 4 lines to show the overall psd for 
    the four sleep examples. (Recall row 0 is REM, rows 1-3 are NREM stages 1,
    2 and 3/4)
    """
    plt.figure()
    for i in range(example.shape[0]):
        y=example[i,:]
        #y=y/np.sum(y)
        pxx,frequencies=m.psd(y,Fs=rate,NFFT=64)
        #pxx=pxx/sum(abs(pxx))
        pxx=np.log10(pxx)*10
        plt.plot(frequencies,pxx)
        #plt.psd(y,Fs=rate,NFFT=512)
        #plt.xlim([0,20])
    plt.legend(['REM',"NREM 1","NREM 2","NREM 3/4"])
    plt.xlabel('Frequency')
    plt.ylabel('Amplitude')
    plt.title('Power spectra')
    plt.show()
    ##YOUR CODE HERE    
    
    return

def plot_example_spectrograms(example,rate):
    """
    This function creates a figure with spectrogram sublpots to of the four
    sleep examples. (Recall row 0 is REM, rows 1-3 are NREM stages 1,
    2 and 3/4)
    """
    titles=['REM',"NREM 1","NREM 2","NREM 3/4"]
    plt.figure()
    for i in range(example.shape[0]):
        plt.subplot(2,2, (i+1) % 4)
        plt.specgram(example[i,:],Fs=rate,NFFT=1024)
        plt.xlabel('Time')
        plt.ylabel('Frequency') 
        plt.title('Spectrogram for %s' % titles[i])
    plt.show()
    
    return
      
            
def classify_epoch(epoch,rate):
    """
    This function returns a sleep stage classification (integers: 1 for NREM
    stage 1, 2 for NREM stage 2, and 3 for NREM stage 3/4) given an epoch of 
    EEG and a sampling rate.
    """
    #frequencies,pxx=ss.welch(epoch,fs=rate,nfft=1024)
    
    #plt.subplot(2,1,1)
    #plt.plot(frequencies,pxx)
    #plt.subplot(2,1,2)
    pxx,frequencies=m.psd(epoch,Fs=rate,NFFT=256,detrend=plt.detrend_linear)
    ids=frequencies<=55;
    pxx=pxx[ids]
    frequencies=frequencies[ids]

    pxx=pxx/np.sum(np.abs(pxx))
    pxx=np.log10(pxx)*10
    pxx=ss.detrend(pxx)

    #plt.plot(frequencies,pxx)
    #plt.xlim([0,20])
    #plt.ylim([-40,40])
    #plt.show()
    
    #mean=np.mean(pxx)
    #pxx = pxx / abs(np.max(pxx))
    indices_nrem34=np.logical_and(0<=frequencies,frequencies<=4)
    #std_nrem34= np.std(pxx[indices_nrem34])/mean
    std_nrem34= np.mean(pxx[indices_nrem34])


    indices_nrem2=np.logical_and(11<=frequencies,frequencies<=14.5)
    #std_nrem2=np.std(pxx[indices_nrem2])/mean
    std_nrem2= np.mean(pxx[indices_nrem2])

    #print (std_nrem2,std_nrem34)
    #print mean
    NREM2_THRESHOLD=-2
    NREM34_THRESHOLD=9
    if (std_nrem34 > NREM34_THRESHOLD and std_nrem2 <= 0 ):
        return 3
    elif (std_nrem2 > NREM2_THRESHOLD ):
        return 2
    else: 
        return 1

    # if (std_nrem34 > NREM34_THRESHOLD and std_nrem2 > NREM2_THRESHOLD ):
    #     return 20
    # elif (std_nrem34 > NREM34_THRESHOLD ):
    #     return 3
    # elif (std_nrem2 > NREM2_THRESHOLD ):
    #     return 2
    # else: 
    #     return 1

def plot_hypnogram(eeg, stages, srate):
    """
    This function takes the eeg, the stages and sampling rate and draws a 
    hypnogram over the spectrogram of the data.
    """
    
    fig,ax1 = plt.subplots()  #Needed for the multiple y-axes
    
    #Use the specgram function to draw the spectrogram as usual
    ax1.specgram(eeg,Fs=srate,NFFT=1024)
    ax1.set_ylabel('Frequency (Hz)')
    #Label your x and y axes and set the y limits for the spectrogram
    #ax1.set_xlabel('')
    plt.xlabel('Time (seconds)')
    #plt.xlim([0,3600])
    ax2 = ax1.twinx() #Necessary for multiple y-axes
    
    #Use ax2.plot to draw the hypnogram.  Be sure your x values are in seconds
    #HINT: Use drawstyle='steps' to allow step functions in your plot

    #Label your right y-axis and change the text color to match your plot
    ax2.set_ylabel('NREM stage',color='b')
    x=np.arange(len(stages))*30
    ax2.plot(x,stages,drawstyle='steps')
    #plt.xlim([0,3600])
 
    #Set the limits for the y-axis 
 
    #Only display the possible values for the stages
    ax2.set_yticks(np.arange(1,4))
    ax2.set_ylim([0,4])
    
    #Change the left axis tick color to match your plot
    for t1 in ax2.get_yticklabels():
        t1.set_color('b')
    
    #Title your plot    
    plt.title('Hypnogram - Practice data')
    plt.show()

        
def classifier_tester(classifiedEEG, actualEEG):
    """
    returns percent of 30s epochs correctly classified
    """
    epochs = len(classifiedEEG)
    incorrect = np.nonzero(classifiedEEG-actualEEG)[0]
    percorrect = (epochs - len(incorrect))/epochs*100
    
    print 'EEG Classifier Performance: '
    print '     Correct Epochs = ' + str(epochs-len(incorrect))
    print '     Incorrect Epochs = ' + str(len(incorrect))
    print '     Percent Correct= ' + str(percorrect) 
    print 
    return percorrect
  
    
def test_examples(examples, srate):
    """
    This is one example of how you might write the code to test the provided 
    examples.
    """
    i = 0
    bin_size = 30*srate
    c = np.zeros((4,len(examples[1,:])/bin_size))
    while i + bin_size < len(examples[1,:]):
        for j in range(1,4):
            print "class %d" % j
            c[j,i/bin_size] = classify_epoch(examples[j,range(i,i+bin_size)],srate)
        i = i + bin_size
    
    totalcorrect = 0
    num_examples = 0
    titles=['REM',"NREM 1","NREM 2","NREM 3/4"]
    for j in range(1,4):
        canswers = np.ones(len(c[j,:]))*j
        print("Results for class %s:\n" % titles[j])
        correct = classifier_tester(c[j,:],canswers)
        totalcorrect = totalcorrect + correct
        num_examples = num_examples + 1
    
    average_percent_correct = totalcorrect/num_examples
    print 'Average Percent Correct= ' + str(average_percent_correct) + "\n"
    return average_percent_correct

def classify_eeg(eeg,srate):
    """
    DO NOT MODIFY THIS FUNCTION
    classify_eeg takes an array of eeg amplitude values and a sampling rate and 
    breaks it into 30s epochs for classification with the classify_epoch function.
    It returns an array of the classified stages.
    """
    bin_size_sec = 30
    bin_size_samp = bin_size_sec*srate
    t = 0
    classified = np.zeros(len(eeg)/bin_size_samp)
    while t + bin_size_samp < len(eeg):
       classified[t/bin_size_samp] = classify_epoch(eeg[range(t,t+bin_size_samp)],srate)
       t = t + bin_size_samp
    return classified
        
##########################
#You can put the code that calls the above functions down here    
if __name__ == "__main__":
    #YOUR CODE HERE
    # sampling rate= 128hz
    # REM similar to NREM 1 (no spindles)
    # NREM3/4 dominated by 1hz
    # 11-15hz Most prominent in NREM2
    #

    plt.close('all') #Closes old plots.
    
    ##PART 1
    #Load the example data
    examples,srate=load_examples('example_stages.npz')

    #Plot the psds
    
    #plot_examples(examples,srate)
    #plot_example_psds(examples,srate)
    #Plot the spectrograms
    #plot_example_spectrograms(examples,srate)    
    #Test the examples
    average_rate_examples=test_examples(examples,srate)
    
    #Load the practice data
    eeg, srate = load_eeg('practice_eeg.npz')
    #Load the practice answers
    stages = load_stages('practice_answers.npz')

    print("Results for practice dataset:\n")
    #Classify the practice data
    classified_stages=classify_eeg(eeg,srate)
    #Check your performance
    average_rate_practice=classifier_tester(classified_stages,stages)
    #print map(lambda x: int(x),list(classified_stages))
    #print stages

    #Generate the hypnogram plots
    plot_hypnogram(eeg,classified_stages,srate)
    test_eeg, test_srate = load_eeg('test_eeg.npz')
    test_classified_stages=classify_eeg(test_eeg,test_srate)
    plot_hypnogram(test_eeg,test_classified_stages,test_srate)

