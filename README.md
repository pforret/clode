![bash_unit CI](https://github.com/pforret/clode/workflows/bash_unit%20CI/badge.svg)
![Shellcheck CI](https://github.com/pforret/clode/workflows/Shellcheck%20CI/badge.svg)
![GH Language](https://img.shields.io/github/languages/top/pforret/clode)
![GH stars](https://img.shields.io/github/stars/pforret/clode)
![GH tag](https://img.shields.io/github/v/tag/pforret/clode)
![GH License](https://img.shields.io/github/license/pforret/clode)
[![basher install](https://img.shields.io/badge/basher-install-white?logo=gnu-bash&style=flat)](https://www.basher.it/package/)

# clode

Prep your projects for AI software development assistants

## 🔥 Usage

```
Program : clode  by peter@forret.com
Version : v0.0.1 (Apr 22 16:07:13 2023)
Purpose : Prep your projects for AI software development assistants
Usage   : clode [-h] [-q] [-v] [-f] [-l <log_dir>] [-t <tmp_dir>] <action>
Flags, options and parameters:
    -h|--help        : [flag] show usage [default: off]
    -q|--quiet       : [flag] no output [default: off]
    -v|--verbose     : [flag] also show debug messages [default: off]
    -f|--force       : [flag] do not ask for confirmation (always yes) [default: off]
    -l|--log_dir <?> : [option] folder for log files   [default: /Users/pforret/log/script]
    -t|--tmp_dir <?> : [option] folder for temp files  [default: /tmp/script]
    <action>         : [choice] action to perform  [options: action1,action2,check,env,update]
                                  
### TIPS & EXAMPLES
* use clode action1 to ...
  clode action1
* use clode action2 to ...
  clode action2
* use clode check to check if this script is ready to execute and what values the options/flags are
  clode check
* use clode env to generate an example .env file
  clode env > .env
* use clode update to update to the latest version
  clode update
* >>> bash script created with pforret/bashew
* >>> for bash development, also check out pforret/setver and pforret/progressbar
```

## ⚡️ Examples

```bash
> clode -h 
# get extended usage info
> clode env > .env
# create a .env file with default values
```

## 🚀 Installation

with [basher](https://github.com/basherpm/basher)

	$ basher install pforret/clode

or with `git`

	$ git clone https://github.com/pforret/clode.git
	$ cd clode

## 📝 Acknowledgements

* script created with [bashew](https://github.com/pforret/bashew)

&copy; 2025 Peter Forret
