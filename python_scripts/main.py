import config.config as config
import func_detect.func_detect_v2 as func_detect_v2
import single2ir.single2ir as single2dir
import json
import os
import sys
import shutil
import subprocess
import re

def result_filter(info):
    module_regx = re.compile(r'M[0-9]* ')
    line_regx = re.compile(r'line: [0-9]*')
    col_regx = re.compile(r'col: [0-9]*')
    name_regx = re.compile(r'op\'s realname is: [0-9a-zA-Z_]*')

    type = "None"
    module = -1
    realname = ""
    line = -1
    col = -1

    # in general, the following regex will match
    if "controlFlowInconsistencyAnalysis" in info:
        type = "CFG"
        if "M2 no call" in info: # cfg, ir2 no call, but ir1 has
            module = 1
            line = int(line_regx.findall(info)[0][6:])
        elif "M1 no call" in info: # cfg, ir1 no call, but ir2 has
            module = 2
            line = int(line_regx.findall(info)[0][6:])
        else:
            module = module_regx.findall(info)[0][1:-1]
            line = int(line_regx.findall(info)[0][6:])
    
    if "dataFlowInconsistencyAnalysis" in info:
        type = "DFG"
        if "lts" in info:
            module = 1
        else:
            module = 2
        line = int(line_regx.findall(info)[0][6:])
        col = int(col_regx.findall(info)[0][5:])
        realname = name_regx.findall(info)[0][18:]
    return [type,module,realname,line,col]

def test(funcs_in_effect):
    print("Analyzing... ",funcs_in_effect)
    for func_name in funcs_in_effect:    
        template_json = config.template_json_path
        with open(template_json, "r") as f:
            template = json.load(f)
            template["IRFile1"] = "./input/" + config.target_name + "_lts.ll"
            template["IRFile2"] = "./input/" + config.target_name + "_ups.ll"
            template["targetFunction"] = func_name
            template["AnalysisCFG"] = True
            template["AnalysisDFG"] = True
            template["Severity"]["fatal"] = True
        f.close()
        
        with open(config.llvm_module_config, "w") as f:
            json.dump(template, f, indent=4)
        f.close()

        os.chdir("./llvm_tool")
        cmd = "./stool"
        result = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        os.chdir(working_path) # return to working path

        output = result.stdout.decode('utf-8')
        error = result.stderr.decode('utf-8')
        
        out_lines = []
        analyzed_data = []
        
        _out_lines = output.split("\n")
        for line in _out_lines:
            if line not in out_lines and line != "":
                out_lines.append(line)
        for line in out_lines:
            # print(line)
            _t = result_filter(line)
            if _t not in analyzed_data:
                analyzed_data.append(_t)

        # test only
        m1_cfg_inconsistency_line = []
        m1_dfg_inconsistency_line = []
        m1_common_inconsistency_line = []
        m2_cfg_inconsistency_line = []
        m2_dfg_inconsistency_line = []
        m2_common_inconsistency_line = []
        for data in analyzed_data:
            if data[1] == 1:
                if data[0] == "CFG":
                    m1_cfg_inconsistency_line.append(data[3])
                if data[0] == "DFG":
                    m1_dfg_inconsistency_line.append(data[3])
            if data[1] == 2:
                if data[0] == "CFG":
                    m2_cfg_inconsistency_line.append(data[3])
                if data[0] == "DFG":
                    m2_dfg_inconsistency_line.append(data[3])

        for line in m1_cfg_inconsistency_line:
            if line in m1_dfg_inconsistency_line:
                m1_common_inconsistency_line.append(line)
        print("M1 cfg inconsistency line: ", m1_cfg_inconsistency_line)
        print("M1 dfg inconsistency line: ", m1_dfg_inconsistency_line)
        print("M1 common_inconsistency_line: ", m1_common_inconsistency_line)

        for line in m2_cfg_inconsistency_line:
            if line in m2_dfg_inconsistency_line:
                m2_common_inconsistency_line.append(line)
        print("M2 cfg inconsistency line: ", m2_cfg_inconsistency_line)
        print("M2 dfg inconsistency line: ", m2_dfg_inconsistency_line)
        print("M2 common_inconsistency_line: ", m2_common_inconsistency_line)
        input()

if __name__ == "__main__":
    working_path = os.getcwd()
    out_json_path = config.out_json_path

    # TODO: consider a very complex patch, with multi modifications in multi funcs
    funcs_in_effect,funcs_in_adds,funcs_in_delete,target_files = func_detect_v2.patch_digest(config.patch_filename)
    # print("funcs_in_effect: ", funcs_in_effect)
    # print("funcs_in_adds: ", funcs_in_adds)
    # print("funcs_in_deletes: ", funcs_in_delete)
    # print(target_files) # target files should be used in compiling, target_file_directory & name should be replaced

    # first: compile ir, gen config file and send them to llvm module
    single2dir.run_command(config.outIR_path,config.linux_lts_path,config.target_file_directory,config.target_name,"_lts")
    single2dir.run_command(config.outIR_path,config.linux_ups_path,config.target_file_directory,config.target_name,"_ups")
    
    os.chdir(working_path) # return to working path

    try:
        cmd = "cp ./ir_files/* ./llvm_tool/input"
        os.system(cmd)
    except:
        print("copy irfiles failed")

    test(funcs_in_effect)
    test(funcs_in_adds)
    test(funcs_in_delete)
    # second, run llvm module and get result,like lines,name of funcs,vars

    # thrid, search these strings in mainline unique commits