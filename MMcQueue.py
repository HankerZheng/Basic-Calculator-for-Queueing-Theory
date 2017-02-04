# M/M/c Queue is a Queue with only `c` servers and an infinite buffer.
# Detail Definition of M/M/c Queue: https://en.wikipedia.org/wiki/M/M/c_queue
# 
# The inter-arrival time of the packets is a Possion R.V., while  The serving
# time of a packet is a Exponential R.V..
# 
# If a packet comes and there is at least one idle server, this packet would
# be served by one server. If a packet comes and there is no idle server, this
# packet would be dropped or blocked.
# 
# Basic Parameter of M/M/c/c queue:
#   1. Packet Arrival Rate: `arrival`, the parameter of Possion R.V.
#   2. Packet Serving Rate: `departure`, the parameter of Expo R.V.
#   3. Number of Servers:   `capacity`

import math

class MMcQueue(object):
    def __init__(self, arrival, departure, capacity):
        """
        Given the parameter of one M/M/c/c Queue, 
        initialize the queue with these parameter and calculate some parameters.
        `_rou`:     Server Utilization
        `_p0`:      Probability of that there is no packets in the queue
        `_pc`:      Probability of that there is exactly `capacity` packets in the queue,
                    that is, all the server is busy.
        `_probSum`:  p0 + p1 + p2 + ... pc - pc
        `_finalTerm`: 1/(c!) * (arrival / departure)^c
        """
        if capacity * departure <= arrival:
            raise ValueError("This Queue is unstable with the Input Parameters!!!")
        self._arrival = float(arrival)
        self._departure = float(departure)
        self._capacity = capacity
        self._rou = self._arrival / self._departure / self._capacity

        # init the parameter as if the capacity == 0
        powerTerm = 1.0
        factorTerm = 1.0
        preSum = 1.0
        # Loop through `1` to `self._capacity` to get each term and preSum
        for i in xrange(1, self._capacity + 1):
            powerTerm *= self._arrival / self._departure
            factorTerm /= i
            preSum += powerTerm * factorTerm
        self._finalTerm = powerTerm * factorTerm
        preSum -= self._finalTerm
        self._p0 = 1.0 / (preSum + self._finalTerm / (1 - self._rou))
        self._pc = self._finalTerm * self._p0
        self._probSum = preSum * self._p0


    @property
    def arrival(self):
        return self._arrival

    @property
    def departure(self):
        return self._departure

    @property
    def capacity(self):
        return self._capacity

    def getPk(self, k):
        """
        Return the probability when there are `k` packets in the system
        """
        if k == 0:
            return self._p0
        elif k == self._capacity:
            return self._pc
        elif k < self._capacity:
            factorTerm = 1.0 / math.factorial(k)
            powerTerm = math.pow(self._arrival / self._departure, k)
            return self._p0 * factorTerm * powerTerm
        else:
            return self._finalTerm * math.pow(self._rou, k - self._capacity) * self._p0

    def getQueueProb(self):
        """
        Return the probability when a packet comes, it needs to queue in the buffer.
        That is, P(W>0) = 1 - P(N < c)
        Also known as Erlang-C function
        """
        return 1.0 - self._probSum

    def getIdleProb(self):
        """
        Return the probability when the sever is idle.
        That is , P(N=0)
        """
        return self._p0

    def getAvgPackets(self):
        """
        Return the average number of packets in the system (in service and in the queue)
        """
        return self._rou / (1 - self._rou) * self.getQueueProb() + self._capacity * self._rou

    def getAvgQueueTime(self):
        """
        Return the average time of packets spending in the queue
        """
        return self.getQueueProb() / (self._capacity * self._departure - self._arrival)

    def getAvgQueuePacket_Given(self):
        """
        Given there is packet in the queue,
        return the average number of packets in the queue
        """
        return self._finalTerm * self._p0 / (1.0 - self._rou) / (1.0 - self._rou)

    def getAvgQueueTime_Given(self):
        """
        Given a packet must wait, 
        return the average time of this packet spending in the queue
        """
        if self.getQueueProb() == 0:
            return 0
        return self.getAvgQueuePacket_Given() / (self.getQueueProb() * self._arrival)

    def getAvgResponseTime(self):
        """
        Return the average time of packets spending in the system (in service and in the queue)
        """
        return self.getAvgQueueTime() + 1.0 / self._departure

    def getAvgPacketInSystem(self):
        """
        Return the average number of packets in the system.
        """
        return self.getAvgResponseTime() * self._arrival

    def getAvgBusyServer(self):
        """
        Return the average number of busy Server.
        """
        return self.arrival / self.departure


    def getPorbWhenQueueTimeLargerThan(self, queueTime):
        """
        Return the probability when the queuing time of the packet is larger than `queueTime`
        That is P(W > queueTime) = 1 - P(W <= queueTime)
        """
        firstTerm = self._pc / (1.0 - self._rou)
        expTerm = - self._capacity * self._departure * (1.0 - self._rou) * queueTime
        secondTerm = math.exp(expTerm)
        return firstTerm * secondTerm

if __name__ == '__main__':
    thisQueue = MMcQueue(3,3,6)
    queueTime = 0.001
    # print "rou = ", thisQueue._rou
    # print "probSum = ", thisQueue._probSum
    print "Avg. # of Packets in System", thisQueue.getAvgPacketInSystem()
    print "Avg. # of Busy Server:\t\t", thisQueue.getAvgBusyServer()
    print "Idle Probability: \t\t\t", thisQueue.getIdleProb()
    print "Queuing Probability: \t\t", thisQueue.getQueueProb()
    print "Given wait, Avg. Wait Time \t", thisQueue.getAvgQueueTime_Given()
    print "Avg. Queuing Time: \t\t\t", thisQueue.getAvgQueueTime()
    print "P[Queuing Time >= %.4f]\t" % queueTime, thisQueue.getPorbWhenQueueTimeLargerThan(queueTime) * 100, "%"