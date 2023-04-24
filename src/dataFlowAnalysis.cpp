#include "dataFlowAnalysis.h"
#include "common.h"
#include "third_party/plog/Log.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/DebugInfoMetadata.h"
#include "llvm/IR/Value.h"
#include "llvm/IR/ValueSymbolTable.h"
#include <cstddef>
#include <llvm-15/llvm/ADT/StringRef.h>
#include <llvm-15/llvm/IR/Instruction.h>
#include <llvm-15/llvm/IR/Value.h>
#include <llvm/Analysis/BasicAliasAnalysis.h>
#include <llvm/IR/CFG.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/Metadata.h>
#include <llvm/IR/PassManager.h>
#include <llvm/Support/raw_ostream.h>
#include <queue>
#include <regex>
#include <string>

namespace llvm {

StringRef DataFlow::Analysis::getValueName(Value *v) {
  std::string temp_result = "val";
  if (!v) {
    return "undefined";
  }
  if (v->getName().empty()) {
    temp_result += std::to_string(num);
    num++;
  } else {
    temp_result = v->getName().str();
  }
  // PLOG_DEBUG_IF(gConfig.severity.debug) << "getValueName: " << temp_result;
  StringRef result(temp_result);
  // errs() << result;
  return result;
}

std::string DataFlow::Analysis::EscapeString(const std::string &Label) {
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

bool DataFlow::Analysis::test(Instruction *I, Function &F) {
  return true;
  errs() << "----------------------test START--------------------\n";
  errs() << *I << "\n";
  for (Instruction::op_iterator op = I->op_begin(), opEnd = I->op_end();
       op != opEnd; ++op) {
    Value *V = op->get();
    if (V) {
      if (varMap->find(V) != varMap->end()) {
        PLOG_DEBUG_IF(gConfig.severity.debug) << "varMap[V]: " << varMap->at(V);
      }
    }
  }
  for (Use &U : I->operands()) {
    Value *v = U.get();
    if (v) {
      if (varMap->find(v) != varMap->end()) {
        PLOG_DEBUG_IF(gConfig.severity.debug) << "varMap[v]: " << varMap->at(v);
      }
    }
  }
  errs() << "----------------------test END----------------------\n";
  return false;
}

bool DataFlow::Analysis::initVarMap(Function &F) {
  for (Function::iterator BB = F.begin(), BEnd = F.end(); BB != BEnd; ++BB) {
    BasicBlock *curBB = &*BB;
    for (BasicBlock::iterator II = curBB->begin(), IEnd = curBB->end();
         II != IEnd; ++II) {
      Instruction *curII = &*II;
      DbgValueInst *dbgVal = dyn_cast<DbgValueInst>(curII);
      if (!dbgVal)
        continue;
      Value *V = dbgVal->getValue();
      DILocalVariable *var = dbgVal->getVariable();
      std::string realname = var->getName().str();
      // errs() << *curII << "\n";
      // *varMap[V] = realname;
      varMap->insert(std::pair<llvm::Value *, std::string>(V, realname));
      // PLOG_DEBUG_IF(gConfig.severity.debug) << V << ": stored: " << realname;

      // get metadata
    }
  }
  return true;
}

std::string DataFlow::Analysis::op2realname(llvm::Value *V,
                                            llvm::Instruction *curII) {

  if (varMap->find(V) != varMap->end()) {
    unsigned lineNum = 0;
    unsigned colNum = 0;
    const DebugLoc &location = curII->getDebugLoc();
    if (location) {
      lineNum = location.getLine();
      colNum = location.getCol();
    }
    PLOG_DEBUG_IF(gConfig.severity.debug)
        << "line: " << lineNum << " col: " << colNum << ", op's realname is "
        << varMap->at(V);
    return varMap->at(V);
  }
  return "";
}

DataFlow::Analysis::Analysis() {
  pInsMap = new int[maxInsCount][maxInsCount];
  pId2Ins = new std::map<int, llvm::Instruction *>();
  pIns2Id = new std::map<llvm::Instruction *, int>();
  varMap = new std::map<llvm::Value *, std::string>();
  instCount = 0;
}

bool DataFlow::Analysis::buildDFG(Function &F) {
  PLOG_INFO_IF(gConfig.severity.info) << "buildDFG in " << F.getName();
  std::error_code error;

  // reuse
  int id = 0;
  edges.clear();
  nodes.clear();
  inst_edges.clear();

  auto mapping = [this](Value *fromV, Value *toV) {
    int from, to;
    from = to = 0;
    if (pIns2Id->find(dyn_cast<Instruction>(fromV)) != pIns2Id->end()) {
      from = pIns2Id->at(dyn_cast<Instruction>(fromV));
    }
    if (pIns2Id->find(dyn_cast<Instruction>(toV)) != pIns2Id->end()) {
      to = pIns2Id->at(dyn_cast<Instruction>(toV));
    }
    this->pInsMap[from][to] = 1;
  };

  for (Function::iterator BB = F.begin(), BEnd = F.end(); BB != BEnd; ++BB) {
    BasicBlock *curBB = &*BB;
    for (BasicBlock::iterator II = curBB->begin(), IEnd = curBB->end();
         II != IEnd; ++II) {
      Instruction *curII = &*II;

      std::string instruction;
      llvm::raw_string_ostream(instruction) << *curII;
      if (instruction.find("llvm.dbg") != std::string::npos) {
        continue;
      }

      // init mapping relation
      if (pIns2Id->find(curII) == pIns2Id->end()) {
        pIns2Id->insert(std::pair<llvm::Instruction *, int>(curII, id));
        pId2Ins->insert(std::pair<int, llvm::Instruction *>(id, curII));
        id++;
      } else {
        PLOG_FATAL_IF(gConfig.severity.fatal)
            << "instruction already exist, WTF?";
      }
      // solve different type instruction
      switch (curII->getOpcode()) {
      case llvm::Instruction::Load: {
        LoadInst *linst = dyn_cast<LoadInst>(curII);
        Value *loadValPtr = linst->getPointerOperand();
        mapping(loadValPtr, curII);
        break;
      }
      case llvm::Instruction::Store: {
        StoreInst *sinst = dyn_cast<StoreInst>(curII);
        Value *storeValPtr = sinst->getPointerOperand();
        Value *storeVal = sinst->getValueOperand();
        mapping(storeVal, curII);
        mapping(curII, storeValPtr);
        break;
      }
      default: {
        for (Instruction::op_iterator op = curII->op_begin(),
                                      opEnd = curII->op_end();
             op != opEnd; ++op) {
          if (dyn_cast<Instruction>(*op)) {
            mapping(*op, curII);
          }
        }
        break;
      }
      }
    }
  }

  PLOG_INFO_IF(gConfig.severity.info)
      << "DFG Build Done with " << id << " instructions";
  instCount = id;
  return false;
}

bool DataFlow::Analysis::drawDataFlowGraph(Function &F) {
  PLOG_INFO_IF(gConfig.severity.info) << "Drawing DFG for " << F.getName();
  std::error_code error;
  std::string _module =
      std::regex_replace(gCurrentModule, std::regex("input"), "output");
  std::string Filename = _module + ("_" + F.getName() + "_DFG" + ".dot").str();
  raw_fd_ostream file(Filename, error, sys::fs::OF_Text);

  edges.clear();
  nodes.clear();
  inst_edges.clear();
  for (Function::iterator BB = F.begin(), BEnd = F.end(); BB != BEnd; ++BB) {
    BasicBlock *curBB = &*BB;
    for (BasicBlock::iterator II = curBB->begin(), IEnd = curBB->end();
         II != IEnd; ++II) {
      Instruction *curII = &*II;
      test(curII, F);
      switch (curII->getOpcode()) {
      // 由于load和store对内存进行操作，需要对load指令和stroe指令单独进行处理
      case llvm::Instruction::Load: {
        LoadInst *linst = dyn_cast<LoadInst>(curII);
        Value *loadValPtr = linst->getPointerOperand();
        op2realname(loadValPtr, curII); // for test func
        edges.push_back(edge(node(loadValPtr, getValueName(loadValPtr)),
                             node(curII, getValueName(curII))));
        break;
      }
      case llvm::Instruction::Store: {
        // errs() << "Store-> " << *curII << "\n";
        StoreInst *sinst = dyn_cast<StoreInst>(curII);
        Value *storeValPtr = sinst->getPointerOperand();
        op2realname(storeValPtr, curII);
        Value *storeVal = sinst->getValueOperand();
        op2realname(storeVal, curII);
        edges.push_back(edge(node(storeVal, getValueName(storeVal)),
                             node(curII, getValueName(curII))));
        edges.push_back(edge(node(curII, getValueName(curII)),
                             node(storeValPtr, getValueName(storeValPtr))));
        break;
      }
      default: {
        for (Instruction::op_iterator op = curII->op_begin(),
                                      opEnd = curII->op_end();
             op != opEnd; ++op) {

          if (dyn_cast<Instruction>(*op)) {
            op2realname(*op, curII); // for test func
            edges.push_back(edge(node(op->get(), getValueName(op->get())),
                                 node(curII, getValueName(curII))));
          } else {
            // constant
          }
        }
        break;
      }
      }
      BasicBlock::iterator next = II;

      nodes.push_back(node(curII, getValueName(curII)));
      ++next;
      if (next != IEnd) {
        inst_edges.push_back(edge(node(curII, getValueName(curII)),
                                  node(&*next, getValueName(&*next))));
      }
    }

    Instruction *terminator = curBB->getTerminator();
    for (BasicBlock *sucBB : successors(curBB)) {
      Instruction *first = &*(sucBB->begin());
      inst_edges.push_back(edge(node(terminator, getValueName(terminator)),
                                node(first, getValueName(first))));
    }
  }

  file << "digraph \"DFG for'" + F.getName() + "\' function\" {\n";

  // 将node节点dump
  for (node_list::iterator node = nodes.begin(), node_end = nodes.end();
       node != node_end; ++node) {
    // errs() << "Node First:" << node->first << "\n";
    // errs() << "Node Second:" << node-> second << "\n";

    // add line:col information to each node
    llvm::Instruction *tmpI = dyn_cast<Instruction>(node->first);
    unsigned lineNum = 0;
    unsigned colNum = 0;
    const DebugLoc &location = tmpI->getDebugLoc();
    if (location) {
      lineNum = location.getLine();
      colNum = location.getCol();
    }

    std::string instruction;
    if (dyn_cast<Instruction>(node->first)) {
      llvm::raw_string_ostream(instruction) << *(node->first);
      // eliminate llvm.dbg.* instructions, just for view
      if (instruction.find("llvm.dbg") != std::string::npos) {
        continue;
      }
      llvm::Instruction *tmpI = dyn_cast<Instruction>(node->first);
      file << "\tNode" << node->first << "[shape=record, label=\""
           << pIns2Id->at(tmpI) << "," << lineNum << ":" << colNum << " "
           << EscapeString(instruction) << "\"];\n";
    } else { // 如果不是指令，那么就是常量, useless
      llvm::raw_string_ostream(instruction) << node->second;
      file << "\tNode" << node->first << "[shape=record, label=\"" << lineNum
           << ":" << colNum << " " << EscapeString(instruction) << "\"];\n";
    }
  }

  // 将inst_edges边dump
  /*
  for (edge_list::iterator edge = inst_edges.begin(),
                           edge_end = inst_edges.end();
       edge != edge_end; ++edge) {
    file << "\tNode" << edge->first.first << " -> Node" << edge->second.first
         << "\n";
  }
  */
  // 将data flow的边dump
  file << "edge [color=red]"
       << "\n";
  for (edge_list::iterator edge = edges.begin(), edge_end = edges.end();
       edge != edge_end; ++edge) {
    file << "\tNode" << edge->first.first << " -> Node" << edge->second.first
         << "\n";
  }
  PLOG_INFO_IF(gConfig.severity.info) << "DFG Write Done";
  file << "}\n";
  file.close();
  return false;
}

AnalyzedDataFlowInfo::AnalyzedDataFlowInfo(Function &F) { valid = false; }

AnalysisKey DataFlow::Key;
DataFlow::Result DataFlow::run(Function &F, FunctionAnalysisManager &AM) {

  AnalyzedDataFlowInfo Result = AnalyzedDataFlowInfo(F);

  Analysis *A = new Analysis();

  A->initVarMap(F);
  A->buildDFG(F);
  if (gConfig.drawDFG)
    A->drawDataFlowGraph(F);

  // do copy
  Result.pId2Ins = A->pId2Ins;
  Result.pIns2Id = A->pIns2Id;
  Result.pInsMap = A->pInsMap;
  Result.pVarMap = A->varMap;
  Result.pF = &F;
  Result.valid = true;
  Result.instCount = A->instCount;

  return Result;
}

dataFlowInconsistencyAnalysis::dataFlowInconsistencyAnalysis() {
  matchMap = new std::map<int, std::pair<int, float>>();
  memset(M1visited, false, sizeof(M1visited));
  memset(M2visited, false, sizeof(M2visited));
}

void dataFlowInconsistencyAnalysis::Wrapper(
    std::vector<AnalyzedDataFlowInfo> *IRFile1FuncAnalysis,
    std::vector<AnalyzedDataFlowInfo> *IRFIle2FuncAnalysis,
    StringRef targetFunc) {
  for (int i = 0; i < IRFile1FuncAnalysis->size(); i++) {
    for (int j = 0; j < IRFIle2FuncAnalysis->size(); j++) {
      AnalyzedDataFlowInfo info1 = IRFile1FuncAnalysis->at(i);
      AnalyzedDataFlowInfo info2 = IRFIle2FuncAnalysis->at(j);
      if (info1.pF->getName().equals(info2.pF->getName()) &&
          info1.pF->getName().equals(
              targetFunc)) { // match same function in two modules
        // begin analysis
        match(info1, info2);
        initialInconsistencyDetect(info1, info2);

        // diffCallInstanceInBB(info1, info2);
      }
    }
  }
}

void dataFlowInconsistencyAnalysis::match(AnalyzedDataFlowInfo info1,
                                          AnalyzedDataFlowInfo info2) {
  PLOG_DEBUG_IF(gConfig.severity.debug)
      << "DFG Matching " << info1.pF->getName();
  std::map<int, std::pair<int, float>> *_tMatchMap =
      new std::map<int, std::pair<int, float>>();
  std::map<int, std::pair<int, float>> *_reverseMatchMap =
      new std::map<int, std::pair<int, float>>();

  PLOG_DEBUG_IF(gConfig.severity.debug)
      << "\n"
      << info1.pF->getName() << " "
      << "inst count: " << info1.instCount << "\n"
      << info2.pF->getName() << " "
      << "inst count: " << info2.instCount;

  for (int i_Inst = 0; i_Inst < info1.instCount; i_Inst++) {
    for (int j_Inst = 0; j_Inst < info2.instCount; j_Inst++) {
      std::string seq1, seq2;
      auto toSeq = [](Instruction *I) {
        std::string seq;
        llvm::raw_string_ostream(seq) << *I;
        return seq;
      };
      seq1 = toSeq(info1.pId2Ins->at(i_Inst));
      seq2 = toSeq(info2.pId2Ins->at(j_Inst));
      float ratio = seqLCS(seq1, seq2);
      if (_tMatchMap->find(i_Inst) == _tMatchMap->end()) {
        _tMatchMap->insert(std::pair<int, std::pair<int, float>>(
            i_Inst, std::pair<int, float>(j_Inst, ratio)));
      } else {
        if (ratio > _tMatchMap->at(i_Inst).second) {
          _tMatchMap->at(i_Inst).first = j_Inst;
          _tMatchMap->at(i_Inst).second = ratio;
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

  for (auto iter = _reverseMatchMap->begin(); iter != _reverseMatchMap->end();
       iter++) {
    matchMap->insert(std::pair<int, std::pair<int, float>>(
        iter->second.first,
        std::pair<int, float>(iter->first, iter->second.second)));
    M1visited[iter->second.first] = true;
    M2visited[iter->first] = true;
  }

  // traverse matchMap
  for (auto iter = matchMap->begin(); iter != matchMap->end(); iter++) {
    PLOG_DEBUG_IF(gConfig.severity.debug)
        << "match: " << iter->first << " " << iter->second.first << " "
        << iter->second.second;
  }

  delete _tMatchMap;
  delete _reverseMatchMap;
}

float dataFlowInconsistencyAnalysis::seqLCS(std::string seq1,
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

std::string dataFlowInconsistencyAnalysis::op2realname(
    AnalyzedDataFlowInfo info, llvm::Value *V, llvm::Instruction *I) {

  if (I) {
    unsigned lineNum = 0;
    unsigned colNum = 0;
    std::string varName = "";
    const DebugLoc &location = I->getDebugLoc();
    if (location) {
      lineNum = location.getLine();
      colNum = location.getCol();
    }
    if (V) {
      if (info.pVarMap->find(V) != info.pVarMap->end()) {
        varName = info.pVarMap->at(V);
      }
    }
    PLOG_FATAL_IF(gConfig.severity.fatal)
        << "line: " << lineNum << " col: " << colNum << ", op's realname is "
        << varName;
  }
  return "";
}

void dataFlowInconsistencyAnalysis::initialInconsistencyDetect(
    AnalyzedDataFlowInfo info1, AnalyzedDataFlowInfo info2) {
  int len1 = info1.instCount, len2 = info2.instCount;

  auto dump = [this](AnalyzedDataFlowInfo info, llvm::Instruction *I) {
    bool output = false;
    for (Instruction::op_iterator op = I->op_begin(), opEnd = I->op_end();
         op != opEnd; ++op) {
      if (dyn_cast<Instruction>(*op)) {
        op2realname(info, *op, I);
        output = true;
      }
    }
    if (!output) {
      op2realname(info, nullptr, I);
    }
  };

  for (int i = 0; i < len1; i++) {
    if (!M1visited[i]) {
      PLOG_DEBUG_IF(gConfig.severity.debug) << "M1 unvisited: " << i;
      llvm::Instruction *I = info1.pId2Ins->at(i);
      dump(info1, I);
    }
  }
  for (int i = 0; i < len2; i++) {
    if (!M2visited[i]) {
      PLOG_DEBUG_IF(gConfig.severity.debug) << "M2 unvisited: " << i;
      llvm::Instruction *I = info2.pId2Ins->at(i);
      dump(info2, I);
    }
  }
}

} // namespace llvm