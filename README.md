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
Version : v0.2.0 (Jul 15 19:26:53 2025)
Purpose : Prep your projects for AI software development assistants
Usage   : clode [-h] [-Q] [-V] [-f] [-A] [-D] [-E] [-G] [-S] [-C <COMMIT>] [-L <LOG_DIR>] [-M <MESSAGE>] [-T <TMP_DIR>] <action> <input?>
Flags, options and parameters:
    -h|--help        : [flag] show usage [default: off]
    -Q|--QUIET       : [flag] no output [default: off]
    -V|--VERBOSE     : [flag] also show debug messages [default: off]
    -f|--FORCE       : [flag] do not ask for confirmation (always yes) [default: off]
    -A|--AUTO_COMMIT : [flag] automatically generate commit messages with Claude Code CLI [default: off]
    -D|--DRY_RUN     : [flag] show what would be done without executing [default: off]
    -E|--ERASE       : [flag] clear command history after final commit [default: off]
    -G|--GENERATE    : [flag] use Claude Code CLI to generate CLAUDE.md file [default: off]
    -S|--SQUASH      : [flag] squash all intermediate commits before push [default: off]
    -C|--COMMIT <?>  : [option] commit type for intermediate commits  [default: fix]
    -L|--LOG_DIR <?> : [option] folder for log files   [default: /Users/pforret/log/clode]
    -M|--MESSAGE <?> : [option] custom commit message
    -T|--TMP_DIR <?> : [option] folder for temp files  [default: .tmp]
    <action>         : [choice] action to perform  [options: prep,branch,b,inter,i,rollback,r,push,p,final,f,status,s,check,env,update]
    <input>          : [parameter] input text (optional)
                                                                                                 
### TIPS & EXAMPLES
* use clode prep to prepare project for AI development
  clode prep
* use clode prep -G to generate CLAUDE.md with Claude Code CLI
  clode prep --GENERATE
* use clode branch [name] to create new feature branch
  clode branch my-feature
* use clode inter [-M "message"] to create intermediate commit
  clode inter -M "implemented feature"
* use clode rollback [target] to rollback commits
  clode rollback last
* use clode push to squash and push branch
  clode push
* use clode push -A to auto-generate commit messages with Claude Code CLI
  clode push --AUTO_COMMIT
* use clode final to squash all commits and push
  clode final
* use clode final -A to auto-generate commit messages with Claude Code CLI
  clode final --AUTO_COMMIT
* use clode final -E to automatically clear command history after final commit
  clode final --ERASE
* use clode status to show current git workflow status
  clode status
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
