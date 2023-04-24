#include "controlFlowAnalysis.h"
#include "common.h"
#include "third_party/plog/Log.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/Value.h"
#include <iomanip>
#include <llvm-15/llvm/IR/BasicBlock.h>
#include <llvm-15/llvm/IR/Function.h>
#include <llvm-15/llvm/IR/Instruction.h>
#include <llvm-15/llvm/IR/Instructions.h>
#include <llvm-15/llvm/Support/Casting.h>
#include <llvm/ADT/StringRef.h>
#include <llvm/Analysis/BasicAliasAnalysis.h>
#include <llvm/Support/raw_ostream.h>
#include <map>
#include <queue>
#include <regex>
namespace llvm {

std::string ControlFlow::Analysis::EscapeString(const std::string &Label) {
  std::string Str(Label);
  for (unsigned i = 0; i != Str.length(); ++i)
    switch (Str[i]) {
    case '\n':
      Str.insert(Str.begin() + i, '\\'); // Escape character...
      ++i;
      Str[i] = 'n';
      break;
    case '\t':
      Str.insert(Str.begin() + i, ' '); // Convert to two spaces
      ++i;
      Str[i] = ' ';
      break;
    case '\\':
      if (i + 1 != Str.length())
        switch (Str[i + 1]) {
        case 'l':
          continue; // don't disturb \l
        case '|':
        case '{':
        case '}':
          Str.erase(Str.begin() + i);
          continue;
        default:
          break;
        }
      [[fallthrough]];
    case '{':
    case '}':
    case '<':
    case '>':
    case '|':
    case '"':
      Str.insert(Str.begin() + i, '\\'); // Escape character...
      ++i;                               // don't infinite loop
      break;
    }
  return Str;
}

unsigned int ControlFlow::Analysis::getInstructionLine(llvm::Instruction *I) {
  unsigned lineNum = 0;
  unsigned colNum = 0;
  const DebugLoc &location = I->getDebugLoc();
  if (location) {
    lineNum = location.getLine();
    colNum = location.getCol();
  }
  return lineNum;
}

// TODO: ret val analysis
bool ControlFlow::Analysis::FuncAnalysis(Function &F) {

  PLOG_DEBUG_IF(gConfig.severity.debug)
      << "FuncAnalysis in " << F.getName() << "\n";

  for (int i_BB = 0; i_BB < bbCount; i_BB++) {
    BasicBlock *curBB = id2BB->at(i_BB); // id2BB[i_BB];
    bool hasCall = false;
    for (BasicBlock::iterator I_iter = curBB->begin(); I_iter != curBB->end();
         ++I_iter) { // dump instructions in the basic block
      llvm::Instruction *I = dyn_cast<llvm::Instruction>(I_iter);

      unsigned int lineNum = getInstructionLine(I);
      (*instance2line)[I] = lineNum; // add all instance-line relationship

      switch (I->getOpcode()) // detect the opcode type of the instruction
      {
      case llvm::Instruction::Call: // detect call instruction
      {
        llvm::CallInst *callInst = dyn_cast<llvm::CallInst>(I);
        llvm::Function *calledFunc = callInst->getCalledFunction();

        if (calledFunc == nullptr)
          break;

        if (!calledFunc->hasName()) // in case of null def
          break;

        // errs() << "In block: " << i_BB << " call " << calledFunc->getName()
        // << "\n";

        if (calledFunc->getName().contains("llvm"))
          break;

        if (callInfo->find(i_BB) != callInfo->end()) {
          (*callInfo)[i_BB].push_back(calledFunc->getName());

          (*callInfo2)[i_BB].push_back(I); // test now
        } else {
          std::vector<llvm::StringRef> *funcName =
              new std::vector<llvm::StringRef>();
          funcName->push_back(calledFunc->getName());
          (*callInfo)[i_BB] = *funcName;

          std::vector<void *> *callInstVec = new std::vector<void *>();
          callInstVec->push_back(I);         // test now
          (*callInfo2)[i_BB] = *callInstVec; // test now
        }
        hasCall = true; // not so rigorous, I don't know if there will be "no
                        // name" function call
        break;
      }
      case llvm::Instruction::Ret: // detect return instruction
      {
        llvm::ReturnInst *retInst = dyn_cast<llvm::ReturnInst>(I);
        llvm::Value *retVal = retInst->getReturnValue();
        if (retVal != nullptr) {
          // errs() << "In block: " << i_BB << " return " << *retVal << "\n";
        } else {
          // errs() << "In block: " << i_BB << " return "
          //        << "\n";
        }
        break;
      }
      }
    }
    if (!hasCall) {
      // TODO: null call
      // auto *ai = new AllocaInst(Type::getin);
    }
  }

  return true;
}

bool ControlFlow::Analysis::dumpCalls() {
  int blocksNum = callInfo->size();
  errs() << "Blocks: " << blocksNum << "\n";
  for (std::map<int, std::vector<llvm::StringRef>>::iterator it =
           callInfo->begin();
       it != callInfo->end(); ++it) {
    errs() << "BB" << it->first << " ";
    for (std::vector<llvm::StringRef>::iterator it2 = it->second.begin();
         it2 != it->second.end(); ++it2) {
      errs() << *it2 << " ";
    }
    errs() << "\n";
  }
  return true;
}

bool ControlFlow::Analysis::functionInfoExtractor(Function &F) { return true; }

bool ControlFlow::Analysis::buildCFG(Function &F) {
  PLOG_INFO_IF(gConfig.severity.info) << "buildCFG in " << F.getName();

  std::map<BasicBlock *, int> basicBlockMap; // block - id

  for (Function::iterator B_iter = F.begin(); B_iter != F.end();
       ++B_iter) { // iterate over basic blocks
    BasicBlock *curBB = &*B_iter;
    int fromCountNum;
    int toCountNum;
    if (basicBlockMap.find(curBB) != basicBlockMap.end()) {
      fromCountNum = basicBlockMap[curBB];
    } else {
      fromCountNum = bbCount;
      basicBlockMap[curBB] = bbCount++;
    }

    for (BasicBlock *SuccBB :
         successors(curBB)) { // dump edges from current basic block to its
                              // successors
      if (basicBlockMap.find(SuccBB) != basicBlockMap.end()) {
        toCountNum = basicBlockMap[SuccBB];
      } else {
        toCountNum = bbCount;
        basicBlockMap[SuccBB] = bbCount++;
      }
      bbMap[fromCountNum][toCountNum] = 1;
    }
  }
  for (auto iter = basicBlockMap.begin(); iter != basicBlockMap.end(); iter++) {
    (*id2BB)[iter->second] = iter->first;
  }
  return true;
}

ControlFlow::Analysis::Analysis() {
  // do init
  this->bbCount = 0;
  this->BB2Id = new std::map<BasicBlock *, int>();
  this->id2BB = new std::map<int, BasicBlock *>();
  this->callInfo = new std::map<int, std::vector<llvm::StringRef>>();
  this->callInfo2 = new std::map<int, std::vector<void *>>();
  this->instance2line = new std::map<void *, int>();
}

bool ControlFlow::Analysis::drawCFG(Function &F) {
  PLOG_DEBUG_IF(gConfig.severity.debug)
      << "Drawing CFG for " << F.getName() << "\n";
  raw_string_ostream rso(str);
  std::string _module =
      std::regex_replace(gCurrentModule, std::regex("input"), "output");
  std::string Filename = _module + ("_" + F.getName() + "_CFG" + ".dot").str();
  raw_fd_ostream file(Filename, error, sys::fs::OF_Text);
  file << "digraph \"CFG for'" + F.getName() + "\' function\" {\n";
  for (int fromBB = 0; fromBB < bbCount; fromBB++) {
    for (int toBB = 0; toBB < bbCount; toBB++) {
      if (bbMap[fromBB][toBB] == 1) {
        file << "\tBB" << fromBB << "-> BB" << toBB << ";\n";
      }
    }
  }
  for (int i_BB = 0; i_BB < bbCount; i_BB++) {
    BasicBlock *curBB = id2BB->at(i_BB); // id2BB[i_BB];
    file << "\tBB" << i_BB << " [shape=record, label=\"{";
    file << "BB" << i_BB << ":\\l";
    for (BasicBlock::iterator I_iter = curBB->begin(); I_iter != curBB->end();
         ++I_iter) { // dump instructions in the basic block
      llvm::Instruction *I = dyn_cast<llvm::Instruction>(I_iter);
      std::string instruction;
      llvm::raw_string_ostream(instruction) << *I;

      unsigned lineNum = 0;
      unsigned colNum = 0;
      const DebugLoc &location = I->getDebugLoc();
      if (location) {
        lineNum = location.getLine();
        colNum = location.getCol();
      }
      file << lineNum << ":" << colNum << " ";

      file << EscapeString(instruction)
           << "\\l "; // escape special characters is necessary
    }
    file << "}\"];\n";
  }
  file << "}\n";
  file.close();
  return true;
}

AnalyzedControlFlowInfo::AnalyzedControlFlowInfo(Function &F) {
  // errs() << "Info::Info in " << F.getName() << "\n";
  valid = false;
}

AnalysisKey ControlFlow::Key;
ControlFlow::Result ControlFlow::run(Function &F, FunctionAnalysisManager &AM) {
  PLOG_DEBUG_IF(gConfig.severity.debug)
      << "ControlFlow::run in " << F.getName();

  AnalyzedControlFlowInfo Result = AnalyzedControlFlowInfo(F);

  Analysis *A = new Analysis();

  A->buildCFG(F);
  if (gConfig.drawCFG)
    A->drawCFG(F);
  A->FuncAnalysis(F);
  // A->dumpCalls();

  // storage the result
  Result.pId2BB = (A->id2BB);
  Result.pBBMap = A->bbMap;
  Result.pBBCount = &(A->bbCount);
  Result.pCallInfo = (A->callInfo);
  Result.pCallInfo2 = (A->callInfo2);
  Result.pInstance2line = (A->instance2line);
  Result.pF = &F;
  Result.valid = true;

  return Result;
}

controlFlowInconsistencyAnalysis::controlFlowInconsistencyAnalysis() {
  // do init
  matchMap = new std::map<int, std::pair<int, float>>();
}

void controlFlowInconsistencyAnalysis::Wrapper(
    std::vector<AnalyzedControlFlowInfo> *IRFile1FuncAnalysis,
    std::vector<AnalyzedControlFlowInfo> *IRFIle2FuncAnalysis,
    StringRef targetFunc) {
  for (int i = 0; i < IRFile1FuncAnalysis->size(); i++) {
    for (int j = 0; j < IRFIle2FuncAnalysis->size(); j++) {
      AnalyzedControlFlowInfo info1 = IRFile1FuncAnalysis->at(i);
      AnalyzedControlFlowInfo info2 = IRFIle2FuncAnalysis->at(j);
      if (info1.pF->getName().equals(info2.pF->getName()) &&
          info1.pF->getName().equals(
              targetFunc)) { // match same function in two modules
        // begin analysis
        match(info1, info2);
        // dumpMatchMap();
        diffCallInstanceInBB(info1, info2);
      }
    }
  }
}

void controlFlowInconsistencyAnalysis::match(AnalyzedControlFlowInfo info1,
                                             AnalyzedControlFlowInfo info2) {
  PLOG_DEBUG_IF(gConfig.severity.debug)
      << "CFG Matching " << info1.pF->getName() << "\n";
  std::map<int, std::pair<int, float>> *_tMatchMap =
      new std::map<int, std::pair<int, float>>();
  std::map<int, std::pair<int, float>> *_reverseMatchMap =
      new std::map<int, std::pair<int, float>>();

  PLOG_DEBUG_IF(gConfig.severity.debug)
      << "\n"
      << info1.pF->getName() << " "
      << "blocks count: " << *info1.pBBCount << "\n"
      << info2.pF->getName() << " "
      << "blocks count: " << *info2.pBBCount << "\n";

  for (int i_BB = 0; i_BB < *info1.pBBCount; i_BB++) {
    for (int j_BB = 0; j_BB < *info2.pBBCount; j_BB++) {
      std::string seq1, seq2;
      auto toSeq = [](BasicBlock *bb) {
        std::string seq;
        for (BasicBlock::iterator I_iter = bb->begin(); I_iter != bb->end();
             ++I_iter) { // dump instructions in the basic block
          llvm::Instruction *I = dyn_cast<llvm::Instruction>(I_iter);
          std::string instruction;
          llvm::raw_string_ostream(instruction) << *I;
          seq += instruction;
        }
        return seq;
      };
      seq1 = toSeq(info1.pId2BB->at(i_BB));
      seq2 = toSeq(info2.pId2BB->at(j_BB));
      float ratio = seqLCS(seq1, seq2);
      if (_tMatchMap->find(i_BB) == _tMatchMap->end()) {
        _tMatchMap->insert(std::pair<int, std::pair<int, float>>(
            i_BB, std::pair<int, float>(j_BB, ratio)));
      } else {
        if (ratio > _tMatchMap->at(i_BB).second) {
          _tMatchMap->at(i_BB).first = j_BB;
          _tMatchMap->at(i_BB).second = ratio;
        }
      }
    }
  }

  // a reverse map, to de duplicate
  for (auto iter = _tMatchMap->begin(); iter != _tMatchMap->end(); iter++) {
    if (_reverseMatchMap->find(iter->second.first) == _reverseMatchMap->end()) {
      _reverseMatchMap->insert(std::pair<int, std::pair<int, float>>(
          iter->second.first,
          std::pair<int, float>(iter->first, iter->second.second)));
    } else {
      if (iter->second.second >
          _reverseMatchMap->at(iter->second.first).second) {
        _reverseMatchMap->at(iter->second.first).first = iter->first;
        _reverseMatchMap->at(iter->second.first).second = iter->second.second;
      }
    }
  }

  // generate real match map

  for (auto iter = _reverseMatchMap->begin(); iter != _reverseMatchMap->end();
       iter++) {
    matchMap->insert(std::pair<int, std::pair<int, float>>(
        iter->second.first,
        std::pair<int, float>(iter->first, iter->second.second)));
  }

  delete _tMatchMap;
  delete _reverseMatchMap;
}

float controlFlowInconsistencyAnalysis::seqLCS(std::string seq1,
                                               std::string seq2) {

  int len1 = seq1.length(), len2 = seq2.length();
  std::vector<std::vector<int>> dp(len1 + 1, std::vector<int>(len2 + 1, 0));
  for (int i = 1; i <= len1; ++i) {
    for (int j = 1; j <= len2; ++j) {
      if (seq1[i - 1] == seq2[j - 1]) {
        dp[i][j] = dp[i - 1][j - 1] + 1;
      } else {
        dp[i][j] = std::max(dp[i - 1][j], dp[i][j - 1]);
      }
    }
  }
  int lcs = dp[len1][len2];
  return 2.0 * lcs / (len1 + len2);
  // errs() << instruction << "\n";
}

void controlFlowInconsistencyAnalysis::dumpMatchMap() {
  for (auto it = matchMap->begin(); it != matchMap->end(); it++) {
    PLOG_DEBUG_IF(gConfig.severity.debug)
        << "BB" << it->first << "-"
        << "BB" << it->second.first << " "
        << "ratio: " << it->second.second << "\n";
  }
}

void controlFlowInconsistencyAnalysis::diffCallInstanceInBB(
    AnalyzedControlFlowInfo info1, AnalyzedControlFlowInfo info2) {
  // errs() << "diffCallInstance " << info1.pF->getName() << "\n";
  PLOG_INFO_IF(gConfig.severity.info) << "diffCallInstance ... ...";

  int maxModule1FuncBBId = *info1.pBBCount;

  auto dumpLine = [](std::vector<void *> instList, AnalyzedControlFlowInfo info,
                     int index) {
    llvm::Instruction *inst = (llvm::Instruction *)instList[index];
    std::map<void *, int> *_t = info.pInstance2line;
    unsigned int line = (*_t)[inst];
    return line;
  };

  // only for debug output

  for (int bb = 0; bb < maxModule1FuncBBId; bb++) {
    if (info1.pCallInfo->find(bb) == info1.pCallInfo->end()) {
      PLOG_DEBUG_IF(gConfig.severity.debug) << "M1 BB" << bb << " "
                                            << "no call instruction"
                                            << "\n";
    } else {
      PLOG_DEBUG_IF(gConfig.severity.debug) << "M1 BB" << bb << " "
                                            << "call instruction: ";
      for (auto iter = info1.pCallInfo->at(bb).begin();
           iter != info1.pCallInfo->at(bb).end(); iter++)
        PLOG_DEBUG_IF(gConfig.severity.debug) << *iter << " ";
    }

    if (matchMap->find(bb) == matchMap->end()) {
      PLOG_DEBUG_IF(gConfig.severity.debug)
          << "No match BB in M2 with BB" << bb << " in M1"
          << "\n\n";
      continue;
    } else {
      int matchBB = matchMap->at(bb).first;
      if (info2.pCallInfo->find(matchBB) == info2.pCallInfo->end()) {
        PLOG_DEBUG_IF(gConfig.severity.debug) << "M2 BB" << matchBB << " "
                                              << "no call instruction"
                                              << "\n\n";
        continue;
      } else {
        PLOG_DEBUG_IF(gConfig.severity.debug) << "M2 BB" << matchBB << " "
                                              << "call instruction: ";
        for (auto iter = info2.pCallInfo->at(matchBB).begin();
             iter != info2.pCallInfo->at(matchBB).end(); iter++)
          PLOG_DEBUG_IF(gConfig.severity.debug) << *iter << " ";
      }
    }
  }

  // debug output end

  for (int bb = 0; bb < maxModule1FuncBBId; bb++) {
    if (matchMap->find(bb) != matchMap->end()) {
      // so far ensure a match status
      int matchBB = matchMap->at(bb).first;
      double ratio = matchMap->at(bb).second;

      if (info1.pCallInfo2->find(bb) == info1.pCallInfo2->end() &&
          info2.pCallInfo2->find(matchBB) != info2.pCallInfo2->end()) {
        std::vector<void *> instList = info2.pCallInfo2->at(matchBB);
        int len = instList.size();
        for (int i = 0; i < len; i++) {
          PLOG_FATAL_IF(gConfig.severity.fatal)
              << "M1 no call, Inconsistent occurs in M2 at line: "
              << dumpLine(instList, info2, i) << " "
              << "match ratio: " << ratio << "\n";
        }
      }

      if (info1.pCallInfo2->find(bb) != info1.pCallInfo2->end() &&
          info2.pCallInfo2->find(matchBB) == info2.pCallInfo2->end()) {
        std::vector<void *> instList = info1.pCallInfo2->at(bb);
        int len = instList.size();
        for (int i = 0; i < len; i++) {
          PLOG_FATAL_IF(gConfig.severity.fatal)
              << "M2 no call, Inconsistent occurs in M1 at line: "
              << dumpLine(instList, info1, i) << " "
              << "match ratio: " << ratio << "\n";
        }
      }
    }
  }

  // compare call instruction
  // TODO: compare zero call, the define is not in this compare class, is in
  // generate class

  for (int bb = 0; bb < maxModule1FuncBBId; bb++) {
    if (info1.pCallInfo->find(bb) != info1.pCallInfo->end() &&
        matchMap->find(bb) != matchMap->end()) {
      int matchBB = matchMap->at(bb).first;
      if (info2.pCallInfo->find(matchBB) != info2.pCallInfo->end()) {
        std::vector<llvm::StringRef> callList1 = info1.pCallInfo->at(bb);
        std::vector<llvm::StringRef> callList2 = info2.pCallInfo->at(matchBB);

        auto printLine = [](std::vector<void *> instList,
                            AnalyzedControlFlowInfo info, std::string module,
                            int bb) {
          for (auto iter = instList.begin(); iter != instList.end();
               iter++) { // get inst
            llvm::Instruction *inst = (llvm::Instruction *)*iter;
            llvm::CallInst *callInst = dyn_cast<llvm::CallInst>(inst);
            llvm::Function *calledFunc = callInst->getCalledFunction();

            std::map<void *, int> *_t = info.pInstance2line;
            unsigned int line = (*_t)[inst];
            // do not need getName check because the list is "named" list,
            // already filtered
            PLOG_FATAL_IF(gConfig.severity.fatal)
                << "Module: " << module << " "
                << "BB: " << bb << " "
                << "Func: " << calledFunc->getName() << " "
                << "line: " << line;
          }
        };

        std::vector<void *> instList1 = info1.pCallInfo2->at(bb);
        std::vector<void *> instList2 = info2.pCallInfo2->at(matchBB);

        int len1 = instList1.size(), len2 = instList2.size();
        int endIndex1 = 0, startIndex1 = 0;
        int endIndex2 = 0, startIndex2 = 0;
        std::vector<std::vector<int>> dp(len1 + 1,
                                         std::vector<int>(len2 + 1, 0));
        for (int i = 1; i <= len1; ++i) {
          for (int j = 1; j <= len2; ++j) {

            llvm::Instruction *inst1 = (llvm::Instruction *)instList1[i - 1];
            llvm::Instruction *inst2 = (llvm::Instruction *)instList2[j - 1];
            llvm::CallInst *callInst1 = dyn_cast<llvm::CallInst>(inst1);
            llvm::CallInst *callInst2 = dyn_cast<llvm::CallInst>(inst2);
            llvm::Function *calledFunc1 = callInst1->getCalledFunction();
            llvm::Function *calledFunc2 = callInst2->getCalledFunction();
            // do not need getName check because the list is "named" list,
            // already filtered
            if (calledFunc1->getName() == calledFunc2->getName()) {
              dp[i][j] = dp[i - 1][j - 1] + 1;
              endIndex1 = i - 1;
              endIndex2 = j - 1;
            } else {
              dp[i][j] = std::max(dp[i - 1][j], dp[i][j - 1]);
            }
          }
        }
        int lcs = dp[len1][len2];

        float ratio = 2.0 * lcs / (len1 + len2);
        startIndex1 = endIndex1 - lcs + 1;
        startIndex2 = endIndex2 - lcs + 1;

        if (ratio != 1.0) {

          if (endIndex1 == 0) {

            PLOG_FATAL_IF(gConfig.severity.fatal)
                << "Inconsistent occurs in M1 at line: "
                << dumpLine(instList1, info1, 0);
          }

          if (endIndex2 == 0) {
            PLOG_FATAL_IF(gConfig.severity.fatal)
                << "Inconsistent occurs in M2 at line: "
                << dumpLine(instList2, info2, 0);
          }

          if (endIndex1 != 0 && endIndex2 != 0) {

            for (int i = 0; i < len1; i++) {
              if (i >= startIndex1 && i <= endIndex1)
                continue;
              PLOG_FATAL_IF(gConfig.severity.fatal)
                  << "Inconsistent occurs in M1 at line: "
                  << dumpLine(instList1, info1, i);
            }

            for (int i = 0; i < len2; i++) {
              if (i >= startIndex2 && i <= endIndex2)
                continue;
              PLOG_FATAL_IF(gConfig.severity.fatal)
                  << "Inconsistent occurs in M2 at line: "
                  << dumpLine(instList2, info2, i);
            }
          }

          PLOG_DEBUG_IF(gConfig.severity.debug)
              << "BB" << bb << ", BB" << matchBB << ", lcs:" << lcs
              << ", ratio:" << ratio << ", startIndex1:" << startIndex1
              << ", endIndex1:" << endIndex1 << ", startIndex2:" << startIndex2
              << ", endIndex2:" << endIndex2;
        }
      }
    }
  }
}

} // namespace llvm