

# def find_peaks(x,y):
#     dv=np.gradient(y)
#     state=0
#     sign_switch=[]
#     for i in range(1,len(y)-1):
#         if state==0:
#             if (dv[i]<0):
#                 sign_switch.append(i)
#                 state=1
#         else:
#             if state==1:
#                 if (dv[i]>0):
#                     sign_switch.append(i)
#                     state=0
#     return np.asarray(sign_switch)

# def remove_similar_values(v,dx):
#     result=[]
#     if (len(v)>0):
#         last=v[0]-dx-1
#         for i in range(0,len(v)):
#             if (abs(last-v[i])>dx):
#                 result.append(v[i])
#                 last=v[i]
#     return np.asarray(result)

# def consecutive_sequences(x):
#     result=[]
#     m=len(v)
#     if (m>0):
#         i=0
#         while i<m-1:
#             start=i
#             while abs(x[i+1]-x[i])<=1:
#                 i=i+1
#             result.append(x[start:i+1])

#         if (result=[])
#             result=[x[m]]
#     return result


# def old_ap_finder(time,voltage):
# APTimes = []
   
# #Let's make sure the input looks at least reasonable
# if (len(voltage) != len(time)):
#     print "Can't run - the vectors aren't the same length!"
#     return APTimes
# voltage=np.copy(voltage)
# voltage[abs(voltage)<50]=0
# #voltage=smooth(voltage,5)
# max_voltage=max(abs(voltage))
# voltage=voltage/max_voltage
# min_amplitude=0.5
# min_dy=10
# min_dx=0.002
# min_dx=0.00
# max_slope=0.1

# slope_crossings=[]
# dv = np.gradient(voltage)
# peaks = find_peaks(time,voltage)
# peaks=remove_consecutive(peaks)
# #crossings = abs(dv)<max_slope
# #upper = voltage > min_amplitude
# #indexes= np.where(np.logical_and(crossings,upper) )
# #APTimes= t[indexes]
# APTimes=t[peaks]
# APTimes=remove_similar_values(APTimes,min_dx)
# print len(APTimes)
# return APTimes
