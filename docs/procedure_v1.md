# Using git as an intermediate checkpoint system with Claude Code

> I have created [github.com/pforret/clode](https://github.com/pforret/clode) to facilitate this workflow, which is a simple wrapper around the `git` command to make it easier to use with Claude Code.

```bash
clode branch [new_branch]        # create a new branch for your big update
clode intermediate               # every time you reach a stable point
clode rollback                   # if the changes after the last commit are not needed
clode push                       # squash all intermediate commits into 1 big commit
```

You can effectively use Git's features to create "checkpoints" during a large software update and then consolidate them into a single pull request (PR) when finished. Here's a strategy:

### 1\. **Start with a Dedicated Feature Branch**

Before you begin the update, create a new branch for your work. This keeps your main development line clean.

```bash
git checkout main # Or whatever your main branch is called
git pull # Ensure your main branch is up to date
git checkout -b big-software-update
```

### 2\. **Create Checkpoints with Commits**

As you reach stable points or "checkpoints" in your update process, make regular commits. Each commit should represent a coherent, tested, and working state of your application. Think of these as your "save points."

```bash
# Make some changes...
git add .
git commit -m "feat: Implemented user authentication module (Checkpoint 1)"

# Make more changes...
git add .
git commit -m "fix: Fixed database connection issues (Checkpoint 2)"

# Continue this process for all crucial stages of your update.
```

### 3\. **Reverting to a Previous Checkpoint**

If you encounter issues and need to revert to a previous stable state, you can use `git reset --hard`.

First, identify the commit hash or a recognizable part of the commit message of the checkpoint you want to go back to. You can use `git log` to see your commit history:

```bash
git log --oneline
```

Once you have the commit hash (e.g., `abcdef1`), you can reset:

```bash
git reset --hard abcdef1
```

**Important:** `git reset --hard` will discard all uncommitted changes and move your branch pointer to the specified commit, effectively erasing all subsequent commits from your local history. Use with caution. If you only want to discard local changes and not the commits, use `git restore .` or `git restore <file>`.

### 4\. **When Everything is Done and Tested: Squashing Commits**

Once your big software update is complete and thoroughly tested, you'll want to consolidate these temporary checkpoint commits into a single, clean commit for your pull request. This is achieved using interactive rebase.

Let's say you have 5 checkpoint commits you want to squash into one. You need to rebase starting from the commit *before* your first checkpoint commit.

First, identify the commit hash of the commit *before* your first checkpoint. You can use `git log` for this. For example, if you have:

```
...
abcde12 (HEAD -> big-software-update) fix: Final adjustments
fghij34 feat: Implemented user authentication module (Checkpoint 3)
klmno56 fix: Fixed database connection issues (Checkpoint 2)
pqrst78 feat: Implemented user authentication module (Checkpoint 1)
uvwxy90 Initial setup for big update (This is the commit BEFORE your checkpoints)
```

You would start the interactive rebase from `uvwxy90`:

```bash
git rebase -i uvwxy90
```

This will open your default text editor with a list of your commits:

```
pick pqrst78 feat: Implemented user authentication module (Checkpoint 1)
pick klmno56 fix: Fixed database connection issues (Checkpoint 2)
pick fghij34 feat: Implemented user authentication module (Checkpoint 3)
pick abcde12 fix: Final adjustments

# Rebase uvwxy90..abcde12 onto uvwxy90 (4 commands)
#
# Commands:
# p, pick <commit> = use commit
# r, reword <commit> = use commit, but edit the commit message
# e, edit <commit> = use commit, but stop for amending
# s, squash <commit> = use commit, but meld into previous commit
# f, fixup <commit> = like "squash", but discard this commit's log message
# x, exec <command> = run command (the rest of the line) for each commit
# b, break = stop here (continue rebase with 'git rebase --continue')
# d, drop <commit> = remove commit
# l, label <label> = label current HEAD with a name
# t, reset <label> = reset HEAD to a label
# m, merge [-C <commit> | -c <commit>] <label> [# <oneline>]
# .       create a merge commit
#
# These lines can be re-ordered; they are executed from top to bottom.
#
# If you remove a line here THAT COMMIT WILL BE LOST.
#
# However, if you remove everything, the rebase will be aborted.
#
# Note that empty commits are commented out
```

To squash them, you'll keep the first commit as `pick` and change the subsequent commits to `squash` (or `s`).

```
pick pqrst78 feat: Implemented user authentication module (Checkpoint 1)
s klmno56 fix: Fixed database connection issues (Checkpoint 2)
s fghij34 feat: Implemented user authentication module (Checkpoint 3)
s abcde12 fix: Final adjustments
```

Save and close the file. Git will then open another editor window, allowing you to combine and edit the commit messages for your new single commit. You can delete the individual messages and write a comprehensive one for your entire update.

```
# This is a combination of 4 commits.
# The first commit's message is:
feat: Implemented user authentication module (Checkpoint 1)

# This is the 2nd commit message:
fix: Fixed database connection issues (Checkpoint 2)

# This is the 3rd commit message:
feat: Implemented user authentication module (Checkpoint 3)

# This is the 4th commit message:
fix: Final adjustments

# Please enter the commit message for your changes. Lines starting
# with '#' will be ignored, and an empty message aborts the commit.
#
# ... (Git rebase output)
```

Change this to something like:

```
feat: Comprehensive big software update

This update includes:
- Implementation of the new user authentication module.
- Fixes for various database connection issues.
- Integration of new reporting features.
- Performance optimizations across several core components.
```

Save and close the file. You will now have a single, clean commit representing your entire update on your `big-software-update` branch.

### 5\. **Create a Pull Request (PR)**

Now that your `big-software-update` branch has a single, well-described commit, you can push it to your remote repository (if you haven't already) and create a pull request.

```bash
git push origin big-software-update -f # Use -f if you squashed commits already pushed
```

**Important Note on `git push -f` (force push):** If you had already pushed your individual checkpoint commits to the remote branch *before* squashing, you will need to use `git push origin big-software-update -f`. **Be very careful with force pushes**, as they rewrite history and can cause problems for others who have pulled your old history. In a personal branch dedicated to an update, it's generally safe, but always be aware of the implications. If you haven't pushed the checkpoints yet, a regular `git push` will suffice.

This workflow provides you with the safety net of checkpoints while maintaining a clean, consolidated history for your main branch.
