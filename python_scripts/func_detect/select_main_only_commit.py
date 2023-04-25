import re
import os
import time

lts_linux_path = "/home/secondst/linux/linux_exp"
mainline_linux_path = "/home/secondst/linux/linux"
blame_file = "net/sunrpc/xprt.c"

def parse_blame(filename):

    #return sets
    commits = set()
    commit_time = {}
    commit_lines = {}

    #timestamp regex
    date_pattern = re.compile(r'\d+-\d+-\d+ \d+:\d+:\d+')
    p = os.popen("git blame " + filename)
    lines = p.readlines()
    lineNum = 0

    #traverse lines in git blame <file>
    for line in lines:
        #print(line)
        lineNum += 1
        t = line.split(" ")
        commitId = t[0]
        date_ = date_pattern.findall(line)

        # detect timestamp, add commit-time relation
        timeStamp = 0
        if len(date_) > 0:
            timeArray = time.strptime(date_[0], "%Y-%m-%d %H:%M:%S")
            timeStamp = int(time.mktime(timeArray))
            if commitId not in commit_time:
                commit_time[commitId] = timeStamp
        
        # add commit-lines relationship
        if commitId not in commit_lines:
            commit_lines[commitId] = [lineNum]
        else:
            commit_lines[commitId].append(lineNum)

        # collect all commits
        commits.add(commitId)
    return commits,commit_time,commit_lines

os.chdir(lts_linux_path)
lts_commits,lts_commit_time,lts_commit_lines = parse_blame(blame_file)
os.chdir(mainline_linux_path)
mainline_commits,mainline_commit_time,mainline_commit_lines = parse_blame(blame_file)

print("mainline_commits:\n",mainline_commits)
print("lts_commits:\n",lts_commits)
print("mainline_commits-lts_commits:\n",mainline_commits-lts_commits)
print("lts_commits-mainline_commits:\n",lts_commits-mainline_commits)

main_only = mainline_commits-lts_commits
print("checking strings ... ...")
#str_pattern = re.compile(r"[+].*spin_lock")
str_pattern = re.compile(r"[+,-].*spin_lock\(&xprt->transport_lock\)")
for commit in main_only:
    p = os.popen("git show -p " + commit)
    content = p.read()
    l_str_pattern = str_pattern.findall(content)
    if len(l_str_pattern) > 0 and "xprt_destroy" in content:
        print(commit)
