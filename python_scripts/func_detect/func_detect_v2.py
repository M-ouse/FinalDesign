import re
import os

involved_function_pattern = re.compile(r'[0-9a-zA-Z_]*\(') # match function name where diffs in
added_pattern = re.compile(r'\+\t.*')
deleted_pattern = re.compile(r'-\t.*')
target_file = re.compile(r'diff --git a/.* ')

def func_detec(patch):
    _t_effect_funcs = []
    added_line_lists = []
    deleted_line_lists = []
    target_files = []

    funcs_in_adds = []
    funcs_in_deletes = []

    # get lines for each purpose
    for line in patch:
        if "@@" in line:
            funcs = involved_function_pattern.findall(line)
            if len(funcs) > 0:
                _t_effect_funcs.append(funcs[0][:-1]) # remove the last char: '('

        _added_lines = added_pattern.findall(line)
        if len(_added_lines) > 0:
            #print(_added_lines)
            for line in _added_lines:
                added_line_lists.append(line)

        _deleted_lines = deleted_pattern.findall(line)
        if len(_deleted_lines) > 0:
            #print(_deleted_lines)
            for line in _deleted_lines:
                deleted_line_lists.append(line)

        _target_files = target_file.findall(line)
        if len(_target_files) > 0:
            for line in _target_files:
                _t = line.split(" ")
                if "" in _t:
                    _t.remove("")
                # print(_t)
                _target = _t[-1][2:]
                # print(_target)
                target_files.append(_target)

    # get funcs from added lines
    for add_line in added_line_lists:
        funcs = involved_function_pattern.findall(add_line)
        if len(funcs) > 0:
            if funcs[0][:-1] != "":
                funcs_in_adds.append(funcs[0][:-1])
    # get funcs from deleted lines
    for del_line in deleted_line_lists:
        funcs = involved_function_pattern.findall(del_line)
        if len(funcs) > 0:
            if funcs[0][:-1] != "":
                funcs_in_deletes.append(funcs[0][:-1])
    
    return set(_t_effect_funcs), set(funcs_in_adds), set(funcs_in_deletes), set(target_files)

def patch_digest(patch_filename):
    with open(patch_filename, "r") as f:
        patch = f.readlines()
        funcs_in_effect,funcs_in_adds,funcs_in_delete,target_files = func_detec(patch)
        # print("funcs_in_effect: ", funcs_in_effect)
        # print("funcs_in_adds: ", funcs_in_adds)
        # print("funcs_in_deletes: ", funcs_in_delete)
    f.close()
    return funcs_in_effect,funcs_in_adds,funcs_in_delete, target_files
