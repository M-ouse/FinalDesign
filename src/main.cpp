#include "llvm/Analysis/BasicAliasAnalysis.h"
#include "llvm/Analysis/CFGPrinter.h"
#include "llvm/Analysis/DependenceAnalysis.h"
#include "llvm/Analysis/MemoryDependenceAnalysis.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Pass.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Scalar/InstSimplifyPass.h"
#include "llvm/Transforms/Scalar/SimplifyCFG.h"
#include <cstdio>
#include <fstream>
#include <llvm/Bitcode/BitcodeReader.h>
#include <llvm/IR/PassManager.h>
#include <llvm/Support/YAMLTraits.h>
#include <set>
#include <vector>

#include "common.h"
#include "controlFlowAnalysis.h"
#include "dataFlowAnalysis.h"
#include "third_party/plog/Log.h"
#include "llvm/Support/Debug.h"

using namespace llvm;

// static cl::opt<std::string>
//     InputBitcode1("i1", cl::Required, cl::desc("Specify input bitcode path"),
//                   cl::value_desc("path"));

// static cl::opt<std::string>
//     InputBitcode2("i2", cl::Required, cl::desc("Specify input bitcode path"),
//                   cl::value_desc("path"));
// static cl::opt<std::string> ConfigPath("c", cl::Required, cl::desc("Specify
// config path"), cl::value_desc("path"));

sConfig gConfig;
std::string gCurrentModule;

int main(int argc, const char *argv[]) {
  SMDiagnostic Err;
  LLVMContext *LLVMCtx = new LLVMContext();
  cl::ParseCommandLineOptions(argc, argv);

  // parse config in json
  gConfig.parseBasic("config/config.json");
  std::string InputBitcode1 = gConfig.IRFile1;
  std::string InputBitcode2 = gConfig.IRFile2;

  std::unique_ptr<Module> M1 = parseIRFile(InputBitcode1, Err, *LLVMCtx);
  if (!M1) {
    Err.print(InputBitcode1.c_str(), errs());
    return -1;
  }

  std::unique_ptr<Module> M2 = parseIRFile(InputBitcode2, Err, *LLVMCtx);
  if (!M2) {
    Err.print(InputBitcode2.c_str(), errs());
    return -1;
  }
  // pasre config

  // build pass manager
  LoopAnalysisManager LAM;
  FunctionAnalysisManager FAM;
  CGSCCAnalysisManager CGAM;
  ModuleAnalysisManager MAM;
  // ModulePassManager MPM;

  PassBuilder PB;

  FAM.registerPass([&] { return DependenceAnalysis(); });
  FAM.registerPass([&] { return BasicAA(); });
  FAM.registerPass([&] { return ControlFlow(); });
  FAM.registerPass([&] { return drawDFG(); });
  // FAM.registerPass([&] {return LongestPathAnalysis();});
  // MAM.registerPass([&] {return FunctionPairingAnalysis();});

  // Register all the basic analyses with the managers.
  PB.registerModuleAnalyses(MAM);
  PB.registerCGSCCAnalyses(CGAM);
  PB.registerFunctionAnalyses(FAM);
  PB.registerLoopAnalyses(LAM);
  PB.crossRegisterProxies(LAM, FAM, CGAM, MAM);

  auto FPM = PB.buildFunctionSimplificationPipeline(llvm::OptimizationLevel::O2,
                                                    ThinOrFullLTOPhase::None);
  // FPM.addPass(EHPairingWarpperPass());

  // MPM.addPass(PairingWrapper());

  // MPM.addPass(createModuleToFunctionPassAdaptor(std::move(FPM)));

  // MPM.addPass(EHPairingWarpperPass());
  // MPM.run(*M, MAM);

  std::vector<AnalyzedControlFlowInfo> *IRFile1FuncAnalysis =
      new std::vector<AnalyzedControlFlowInfo>();
  std::vector<AnalyzedControlFlowInfo> *IRFIle2FuncAnalysis =
      new std::vector<AnalyzedControlFlowInfo>();
  // PLOG(plog::debug) << "Hello log!"; // function-style macro

  PLOG_INFO_IF(gConfig.severity.info)
      << "Resolve " << M1->getName() << " ... ...\n";
  gCurrentModule = M1->getName().str();
  for (Function &F : *M1) {
    // FAM.getResult<ControlFlow>(F);
    if (!F.isDeclaration()) {
      PLOG_DEBUG_IF(gConfig.severity.debug)
          << "Run FAM in " << F.getName() << "\n";
      AnalyzedControlFlowInfo res = FAM.getResult<ControlFlow>(F);
      if (res.valid) {
        IRFile1FuncAnalysis->push_back(res);
      }
    }
  }

  PLOG_INFO_IF(gConfig.severity.info)
      << "Resolve " << M2->getName() << " ... ...\n";
  gCurrentModule = M2->getName().str();
  for (Function &F : *M2) {
    // FAM.getResult<ControlFlow>(F);
    if (!F.isDeclaration()) {
      PLOG_DEBUG_IF(gConfig.severity.debug)
          << "Run FAM in " << F.getName() << "\n";
      AnalyzedControlFlowInfo res = FAM.getResult<ControlFlow>(F);
      if (res.valid) {
        IRFIle2FuncAnalysis->push_back(res);
      }
    }
  }

  PLOG_INFO_IF(gConfig.severity.info) << "Starting Basicblock match"
                                      << " ... ...\n";
  inconsistencyAnalysis *result = new inconsistencyAnalysis();
  StringRef targetFunc = gConfig.targetFunction;
  result->inconsistencyAnalysisWrapper(IRFile1FuncAnalysis, IRFIle2FuncAnalysis,
                                       targetFunc);
  return 0;
}