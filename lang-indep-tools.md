# Language Independent Tooling

## EditorConfig

[EditorConfig](https://editorconfig.org/) is a coding style describing file format, it's not a "tool" because it doesn't do anything itself, but many editors (most of the commonly used ones certainly) will parse the `.editorconfig` file and configure the editor accordingly.

Some of the standard code-style considerations and issues that crop up often are covered here, things like: line endings, file endings, charsets, indenting and spaces, etc.

These can be set for different set of files by glob with the notable use of selecting files by extension, i.e. different rules for different languages.

The [core property set](https://github.com/editorconfig/editorconfig/wiki/EditorConfig-Properties#current-universal-properties) is pretty darn solid and there are a number of considered [domain-specific properties](https://github.com/editorconfig/editorconfig/wiki/EditorConfig-Properties#ideas-for-domain-specific-properties). These latter "extra" properties would be up to the editor to implement, this does mean that them being respected across multiple contributors can't be fully relied upon so maybe better to stick to the core here.

A simple, example `.editorconfig` [is provided](./.editorconfig).

## Pre-commit

[Pre-commit](https://pre-commit.com/) is a tool which, as the name implies, installs and manages [pre-commit hooks](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks).

These hooks are configured per directory and reference: repositories that contain a `.pre-commit-hooks.yaml` containing the specification for the hooks offered by the repository; local scripts and binaries; docker containers; things like that.

**Security consideration**: You are essentially inviting other people's code to run on your computer, this is no different to using any piece of software you didn't write but version pinning and using only those hooks from trusted sources is a must - local is ideal.

A good list of support hooks for various languages can be found [here](https://pre-commit.com/hooks.html).

This repo has some Groovy, some Markdown, and some Yaml (configuring pre-commit itself). [`./.pre-commit-config.yaml`](./.pre-commit-config.yaml) has some hooks for each of these.
