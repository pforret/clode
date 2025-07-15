/# PRP: Git Workflow Implementation for clode.sh

## Product Requirements Prompt (PRP)

**Feature**: Complete Git Workflow Implementation for AI-Assisted Development  
**Complexity**: High  
**Estimated Implementation Time**: 2-3 hours  
**Target File**: `clode.sh`

## Overview

Implement a comprehensive git workflow tool that helps developers using Claude Code manage their development process through structured branching, intermediate commits, and clean final merges. This tool implements the workflow described in https://raw.githubusercontent.com/pforret/claude_code_tips/refs/heads/main/GIT.md

## Context and Research Findings

### Framework Information
- **Codebase**: Built on [pforret/bashew](https://github.com/pforret/bashew) framework
- **Current State**: Template script with placeholder actions (action1, action2, action3)
- **Architecture**: Option:config() defines CLI interface, Script:main() routes actions, helper functions implement logic

### Git Workflow Requirements (from planning.md)
The tool must implement 5 core commands following conventional commits and structured branching:

1. `clode prep` - Project preparation for AI assistants
2. `clode branch|b` - New branch creation
3. `clode inter|i` - Intermediate commits with auto-numbering
4. `clode rollback|r` - Rollback functionality
5. `clode push|p` - Squash and push commits

### Key Technical Patterns Identified
- **Conventional Commits**: `feat:`, `fix:`, `docs:`, `break:` prefixes
- **Intermediate Commit Format**: `{type}: {message} #intermediate #step:[NN] #date:[YYYY-MM-DD]`
- **Squashing**: Use `git rebase -i` for combining intermediate commits
- **Branch Management**: Feature branches with clean final commits

## Implementation Blueprint

### Phase 1: Update Option Configuration

**File**: `clode.sh` lines 40-52

**Action**: Replace the current action choice line with:
```bash
choice|1|action|action to perform|prep,branch,b,inter,i,rollback,r,push,p,final,f,check,env,update
```

**Add new options**:
```bash
option|c|commit|commit type for intermediate commits|fix
option|m|message|custom commit message|
flag|s|squash|squash all intermediate commits before push
flag|d|dry-run|show what would be done without executing
```

### Phase 2: Implement Core Action Router

**File**: `clode.sh` lines 63-102

**Replace existing action cases with**:
```bash
prep)
    do_prep_project
    ;;
branch | b)
    do_create_branch
    ;;
inter | i)
    do_intermediate_commit
    ;;
rollback | r)
    do_rollback_commit
    ;;
push | p)
    do_push_branch
    ;;
final | f)
    do_final_commit
    ;;
```

### Phase 3: Implement Helper Functions

**File**: `clode.sh` starting around line 111

Replace existing placeholder functions with:

#### Function 1: Project Preparation
```bash
function do_prep_project() {
    IO:log "Preparing project for AI development"
    
    # Create necessary directories
    [[ ! -d ".claude" ]] && mkdir -p ".claude" && IO:success "Created .claude/ directory"
    
    # Create CLAUDE.md if it doesn't exist
    if [[ ! -f "CLAUDE.md" ]]; then
        cat > CLAUDE.md << 'EOF'
# CLAUDE.md

This file provides guidance to Claude Code when working with this project.

## Project Overview
[Describe your project here]

## Development Commands
- `./clode.sh branch` - Create new feature branch
- `./clode.sh inter` - Create intermediate commit
- `./clode.sh rollback` - Rollback last commit
- `./clode.sh push` - Squash and push branch

## Architecture
[Describe key components and patterns]

## Testing
[Describe how to run tests]
EOF
        IO:success "Created CLAUDE.md template"
    fi
    
    # Create planning.md if it doesn't exist
    if [[ ! -f "planning.md" ]]; then
        cat > planning.md << 'EOF'
# Project Planning

## Current Task
[Describe what you're working on]

## Goals
- [ ] Goal 1
- [ ] Goal 2

## Notes
[Development notes and decisions]
EOF
        IO:success "Created planning.md template"
    fi
    
    # Initialize git if not already initialized
    if [[ ! -d ".git" ]]; then
        git init
        IO:success "Initialized git repository"
    fi
    
    IO:success "Project prepared for AI development"
}
```

#### Function 2: Branch Creation
```bash
function do_create_branch() {
    local branch_name="${input:-}"
    
    # Generate branch name if not provided
    if [[ -z "$branch_name" ]]; then
        local timestamp=$(date +%Y%m%d-%H%M)
        branch_name="feature/ai-task-$timestamp"
        IO:announce "Generated branch name: $branch_name"
    fi
    
    # Validate we're in a git repo
    if [[ ! -d ".git" ]]; then
        IO:die "Not in a git repository. Run 'clode prep' first."
    fi
    
    # Check for uncommitted changes
    if [[ -n "$(git status --porcelain)" ]]; then
        if IO:confirm "You have uncommitted changes. Commit them first?"; then
            git add -A
            git commit -m "feat: save work before creating new branch"
        else
            IO:die "Please commit or stash your changes first"
        fi
    fi
    
    # Create and switch to new branch
    git checkout -b "$branch_name"
    IO:success "Created and switched to branch: $branch_name"
    
    # Store branch info for later use
    echo "$branch_name" > .claude/current_branch
    echo "0" > .claude/step_counter
}
```

#### Function 3: Intermediate Commits
```bash
function do_intermediate_commit() {
    local commit_type="${commit:-fix}"
    local commit_msg="${message:-}"
    local step_file=".claude/step_counter"
    local current_date=$(date +%Y-%m-%d)
    
    # Validate we're in a git repo and on a feature branch
    if [[ ! -d ".git" ]]; then
        IO:die "Not in a git repository"
    fi
    
    local current_branch=$(git branch --show-current)
    if [[ "$current_branch" == "main" || "$current_branch" == "master" ]]; then
        IO:die "Cannot create intermediate commits on main/master branch"
    fi
    
    # Get or initialize step counter
    local step_num=1
    if [[ -f "$step_file" ]]; then
        step_num=$(cat "$step_file")
        ((step_num++))
    fi
    
    # Generate commit message if not provided
    if [[ -z "$commit_msg" ]]; then
        # Auto-generate based on changed files
        local changed_files=$(git diff --name-only HEAD)
        if [[ -n "$changed_files" ]]; then
            local file_count=$(echo "$changed_files" | wc -l)
            commit_msg="update $file_count file(s)"
        else
            commit_msg="checkpoint update"
        fi
    fi
    
    # Check for changes
    if [[ -z "$(git status --porcelain)" ]]; then
        IO:alert "No changes to commit"
        return 0
    fi
    
    # Create the intermediate commit
    git add -A
    local full_commit_msg="${commit_type}: ${commit_msg} #intermediate #step:[$(printf "%02d" $step_num)] #date:[$current_date]"
    
    if ((dry_run)); then
        IO:print "Would commit: $full_commit_msg"
        return 0
    fi
    
    git commit -m "$full_commit_msg"
    echo "$step_num" > "$step_file"
    
    IO:success "Created intermediate commit #$(printf "%02d" $step_num): $commit_msg"
}
```

#### Function 4: Rollback Functionality
```bash
function do_rollback_commit() {
    local target="${input:-last}"
    
    # Validate we're in a git repo
    if [[ ! -d ".git" ]]; then
        IO:die "Not in a git repository"
    fi
    
    case "$target" in
        "last")
            # Rollback last commit
            local last_commit=$(git log -1 --pretty=format:"%h %s")
            if IO:confirm "Rollback last commit: $last_commit?"; then
                git reset --hard HEAD~1
                IO:success "Rolled back last commit"
                
                # Update step counter if it was an intermediate commit
                if [[ "$last_commit" == *"#intermediate"* ]]; then
                    local step_file=".claude/step_counter"
                    if [[ -f "$step_file" ]]; then
                        local current_step=$(cat "$step_file")
                        ((current_step > 0)) && echo $((current_step - 1)) > "$step_file"
                    fi
                fi
            fi
            ;;
        "branch")
            # Rollback to start of branch
            local branch_start=$(git merge-base HEAD main || git merge-base HEAD master)
            if [[ -n "$branch_start" ]]; then
                git log --oneline "$branch_start..HEAD"
                if IO:confirm "Rollback to start of branch (delete all commits above)?"; then
                    git reset --hard "$branch_start"
                    echo "0" > .claude/step_counter
                    IO:success "Rolled back to start of branch"
                fi
            else
                IO:die "Cannot find branch starting point"
            fi
            ;;
        *)
            # Rollback to specific commit hash
            if git rev-parse --verify "$target" &>/dev/null; then
                if IO:confirm "Rollback to commit $target?"; then
                    git reset --hard "$target"
                    IO:success "Rolled back to commit $target"
                fi
            else
                IO:die "Invalid commit hash: $target"
            fi
            ;;
    esac
}
```

#### Function 5: Push with Squashing
```bash
function do_push_branch() {
    # Validate we're in a git repo and on feature branch
    if [[ ! -d ".git" ]]; then
        IO:die "Not in a git repository"
    fi
    
    local current_branch=$(git branch --show-current)
    if [[ "$current_branch" == "main" || "$current_branch" == "master" ]]; then
        IO:die "Cannot push from main/master branch"
    fi
    
    # Count intermediate commits
    local intermediate_commits=$(git log --oneline --grep="#intermediate" | wc -l)
    
    if [[ $intermediate_commits -gt 1 ]] && ! ((squash)); then
        IO:print "Found $intermediate_commits intermediate commits"
        if IO:confirm "Squash intermediate commits into single commit?"; then
            squash=1
        fi
    fi
    
    if ((squash)) && [[ $intermediate_commits -gt 1 ]]; then
        IO:announce "Squashing $intermediate_commits intermediate commits..."
        
        # Find the commit before first intermediate commit
        local base_commit=$(git log --oneline --grep="#intermediate" | tail -1 | awk '{print $1}')
        local before_base=$(git rev-parse "$base_commit^")
        
        # Create squash commit message
        local final_msg="feat: completed feature implementation
        
$(git log --oneline "$before_base..HEAD" --grep="#intermediate" | sed 's/^[a-f0-9]* /- /')

🤖 Generated with Claude Code"
        
        if ((dry_run)); then
            IO:print "Would squash commits from $before_base to HEAD"
            IO:print "Final commit message:"
            IO:print "$final_msg"
            return 0
        fi
        
        # Perform interactive rebase (automated)
        git reset --soft "$before_base"
        git commit -m "$final_msg"
        
        IO:success "Squashed $intermediate_commits commits into single commit"
    fi
    
    # Push to remote
    if ((dry_run)); then
        IO:print "Would push branch: $current_branch"
        return 0
    fi
    
    # Check if remote branch exists
    if git ls-remote --heads origin "$current_branch" | grep -q "$current_branch"; then
        git push --force-with-lease origin "$current_branch"
    else
        git push -u origin "$current_branch"
    fi
    
    IO:success "Pushed branch: $current_branch"
    
    # Provide next steps
    IO:print ""
    IO:print "Next steps:"
    IO:print "1. Create pull request on GitHub"
    IO:print "2. Review and merge when ready"
    IO:print "3. Delete feature branch after merge"
}
```

#### Function 6: Final Commit (alias for push)
```bash
function do_final_commit() {
    squash=1
    do_push_branch
}
```

### Phase 4: Validation Gates

**Commands to verify implementation**:
```bash
# Test script syntax
bash -n clode.sh

# Test basic functionality
./clode.sh check

# Test help output
./clode.sh -h

# Test individual commands
./clode.sh prep --dry-run
./clode.sh branch test-branch --dry-run
./clode.sh inter --message "test commit" --dry-run
```

## Implementation Task List

1. **Update Option:config()** - Add new action choices and options
2. **Implement Action Router** - Update Script:main() with new action cases
3. **Create do_prep_project()** - Project initialization function
4. **Create do_create_branch()** - Branch creation with validation
5. **Create do_intermediate_commit()** - Intermediate commits with auto-numbering
6. **Create do_rollback_commit()** - Rollback functionality
7. **Create do_push_branch()** - Squash and push logic
8. **Create do_final_commit()** - Alias for push with squash
9. **Test and validate** - Run validation gates

## Key Implementation Details

### Git Command Patterns
- Use `git status --porcelain` for checking uncommitted changes
- Use `git branch --show-current` for current branch detection
- Use `git merge-base` for finding branch starting points
- Use `git reset --soft` followed by `git commit` for squashing
- Use `git push --force-with-lease` for safe force pushing

### Error Handling
- Validate git repository existence with `[[ -d ".git" ]]`
- Check for uncommitted changes before branch operations
- Prevent operations on main/master branches
- Use `IO:confirm()` for destructive operations
- Provide `--dry-run` flag for testing

### State Management
- Store current branch in `.claude/current_branch`
- Track step counter in `.claude/step_counter`
- Use conventional commit format throughout
- Maintain clean commit history

### User Experience
- Provide clear success/error messages using `IO:success()` and `IO:die()`
- Auto-generate branch names and commit messages when not provided
- Show what would happen with `--dry-run` flag
- Confirm destructive operations

## Testing Strategy

1. **Syntax Testing**: `bash -n clode.sh`
2. **Basic Function Testing**: `./clode.sh check`
3. **Dry-run Testing**: Test all commands with `--dry-run`
4. **Integration Testing**: Full workflow test in isolated git repo
5. **Edge Case Testing**: Test error conditions and validations

## Documentation URLs

- **Bashew Framework**: https://github.com/pforret/bashew
- **Git Workflow Source**: https://raw.githubusercontent.com/pforret/claude_code_tips/refs/heads/main/GIT.md
- **Conventional Commits**: https://www.conventionalcommits.org/en/v1.0.0/
- **Git Squashing Guide**: https://www.git-tower.com/learn/git/faq/git-squash

## Success Criteria

- All 5 core commands implemented and functional
- Proper conventional commit formatting
- Intermediate commit numbering and tracking
- Safe rollback functionality
- Clean squash and push workflow
- Comprehensive error handling and validation
- Full dry-run support for testing

## Risk Assessment

- **Low Risk**: Project preparation and basic git operations
- **Medium Risk**: Squashing logic and force push operations
- **High Risk**: Rollback functionality affecting commit history

## Confidence Score: 9/10

This PRP provides comprehensive context, clear implementation steps, and detailed technical specifications. The high confidence score reflects:

- Complete research and context gathering
- Detailed implementation blueprint with code examples
- Clear validation gates and testing strategy
- Comprehensive error handling specifications
- Real-world git workflow patterns
- Bashew framework integration knowledge

The implementation should be achievable in one pass with this level of detail and context.