<!-- TOC -->

- [Contributing](#contributing)
  - [Requirements](#requirements)
- [How to](#how-to)

<!-- TOC -->

# Contributing

## Requirements

* Install the following packages: ``git`` and a text editor of your choice. By default, the use of [VSCode](https://code.visualstudio.com) is recommended.

* VSCode (https://code.visualstudio.com), combined with the following plugins, helps the editing/review process, mainly allowing the preview of the content before the commit, analyzing the Markdown syntax and generating the automatic summary, as the section titles are created/changed.

    * Markdown-lint: https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint
    * Markdown-toc: https://marketplace.visualstudio.com/items?itemName=AlanWalk.markdown-toc
    * Markdown-all-in-one: https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one

* Configure authentication on your Github account to use the SSH protocol instead of HTTP. Watch this tutorial to learn how to set up: https://help.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account

# How to

When someone wants to contribute to improvements in this repository, the following steps must be performed.

* Clone the repository to your computer, with the following command:

```bash
git clone git@github.com:Sensedia/open-tools.git
```

* Create a branch using the following command:

```bash
git checkout -b BRANCH_NAME
```

* Make sure it is the correct branch, using the following command:

```bash
git branch
```

* The branch with an '*' before the name will be used.
* Make the necessary changes.
* Test your changes.
* Commit your changes to the newly created branch.
* Submit the commits to the remote repository with the following command:

```bash
git push --set-upstream origin BRANCH_NAME
```

* Create a Pull Request (PR) for the `master` branch of the repository. Watch this [tutorial](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork).
* Update the content with the reviewers suggestions (if necessary).
* After your PR has been approved and merged, update the changes in your local repository with the following commands:

```bash
git checkout master
git pull upstream master
```

* Remove the local branch after approval and merge from your PR, using the following command:

```bash
git branch -d BRANCH_NAME
```

Reference:

* https://blog.scottlowe.org/2015/01/27/using-fork-branch-git-workflow/