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
  errs() << "----------------------test START--------------------\n";
  errs() << "Raw I: " << *I << "\n";
  unsigned int n =  I->getNumOperands();
  errs() << "I->getNumOperands(): " << n << "\n";
  for (Instruction::op_iterator op = I->op_begin(), opEnd = I->op_end();
       op != opEnd; ++op) {
      llvm::Type* type = op->get()->getType();
      errs() << "op: " << *op->get() << " type: "<< type->getTypeID() << "\n";
      Value *V = op->get();
      if (V) {
        if(V->hasName()){
          errs() << "V->getName(): " << V->getName() << "\n";
        }
      }
    /*
    if (dyn_cast<Instruction>(*op)) {
      Value *V = dyn_cast<Value>(*op);
      if(V){
        if(V->hasName()){
          errs() << V->getName() << "\n";
        }
      }
    }
    */
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
      varMap[V] = realname;
      PLOG_DEBUG_IF(gConfig.severity.debug) << V << ": stored: " << realname;
      
      // get metadata



    }
  }
  return true;
}

std::string DataFlow::Analysis::op2realname(llvm::Value *V,
                                            llvm::Instruction *curII) {

  if (varMap.find(V) != varMap.end()) {
    unsigned lineNum = 0;
    unsigned colNum = 0;
    const DebugLoc &location = curII->getDebugLoc();
    if (location) {
      lineNum = location.getLine();
      colNum = location.getCol();
    }
    PLOG_DEBUG_IF(gConfig.severity.debug)
        << "line: " << lineNum << " col: " << colNum << ", op's realname is "
        << varMap[V];
    return varMap[V];
  }
  return "";
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
      file << "\tNode" << node->first << "[shape=record, label=\"" << lineNum
           << ":" << colNum << " " << EscapeString(instruction) << "\"];\n";
    } else { // 如果不是指令，那么就是常量
      llvm::raw_string_ostream(instruction) << node->second;
      file << "\tNode" << node->first << "[shape=record, label=\"" << lineNum
           << ":" << colNum << " " << EscapeString(instruction) << "\"];\n";
    }
  }

  // 将inst_edges边dump
  for (edge_list::iterator edge = inst_edges.begin(),
                           edge_end = inst_edges.end();
       edge != edge_end; ++edge) {
    file << "\tNode" << edge->first.first << " -> Node" << edge->second.first
         << "\n";
  }
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
  if (gConfig.drawDFG)
    A->drawDataFlowGraph(F);

  return Result;
}

} // namespace llvm