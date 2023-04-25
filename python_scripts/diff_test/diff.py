import re
import difflib

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

blockPattern = re.compile(r'BB\d')
irPattern = re.compile(r'\{.*\}')

def string_similar(s1, s2):
    return difflib.SequenceMatcher(None, s1, s2).quick_ratio()

def genBlockList(dotFilename):
    tmpBlockList = []
    with open(dotFilename,"r") as f:
        lines = f.readlines()
        for line in lines:
            if "shape=record" in line:
                #print(line)
                blockId = blockPattern.findall(line)[0]
                irs = irPattern.findall(line)
                if len(irs) > 0:
                    irsList = irs[0].split("\l")[1:-1] # remove BBx,}
                    tmpBlockList.append([blockId,irsList])
    return tmpBlockList

def getMatch(blockList1,blockList2):
    match_list = {}
    reverse_match_list = {}
    for block1 in blockList1:
        for block2 in blockList2:
            id1 = block1[0]
            id2 = block2[0]
            irs1 = block1[1]
            irs2 = block2[1]
            #irs_len1 = len(irs1)
            #irs_len2 = len(irs2)
            ir1_string = "".join(irs1)
            ir2_string = "".join(irs2)
            match_rate = string_similar(ir1_string,ir2_string)
            #if match_rate > 0.85:
            #    print(id1,id2,match_rate)
            if id1 not in match_list:
                match_list[id1] = [id2,match_rate]
            else:
                if match_list[id1][1] < match_rate:
                    match_list[id1] = [id2,match_rate]
    # de dup match
    # blocks2 to blocks in, because "reverse" to de dup in the first match result
    for block1 in match_list.keys():
        block2 = match_list[block1][0]
        rate = match_list[block1][1]
        if block2 not in reverse_match_list:
            reverse_match_list[block2] = [block1,rate]
        else:
            rate_old = reverse_match_list[block2][1]
            if rate_old < rate:
                reverse_match_list[block2] = [block1,rate]

    match_list.clear()
    for block2 in reverse_match_list.keys():
        block1 = reverse_match_list[block2][0]
        rate = reverse_match_list[block2][1]
        match_list[block1] = [block2,rate]
    for block1 in match_list.keys():
        print(block1,match_list[block1])

    return match_list

def getLLVMFuncInfo(filename):
    funcName = ""
    blockNum = 0
    blockCall = {}
    with open(filename,"r") as f:
        lines = f.readlines()
        for line in lines:
            line = line[:-1] # remove \n
            if "Analysis func info" in line:
                _t = line.split(" ")
                try:
                    funcName = _t[4]
                except:
                    pass
            if "Blocks" in line:
                _t = line.split(" ")
                try:
                    blockNum = int(_t[1])
                except:
                    pass
            if "BB" in line:
                _t = line.split(" ")
                _len = len(_t)
                funcCalls = []
                try:
                    blockName = _t[0]
                    for i in range(1,_len):
                        funcCalls.append(_t[i])
                    # wait optimization
                    if '' in funcCalls:
                        funcCalls.remove('')
                    blockCall[blockName] = funcCalls
                    # print(blockName,blockCall[blockName])
                except Exception as e:
                    print("fail at %s because %s" % (line,e))
                    pass
    return funcName,blockNum,blockCall

def funcCompare(matchResult,funcName1,funcName2,blockNum1,blockNum2,blockCall1,blockCall2):
    if blockNum1 != blockNum2:
        print("%s and %s blocks number not match\n" % (funcName1,funcName2))

    for block1 in matchResult.keys():
        block2 = matchResult[block1][0]
        print("checking %s_%s and %s_%s ... ..." % (funcName1,block1,funcName2,block2))
        try:
            callList1 = blockCall1[block1]
        except:
            print(f"{bcolors.WARNING}In %s_%s , no call ir{bcolors.ENDC}" % (funcName1,block1))
            continue

        try:
            callList2 = blockCall2[block2]
        except:
            print("In %s_%s , no call ir" % (funcName2,block2))
            continue

        len1 = len(callList1)
        len2 = len(callList2)
        longer = max(len1,len2)

        if len1 != len2:
            print("In block %s-%s , call list len not match" % (block1,block2))

        for i in range(longer):
            try:
                call1 = callList1[i]
            except:
                call1 = "No func call"
            try:
                call2 = callList2[i]
            except:
                call2 = "No func call"
            if call1 != call2:
                print(f"{bcolors.WARNING}In block %s-%s , mismatch func: %s <=> %s{bcolors.ENDC}" % (block1,block2,call1,call2))


if __name__ == "__main__":
    blockList1 = genBlockList("./demo/usep0_CFG.dot") # CFG dot1 file blocks' relation
    blockList2 = genBlockList("./demo/usep1_CFG.dot") # CFG dot2 file blocks' relation
    match_result = getMatch(blockList1,blockList2) # block match result (ir strings similarity)

    # call sequence in each block
    funcName1, blockNum1, blockCall1 = getLLVMFuncInfo("./demo/func_info1.txt")
    funcName2, blockNum2, blockCall2 = getLLVMFuncInfo("./demo/func_info2.txt")
    
    # compare call sequence in each block
    funcCompare(match_result,funcName1,funcName2,blockNum1,blockNum2,blockCall1,blockCall2)