import re
import os


#linux_path = "/home/secondst/linux/linux_exp/"
#target_file_directory = "net/ipv4/"
#target_name = "ip_output"

# linux_path = "/home/secondst/linux/linux-4.9.y/"
# target_file_directory = "drivers/net/can/"
# target_name = "slcan"


def remove_uselsess_args(cmd):
    # remove error
    cmd = cmd.replace("-mpreferred-stack-boundary=3", "")
    cmd = cmd.replace("-mindirect-branch=thunk-extern", "")
    cmd = cmd.replace("-mindirect-branch-register", "")
    cmd = cmd.replace("-mindirect-branch-cs-prefix", "")
    cmd = cmd.replace("-fno-allow-store-data-races", "")
    cmd = cmd.replace("-fconserve-stack", "")
    cmd = cmd.replace("-mrecord-mcount", "")
    cmd = cmd.replace("-ftrivial-auto-var-init=zero", "")
    cmd = cmd.replace("-maccumulate-outgoing-args", "")
    cmd = cmd.replace("-fno-var-tracking-assignments", "")

    # remove warning
    cmd = cmd.replace("-falign-jumps=1", "")
    cmd = cmd.replace("-funit-at-a-time", "")
    cmd = cmd.replace("-fmerge-constants", "")
    # cmd = cmd.replace("", "")
    return cmd


def gen_command(outIR_path,linux_path,target_file_directory,target_name,version):
    cmd_file = linux_path + target_file_directory + "." + target_name + ".o.cmd"
    src_file = linux_path + target_file_directory + target_name + ".c"

    final_command = "clang "
    # pattern_command = re.compile(r":= gcc .*;")
    pattern_command = re.compile(r":= gcc .*")
    # print(cmd_file)
    with open(cmd_file, "r") as f:
        # print("open file")
        line_one = f.readline()
        _t = pattern_command.findall(line_one)
        print(_t)
        if (len(_t) != 0):
            print("start to parse command")
            raw_command = _t[0]
            raw_command = raw_command[6:]  # remove ":= gcc "

            output_index = raw_command.find(" -o ")
            raw_command = raw_command[:output_index]  # remove " -o *.o"

            final_command += "-g "  # add debug info
            final_command += "-S -emit-llvm "  # dump ir
            final_command += "-fno-inline "  # no inline
            final_command += raw_command
            final_command += " "+src_file  # corrsponding "-c"
            final_command += " -o " + outIR_path + "/" + target_name + version + ".ll"
            final_command = remove_uselsess_args(final_command)
    f.close()
    # print(final_command)
    return final_command


def run_command(outIR_path,linux_path,target_file_directory,target_name,version):
    os.chdir(linux_path)
    cmd = gen_command(outIR_path,linux_path,target_file_directory,target_name,version)
    os.system(cmd)
