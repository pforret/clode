# PRP: Implement Procedure v2.md Step 5.b - Claude Code Assisted Merge

## Product Requirements Prompt (PRP)

**Feature**: Implement Step 5.b Claude Code Assisted Merge workflow from docs/procedure_v2.md  
**Complexity**: Medium  
**Estimated Implementation Time**: 1-2 hours  
**Target File**: `clode.sh`

## Overview

Implement the specific "Claude Code Assisted Merge" workflow described in step 5.b of docs/procedure_v2.md. 
This provides an alternative to the current squashing approach by using `git reset --soft main` to stage all changes from a feature branch as a single commit, then having Claude Code analyze and create the final commit message.

## Context and Research Findings

### Current State Analysis
- **Status**: clode.sh is fully functional with comprehensive git workflow implementation
- **Existing Commands**: All core commands implemented (prep, branch, inter, rollback, final, status)
- **Current Squashing**: Uses `git reset --soft "$before_base"` approach with intermediate commit detection
- **AI Integration**: Has `gen_commit_with_claude()` function and `AUTO_COMMIT` flag

### Gap Identification
The current `do_push_branch()` and `do_final_commit()` functions implement a different workflow than procedure_v2.md step 5.b:

**Current Implementation**:
1. Finds commits before first intermediate commit
2. Uses `git reset --soft "$before_base"` 
3. Creates squash commit with structured message
4. Optionally enhances message with Claude Code

**Procedure v2.md Step 5.b**:
1. Uses `git diff main...HEAD` to analyze all branch changes
2. Uses `git reset --soft main` to stage everything from branch  
3. Claude Code analyzes staged changes and creates commit message
4. Results in clean single commit on main branch

### Technical Requirements

**Commands from procedure_v2.md step 5.b**:
```bash
# Analyze changes between main and feature branch
git diff main...HEAD

# Reset to main while keeping all changes staged
git reset --soft main

# Show status and staged changes for Claude analysis
git status
git diff --cached

# Claude Code examines and commits with generated message
# (Implementation will integrate with existing gen_commit_with_claude)
```

## Implementation Blueprint

### Phase 1: Add New Command Option

**File**: `clode.sh` line 54  
**Change**: Add new action choice for the step 5.b workflow

```bash
# Current:
choice|1|action|action to perform|prep,branch,b,inter,i,rollback,r,final,f,status,s,spatie,check,env,update

# Updated:
choice|1|action|action to perform|prep,branch,b,inter,i,rollback,r,final,f,merge,m,status,s,spatie,check,env,update
```

### Phase 2: Add Command Router Case

**File**: `clode.sh` lines 96-104 (after final action)  
**Addition**: New action case for merge command

```bash
merge | m)
  #TIP: use «$script_prefix merge» to merge feature branch using procedure v2 step 5.b workflow
  #TIP:> $script_prefix merge
  #TIP: use «$script_prefix merge -A» to auto-generate commit messages with Claude Code CLI  
  #TIP:> $script_prefix merge --AUTO_COMMIT
  do_claude_assisted_merge
  ;;
```

### Phase 3: Implement Core Function

**File**: `clode.sh` (after do_final_commit around line 621)  
**Addition**: Complete implementation of step 5.b workflow

```bash
function do_claude_assisted_merge() {
  # Validate we're in a git repo and on feature branch
  if [[ ! -d ".git" ]]; then
    IO:die "Not in a git repository"
  fi

  local current_branch
  current_branch=$(git branch --show-current)
  if [[ "$current_branch" == "main" || "$current_branch" == "master" ]]; then
    IO:die "Cannot merge from main/master branch. Switch to feature branch first."
  fi

  # Ensure we're on a feature branch with changes
  if ! git show-ref --verify --quiet "refs/heads/main" && ! git show-ref --verify --quiet "refs/heads/master"; then
    IO:die "No main or master branch found"
  fi

  # Determine main branch name
  local main_branch="main"
  if git show-ref --verify --quiet "refs/heads/master" && ! git show-ref --verify --quiet "refs/heads/main"; then
    main_branch="master"
  fi

  # Check if there are changes between current branch and main
  if [[ -z "$(git diff "$main_branch...HEAD")" ]]; then
    IO:alert "No changes detected between $current_branch and $main_branch"
    return 0
  fi

  # Show what we're about to do
  IO:announce "Claude Code Assisted Merge - Procedure v2 Step 5.b"
  IO:print "Current branch: $current_branch"
  IO:print "Target branch: $main_branch"
  
  # Show changes that will be merged (following procedure_v2.md)
  IO:print ""
  IO:print "${txtBold}Changes to be merged:${txtReset}"
  git diff --stat "$main_branch...HEAD"
  
  if ((DRY_RUN)); then
    IO:print ""
    IO:print "${txtBold}Dry run - would execute:${txtReset}"
    IO:print "git diff $main_branch...HEAD"
    IO:print "git reset --soft $main_branch"
    IO:print "git status"
    IO:print "git diff --cached"
    IO:print "[Claude Code analyzes and commits]"
    return 0
  fi

  # Ask for confirmation
  if ! IO:confirm "Proceed with Claude Code assisted merge?"; then
    IO:alert "Merge cancelled"
    return 0
  fi

  # Step 1: Analyze the diff (as per procedure_v2.md)
  IO:announce "Analyzing changes between $main_branch and $current_branch..."
  local diff_output
  diff_output=$(git diff "$main_branch...HEAD")
  
  if [[ -z "$diff_output" ]]; then
    IO:alert "No diff found - merge not needed"
    return 0
  fi

  # Step 2: Reset to main while keeping changes staged (key step from procedure_v2.md)
  IO:announce "Staging all changes from feature branch..."
  if ! git reset --soft "$main_branch"; then
    IO:die "Failed to reset to $main_branch. Please check your git status."
  fi

  # Verify we're now on main with staged changes
  local current_after_reset
  current_after_reset=$(git branch --show-current)
  if [[ "$current_after_reset" != "$main_branch" ]]; then
    IO:die "Reset failed - expected to be on $main_branch, but on $current_after_reset"
  fi

  # Step 3: Show status (as per procedure_v2.md)
  IO:print ""
  IO:print "${txtBold}Current status after reset:${txtReset}"
  git status --short

  # Step 4: Generate commit message with Claude Code
  local final_commit_msg
  if ((AUTO_COMMIT)) || { ! ((AUTO_COMMIT)) && IO:confirm "Generate commit message with Claude Code CLI?"; }; then
    IO:announce "Generating commit message with Claude Code CLI..."
    final_commit_msg=$(gen_commit_with_claude_v2 "$main_branch" "$current_branch")
    if [[ -n "$final_commit_msg" ]]; then
      final_commit_msg="$final_commit_msg

🤖 Generated with Claude Code - Procedure v2 Step 5.b"
    else
      # Fallback to manual message
      IO:alert "Claude Code generation failed, please provide commit message manually"
      final_commit_msg=$(IO:question "Enter commit message" "feat: merge feature branch $current_branch")
    fi
  else
    # Manual commit message
    final_commit_msg=$(IO:question "Enter commit message" "feat: merge feature branch $current_branch")
  fi

  # Step 5: Create the final commit
  IO:announce "Creating final commit..."
  if git commit -m "$final_commit_msg"; then
    IO:success "Successfully merged $current_branch into $main_branch using Claude Code assisted workflow"
    
    # Show final result
    IO:print ""
    IO:print "${txtBold}Final commit:${txtReset}"
    git log -1 --oneline
    
    # Clean up feature branch
    if IO:confirm "Delete feature branch $current_branch?"; then
      git branch -d "$current_branch" 2>/dev/null || git branch -D "$current_branch"
      IO:success "Deleted feature branch: $current_branch"
    fi
    
  else
    IO:die "Failed to create commit. Changes are staged - you can commit manually."
  fi

  # Show next steps
  IO:print ""
  IO:print "${txtBold}Next steps:${txtReset}"
  IO:print "1. Review the commit: git show HEAD"
  IO:print "2. Push to remote: git push"
  IO:print "3. The feature branch has been merged as a single clean commit"
}

function gen_commit_with_claude_v2() {
  local main_branch="$1"
  local feature_branch="$2"

  if ! command -v claude >/dev/null 2>&1; then
    IO:debug "Claude CLI not available"
    return 1
  fi

  # Get the staged changes (different from original gen_commit_with_claude)
  local staged_diff staged_files
  staged_diff=$(git diff --cached)
  staged_files=$(git diff --cached --name-only)

  # Create enhanced prompt for Claude based on procedure v2 requirements
  local claude_prompt="You are helping create a commit message for a git merge using the Procedure v2 Step 5.b workflow.

CONTEXT:
- Feature branch '$feature_branch' is being merged into '$main_branch'
- All changes have been staged using 'git reset --soft $main_branch'
- This represents the complete work from the feature branch

STAGED FILES:
$staged_files

STAGED CHANGES SUMMARY:
$(git diff --cached --stat)

REQUIREMENTS:
- Create a single-line commit message using conventional commits format
- Focus on the overall feature/change being merged, not individual commits
- Use appropriate prefix: feat:, fix:, docs:, refactor:, etc.
- Maximum 72 characters for the first line
- Briefly describe the main accomplishment or feature added

Generate ONLY the commit message, no explanations:"

  if ((DRY_RUN)); then
    IO:print "Would generate commit message with Claude Code CLI using:"
    IO:print "---------"
    IO:print "$claude_prompt"
    IO:print "---------"
    return 0
  fi

  # Generate commit message with Claude
  local generated_msg
  if generated_msg=$(echo "$claude_prompt" | claude 2>/dev/null); then
    # Clean up the message (remove quotes, extra whitespace)
    generated_msg=$(echo "$generated_msg" | sed 's/^["'"'"']//' | sed 's/["'"'"']$//' | head -1)
    echo "$generated_msg"
  else
    IO:debug "Claude generation failed"
    return 1
  fi
}
```

## Validation Gates

**Commands to verify implementation**:
```bash
# Test script syntax
bash -n clode.sh

# Test basic functionality
./clode.sh check

# Test help output includes new merge command
./clode.sh -h | grep merge

# Test dry-run functionality  
./clode.sh merge --dry-run

# Integration test (requires test git repo)
mkdir test_merge && cd test_merge
git init --initial-branch=main
echo "initial" > file.txt && git add . && git commit -m "initial commit"
git checkout -b feature/test
echo "feature work" >> file.txt && git add . && git commit -m "add feature"
../clode.sh merge --dry-run  # Should show merge preview
```

## Implementation Task List

1. **Update action choice** - Add 'merge,m' to Option:config choice line
2. **Add action router case** - Add merge command case in Script:main()  
3. **Implement do_claude_assisted_merge()** - Complete function following procedure v2 workflow
4. **Implement gen_commit_with_claude_v2()** - Enhanced Claude integration for staged changes
5. **Test dry-run functionality** - Ensure --dry-run shows correct preview
6. **Test integration** - Full workflow test with actual git repo
7. **Update help/tips** - Add TIP comments for new merge command

## Key Implementation Details

### Git Command Patterns (from procedure_v2.md)
- Use `git diff main...HEAD` to analyze branch changes (three-dot notation)
- Use `git reset --soft main` to stage all changes while switching to main
- Use `git diff --cached` to show staged changes for Claude analysis
- Use `git status --short` for concise status display

### Error Handling
- Validate git repository exists and has main/master branch
- Ensure we're on a feature branch before starting
- Check for uncommitted changes and handle appropriately  
- Verify reset operation succeeded and we're on the target branch
- Provide clear feedback at each step of the process

### Claude Code Integration
- Create enhanced prompt specifically for staged changes analysis
- Focus on overall feature description rather than individual commits
- Maintain compatibility with existing AUTO_COMMIT flag
- Provide fallback to manual commit message if Claude fails

### User Experience
- Clear progress indicators at each step
- Show diff preview before proceeding
- Confirmation prompts for destructive operations
- Option to clean up feature branch after successful merge
- Comprehensive next steps guidance

## Testing Strategy

1. **Syntax Testing**: `bash -n clode.sh`
2. **Help Testing**: Verify new command appears in help output
3. **Dry-run Testing**: Test all paths with `--dry-run` flag
4. **Integration Testing**: Full workflow test in isolated git repo
5. **Edge Case Testing**: Test error conditions and validations
6. **Claude Integration Testing**: Test both with and without Claude CLI

## Documentation URLs

- **Source Procedure**: `/docs/procedure_v2.md` (lines 149-182)
- **Git Reset Documentation**: https://git-scm.com/docs/git-reset
- **Git Diff Three-dot**: https://git-scm.com/docs/git-diff#Documentation/git-diff.txt-emgitdiffemltoptionsgtltcommitgtltcommitgt--ltpathgt82308203
- **Conventional Commits**: https://www.conventionalcommits.org/en/v1.0.0/
- **Claude Code CLI**: https://claude.ai/code

## Success Criteria

- New `merge` command implements exact workflow from procedure_v2.md step 5.b
- Uses `git reset --soft main` approach instead of current squashing method
- Integrates with existing Claude Code CLI for commit message generation  
- Provides comprehensive error handling and user feedback
- Maintains compatibility with existing DRY_RUN and AUTO_COMMIT flags
- Successfully merges feature branches as single clean commits on main

## Risk Assessment

- **Low Risk**: Adding new command alongside existing functionality
- **Medium Risk**: Git reset operations that modify branch state
- **Low Risk**: Claude CLI integration (has fallback mechanisms)

## Confidence Score: 9/10

This PRP provides comprehensive context and detailed implementation steps for the specific missing feature. The high confidence score reflects:

- Clear gap identification between current implementation and requirements
- Detailed research of existing codebase patterns and conventions
- Step-by-step implementation blueprint with exact code
- Comprehensive validation gates and testing strategy  
- Integration with existing Claude Code CLI functionality
- Follows established bashew framework patterns from existing code

The implementation should be achievable in one pass with this level of detail and context.