#------------------------------------#
#  John Niemynski                    #
#  Testing python script for arctan  #
#------------------------------------#
import time
import mmap
import struct
#------------------------------#
# Global Initialized Variables #
#------------------------------#

inAoffset = 0
inBoffset = 4
ClkEnOffset = 8
resetOffset = 4
OutOffset = 0
arctanWriteInFile = open("/dev/mem", "r+b")
arctanWriteEnFile = open("/dev/mem", "r+b")
arctanReadOutFile = open("/dev/mem", "r+b")
inA = []
inB = []
with open("atanInaData.txt", "r") as f:
    for line in f:
        inA.append(line.strip())

with open("atanInbData.txt", "r") as f:
    for line in f:
        inB.append(line.strip())


writeDataAddr = mmap.mmap(arctanWriteInFile.fileno(), 32, offset=0x43C00000)
writeEnAddr = mmap.mmap(arctanWriteEnFile.fileno(), 32, offset=0x43C60000)
readOutAddr = mmap.mmap(arctanReadOutFile.fileno(), 32, offset=0x43C10000)

#enable the arctan module for data
writeEnAddr.seek(ClkEnOffset)
writeEnAddr.write(struct.pack('l', 1))#enable clk en
writeEnAddr.seek(resetOffset)
writeEnAddr.write(struct.pack('l', 1))#reset
time.sleep(0.01)
writeEnAddr.seek(resetOffset)
writeEnAddr.write(struct.pack('l', 0))#lift reset
#module now ready for data
outData = []
#write data into the input ports
for i in range(len(inA)):
    writeDataAddr.seek(inAoffset)
    writeDataAddr.write(struct.pack('I', int(inA[i],2)))
    writeDataAddr.seek(inBoffset)
    writeDataAddr.write(struct.pack('I', int(inB[i],2)))
    time.sleep(0.01) #adding some software delay even though system should be fast enough
    readOutAddr.seek(OutOffset)
    outData.append(struct.unpack('I', readOutAddr.read(4))[0])

with open("atanOutPythonData.txt","w") as f:
    for item in outData:
        #our design concatenates the same answer to each side of a 32 bit int
        #thus we want to remove the top 16 bits and collect the remainder
        #to format the number the way we want it
        item = item/(2**16)
        print(str(format(item,'016b')))
        f.write(format(item,'016b') + "\n")
        
arctanWriteInFile.close()
arctanWriteEnFile.close()
arctanReadOutFile.close()