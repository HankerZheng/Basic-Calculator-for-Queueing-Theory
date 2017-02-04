''''''''''''''''''''''''''''
' M|M|c|c Queue Calculator '
''''''''''''''''''''''''''''
Function MMcc_getCapacity(arrival As Double, departure As Double, probBlocking As Double):
    'M|M|c|c Queue Calculator'
    'Given the arrival rate, departure rate, and blocking probability, return the min capacity'
    Dim capacity As Double
    Dim preSum As Double
    Dim powerTerm As Double
    Dim factorTerm As Double
    Dim rou As Double
    
    rou = arrival / departure
    capacity = 1
    preSum = 1 + rou
    powerTerm = rou
    factorTerm = 1
    
    While (probBlocking * preSum) < powerTerm * factorTerm:
        capacity = capacity + 1
        powerTerm = powerTerm * rou
        factorTerm = factorTerm / capacity
        preSum = preSum + powerTerm * factorTerm
    Wend
    MMcc_getCapacity = capacity

End Function

Function MMcc_getP0(arrival As Double, departure As Double, capacity As Integer):
    
    Dim rou As Double
    Dim preSum As Double
    Dim powerTerm As Double
    Dim factorTerm As Double
    Dim i As Integer
    
    rou = arrival / departure
    preSum = 1
    powerTerm = 1
    factorTerm = 1
    
    For i = 1 To capacity Step 1
        powerTerm = powerTerm * rou
        factorTerm = factorTerm / i
        preSum = preSum + powerTerm * factorTerm
    Next
    
    MMcc_getP0 = 1# / preSum
End Function


Function MMcc_BusyServer(arrival As Double, departure As Double, capacity As Integer):
    Dim p0 As Double
    Dim ans As Double
    Dim curCnt As Integer
    Dim powerTerm As Double
    Dim factorTerm As Double
    Dim rou As Double
    
    rou = arrival / departure
    p0 = MMcc_getP0(arrival, departure, capacity)
    curCnt = 0
    powerTerm = 1
    factorTerm = 1
    ans = 0
    While curCnt <= capacity
        ans = ans + curCnt * factorTerm * powerTerm * p0
        curCnt = curCnt + 1
        factorTerm = factorTerm / curCnt
        powerTerm = powerTerm * rou
    Wend
    MMcc_BusyServer = ans
    
End Function

''''''''''''''''''''''''''''
'  M|M|c Queue Calculator  '
''''''''''''''''''''''''''''

Function MMc_getCapacity(arrival As Double, departure As Double, probQueuing As Double, alpha As Double, beta As Double, xi As Double):
    Dim capacity As Integer
    Dim preSum As Double
    Dim thisTerm As Double
    Dim rou As Double
    Dim pc As Double

    capacity = 1
    preSum = 1 + arrival / departure
    thisTerm = arrival / departure
    rou = arrival / departure / capacity

    pc = rou * (1 - rou)   'When c = 1, it is a M|M|1 Queue

    While (pc <= 0 Or pc > probQueuing * (1 - rou))
        capacity = capacity + 1
        rou = arrival / departure / capacity
        thisTerm = thisTerm * rou
        preSum = preSum + thisTerm
        If rou >= 1 Then
            pc = 1000
        Else
            pc = thisTerm / (preSum - thisTerm + thisTerm / (1 - rou))
        End If
    Wend

    While (pc <= 0 Or alpha * arrival * (1 - rou) < 1)
        capacity = capacity + 1
        rou = arrival / departure / capacity
        thisTerm = thisTerm * rou
        preSum = preSum + thisTerm
        If rou >= 1 Then
            pc = 1000
        Else
            pc = thisTerm / (preSum - thisTerm + thisTerm / (1 - rou))
        End If
    Wend
    
    If departure * (1 - rou) * xi * capacity < 200 Then
        While (pc <= 0 Or pc > (1 - rou) * beta / Exp(-departure * (1 - rou) * xi * capacity))
            capacity = capacity + 1
            rou = arrival / departure / capacity
            thisTerm = thisTerm * rou
            preSum = preSum + thisTerm
            If rou >= 1 Then
                pc = 1000
            Else
                pc = thisTerm / (preSum - thisTerm + thisTerm / (1 - rou))
            End If
        Wend
    End If

    MMc_getCapacity = capacity
End Function


Function MMc_getP0(arrival As Double, departure As Double, capacity As Integer):
    
    Dim rou As Double
    Dim preSum As Double
    Dim powerTerm As Double
    Dim factorTerm As Double
    Dim i As Integer
    
    preSum = 1
    powerTerm = 1
    factorTerm = 1
    rou = arrival / departure / capacity
    
    For i = 1 To capacity Step 1
        powerTerm = powerTerm * arrival / departure
        factorTerm = factorTerm / i
        preSum = preSum + powerTerm * factorTerm
    Next
    
    MMc_getP0 = 1# / (preSum + powerTerm * factorTerm / (1 - rou) - powerTerm * factorTerm)
End Function


Function MMc_BusyServer(arrival As Double, departure As Double):

    MMc_BusyServer = arrival / departure
End Function


Function MMc_ErlangC(arrival As Double, departure As Double, capacity As Integer, p0 As Double):

    Dim curCnt As Integer
    Dim powerTerm As Double
    Dim factorTerm As Double
    Dim rou As Double
    Dim i As Integer

    powerTerm = 1
    factorTerm = 1
    rou = arrival / departure / capacity

    For i = 1 To capacity Step 1
        powerTerm = powerTerm * arrival / departure
        factorTerm = factorTerm / i
    Next
    MMc_ErlangC = powerTerm * factorTerm * p0 / (1 - rou)
End Function


Function MMc_AvgPacket(arrival As Double, departure As Double, capacity As Integer, p0 As Double, erlangC As Double):

    Dim rou As Double

    rou = arrival / departure / capacity
    MMc_AvgPacket = rou / (1 - rou) * erlangC + capacity * rou
End Function
