# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is **clode**, a bash utility tool that helps prep projects for AI software development assistants, more specifically Claude Code. 
It prepares the project by setting up necessary files and configurations, and it provides a structured git workflow to interact with AI coding assistants.

It's built using the [pforret/bashew](https://github.com/pforret/bashew) framework, which provides a robust foundation for command-line bash scripts.

## Key Commands

### AI Development Commands
- `./clode.sh prep` - 
- `./clode.sh branch` -
- `./clode.sh inter` -
- `./clode.sh rollback` -
- `./clode.sh final` - 

### Development Commands
- `./clode.sh check` - Check script configuration and show current option values
- `./clode.sh env > .env` - Generate example environment file
- `./clode.sh update` - Update script to latest version via git pull

### Testing Commands
- `tests/run_tests.sh` - Run all tests using bash_unit framework
- `shellcheck clode.sh` - Run shellcheck linting on the main script
- `bash_unit tests/test_*` - Run specific test files (requires bash_unit to be installed)

## Architecture

### Core Structure
- `clode.sh` - Main executable script (identical to `clode`)
- `clode` - Symlink or copy of main script
- `tests/` - Test directory with bash_unit tests
- `VERSION.md` - Version tracking file

### Bashew Framework Integration
The script uses the bashew framework which provides:
- **Option parsing system** (`Option:config()`) - Handles flags, options, and parameters
- **Logging and output** (`IO:*` functions) - Structured logging and user feedback
- **System utilities** (`Os:*` functions) - Cross-platform system operations
- **String processing** (`Str:*` functions) - Text manipulation utilities
- **Error handling** - Comprehensive error trapping and reporting

### Main Components
- **Script:main()** - Primary execution logic with action routing
- **Option:config()** - Command-line interface definition
- **do_action1()** and **do_action2()** - Placeholder action functions to be implemented
- **Helper functions** - Utility functions for specific tasks

## Development Notes

### Style guide
- follow https://google.github.io/styleguide/shellguide.html
- keep in mind that some binaries like `date` and `sed` may not work the same on MacOS and Linux, so if you need them, put them in a function() that detects the OS and uses the right command/parameters

### Framework Features
- Automatic OS detection and package manager integration
- Unicode support detection
- Environment file (.env) support
- Temporary file management
- Git integration for updates and version tracking
- Cross-platform compatibility (Linux, macOS, Windows)

### Testing Framework
Uses bash_unit for testing with GitHub Actions CI/CD:
- Ubuntu runner for main testing
- macOS runner for platform-specific testing (triggered by `[macos]` in commit messages)
- Shellcheck integration for code quality
- Skip CI with `[skip ci]` in commit messages

### Version Management
- Version stored in `VERSION.md`
- Git tags used for version tracking
- Automatic version detection from git tags or VERSION.md file