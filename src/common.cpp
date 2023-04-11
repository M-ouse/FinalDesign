#include "common.h"
#include "third_party/json/json.hpp"

#include <fstream>

bool sConfig::parseBasic(std::string configPath) {
  std::ifstream fin("config/config.json");
  nlohmann::json config;
  fin >> config;
  fin.close();

  IRFile1 = config["IRFile1"];
  IRFile2 = config["IRFile2"];
  targetFunction = config["targetFunction"];
  drawCFG = config["drawCFG"].get<bool>();

  severity.verbose = config["Severity"]["verbose"].get<bool>();
  severity.debug = config["Severity"]["debug"].get<bool>();
  severity.info = config["Severity"]["info"].get<bool>();
  severity.warning = config["Severity"]["warning"].get<bool>();
  severity.error = config["Severity"]["error"].get<bool>();
  severity.fatal = config["Severity"]["fatal"].get<bool>();
  severity.none = config["Severity"]["none"].get<bool>();

  static plog::ConsoleAppender<plog::TxtFormatter> consoleAppender;
  plog::init(plog::debug, &consoleAppender); // Initialize the logger to console
                                             // for all project files
}