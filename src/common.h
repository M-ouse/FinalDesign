/*
#include "llvm/IR/BasicBlock.h"
#include <map>
#include <vector>
*/
#ifndef __common
#define __common

#include "third_party/json/json.hpp"
#include "third_party/plog/Initializers/ConsoleInitializer.h"
#include "third_party/plog/Initializers/RollingFileInitializer.h"
#include "third_party/plog/Log.h"

class sConfig {
public:
  std::string IRFile1;
  std::string IRFile2;
  std::string targetFunction;
  bool AnalysisCFG = false;
  bool AnalysisDFG = false;
  bool drawCFG = false;
  bool drawDFG = false;
  struct Severity {
    bool verbose;
    bool debug;
    bool info;
    bool warning;
    bool error;
    bool fatal;
    bool none;
  } severity;
  bool parseBasic(std::string configPath);
};

extern sConfig gConfig;
extern std::string gCurrentModule;

#endif