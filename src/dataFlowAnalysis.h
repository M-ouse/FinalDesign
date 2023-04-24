#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/Statistic.h"
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
#include <llvm-15/llvm/IR/Function.h>
#include <llvm-15/llvm/IR/Instruction.h>
#include <llvm-15/llvm/IR/Value.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/PassManager.h>

#include <list>
#include <map>

namespace llvm {

#define maxInsCount 5000
class AnalyzedDataFlowInfo {
public:
  AnalyzedDataFlowInfo(Function &F);
  std::map<int, Instruction *> *pId2Ins; // id - ins
  std::map<Instruction *, int> *pIns2Id; // ins - id
  int (*pInsMap)[maxInsCount];
  std::map<llvm::Value *, std::string> *pVarMap;
  int instCount;

  Function *pF;
  bool valid = false;
};
class DataFlow : public AnalysisInfoMixin<DataFlow> {

  friend AnalysisInfoMixin<DataFlow>;
  static AnalysisKey Key;

public:
  class Analysis {
  public:
    typedef std::pair<Value *, StringRef> node;
    // 指令与指令之间的边
    typedef std::pair<node, node> edge;
    // 指令的集合
    typedef std::list<node> node_list;
    // 边的集合
    typedef std::list<edge> edge_list;
    // static char ID;
    // std::error_code error;
    edge_list inst_edges; // 存储每条指令之间的先后执行顺序
    edge_list edges;      // 存储data flow的边
    node_list nodes;      // 存储每条指令
    int num = 0;
    std::map<llvm::Value *, std::string> *varMap; // Value* -> realname

    int (*pInsMap)[maxInsCount];
    std::map<int, llvm::Instruction *> *pId2Ins; // id - ins
    std::map<llvm::Instruction *, int> *pIns2Id; // ins - id
    int instCount;

    Analysis();
    StringRef getValueName(Value *v);
    std::string changeIns2Str(Instruction *ins);
    std::string EscapeString(const std::string &Label);
    bool drawDataFlowGraph(Function &F);
    bool test(Instruction *I, Function &F);
    std::string op2realname(llvm::Value *, llvm::Instruction *);
    bool initVarMap(Function &F);
    bool buildDFG(Function &F);
  };

public:
  using Result = AnalyzedDataFlowInfo;
  Result run(Function &F, FunctionAnalysisManager &AM);
};

class dataFlowInconsistencyAnalysis {
  std::map<int, std::pair<int, float>> *matchMap;
  bool M1visited[maxInsCount];
  bool M2visited[maxInsCount];

public:
  dataFlowInconsistencyAnalysis();
  void Wrapper(std::vector<AnalyzedDataFlowInfo> *,
               std::vector<AnalyzedDataFlowInfo> *, StringRef);
  void match(AnalyzedDataFlowInfo, AnalyzedDataFlowInfo);
  float seqLCS(std::string, std::string);
  std::string op2realname(AnalyzedDataFlowInfo,llvm::Value*,llvm::Instruction*);
  void initialInconsistencyDetect(AnalyzedDataFlowInfo, AnalyzedDataFlowInfo);
  
};
} // namespace llvm