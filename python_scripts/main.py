import config.config as config
import func_detect.func_detect_v2 as func_detect_v2

if __name__ == "__main__":
    out_config_path = config.output_path
    
    # first: compile ir, gen config file and send them to llvm module
    # second, run llvm module and get result,like lines,name of funcs,vars
    # thrid, search these strings in mainline unique commits