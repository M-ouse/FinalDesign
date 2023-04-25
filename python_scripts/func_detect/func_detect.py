import re
import os

linux_path = "/home/secondst/linux/linux/"

def func_detec(commits):
    pattern = re.compile(r'[0-9a-zA-Z_]*\(')
    results = []
    i = 0
    for commit in commits:
        i += 1
        p = os.popen("git show "+commit)
        try:
            lines = p.readlines()
        except:
            print("error at "+commit)
            continue
        t = []
        for line in lines:
            if "@@" in line:
                funcs = pattern.findall(line)
                if len(funcs) > 0:
                    t.append(funcs[0])
        if len(t) == 0:
            continue
        for func in t:
            if len(func) < 2:
                t.remove(func)

        #print(i,commit,set(t))
        results.append([commit,set(t)])
        #final = results[0] & results[1]
        #input()
    return results

def getLogCommits(filename):
    filename = linux_path + filename
    pattern = re.compile(r'[0-9a-z]{40}')
    p = os.popen("git log " + filename)
    val = p.read()
    commits = pattern.findall(val)
    #print(len(commits),commits)
    return commits

os.chdir(linux_path)
commits = getLogCommits("kernel/padata.c")
funcs = func_detec(commits) # from new to old

commit = "07928d9bfc81"
target_commit = ""
target_funcsSet = {}
print(commit," rely on :")
found = 0
for i in range(len(funcs)):
    iter_commit = funcs[i][0]
    iter_funcsSet = funcs[i][1]

    if commit in iter_commit:
        target_commit = funcs[i][0]
        target_funcsSet = funcs[i][1]
        found = 1
    
    if found == 1:
        ans = target_funcsSet & iter_funcsSet
        if ans:
            print(iter_commit,ans)
