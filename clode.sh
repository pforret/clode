#!/usr/bin/env bash
### ==============================================================================
### SO HOW DO YOU PROCEED WITH YOUR SCRIPT?
### 1. define the flags/options/parameters and defaults you need in Option:config()
### 2. implement the different actions in Script:main() directly or with helper functions do_action1
### 3. implement helper functions you defined in previous step
### ==============================================================================

### Created by Peter Forret ( pforret ) on 2025-07-13
### Based on https://github.com/pforret/bashew 1.22.0
script_version="0.0.1" # if there is a VERSION.md in this script's folder, that will have priority over this version number
readonly script_author="peter@forret.com"
readonly script_created="2025-07-13"
readonly run_as_root=-1 # run_as_root: 0 = don't check anything / 1 = script MUST run as root / -1 = script MAY NOT run as root
readonly script_description="Prep your projects for AI software development assistants"

function Option:config() {
  ### Change the next lines to reflect which flags/options/parameters you need
  ### flag:   switch a flag 'on' / no value specified
  ###     flag|<short>|<long>|<description>
  ###     e.g. "-v" or "--VERBOSE" for VERBOSE output / default is always 'off'
  ###     will be available as $<long> in the script e.g. $VERBOSE
  ### option: set an option / 1 value specified
  ###     option|<short>|<long>|<description>|<default>
  ###     e.g. "-e <extension>" or "--extension <extension>" for a file extension
  ###     will be available a $<long> in the script e.g. $extension
  ### list: add an list/array item / 1 value specified
  ###     list|<short>|<long>|<description>| (default is ignored)
  ###     e.g. "-u <user1> -u <user2>" or "--user <user1> --user <user2>"
  ###     will be available a $<long> array in the script e.g. ${user[@]}
  ### param:  comes after the options
  ###     param|<type>|<long>|<description>
  ###     <type> = 1 for single parameters - e.g. param|1|output expects 1 parameter <output>
  ###     <type> = ? for optional parameters - e.g. param|1|output expects 1 parameter <output>
  ###     <type> = n for list parameter    - e.g. param|n|inputs expects <input1> <input2> ... <input99>
  ###     will be available as $<long> in the script after option/param parsing
  ### choice:  is like a param, but when there are limited options
  ###     choice|<type>|<long>|<description>|choice1,choice2,...
  ###     <type> = 1 for single parameters - e.g. param|1|output expects 1 parameter <output>
  grep <<<"
#commented lines will be filtered
flag|h|help|show usage
flag|Q|QUIET|no output
flag|V|VERBOSE|also show debug messages
flag|f|FORCE|do not ask for confirmation (always yes)
flag|A|AUTO_COMMIT|automatically generate commit messages with Claude Code CLI
flag|D|DRY_RUN|show what would be done without executing
flag|G|GENERATE|use Claude Code CLI to generate CLAUDE.md file
flag|S|SQUASH|squash all intermediate commits before push
option|C|COMMIT|commit type for intermediate commits|fix
option|L|LOG_DIR|folder for log files |$HOME/log/$script_prefix
option|M|MESSAGE|custom commit message|
option|T|TMP_DIR|folder for temp files|.tmp
choice|1|action|action to perform|prep,branch,b,inter,i,rollback,r,final,f,merge,m,status,s,spatie,check,env,update
param|?|input|input text
" -v -e '^#' -e '^\s*$'
}

#####################################################################
## Put your Script:main script here
#####################################################################

function Script:main() {
  IO:log "[$script_basename] $script_version started"

  Os:require "awk"
  Os:require "git"

  case "${action,,}" in
  prep)
    #TIP: use «$script_prefix prep» to prepare project for AI development
    #TIP:> $script_prefix prep
    #TIP: use «$script_prefix prep -G» to generate CLAUDE.md with Claude Code CLI
    #TIP:> $script_prefix prep --GENERATE
    do_prep_project
    ;;

  branch | b)
    #TIP: use «$script_prefix branch [name]» to create new feature branch
    #TIP:> $script_prefix branch my-feature
    do_create_branch
    ;;

  inter | i)
    #TIP: use «$script_prefix inter [-M "message"]» to create intermediate commit
    #TIP:> $script_prefix inter -M "implemented feature"
    do_intermediate_commit
    ;;

  rollback | r)
    #TIP: use «$script_prefix rollback [target]» to rollback commits
    #TIP:> $script_prefix rollback last
    do_rollback_commit
    ;;

  final | f)
    #TIP: use «$script_prefix final» to choose between pull request or merge-into-main workflow
    #TIP:> $script_prefix final
    #TIP: use «$script_prefix final -A» to auto-generate commit messages with Claude Code CLI
    #TIP:> $script_prefix final --AUTO_COMMIT
    #TIP: use «$script_prefix final -E» to automatically clear command history after final commit
    #TIP:> $script_prefix final --ERASE
    do_final_commit
    ;;

  merge | m)
    #TIP: use «$script_prefix merge» to merge feature branch using Merge-into-main  workflow
    #TIP:> $script_prefix merge
    #TIP: use «$script_prefix merge -A» to auto-generate commit messages with Claude Code CLI  
    #TIP:> $script_prefix merge --AUTO_COMMIT
    do_claude_assisted_merge
    ;;

  status | s)
    #TIP: use «$script_prefix status» to show current git workflow status
    #TIP:> $script_prefix status
    do_show_status
    ;;

  spatie)
    #TIP: use «$script_prefix spatie» to install Spatie's Laravel Claude Code recommendations
    #TIP:> $script_prefix spatie
    do_install_spatie
    ;;

  check | env)
    ## leave this default action, it will make it easier to test your script
    #TIP: use «$script_prefix check» to check if this script is ready to execute and what values the options/flags are
    #TIP:> $script_prefix check
    #TIP: use «$script_prefix env» to generate an example .env file
    #TIP:> $script_prefix env > .env
    Script:check
    ;;

  update)
    ## leave this default action, it will make it easier to test your script
    #TIP: use «$script_prefix update» to update to the latest version
    #TIP:> $script_prefix update
    Script:git_pull
    ;;

  *)
    IO:die "action [$action] not recognized"
    ;;
  esac
  IO:log "[$script_basename] ended after $SECONDS secs"
  #TIP: >>> bash script created with «pforret/bashew»
  #TIP: >>> for bash development, also check out «pforret/setver» and «pforret/progressbar»
}

#####################################################################
## Put your helper scripts here
#####################################################################

function do_prep_project() {
  IO:log "Preparing project for AI development"

  # Create necessary directories
  [[ ! -d ".claude" ]] && mkdir -p ".claude" && IO:success "Created .claude/ directory"

  # Create CLAUDE.md if it doesn't exist
  if [[ ! -f "CLAUDE.md" ]]; then
    #shellcheck disable=SC2154
    if ((GENERATE)) && command -v claude >/dev/null 2>&1; then
      IO:announce "Generating CLAUDE.md with Claude Code CLI..."
      if claude generate-claude-md >CLAUDE.md 2>/dev/null; then
        IO:success "Generated CLAUDE.md using Claude Code CLI"
      else
        IO:alert "Failed to generate with Claude Code CLI, falling back to template"
        GENERATE=0 # Fall back to template approach
      fi
    fi

    # Use template or fallback if generation wasn't requested or failed
    if ! ((GENERATE)) || [[ ! -f "CLAUDE.md" ]]; then
      local template_path="$script_install_folder/templates/CLAUDE.md"
      if [[ -f "$template_path" ]]; then
        cp "$template_path" "CLAUDE.md"
        IO:success "Created CLAUDE.md from template"
      else
        IO:alert "Template file not found: $template_path"
        IO:alert "Creating basic CLAUDE.md file"
        {
          echo "# CLAUDE.md"
          echo ""
          echo "This file provides guidance to Claude Code when working with this project."
        } >CLAUDE.md
        IO:success "Created basic CLAUDE.md"
      fi
    fi
  fi

  # Create planning.md if it doesn't exist
  if [[ ! -f "planning.md" ]]; then
    local template_path="$script_install_folder/templates/planning.md"
    if [[ -f "$template_path" ]]; then
      cp "$template_path" "planning.md"
      IO:success "Created planning.md from template"
    else
      IO:alert "Template file not found: $template_path"
      IO:alert "Creating basic planning.md file"
      {
        echo "# Project Planning"
        echo ""
        echo "## Current Task"
        echo "[Describe what you're working on]"
      } >planning.md
      IO:success "Created basic planning.md"
    fi
  fi

  # Initialize git if not already initialized
  if [[ ! -d ".git" ]]; then
    # Try to initialize with main branch (newer git versions)
    if git init --initial-branch=main 2>/dev/null; then
      IO:success "Initialized git repository with main branch"
    else
      # Fallback for older git versions
      git init
      git branch -m main 2>/dev/null || true # Rename master to main if it exists
      IO:success "Initialized git repository with main branch"
    fi
  fi

  if IO:confirm "Install essential MCP servers?"; then
    claude mcp add playwright npx -- @playwright/mcp@latest
    claude mcp add context7 -- npx -y @upstash/context7-mcp
    claude mcp add --transport http github https://api.githubcopilot.com/mcp/
    IO:announce "Installed essential MCP servers:"
    claude mcp list
  fi

  IO:success "Project prepared for AI development"
}

function do_create_branch() {
  local branch_name="${input:-}"

  # Validate we're in a git repo
  if [[ ! -d ".git" ]]; then
    IO:die "Not in a git repository. Run 'clode prep' first."
  fi

  # Generate branch name if not provided
  if [[ -z "$branch_name" ]]; then
    local timestamp
    timestamp=$(date +%Y%m%d-%H%M)
    branch_name="feature/ai-task-$timestamp"
    IO:announce "Generated branch name: $branch_name"
  fi

  # Show current branch for debugging
  local current_branch
  current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
  IO:debug "Current branch: $current_branch"

  # Check for uncommitted changes
  if [[ -n "$(git status --porcelain)" ]]; then
    if IO:confirm "You have uncommitted changes. Commit them first?"; then
      #shellcheck disable=SC2154
      if ((DRY_RUN)); then
        IO:print "Would run: git add -A"
        IO:print "Would run: git commit -m \"feat: save work before creating new branch\""
      else
        git add -A
        git commit -m "feat: save work before creating new branch"
      fi
    else
      IO:die "Please commit or stash your changes first"
    fi
  fi

  # Check if branch already exists
  if git show-ref --verify --quiet "refs/heads/$branch_name"; then
    IO:alert "Branch '$branch_name' already exists"
    if IO:confirm "Switch to existing branch?"; then
      if ((DRY_RUN)); then
        IO:print "Would run: git checkout $branch_name"
        IO:print "Would switch to existing branch: $branch_name"
        return 0
      else
        if git checkout "$branch_name"; then
          # Verify the branch switch worked
          local actual_branch
          actual_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
          if [[ "$actual_branch" == "$branch_name" ]]; then
            IO:success "Switched to existing branch: $branch_name"
          else
            IO:die "Failed to switch to branch: $branch_name. Current branch: $actual_branch"
          fi
        else
          IO:die "Failed to switch to branch: $branch_name"
        fi
      fi
    else
      IO:die "Branch creation cancelled"
    fi
  else
    # Create and switch to new branch
    if ((DRY_RUN)); then
      IO:print "Would run: git checkout -b $branch_name"
      IO:print "Would create and switch to new branch: $branch_name"
      IO:print "Would create: .claude/current_branch"
      IO:print "Would create: .claude/step_counter"
      return 0
    else
      if git checkout -b "$branch_name"; then
        # Verify the branch switch worked
        local actual_branch
        actual_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
        if [[ "$actual_branch" == "$branch_name" ]]; then
          IO:success "Created and switched to branch: $branch_name"

          [[ ! -d .claude ]] && mkdir .claude
          # Store branch info for later use
          echo "$branch_name" >.claude/current_branch
          echo "0" >.claude/step_counter
        else
          IO:die "Branch created but failed to switch. Current branch: $actual_branch"
        fi
      else
        IO:die "Failed to create branch: $branch_name"
      fi
    fi
  fi
}

function do_intermediate_commit() {
  local commit_type="${COMMIT:-fix}"
  local commit_msg="${MESSAGE:-}"
  local step_file=".claude/step_counter"

  # Validate we're in a git repo and on a feature branch
  if [[ ! -d ".git" ]]; then
    IO:die "Not in a git repository"
  fi

  local current_branch
  current_branch=$(git branch --show-current)
  if [[ "$current_branch" == "main" || "$current_branch" == "master" ]]; then
    IO:die "Cannot create intermediate commits on main/master branch"
  fi

  # Get or initialize step counter
  local step_num=1
  if [[ -f "$step_file" ]]; then
    step_num=$(cat "$step_file")
    ((step_num++))
  else
    # Ensure .claude directory exists
    mkdir -p .claude
  fi

  # Check for changes
  if [[ -z "$(git status --porcelain)" ]]; then
    IO:alert "No changes to commit"
    return 0
  fi

  # Stage all changes first
  git add -A

  # Generate commit message if not provided
  if [[ -z "$commit_msg" ]]; then
    # Auto-generate based on staged files
    local changed_files
    changed_files=$(git diff --name-only --staged)
    if [[ -n "$changed_files" ]]; then
      local file_count
      file_count=$(echo "$changed_files" | wc -l)

      if [[ $file_count -eq 1 ]]; then
        commit_msg="update $file_count $(git diff --stat --staged "$changed_files" | head -1)"
      else
        local top_files

        top_files=$(git diff --stat --staged | sed '$d' | sort -k2 -nr | head -5 | awk '{print $1}' | paste -sd, -)

        if [[ -n "$top_files" ]]; then
          commit_msg="update $file_count file(s): $top_files"
        else
          commit_msg="update $file_count file(s)"
        fi
      fi
    else
      commit_msg="checkpoint update"
    fi
  fi
  local full_commit_msg
  full_commit_msg="${commit_type}: ${commit_msg} #intermediate #step:[$(printf "%02d" $step_num)]"

  #shellcheck disable=SC2154
  if ((DRY_RUN)); then
    IO:print "Would commit: $full_commit_msg"
    return 0
  fi

  git commit -m "$full_commit_msg"
  echo "$step_num" >"$step_file"

  IO:success "Created intermediate commit #$(printf "%02d" $step_num): $commit_msg"
}

function do_rollback_commit() {
  local target="${input:-last}"

  # Validate we're in a git repo
  if [[ ! -d ".git" ]]; then
    IO:die "Not in a git repository"
  fi

  case "$target" in
  "last")
    # Rollback last commit
    local last_commit
    last_commit=$(git log -1 --pretty=format:"%h %s")
    if IO:confirm "Rollback last commit: $last_commit?"; then
      git reset --hard HEAD~1 # restore existing files/deleted files
      git clean -f            # delete new files
      IO:success "Rolled back last commit"

      # Update step counter if it was an intermediate commit
      if [[ "$last_commit" == *"#intermediate"* ]]; then
        local step_file=".claude/step_counter"
        if [[ -f "$step_file" ]]; then
          local current_step
          current_step=$(cat "$step_file")
          ((current_step > 0)) && echo $((current_step - 1)) >"$step_file"
        fi
      fi
    fi
    ;;
  "branch")
    # Rollback to start of branch
    local branch_start
    branch_start=$(git merge-base HEAD main || git merge-base HEAD master)
    if [[ -n "$branch_start" ]]; then
      git log --oneline "$branch_start..HEAD"
      if IO:confirm "Rollback to start of branch (delete all commits above)?"; then
        git reset --hard "$branch_start"
        # Ensure .claude directory exists and reset step counter
        mkdir -p .claude
        echo "0" >.claude/step_counter
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

function do_pull_request() {
  local current_branch intermediate_commits base_commit before_base final_msg
  # Validate we're in a git repo and on feature branch
  if [[ ! -d ".git" ]]; then
    IO:die "Not in a git repository"
  fi

  current_branch=$(git branch --show-current)
  if [[ "$current_branch" == "main" || "$current_branch" == "master" ]]; then
    IO:die "Cannot squash/push from main/master branch"
  fi

  # Check for uncommitted changes
  if ! git diff --quiet || ! git diff --cached --quiet || [[ -n $(git ls-files --others --exclude-standard) ]]; then
    IO:print "Uncommitted changes detected"
    if IO:confirm "Create one last intermediate commit with current changes?"; then
      git add .
      git commit -m "WIP: final changes #intermediate"
      IO:print "Created final intermediate commit"
    fi
  fi

  # Count intermediate commits
  intermediate_commits=$(git log --oneline --grep="#intermediate" | wc -l)

  if [[ $intermediate_commits -gt 1 ]] && ! ((SQUASH)); then
    IO:print "Found $intermediate_commits intermediate commits"
    if IO:confirm "Squash intermediate commits into single commit?"; then
      SQUASH=1
    fi
  fi

  if ((SQUASH)) && [[ $intermediate_commits -gt 1 ]]; then
    IO:announce "Squashing $intermediate_commits intermediate commits..."

    # Find the commit before first intermediate commit
    base_commit=$(git log --oneline --grep="#intermediate" | tail -1 | awk '{print $1}')
    before_base=$(git rev-parse "$base_commit^")

    # Create squash commit message
    local default_msg
    default_msg="$COMMIT: completed feature implementation #squashed #clode.sh
        
$(git log --oneline "$before_base..HEAD" --grep="#intermediate" | sed 's/^[a-f0-9]* /- /')
"

    #shellcheck disable=SC2154
    if ((AUTO_COMMIT)) || { ! ((AUTO_COMMIT)) && IO:confirm "Generate commit message with Claude Code CLI?"; }; then
      IO:announce "Generating commit message with Claude Code CLI..."
      final_msg=$(gen_commit_with_claude "$before_base" "$default_msg")
      final_msg="$final_msg

🤖 Generated with Claude Code"
    else
      final_msg="$default_msg"
    fi

    if ((DRY_RUN)); then
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
  if ((DRY_RUN)); then
    IO:print "Would push branch: $current_branch"
    return 0
  fi

  # Check if remote branch exists and push
  if git ls-remote --heads origin "$current_branch" | grep -q "$current_branch"; then
    if ((DRY_RUN)); then
      IO:print "Would run: git push --force-with-lease origin $current_branch"
    else
      git push --force-with-lease origin "$current_branch"
    fi
  else
    if ((DRY_RUN)); then
      IO:print "Would run: git push -u origin $current_branch"
    else
      git push -u origin "$current_branch"
    fi
  fi

  if ((DRY_RUN)); then
    IO:print "Would have pushed branch: $current_branch"
  else
    IO:success "Pushed branch: $current_branch"
  fi

  # Provide next steps
  IO:print ""
  IO:print "Next steps:"
  IO:print "1. Create pull request on GitHub"
  IO:print "2. Review and merge when ready"
  IO:print "3. Delete feature branch after merge"
}

function do_final_commit() {
  # Validate we're in a git repo and on feature branch
  if [[ ! -d ".git" ]]; then
    IO:die "Not in a git repository"
  fi

  local current_branch
  current_branch=$(git branch --show-current)
  if [[ "$current_branch" == "main" || "$current_branch" == "master" ]]; then
    IO:die "Cannot finalize from main/master branch. Switch to feature branch first."
  fi

  # Ask user to choose the final workflow
  IO:print ""
  IO:print "${txtBold}Choose final workflow:${txtReset}"
  IO:print "1. Squash & Push for Pull Request (with formal review & approval)"
  IO:print "2. Merge into Main (local merge and update main branch)"
  IO:print ""
  
  local choice
  choice=$(IO:question "Enter your choice (1 or 2)" "1")
  
  case "$choice" in
    "1")
      IO:announce "Executing: Squash & Push ..."
      SQUASH=1
      do_pull_request
      ;;
    "2") 
      IO:announce "Executing: Merge into Main ..."
      do_merge_into_main
      ;;
    *)
      IO:die "Invalid choice. Please enter 1 or 2."
      ;;
  esac
  
  IO:print "It might be a good idea to execute /clear in your Claude Code window"
}

function do_merge_into_main() {
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
  IO:announce "Claude Code Assisted Merge Into Main"
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
  # This stays on feature branch but resets commit history to main and stages all changes
  IO:announce "Staging all changes from feature branch (resetting to $main_branch commit history)..."
  if ! git reset --soft "$main_branch"; then
    IO:die "Failed to reset to $main_branch. Please check your git status."
  fi

  # Verify we're still on feature branch (this is correct behavior)
  local current_after_reset
  current_after_reset=$(git branch --show-current)
  if [[ "$current_after_reset" != "$current_branch" ]]; then
    IO:die "Reset failed - expected to stay on $current_branch, but on $current_after_reset"
  fi

  # Verify we have staged changes
  if [[ -z "$(git diff --cached --name-only)" ]]; then
    IO:die "Reset failed - no staged changes found after reset"
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

🤖 Generated with Claude Code - pforret/clode"
    else
      # Fallback to manual message
      IO:alert "Claude Code generation failed, please provide commit message manually"
      final_commit_msg=$(IO:question "Enter commit message" "feat: merge feature branch $current_branch")
    fi
  else
    # Manual commit message
    final_commit_msg=$(IO:question "Enter commit message" "feat: merge feature branch $current_branch")
  fi

  # Step 5: Create the final commit on feature branch
  IO:announce "Creating final commit..."
  if git commit -m "$final_commit_msg"; then
    local final_commit_hash
    final_commit_hash=$(git rev-parse HEAD)
    
    # Show the commit that was created
    IO:print ""
    IO:print "${txtBold}Final commit created:${txtReset}"
    git log -1 --oneline
    
    # Step 6: Switch to main and update it to point to our new commit
    IO:announce "Updating $main_branch branch to include the merge..."
    if git checkout "$main_branch"; then
      # Fast-forward main to our new commit
      if git reset --hard "$final_commit_hash"; then
        IO:success "Successfully merged $current_branch into $main_branch using Claude Code assisted workflow"
        
        # Clean up feature branch
        if IO:confirm "Delete feature branch $current_branch?"; then
          git branch -d "$current_branch" 2>/dev/null || git branch -D "$current_branch"
          IO:success "Deleted feature branch: $current_branch"
        fi
      else
        IO:die "Failed to update $main_branch branch to new commit"
      fi
    else
      IO:die "Failed to switch to $main_branch branch"
    fi
    
  else
    IO:die "Failed to create commit. Changes are staged - you can commit manually."
  fi

  # Show next steps
  IO:print ""
  IO:print "${txtBold}Next steps:${txtReset}"
  IO:print "1. Review the merge: git show HEAD"
  IO:print "2. Push to remote: git push"
  IO:print "3. Your feature has been merged as a single clean commit on $main_branch"
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
  local claude_prompt
  claude_prompt="You are helping create a commit message for a git merge using the Merge-into-main workflow.

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

function do_show_status() {
  # Validate we're in a git repo
  if [[ ! -d ".git" ]]; then
    IO:die "Not in a git repository. Run 'clode prep' first."
  fi

  # Get current branch
  local current_branch
  current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")

  # Display current branch
  IO:print "📍  ${txtBold}Current branch:${txtReset}    $current_branch"

  # Check if we're on main/master
  if [[ "$current_branch" == "main" || "$current_branch" == "master" ]]; then
    IO:alert "You're on the main branch"
    return 0
  fi

  # Find last final commit (before any intermediate commits)
  local last_final_commit
  last_final_commit=$(git log --oneline --grep="#intermediate" | tail -1 | awk '{print $1}')

  if [[ -n "$last_final_commit" ]]; then
    # Get the commit before the first intermediate commit
    local before_base
    before_base=$(git rev-parse "$last_final_commit^" 2>/dev/null)

    if [[ -n "$before_base" ]]; then
      local final_commit_msg
      final_commit_msg=$(git log --oneline -1 "$before_base" | sed 's/^[a-f0-9]* //')
      IO:print "🎯  ${txtBold}Last final commit:${txtReset} $final_commit_msg"
    else
      IO:print "🎯  ${txtBold}Last final commit:${txtReset} (initial commit)"
    fi
  else
    # No intermediate commits found, show last commit
    local last_commit
    last_commit=$(git log --oneline -1 2>/dev/null | sed 's/^[a-f0-9]* //')
    IO:print "🎯  ${txtBold}Last final commit:${txtReset} $last_commit"
  fi

  # List all intermediate commits
  local intermediate_commits
  intermediate_commits=$(git log --oneline --grep="#intermediate")

  if [[ -n "$intermediate_commits" ]]; then
    local count
    count=$(echo "$intermediate_commits" | wc -l | xargs)
    IO:print "🔄  ${txtBold}Intermediate commits ($count):${txtReset}"
    echo "$intermediate_commits" | while read -r commit; do
      local msg
      msg=$(echo "$commit" | sed 's/^[a-f0-9]* //')
      IO:print "   • $msg"
    done
  else
    IO:print "🔄  ${txtBold}Intermediate commits:${txtReset} none"
  fi

  # Show changed files since last intermediate commit
  local last_intermediate
  last_intermediate=$(git log --oneline --grep="#intermediate" -1 | awk '{print $1}')

  if [[ -n "$last_intermediate" ]]; then
    # Show both committed changes since last intermediate AND uncommitted changes
    local committed_files uncommitted_files untracked_files all_changed_files
    committed_files=$(git diff --name-only "$last_intermediate..HEAD")
    uncommitted_files=$(git diff --name-only)
    untracked_files=$(git status --porcelain | grep "^??" | cut -c4-)

    # Combine and deduplicate the files
    all_changed_files=$(echo -e "$committed_files\n$uncommitted_files\n$untracked_files" | sort -u | grep -v '^$')

    if [[ -n "$all_changed_files" ]]; then
      local file_count
      file_count=$(echo "$all_changed_files" | wc -l | xargs)
      IO:print "📝  ${txtBold}Changed files since last intermediate ($file_count):${txtReset}"
      echo "$all_changed_files" | while read -r file; do
        local status
        status=$(git status --porcelain "$file" | cut -c1-2)
        case "$status" in
        " M" | "M " | "MM") IO:print "   ${txtBold}M${txtReset} $file" ;;
        " A" | "A " | "AM") IO:print "   ${txtInfo}A${txtReset} $file" ;;
        " D" | "D " | "DM") IO:print "   ${txtError}D${txtReset} $file" ;;
        "??") IO:alert "? $file" ;;
        *) IO:print "   • $file" ;;
        esac
      done
    else
      IO:print "📝  ${txtBold}Changed files since last intermediate:${txtReset} none"
    fi
  else
    # No intermediate commits, show uncommitted changes and untracked files
    local uncommitted_files untracked_files all_changed_files
    uncommitted_files=$(git diff --name-only)
    untracked_files=$(git status --porcelain | grep "^??" | cut -c4-)

    # Combine and deduplicate the files
    all_changed_files=$(echo -e "$uncommitted_files\n$untracked_files" | sort -u | grep -v '^$')

    if [[ -n "$all_changed_files" ]]; then
      local file_count
      file_count=$(echo "$all_changed_files" | wc -l | xargs)
      IO:print "📝  ${txtBold}Changed files since last commit ($file_count):${txtReset}"
      echo "$all_changed_files" | while read -r file; do
        local status
        status=$(git status --porcelain "$file" | cut -c1-2)
        case "$status" in
        " M" | "M " | "MM") IO:print "   ${txtBold}M${txtReset} $file" ;;
        " A" | "A " | "AM") IO:print "   ${txtInfo}A${txtReset} $file" ;;
        " D" | "D " | "DM") IO:print "   ${txtError}D${txtReset} $file" ;;
        "??") IO:alert "? $file" ;;
        *) IO:print "   • $file" ;;
        esac
      done
    else
      IO:print "📝  ${txtBold}Changed files since last commit:${txtReset} none"
    fi
  fi
}

function do_install_spatie() {
  [[ ! -f CLAUDE.md ]] && IO:die "CLAUDE.md file not found. Please run 'clode prep' first."
  [[ ! -d .claude ]] && IO:die ".claude folder not found. Please run 'clode prep' first."
  [[ ! -w . ]] && IO:die "Current directory is not writable"
  [[ ! -w CLAUDE.md ]] && IO:die "CLAUDE.md is not writable"

  # Check if Spatie guidelines are already included
  if grep -q "laravel-php-guidelines.md" CLAUDE.md; then
    IO:print "Spatie guidelines are already included in CLAUDE.md"
    return 0
  fi

  local guidelines=".claude/laravel-php-guidelines.md"

  # cf https://spatie.be/guidelines/aia
  # Download our guidelines
  if ! curl -s -f -o "$guidelines" https://spatie.be/laravel-php-ai-guidelines.md; then
    IO:die "Failed to download Spatie guidelines"
  fi
  IO:success "Downloaded Spatie guidelines to $guidelines"

  # Tell Claude to read the guidelines file
  {
    echo " "
    echo " "
    echo "## Spatie Coding Standards"
    echo "When working on this Laravel/PHP project, first read the coding guidelines at @$guidelines"
  } >>CLAUDE.md

  IO:success "Added reference to Spatie guidelines to CLAUDE.md"
}

#####################################################################
################### DO NOT MODIFY BELOW THIS LINE ###################
#####################################################################

action=""
error_prefix=""
git_repo_remote=""
git_repo_root=""
install_package=""
os_kernel=""
os_machine=""
os_name=""
os_version=""
script_basename=""
script_hash="?"
script_lines="?"
script_prefix=""
shell_brand=""
shell_version=""
temp_files=()

# set strict mode -  via http://redsymbol.net/articles/unofficial-bash-strict-mode/
# removed -e because it made basic [[ testing ]] difficult
set -uo pipefail
IFS=$'\n\t'
FORCE=0
help=0

#to enable VERBOSE even before option parsing
VERBOSE=0
[[ $# -gt 0 ]] && [[ $1 == "-v" ]] && VERBOSE=1

#to enable QUIET even before option parsing
QUIET=0
[[ $# -gt 0 ]] && [[ $1 == "-q" ]] && QUIET=1

txtReset=""
txtError=""
txtInfo=""
txtInfo=""
txtWarn=""
txtBold=""
txtItalic=""
txtUnderline=""

char_succes="OK "
char_fail="!! "
char_alert="?? "
char_wait="..."
info_icon="(i)"
config_icon="[c]"
clean_icon="[c]"
require_icon="[r]"

### stdIO:print/stderr output
function IO:initialize() {
  script_started_at="$(Tool:time)"
  IO:debug "script $script_basename started at $script_started_at"

  [[ "${BASH_SOURCE[0]:-}" != "${0}" ]] && sourced=1 || sourced=0
  [[ -t 1 ]] && piped=0 || piped=1 # detect if output is piped
  if [[ $piped -eq 0 && -n "$TERM" ]]; then
    txtReset=$(tput sgr0)
    txtError=$(tput setaf 160)
    txtInfo=$(tput setaf 2)
    txtWarn=$(tput setaf 214)
    txtBold=$(tput bold)
    txtItalic=$(tput sitm)
    txtUnderline=$(tput smul)
  fi

  [[ $(echo -e '\xe2\x82\xac') == '€' ]] && unicode=1 || unicode=0 # detect if unicode is supported
  if [[ $unicode -gt 0 ]]; then
    char_succes="✅"
    char_fail="⛔"
    char_alert="✴️"
    char_wait="⏳"
    info_icon="🌼"
    config_icon="🌱"
    clean_icon="🧽"
    require_icon="🔌"
  fi
  error_prefix="${txtError}>${txtReset}"
}

function IO:print() {
  ((QUIET)) && true || printf '%b\n' "$*"
}

function IO:debug() {
  ((VERBOSE)) && IO:print "${txtInfo}# $* ${txtReset}" >&2
  true
}

function IO:die() {
  IO:print "${txtError}${char_fail} $script_basename${txtReset}: $*" >&2
  Os:beep
  Script:exit
}

function IO:alert() {
  IO:print "${txtWarn}${char_alert}${txtReset}: ${txtUnderline}$*${txtReset}" >&2
}

function IO:success() {
  IO:print "${txtInfo}${char_succes}${txtReset}  ${txtBold}$*${txtReset}"
}

function IO:announce() {
  IO:print "${txtInfo}${char_wait}${txtReset}  ${txtItalic}$*${txtReset}"
  sleep 1
}

function IO:progress() {
  ((QUIET)) || (
    local screen_width
    screen_width=$(tput cols 2>/dev/null || echo 80)
    local rest_of_line
    rest_of_line=$((screen_width - 5))

    if ((piped)); then
      IO:print "... $*" >&2
    else
      printf "... %-${rest_of_line}b\r" "$*                                             " >&2
    fi
  )
}

function IO:countdown() {
  local seconds=${1:-5}
  local message=${2:-Countdown :}
  local i

  if ((piped)); then
    IO:print "$message $seconds seconds"
  else
    for ((i = 0; i < "$seconds"; i++)); do
      IO:progress "${txtInfo}$message $((seconds - i)) seconds${txtReset}"
      sleep 1
    done
    IO:print "                         "
  fi
}

### interactive
function IO:confirm() {
  ((FORCE)) && return 0
  read -r -p "$1 [y/N] " -n 1
  echo " "
  [[ $REPLY =~ ^[Yy]$ ]]
}

function IO:question() {
  local ANSWER
  local DEFAULT=${2:-}
  read -r -p "$1 ($DEFAULT) > " ANSWER
  [[ -z "$ANSWER" ]] && echo "$DEFAULT" || echo "$ANSWER"
}

function IO:log() {
  [[ -n "${log_file:-}" ]] && echo "$(date '+%H:%M:%S') | $*" >>"$log_file"
}

function Tool:calc() {
  awk "BEGIN {print $*} ; "
}

function Tool:round() {
  local number="${1}"
  local decimals="${2:-0}"

  awk "BEGIN {print sprintf( \"%.${decimals}f\" , $number )};"
}

function Tool:time() {
  if [[ $(command -v perl) ]]; then
    perl -MTime::HiRes=time -e 'printf "%f\n", time'
  elif [[ $(command -v php) ]]; then
    php -r 'printf("%f\n",microtime(true));'
  elif [[ $(command -v python) ]]; then
    python -c 'import time; print(time.time()) '
  elif [[ $(command -v python3) ]]; then
    python3 -c 'import time; print(time.time()) '
  elif [[ $(command -v node) ]]; then
    node -e 'console.log(+new Date() / 1000)'
  elif [[ $(command -v ruby) ]]; then
    ruby -e 'STDOUT.puts(Time.now.to_f)'
  else
    date '+%s.000'
  fi
}

function Tool:throughput() {
  local time_started="$1"
  [[ -z "$time_started" ]] && time_started="$script_started_at"
  local operations="${2:-1}"
  local name="${3:-operation}"

  local time_finished
  local duration
  local seconds
  time_finished="$(Tool:time)"
  duration="$(Tool:calc "$time_finished - $time_started")"
  seconds="$(Tool:round "$duration")"
  local ops
  if [[ "$operations" -gt 1 ]]; then
    if [[ $operations -gt $seconds ]]; then
      ops=$(Tool:calc "$operations / $duration")
      ops=$(Tool:round "$ops" 3)
      duration=$(Tool:round "$duration" 2)
      IO:print "$operations $name finished in $duration secs: $ops $name/sec"
    else
      ops=$(Tool:calc "$duration / $operations")
      ops=$(Tool:round "$ops" 3)
      duration=$(Tool:round "$duration" 2)
      IO:print "$operations $name finished in $duration secs: $ops sec/$name"
    fi
  else
    duration=$(Tool:round "$duration" 2)
    IO:print "$name finished in $duration secs"
  fi
}

### string processing

function Str:trim() {
  local var="$*"
  # remove leading whitespace characters
  var="${var#"${var%%[![:space:]]*}"}"
  # remove trailing whitespace characters
  var="${var%"${var##*[![:space:]]}"}"
  printf '%s' "$var"
}

function Str:lower() {
  if [[ -n "$1" ]]; then
    local input="$*"
    echo "${input,,}"
  else
    awk '{print tolower($0)}'
  fi
}

function Str:upper() {
  if [[ -n "$1" ]]; then
    local input="$*"
    echo "${input^^}"
  else
    awk '{print toupper($0)}'
  fi
}

function Str:ascii() {
  # remove all characters with accents/diacritics to latin alphabet
  # shellcheck disable=SC2020
  sed 'y/àáâäæãåāǎçćčèéêëēėęěîïííīįìǐłñńôöòóœøōǒõßśšûüǔùǖǘǚǜúūÿžźżÀÁÂÄÆÃÅĀǍÇĆČÈÉÊËĒĖĘĚÎÏÍÍĪĮÌǏŁÑŃÔÖÒÓŒØŌǑÕẞŚŠÛÜǓÙǕǗǙǛÚŪŸŽŹŻ/aaaaaaaaaccceeeeeeeeiiiiiiiilnnooooooooosssuuuuuuuuuuyzzzAAAAAAAAACCCEEEEEEEEIIIIIIIILNNOOOOOOOOOSSSUUUUUUUUUUYZZZ/'
}

function Str:slugify() {
  # Str:slugify <input> <separator>
  # Str:slugify "Jack, Jill & Clémence LTD"      => jack-jill-clemence-ltd
  # Str:slugify "Jack, Jill & Clémence LTD" "_"  => jack_jill_clemence_ltd
  separator="${2:-}"
  [[ -z "$separator" ]] && separator="-"
  Str:lower "$1" |
    Str:ascii |
    awk '{
          gsub(/[\[\]@#$%^&*;,.:()<>!?\/+=_]/," ",$0);
          gsub(/^  */,"",$0);
          gsub(/  *$/,"",$0);
          gsub(/  */,"-",$0);
          gsub(/[^a-z0-9\-]/,"");
          print;
          }' |
    sed "s/-/$separator/g"
}

function Str:title() {
  # Str:title <input> <separator>
  # Str:title "Jack, Jill & Clémence LTD"     => JackJillClemenceLtd
  # Str:title "Jack, Jill & Clémence LTD" "_" => Jack_Jill_Clemence_Ltd
  separator="${2:-}"
  # shellcheck disable=SC2020
  Str:lower "$1" |
    tr 'àáâäæãåāçćčèéêëēėęîïííīįìłñńôöòóœøōõßśšûüùúūÿžźż' 'aaaaaaaaccceeeeeeeiiiiiiilnnoooooooosssuuuuuyzzz' |
    awk '{ gsub(/[\[\]@#$%^&*;,.:()<>!?\/+=_-]/," ",$0); print $0; }' |
    awk '{
          for (i=1; i<=NF; ++i) {
              $i = toupper(substr($i,1,1)) tolower(substr($i,2))
          };
          print $0;
          }' |
    sed "s/ /$separator/g" |
    cut -c1-50
}

function Str:digest() {
  local length=${1:-6}
  if [[ -n $(command -v md5sum) ]]; then
    # regular linux
    md5sum | cut -c1-"$length"
  else
    # macos
    md5 | cut -c1-"$length"
  fi
}

# Gha: function should only be run inside of a Github Action

function Gha:finish() {
  [[ -z "${RUNNER_OS:-}" ]] && IO:die "This should only run inside a Github Action, don't run it on your machine"
  local timestamp message
  git config user.name "Bashew Runner"
  git config user.email "actions@users.noreply.github.com"
  git add -A
  timestamp="$(date -u)"
  message="$timestamp < $script_basename $script_version"
  IO:print "Commit Message: $message"
  git commit -m "${message}" || exit 0
  git pull --rebase
  git push
  IO:success "Commit OK!"
}

trap "IO:die \"ERROR \$? after \$SECONDS seconds \n\
\${error_prefix} last command : '\$BASH_COMMAND' \" \
\$(< \$script_install_path awk -v lineno=\$LINENO \
'NR == lineno {print \"\${error_prefix} from line \" lineno \" : \" \$0}')" INT TERM EXIT
# cf https://askubuntu.com/questions/513932/what-is-the-bash-command-variable-good-for

Script:exit() {
  local temp_file
  for temp_file in "${temp_files[@]-}"; do
    [[ -f "$temp_file" ]] && (
      IO:debug "Delete temp file [$temp_file]"
      rm -f "$temp_file"
    )
  done
  trap - INT TERM EXIT
  IO:debug "$script_basename finished after $SECONDS seconds"
  exit 0
}

Script:check_version() {
  (
    # shellcheck disable=SC2164
    pushd "$script_install_folder" &>/dev/null
    if [[ -d .git ]]; then
      local remote
      remote="$(git remote -v | grep fetch | awk 'NR == 1 {print $2}')"
      IO:progress "Check for updates - $remote"
      git remote update &>/dev/null
      if [[ $(git rev-list --count "HEAD...HEAD@{upstream}" 2>/dev/null) -gt 0 ]]; then
        IO:print "There is a more recent update of this script - run <<$script_prefix update>> to update"
      else
        IO:progress "                                         "
      fi
    fi
    # shellcheck disable=SC2164
    popd &>/dev/null
  )
}

Script:git_pull() {
  # run in background to avoid problems with modifying a running interpreted script
  (
    sleep 1
    cd "$script_install_folder" && git pull
  ) &
}

Script:show_tips() {
  ((sourced)) && return 0
  # shellcheck disable=SC2016
  grep <"${BASH_SOURCE[0]}" -v '$0' |
    awk \
      -v green="$txtInfo" \
      -v yellow="$txtWarn" \
      -v reset="$txtReset" \
      '
      /TIP: /  {$1=""; gsub(/«/,green); gsub(/»/,reset); print "*" $0}
      /TIP:> / {$1=""; print " " yellow $0 reset}
      ' |
    awk \
      -v script_basename="$script_basename" \
      -v script_prefix="$script_prefix" \
      '{
      gsub(/\$script_basename/,script_basename);
      gsub(/\$script_prefix/,script_prefix);
      print ;
      }'
}

Script:check() {
  local name
  if [[ -n $(Option:filter flag) ]]; then
    IO:print "## ${txtInfo}boolean flags${txtReset}:"
    Option:filter flag |
      grep -v help |
      while read -r name; do
        declare -p "$name" | cut -d' ' -f3-
      done
  fi

  if [[ -n $(Option:filter option) ]]; then
    IO:print "## ${txtInfo}option defaults${txtReset}:"
    Option:filter option |
      while read -r name; do
        declare -p "$name" | cut -d' ' -f3-
      done
  fi

  if [[ -n $(Option:filter list) ]]; then
    IO:print "## ${txtInfo}list options${txtReset}:"
    Option:filter list |
      while read -r name; do
        declare -p "$name" | cut -d' ' -f3-
      done
  fi

  if [[ -n $(Option:filter param) ]]; then
    if ((piped)); then
      IO:debug "Skip parameters for .env files"
    else
      IO:print "## ${txtInfo}parameters${txtReset}:"
      Option:filter param |
        while read -r name; do
          declare -p "$name" | cut -d' ' -f3-
        done
    fi
  fi

  if [[ -n $(Option:filter choice) ]]; then
    if ((piped)); then
      IO:debug "Skip choices for .env files"
    else
      IO:print "## ${txtInfo}choice${txtReset}:"
      Option:filter choice |
        while read -r name; do
          declare -p "$name" | cut -d' ' -f3-
        done
    fi
  fi

  IO:print "## ${txtInfo}required commands${txtReset}:"
  Script:show_required
}

Option:usage() {
  IO:print "Program : ${txtInfo}$script_basename${txtReset}  by ${txtWarn}$script_author${txtReset}"
  IO:print "Version : ${txtInfo}v$script_version${txtReset} (${txtWarn}$script_modified${txtReset})"
  IO:print "Purpose : ${txtInfo}$script_description${txtReset}"
  echo -n "Usage   : $script_basename"
  Option:config |
    awk '
  BEGIN { FS="|"; OFS=" "; oneline="" ; fulltext="Flags, options and parameters:"}
  $1 ~ /flag/  {
    fulltext = fulltext sprintf("\n    -%1s|--%-12s: [flag] %s [default: off]",$2,$3,$4) ;
    oneline  = oneline " [-" $2 "]"
    }
  $1 ~ /option/  {
    fulltext = fulltext sprintf("\n    -%1s|--%-12s: [option] %s",$2,$3 " <?>",$4) ;
    if($5!=""){fulltext = fulltext "  [default: " $5 "]"; }
    oneline  = oneline " [-" $2 " <" $3 ">]"
    }
  $1 ~ /list/  {
    fulltext = fulltext sprintf("\n    -%1s|--%-12s: [list] %s (array)",$2,$3 " <?>",$4) ;
    fulltext = fulltext "  [default empty]";
    oneline  = oneline " [-" $2 " <" $3 ">]"
    }
  $1 ~ /secret/  {
    fulltext = fulltext sprintf("\n    -%1s|--%s <%s>: [secret] %s",$2,$3,"?",$4) ;
      oneline  = oneline " [-" $2 " <" $3 ">]"
    }
  $1 ~ /param/ {
    if($2 == "1"){
          fulltext = fulltext sprintf("\n    %-17s: [parameter] %s","<"$3">",$4);
          oneline  = oneline " <" $3 ">"
     }
     if($2 == "?"){
          fulltext = fulltext sprintf("\n    %-17s: [parameter] %s (optional)","<"$3">",$4);
          oneline  = oneline " <" $3 "?>"
     }
     if($2 == "n"){
          fulltext = fulltext sprintf("\n    %-17s: [parameters] %s (1 or more)","<"$3">",$4);
          oneline  = oneline " <" $3 " …>"
     }
    }
  $1 ~ /choice/ {
        fulltext = fulltext sprintf("\n    %-17s: [choice] %s","<"$3">",$4);
        if($5!=""){fulltext = fulltext "  [options: " $5 "]"; }
        oneline  = oneline " <" $3 ">"
    }
    END {print oneline; print fulltext}
  '
}

function Option:filter() {
  Option:config | grep "$1|" | cut -d'|' -f3 | sort | grep -v '^\s*$'
}

function Script:show_required() {
  grep 'Os:require' "$script_install_path" |
    grep -v -E '\(\)|grep|# Os:require' |
    awk -v install="# $install_package " '
    function ltrim(s) { sub(/^[ "\t\r\n]+/, "", s); return s }
    function rtrim(s) { sub(/[ "\t\r\n]+$/, "", s); return s }
    function trim(s) { return rtrim(ltrim(s)); }
    NF == 2 {print install trim($2); }
    NF == 3 {print install trim($3); }
    NF > 3  {$1=""; $2=""; $0=trim($0); print "# " trim($0);}
  ' |
    sort -u
}

function Option:initialize() {
  local init_command
  init_command=$(Option:config |
    grep -v "VERBOSE|" |
    awk '
    BEGIN { FS="|"; OFS=" ";}
    $1 ~ /flag/   && $5 == "" {print $3 "=0; "}
    $1 ~ /flag/   && $5 != "" {print $3 "=\"" $5 "\"; "}
    $1 ~ /option/ && $5 == "" {print $3 "=\"\"; "}
    $1 ~ /option/ && $5 != "" {print $3 "=\"" $5 "\"; "}
    $1 ~ /choice/   {print $3 "=\"\"; "}
    $1 ~ /list/     {print $3 "=(); "}
    $1 ~ /secret/   {print $3 "=\"\"; "}
    ')
  if [[ -n "$init_command" ]]; then
    eval "$init_command"
  fi
}

function Option:has_single() { Option:config | grep 'param|1|' >/dev/null; }
function Option:has_choice() { Option:config | grep 'choice|1' >/dev/null; }
function Option:has_optional() { Option:config | grep 'param|?|' >/dev/null; }
function Option:has_multi() { Option:config | grep 'param|n|' >/dev/null; }

function Option:parse() {
  if [[ $# -eq 0 ]]; then
    Option:usage >&2
    Script:exit
  fi

  ## first process all the -x --xxxx flags and options
  while true; do
    # flag <flag> is saved as $flag = 0/1
    # option <option> is saved as $option
    if [[ $# -eq 0 ]]; then
      ## all parameters processed
      break
    fi
    if [[ ! $1 == -?* ]]; then
      ## all flags/options processed
      break
    fi
    local save_option
    save_option=$(Option:config |
      awk -v opt="$1" '
        BEGIN { FS="|"; OFS=" ";}
        $1 ~ /flag/   &&  "-"$2 == opt {print $3"=1"}
        $1 ~ /flag/   && "--"$3 == opt {print $3"=1"}
        $1 ~ /option/ &&  "-"$2 == opt {print $3"=${2:-}; shift"}
        $1 ~ /option/ && "--"$3 == opt {print $3"=${2:-}; shift"}
        $1 ~ /list/ &&  "-"$2 == opt {print $3"+=(${2:-}); shift"}
        $1 ~ /list/ && "--"$3 == opt {print $3"=(${2:-}); shift"}
        $1 ~ /secret/ &&  "-"$2 == opt {print $3"=${2:-}; shift #noshow"}
        $1 ~ /secret/ && "--"$3 == opt {print $3"=${2:-}; shift #noshow"}
        ')
    if [[ -n "$save_option" ]]; then
      if echo "$save_option" | grep shift >>/dev/null; then
        local save_var
        save_var=$(echo "$save_option" | cut -d= -f1)
        IO:debug "$config_icon parameter: ${save_var}=$2"
      else
        IO:debug "$config_icon flag: $save_option"
      fi
      eval "$save_option"
    else
      IO:die "cannot interpret option [$1]"
    fi
    shift
  done

  ((help)) && (
    Option:usage
    Script:check_version
    IO:print "                                  "
    echo "### TIPS & EXAMPLES"
    Script:show_tips

  ) && Script:exit

  local option_list
  local option_count
  local choices
  local single_params
  ## then run through the given parameters
  if Option:has_choice; then
    choices=$(Option:config | awk -F"|" '
      $1 == "choice" && $2 == 1 {print $3}
      ')
    option_list=$(xargs <<<"$choices")
    option_count=$(wc <<<"$choices" -w | xargs)
    IO:debug "$config_icon Expect : $option_count choice(s): $option_list"
    [[ $# -eq 0 ]] && IO:die "need the choice(s) [$option_list]"

    local choices_list
    local valid_choice
    local param
    for param in $choices; do
      [[ $# -eq 0 ]] && IO:die "need choice [$param]"
      [[ -z "$1" ]] && IO:die "need choice [$param]"
      IO:debug "$config_icon Assign : $param=$1"
      # check if choice is in list
      choices_list=$(Option:config | awk -F"|" -v choice="$param" '$1 == "choice" && $3 = choice {print $5}')
      valid_choice=$(tr <<<"$choices_list" "," "\n" | grep "$1")
      [[ -z "$valid_choice" ]] && IO:die "choice [$1] is not valid, should be in list [$choices_list]"

      eval "$param=\"$1\""
      shift
    done
  else
    IO:debug "$config_icon No choices to process"
    choices=""
    option_count=0
  fi

  if Option:has_single; then
    single_params=$(Option:config | awk -F"|" '
      $1 == "param" && $2 == 1 {print $3}
      ')
    option_list=$(xargs <<<"$single_params")
    option_count=$(wc <<<"$single_params" -w | xargs)
    IO:debug "$config_icon Expect : $option_count single parameter(s): $option_list"
    [[ $# -eq 0 ]] && IO:die "need the parameter(s) [$option_list]"

    for param in $single_params; do
      [[ $# -eq 0 ]] && IO:die "need parameter [$param]"
      [[ -z "$1" ]] && IO:die "need parameter [$param]"
      IO:debug "$config_icon Assign : $param=$1"
      eval "$param=\"$1\""
      shift
    done
  else
    IO:debug "$config_icon No single params to process"
    single_params=""
    option_count=0
  fi

  if Option:has_optional; then
    local optional_params
    local optional_count
    optional_params=$(Option:config | grep 'param|?|' | cut -d'|' -f3)
    optional_count=$(wc <<<"$optional_params" -w | xargs)
    IO:debug "$config_icon Expect : $optional_count optional parameter(s): $(echo "$optional_params" | xargs)"

    for param in $optional_params; do
      IO:debug "$config_icon Assign : $param=${1:-}"
      eval "$param=\"${1:-}\""
      shift
    done
  else
    IO:debug "$config_icon No optional params to process"
    optional_params=""
    optional_count=0
  fi

  if Option:has_multi; then
    #IO:debug "Process: multi param"
    local multi_count
    local multi_param
    multi_count=$(Option:config | grep -c 'param|n|')
    multi_param=$(Option:config | grep 'param|n|' | cut -d'|' -f3)
    IO:debug "$config_icon Expect : $multi_count multi parameter: $multi_param"
    ((multi_count > 1)) && IO:die "cannot have >1 'multi' parameter: [$multi_param]"
    ((multi_count > 0)) && [[ $# -eq 0 ]] && IO:die "need the (multi) parameter [$multi_param]"
    # save the rest of the params in the multi param
    if [[ -n "$*" ]]; then
      IO:debug "$config_icon Assign : $multi_param=$*"
      eval "$multi_param=( $* )"
    fi
  else
    multi_count=0
    multi_param=""
    [[ $# -gt 0 ]] && IO:die "cannot interpret extra parameters"
  fi
}

function Os:require() {
  local install_instructions
  local binary
  local words
  local path_binary
  # $1 = binary that is required
  binary="$1"
  path_binary=$(command -v "$binary" 2>/dev/null)
  [[ -n "$path_binary" ]] && IO:debug "️$require_icon required [$binary] -> $path_binary" && return 0
  # $2 = how to install it
  IO:alert "$script_basename needs [$binary] but it cannot be found"
  words=$(echo "${2:-}" | wc -w)
  install_instructions="$install_package $1"
  [[ $words -eq 1 ]] && install_instructions="$install_package $2"
  [[ $words -gt 1 ]] && install_instructions="${2:-}"
  if ((FORCE)); then
    IO:announce "Installing [$1] ..."
    eval "$install_instructions"
  else
    IO:alert "1) install package  : $install_instructions"
    IO:alert "2) check path       : export PATH=\"[path of your binary]:\$PATH\""
    IO:die "Missing program/script [$binary]"
  fi
}

function Os:folder() {
  if [[ -n "$1" ]]; then
    local folder="$1"
    local max_days=${2:-365}
    if [[ ! -d "$folder" ]]; then
      IO:debug "$clean_icon Create folder : [$folder]"
      mkdir -p "$folder"
    else
      IO:debug "$clean_icon Cleanup folder: [$folder] - delete files older than $max_days day(s)"
      find "$folder" -mtime "+$max_days" -type f -exec rm {} \;
    fi
  fi
}

function Os:follow_link() {
  [[ ! -L "$1" ]] && echo "$1" && return 0 ## if it's not a symbolic link, return immediately
  local file_folder link_folder link_name symlink
  file_folder="$(dirname "$1")"                                                                                   ## check if file has absolute/relative/no path
  [[ "$file_folder" != /* ]] && file_folder="$(cd -P "$file_folder" &>/dev/null && pwd)"                          ## a relative path was given, resolve it
  symlink=$(readlink "$1")                                                                                        ## follow the link
  link_folder=$(dirname "$symlink")                                                                               ## check if link has absolute/relative/no path
  [[ -z "$link_folder" ]] && link_folder="$file_folder"                                                           ## if no link path, stay in same folder
  [[ "$link_folder" == \.* ]] && link_folder="$(cd -P "$file_folder" && cd -P "$link_folder" &>/dev/null && pwd)" ## a relative link path was given, resolve it
  link_name=$(basename "$symlink")
  IO:debug "$info_icon Symbolic ln: $1 -> [$link_folder/$link_name]"
  Os:follow_link "$link_folder/$link_name" ## recurse
}

function Os:notify() {
  # cf https://levelup.gitconnected.com/5-modern-bash-scripting-techniques-that-only-a-few-programmers-know-4abb58ddadad
  local message="$1"
  local source="${2:-$script_basename}"

  [[ -n $(command -v notify-send) ]] && notify-send "$source" "$message"                                      # for Linux
  [[ -n $(command -v osascript) ]] && osascript -e "display notification \"$message\" with title \"$source\"" # for MacOS
}

function Os:busy() {
  # show spinner as long as process $pid is running
  local pid="$1"
  local message="${2:-}"
  local frames=("|" "/" "-" "\\")
  (
    while kill -0 "$pid" &>/dev/null; do
      for frame in "${frames[@]}"; do
        printf "\r[ $frame ] %s..." "$message"
        sleep 0.5
      done
    done
    printf "\n"
  )
}

function Os:beep() {
  if [[ -n "$TERM" ]]; then
    tput bel
  fi
}

function Script:meta() {

  script_prefix=$(basename "${BASH_SOURCE[0]}" .sh)
  script_basename=$(basename "${BASH_SOURCE[0]}")
  execution_day=$(date "+%Y-%m-%d")

  script_install_path="${BASH_SOURCE[0]}"
  IO:debug "$info_icon Script path: $script_install_path"
  script_install_path=$(Os:follow_link "$script_install_path")
  IO:debug "$info_icon Linked path: $script_install_path"
  script_install_folder="$(cd -P "$(dirname "$script_install_path")" && pwd)"
  IO:debug "$info_icon In folder  : $script_install_folder"
  if [[ -f "$script_install_path" ]]; then
    script_hash=$(Str:digest <"$script_install_path" 8)
    script_lines=$(awk <"$script_install_path" 'END {print NR}')
  fi

  # get shell/operating system/versions
  shell_brand="sh"
  shell_version="?"
  [[ -n "${ZSH_VERSION:-}" ]] && shell_brand="zsh" && shell_version="$ZSH_VERSION"
  [[ -n "${BASH_VERSION:-}" ]] && shell_brand="bash" && shell_version="$BASH_VERSION"
  [[ -n "${FISH_VERSION:-}" ]] && shell_brand="fish" && shell_version="$FISH_VERSION"
  [[ -n "${KSH_VERSION:-}" ]] && shell_brand="ksh" && shell_version="$KSH_VERSION"
  IO:debug "$info_icon Shell type : $shell_brand - version $shell_version"
  if [[ "$shell_brand" == "bash" && "${BASH_VERSINFO:-0}" -lt 4 ]]; then
    IO:die "Bash version 4 or higher is required - current version = ${BASH_VERSINFO:-0}"
  fi

  os_kernel=$(uname -s)
  os_version=$(uname -r)
  os_machine=$(uname -m)
  install_package=""
  case "$os_kernel" in
  CYGWIN* | MSYS* | MINGW*)
    os_name="Windows"
    ;;
  Darwin)
    os_name=$(sw_vers -productName)       # macOS
    os_version=$(sw_vers -productVersion) # 11.1
    install_package="brew install"
    ;;
  Linux | GNU*)
    if [[ $(command -v lsb_release) ]]; then
      # 'normal' Linux distributions
      os_name=$(lsb_release -i | awk -F: '{$1=""; gsub(/^[\s\t]+/,"",$2); gsub(/[\s\t]+$/,"",$2); print $2}')    # Ubuntu/Raspbian
      os_version=$(lsb_release -r | awk -F: '{$1=""; gsub(/^[\s\t]+/,"",$2); gsub(/[\s\t]+$/,"",$2); print $2}') # 20.04
    else
      # Synology, QNAP,
      os_name="Linux"
    fi
    [[ -x /bin/apt-cyg ]] && install_package="apt-cyg install"     # Cygwin
    [[ -x /bin/dpkg ]] && install_package="dpkg -i"                # Synology
    [[ -x /opt/bin/ipkg ]] && install_package="ipkg install"       # Synology
    [[ -x /usr/sbin/pkg ]] && install_package="pkg install"        # BSD
    [[ -x /usr/bin/pacman ]] && install_package="pacman -S"        # Arch Linux
    [[ -x /usr/bin/zypper ]] && install_package="zypper install"   # Suse Linux
    [[ -x /usr/bin/emerge ]] && install_package="emerge"           # Gentoo
    [[ -x /usr/bin/yum ]] && install_package="yum install"         # RedHat RHEL/CentOS/Fedora
    [[ -x /usr/bin/apk ]] && install_package="apk add"             # Alpine
    [[ -x /usr/bin/apt-get ]] && install_package="apt-get install" # Debian
    [[ -x /usr/bin/apt ]] && install_package="apt install"         # Ubuntu
    ;;

  esac
  IO:debug "$info_icon System OS  : $os_name ($os_kernel) $os_version on $os_machine"
  IO:debug "$info_icon Package mgt: $install_package"

  # get last modified date of this script
  script_modified="??"
  [[ "$os_kernel" == "Linux" ]] && script_modified=$(stat -c %y "$script_install_path" 2>/dev/null | cut -c1-16) # generic linux
  [[ "$os_kernel" == "Darwin" ]] && script_modified=$(stat -f "%Sm" "$script_install_path" 2>/dev/null)          # for MacOS

  IO:debug "$info_icon Version  : $script_version"
  IO:debug "$info_icon Created  : $script_created"
  IO:debug "$info_icon Modified : $script_modified"

  IO:debug "$info_icon Lines    : $script_lines lines / md5: $script_hash"
  IO:debug "$info_icon User     : $USER@$HOSTNAME"

  # if run inside a git repo, detect for which remote repo it is
  if git status &>/dev/null; then
    git_repo_remote=$(git remote -v | awk '/(fetch)/ {print $2}')
    IO:debug "$info_icon git remote : $git_repo_remote"
    git_repo_root=$(git rev-parse --show-toplevel)
    IO:debug "$info_icon git folder : $git_repo_root"
  fi

  # get script version from VERSION.md file - which is automatically updated by pforret/setver
  [[ -f "$script_install_folder/VERSION.md" ]] && script_version=$(cat "$script_install_folder/VERSION.md")
  # get script version from git tag file - which is automatically updated by pforret/setver
  [[ -n "$git_repo_root" ]] && [[ -n "$(git tag &>/dev/null)" ]] && script_version=$(git tag --sort=version:refname | tail -1)
}

function Script:initialize() {
  log_file=""
  if [[ -n "${TMP_DIR:-}" ]]; then
    # clean up TMP folder after 1 day
    Os:folder "$TMP_DIR" 1
  fi
  if [[ -n "${LOG_DIR:-}" ]]; then
    # clean up LOG folder after 1 month
    Os:folder "$LOG_DIR" 30
    log_file="$LOG_DIR/$script_prefix.$execution_day.log"
    IO:debug "$config_icon log_file: $log_file"
  fi
}

function Os:tempfile() {
  local extension=${1:-txt}
  local file="${TMP_DIR:-/tmp}/$execution_day.$RANDOM.$extension"
  IO:debug "$config_icon tmp_file: $file"
  temp_files+=("$file")
  echo "$file"
}

function Os:import_env() {
  local env_files
  if [[ $(pwd) == "$script_install_folder" ]]; then
    env_files=(
      "$script_install_folder/.env"
      "$script_install_folder/.$script_prefix.env"
      "$script_install_folder/$script_prefix.env"
    )
  else
    env_files=(
      "$script_install_folder/.env"
      "$script_install_folder/.$script_prefix.env"
      "$script_install_folder/$script_prefix.env"
      "./.env"
      "./.$script_prefix.env"
      "./$script_prefix.env"
    )
  fi

  local env_file
  for env_file in "${env_files[@]}"; do
    if [[ -f "$env_file" ]]; then
      IO:debug "$config_icon Read  dotenv: [$env_file]"
      local clean_file
      clean_file=$(Os:clean_env "$env_file")
      # shellcheck disable=SC1090
      source "$clean_file" && rm "$clean_file"
    fi
  done
}

function Os:clean_env() {
  local input="$1"
  local output="$1.__.sh"
  [[ ! -f "$input" ]] && IO:die "Input file [$input] does not exist"
  IO:debug "$clean_icon Clean dotenv: [$output]"
  awk <"$input" '
      function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
      function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
      function trim(s) { return rtrim(ltrim(s)); }
      /=/ { # skip lines with no equation
        $0=trim($0);
        if(substr($0,1,1) != "#"){ # skip comments
          equal=index($0, "=");
          key=trim(substr($0,1,equal-1));
          val=trim(substr($0,equal+1));
          if(match(val,/^".*"$/) || match(val,/^\047.*\047$/)){
            print key "=" val
          } else {
            print key "=\"" val "\""
          }
        }
      }
  ' >"$output"
  echo "$output"
}

IO:initialize # output settings
Script:meta   # find installation folder

[[ $run_as_root == 1 ]] && [[ $UID -ne 0 ]] && IO:die "user is $USER, MUST be root to run [$script_basename]"
[[ $run_as_root == -1 ]] && [[ $UID -eq 0 ]] && IO:die "user is $USER, CANNOT be root to run [$script_basename]"

Option:initialize # set default values for flags & options
Os:import_env     # overwrite with .env if any

if [[ $sourced -eq 0 ]]; then
  Option:parse "$@" # overwrite with specified options if any
  Script:initialize # clean up folders
  Script:main       # run Script:main program
  Script:exit       # exit and clean up
else
  # just disable the trap, don't execute Script:main
  trap - INT TERM EXIT
fi
