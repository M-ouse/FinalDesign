#include "llvm/Analysis/BlockFrequencyInfo.h"
#include "llvm/Analysis/BranchProbabilityInfo.h"
#include "llvm/Analysis/HeatUtils.h"
#include "llvm/IR/PassManager.h"
#include "llvm/Pass.h"
#include "llvm/Support/DOTGraphTraits.h"
#include "llvm/Support/FormatVariadic.h"

#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Type.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/raw_ostream.h"
#include <llvm/IR/Function.h>

#include <list>
#include <map>
#include <set>
#include <vector>

namespace llvm {

#define maxBBCount 1000

class AnalyzedControlFlowInfo {
public:
  AnalyzedControlFlowInfo(Function &F);
  std::map<int, BasicBlock *> *pId2BB; // id - block
  int (*pBBMap)[maxBBCount];
  int *pBBCount; // total bb count
  std::map<int, std::vector<llvm::StringRef>>
      *pCallInfo; // called function name string vector
  std::map<int, std::vector<void *>> *pCallInfo2; // test
  std::map<void *, int> *pInstance2line;          // ir instance - source line
  Function *pF;
  bool valid = false;
};

class ControlFlow : public AnalysisInfoMixin<ControlFlow> {

  friend AnalysisInfoMixin<ControlFlow>;
  static AnalysisKey Key;

public:
  class Analysis {
    std::string EscapeString(const std::string &Label);
    unsigned int getInstructionLine(llvm::Instruction *);

  public:
    std::error_code error;
    std::string str;
    int bbCount;                       // total bb count
    std::map<BasicBlock *, int> BB2Id; // block - id
    std::map<int, BasicBlock *> id2BB; // id - block
    int bbMap[maxBBCount][maxBBCount];
    std::map<int, std::vector<llvm::StringRef>> callInfo;
    std::map<int, std::vector<void *>> callInfo2;
    std::map<void *, int> instance2line; // ir instance - source line

    // public:
    Analysis() = default;
    ~Analysis() = default;
    bool draw(Function &F);
    bool FuncAnalysis(Function &F);
    bool dumpCalls();
    bool functionInfoExtractor(Function &F);
    bool buildCFG(Function &F);
    bool drawCFG(Function &F);
  };

  using Result = AnalyzedControlFlowInfo;
  Result run(Function &F, FunctionAnalysisManager &AM);
};

class inconsistencyAnalysis {
  std::map<int, std::pair<int, float>> matchMap;

public:
  void inconsistencyAnalysisWrapper(std::vector<AnalyzedControlFlowInfo> *,
                                    std::vector<AnalyzedControlFlowInfo> *,
                                    StringRef);
  void match(AnalyzedControlFlowInfo, AnalyzedControlFlowInfo);
  float seqLCS(std::string, std::string);
  void dumpMatchMap();
  void diffCallInstanceInBB(AnalyzedControlFlowInfo, AnalyzedControlFlowInfo);
  inconsistencyAnalysis() = default;
};

} // namespace llvm