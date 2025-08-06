# Project vision

clode.sh is a bash CLI tool, that helps developers using Claude Code.

## Best Practices

### `clode prep`

prepares the current project for AI software development assistants like Claude Code. It sets up the necessary files, folders (CLAUDE.md, planning.md, .claude/ folder) and configurations to ensure the AI can effectively assist with coding tasks.

It asks questions to gather information about the project, such as its architecture, technology stack, and specific requirements. This information is then used to generate a comprehensive "Product Requirements Prompt" (PRP) that guides the AI in understanding the project context and goals.

## Git Checkpoints

This implements the git workflow described in @docs/procedure_v1.md

### `clode branch` |`clode b`

creates a new git branch for the current task. This helps in organizing work and keeping changes isolated until they are ready to be merged. The intermediate commits are 'children' of this branch, and will all be squashed into a single commit when the branch is merged into the main branch.

### `clode inter`|`clode i`

creates an intermediate git commit with the current state of the project. This is useful for saving progress before making significant changes or starting a new feature. 

the commit message is either specified as `clode i "commit message"` or generated automatically based on the files that have changed since the last commit. 

The commit message always starts with '`feat:`', '`fix:`' or '`docs:`'. This is specified as a command-line option (`--commit fix|docs|feat|break`), or defaults to 'fix' if not specified. [inspired by Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)

The commit message always ends with the string `#intermediate #step:[09] #date:[YYYY-MM-DD]`, which indicates that 
* this commit is an intermediate step in the development process.
* there is a sequential step number (e.g., [09]) that can be used to track the order of commits since the branch was created.
* the date of the commit is included for reference.

An example of an intermediate commit message might be: 

### `clode rollback`|`clode r`

rolls back the last intermediate commit, a specific earlier commit (`clode r --commit 123abc`, or the start of the branch (`clode r --branch`, allowing developers to revert to a previous state if needed. 

### `clode final`|`clode f`

squashes all intermediate commits into a single commit and pushes the branch to the remote repository. This is typically done when the feature or task is complete and ready for review or merging into the main branch.
