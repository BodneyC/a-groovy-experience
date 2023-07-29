# Groovy-specific Tooling

There are four options we have to choose from:

1. Using a [Jenkins instances](https://www.jenkins.io/doc/book/pipeline/development/) to review declarative pipeline syntax
2. Using [Groovy Language Server](https://github.com/GroovyLanguageServer/groovy-language-server)
3. Using [NPM Groovy Lint](https://www.npmjs.com/package/npm-groovy-lint#other) to check Groovy syntax and style
4. Using [the Groovy compiler](https://groovy-lang.org/groovyc.html) locally...

## Comparison of Tools

There's two sides of this for me, two hopeful outcomes with these docs as a starting point, one is speeding up the process of development and the other is improving Groovy code-quality (almost oxymoronic, I know).

The first side is that of syntax errors, too much iteration time is spent chasing errors that should be caught in the editor.

The other side is quality checking, even down to simple aspects of style, using the right number of spaces for indenting, missing line breaks which I assume are copy-paste errors, large dead/unreachable/commented out blocks, etc.

I know tools like [Editorconfig](https://editorconfig.org/) can cover a lot and provide uniformity but this doc focuses on Groovy-specific tools and style.

### Jenkins Pipeline Validator

Related files in [`./local-jenkins/`](./local-jenkins/).

This is an interaction between a client and a running Jenkins instance, so immediately we have the first issue - if every dev is constantly calling a live Jenkins instance that's a fair amount of traffic, luckily, for what value the tool brings, we can just spin up a local one.

A local version of Jenkins can be ran on port 8090 (assuming you have Docker installed) with [`run.sh`](./local-jenkins/run.sh).

You can call the pipeline validator with [`call-linter.sh`](./local-jenkins/call-linter.sh) optionally providing a specific Jenkinsfile to run.

#### What it Covers

The structure of your **declarative** Jenkins pipelines, it would seem specifically the JSON-schema found in [`schema.json`](./local-jenkins/schema.json) from a quick analysis.

If there is a Groovy syntax error such that it is unable to check the structure, it is able to tell you where that error is (well, that is to say that it runs `groovyc` over the file). A good example can be found in [`syntax-error.groovy`](./example-pipelines/syntax-error.groovy) where a brace is missing (more on this in [Thoughts](#thoughts-on-the-validator)).

#### What it Does Not Cover

This is a little more vast.

***I should note*** that this is not this is not surprising, this functionality is provided by a [pipeline model plugin](https://github.com/jenkinsci/pipeline-model-definition-plugin/) and not a language linter, all it cares about is the "model" of your "pipeline"... it's in the name - but it's sold by Jenkins themselves as a "linter" which, though a general term and can be applied to very specific tools, indicates something other than this tool provides to me.

First off, anything aside from a declarative pipeline will throw an error, likely "`pipeline` block not found". This includes Groovy library files, pipeline-DSL job scripts, anything that is not a declarative pipeline.

It doesn't care about style, indenting, and the like.

It doesn't care about logic or semantics.

<!-- markdownlint-disable-next-line MD033 -->
<div id="thoughts-on-the-validator"></div>

#### Thoughts

Again, it just checks the model of one type of Jenkins pipeline which is only one use of the Groovy language - not enough for my purposes.

When serious syntax errors are provided then the validator can reporting down to the line, however the interface of use would be that your syntax is a-okay if the tool reports that `pipeline` is missing...

Realistically, this would be no better that just attempting to compile the file locally with `groovyc` which is likely what the plugin does anyway.

### Groovy Language Server

This is a fairly limited and fairly finickity language server based on Microsoft's [LSP](https://learn.microsoft.com/en-us/visualstudio/extensibility/language-server-protocol?view=vs-2022) standard. Most modern editors have support for configuring, running, and interacting with these servers.

#### What it Covers

Some features of what is often referred to as "intellisense", this includes code completion based on known and relevant symbols, type and signature information, finding references to a symbol, etc. A good amount of trial and error has shown *some* of this working *some* of the time. Also processes not dying when they should, consuming resources, things of this nature.

Clearly to provide these features, the code has to be valid Groovy, so it (like all these tools) will have to successfully compile, meaning that Groovy syntax errors are inherently caught.

#### What it Does Not Cover

Jenkins-related things. This does have some not-so-significant impacts.

This tool, as has been mentioned, is for any and all uses of the Groovy language, i.e. not specific to Groovy as it is used in Jenkins. One prime example of this is the `Library` annotation used to load shared libraries. Groovy does not define a `Library` annotation, Jenkins' magic defines it - this means that lines using this (e.g. in [`with-lib.groovy`](./example-pipelines/with-lib.groovy)) will always show as a fault.

Perhaps there's a way to let GroovyLS know about pre-imported tokens but this information is not readily available online. And, it's not only the fact that the annotation exists, it would need to know how that annotation worked, where it loads the libraries from (probably in one of the Jenkins JARs), but *even then* we'd need to configure GroovyLS to be able to find those mentioned libraries if you wish to get intellisense around items in those libraries...

#### Thoughts

For immediate, editor-level feedback, this is the way to go - ignoring the fancier intellisense features and even considering the flakiness I've experienced with them, I would still rather have this running in the background than running `npm-groovy-lint` on every save, this is purely due to speed.

That being said, it's still not ideal for reasons already mentioned.

*Just as a note*: Another thing to **be aware of** with this is that it's project-wise, so *all* syntax errors require fixing in a directory if you wish to work with any file - if one file has a syntax error, you'll receive little to no information about the other files (something akin to [this issue](https://github.com/GroovyLanguageServer/groovy-language-server/issues/54)).

### NPM Groovy Lint

This is a configurable command-line linter based on [CodeNarc](https://codenarc.org/).

It's [pre-containerized](https://hub.docker.com/r/nvuillam/npm-groovy-lint/) for each of use and comes with considerations for other tools like defining [pre-commit](https://pre-commit.com/) [hooks](https://hub.docker.com/r/nvuillam/npm-groovy-lint/) (though, these aren't ideal, see [`.pre-commit-config.yaml`](./.pre-commit-config.yaml) for a note on this.

#### What it Covers

It check all the [CodeNarc rules](https://codenarc.org/codenarc-rule-index.html)... which are pretty comprehensive.

It even has considerations for Jenkins (in the form of [recommended Jenkins rules](https://github.com/nvuillam/npm-groovy-lint/blob/master/lib/.groovylintrc-recommended-jenkinsfile.json)) despite, like with GroovyLS, being designed for any and all thing Groovy.

It can also attempt to fix issues found, saving us time and it can even format the code based on the (default or user-provided) formatting configuration file - bonus points.

#### What it Does Not Cover

Logic. But, it's not supposed to, it's a linter. It's not going to tell me that I missed an argument from a function call but I wouldn't expect it to.

#### Thoughts

One big thought I've only mentioned in another section: damn is it slow. I thought it was just because I was using the Dockerized version and I had some limit or something... but no, it's just slow. As a pre-commit thing or something happening in CI (which I think is the point of this one), this would be a-okay but for editor support, i.e. run-on-save or even with live changes, this isn't practical.

There is also the possible future problem that, though frequently updated there is [an issue](https://github.com/nvuillam/npm-groovy-lint/issues/158) requesting maintainers.

Another potential issue (which *I have not looked into* so I may be wrong here) is architecture if running "raw" - I quickly installed and ran this on an M1 Macbook I have and got some `arm`-ish issue - maybe that `arch -x86_64 $prog` trick'd work?

### GroovyC

One obvious answer is for us to just use the Groovy compiler (`groovyc`) locally, it doesn't give us the style aspect but in terms of the iteration lifecycle I mentioned at the top of this, git-ignoring `*.class` and just running `groovyc $file` would save some time.

## Conclusions

Why lord, why? I hate Groovy, what have I done to have this trash back in my life? I thought my days of configuring Java crap with 100 character options and endless XML was over, I thought my days of longing for such a well established and widely used language/tool to have even the simplest quality of life considerations for its devs was done, yet here we are again, why did this happen, what did I do?

They're all problematic for different reasons, there is little editor support and what exists isn't particularly suitable because of the Jenkins magic that is assumed in the scripts.

The best choice for us is a combination of two accepting and working around their downsides:

1. Groovy Language Server set up in editors for syntax and sanity checks - ignoring Jenkins-related issues and messing with classpaths if libraries are used...
2. NPM Groovy Lint set up in something like [pre-commit](https://pre-commit.com/), [custom hooks](https://github.com/nvuillam/npm-groovy-lint/blob/master/.pre-commit-hooks.yaml) are already defined by the maintainers of `npm-groovy-lint`

## Next Steps

Guides for installing GroovyLS and setting it up in a number of editors.

Well thought out and documented [configuration files](https://github.com/nvuillam/npm-groovy-lint/tree/master#configuration) - a very simple on can be found in [`.groovylintrc.json`](./npm-package/.groovylintrc.json) and note that using `-o json` is the only way I can find to get the rulename and it doesn't even give you the full thing... I'm sure I'm missing a trick here though.
