#!/usr/bin/env python
import numpy as np
class AverageQueue():

    def __init__(self, size):
        self.size = size
        self.arr = np.array([])

    def push(self, val):
        isInit = (self.arr.size == 0)
        if isInit:
            self.arr = np.array([val for i in range(self.size)])
        else:
            arr_tmp = self.arr[:-1]
            self.arr = np.hstack((np.array([val]), arr_tmp))

    def get_average(self):
        ave = np.average(self.arr)
        return ave
        
if __name__ == '__main__':
    ta = TemporalAverage(5)
    ta.push(0)
    print ta.get_average()
    ta.push(1)
    print ta.get_average()
    ta.push(4)
    print ta.get_average()










"""
class AverageQueue():

    def __init__(self, n_size):
        self.n_size = n_size
        self.queue = 

    def put(self, val):
    """

        
                
        

import Queue
class myQueue(Queue.Queue, object):
    def __init__(self, n_size):
        super(myQueue, self).__init__()
        self.n_size = n_size

    def put(self, val):
        super(myQueue, self).put(val)
    """
    def put(self, val): #override
        isInit = (selfb.qsize == 0)
        if isInit:
            for i in range(n_size):
                sup
                """




aq = myQueue(2)
aq.put(1)

# cannot inherit somehow


