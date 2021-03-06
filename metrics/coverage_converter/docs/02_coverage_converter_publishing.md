# Coverage Converter publishing

> Summary of the proposed change

An explanation of the Coverage Converter tool publishing approach.

# References

> Link to supporting documentation, GitHub tickets, etc.

- [GitHub releases](https://docs.github.com/en/free-pro-team@latest/github/administering-a-repository/managing-releases-in-a-repository)
- [PPA](https://help.ubuntu.com/stable/ubuntu-help/addremove-ppa.html.en)
- [Homebrew](https://docs.brew.sh/Taps)
- [Chocolatey](https://chocolatey.org/docs/create-packages)
- [Dart packages](https://dart.dev/guides/libraries/create-library-packages)

# Motivation

> What problem is this project solving?

Once we have a Coverage Converter tool ready, we want to make it available and easy-to-install for users. Thus, we should choose the place where we'll deploy this CLI. Also, we should explain the way of using the Coverage Converter tool.

# Goals

> Identify success metrics and measurable goals.

- Choose the place where to publish the Coverage Converter tool.
- Explain the usage of the Coverage Converter tool.

# Non-Goals

> Identify what's not in scope.

This document does not include information about configuring building jobs for the Coverage Converter tool.

# Design

> Explain and diagram the technical design

`Coverage Converter` -> `Build using GitHub Actions` -> `GitHub Releases publishing`

> Identify risks and edge cases

# API

> What will the proposed API look like?

# Coverage Converter publishing

There are a couple of places we can publish the Coverage Converter: 

- GitHub Releases.
- Ubuntu Personal Package Archive (PPA), Homebrew, and Chocolatey.
- pub.dev publishing.


Since we are using GitHub Actions for building our projects, GitHub Releases seems to be the most convenient way of publishing. Let's take a closer look at the GitHub Releases: 

## GitHub Releases

GitHub provides an easy way of publishing the applications - GitHub Releases. It allows you to create a GitHub release and publish any files you want there. So, to publish a Coverage Converter CLI, we'll need to follow the next steps: 

1. Build the Coverage Converter tool.
2. Create a new release.
3. Add executables to created release.

Moreover, GitHub Actions has ready-to-use actions that simplify the process of publishing: 

- [Create a release action](https://github.com/marketplace/actions/create-a-release) - an action that helps to create a new release.
- [Upload a release asset action](https://github.com/marketplace/actions/upload-a-release-asset) - an action that helps to add assets to the existing release.

### Pros & Cons

Pros: 
- Easy to configure.
- Great integration with GitHub Actions.
- It does not require any configuration files to publish.
- Can publish any file type, so downloading the CLI user gets the ready-to-use application.

Cons: 
- More complex configuration for monorepo (could be solved with tags, etc..)
- Downloading to CI action becomes a bit more complex compared to the [alternatives](#Personal-Package-Archive-(PPA)-Homebrew-and-Chocolatey); see more [here](#Downloading-using-the-command-line-commands)

So, the GitHub Releases is the best choice in our case because it allows us easily configure the publishing and allows users to easily download and start using the Coverage Converter tool. 

### Publishing details

Once we've chosen the [GitHub Releases](#GitHub-Releases), let's consider the deployment process in more detail. To publish the application to the GitHub releases, we should create a tag that will correspond to the release. Since we want to keep the release history and we'll have more than one project on our repository, we should create a tag that will contain the version number and the name of the project - `v1.0-coverage-converter`.

For every time that we change coverage converter tool sources, we use a `coverage-converter-snapshot` tag that will be re-assigned after each build to the newly published binary. It should be marked as `pre-release`. There should be only 1 release at a time with `coverage-converter-snapshot` tag.

# Coverage Converter usage

First of all, you should download the Coverage Converter tool. There are a couple of ways to do that:

- Download using the GitHub GUI.
- Download using the command line commands.

Let's consider each of them separately: 

## Downloading using the GitHub GUI

To download the Coverage Converter tool from the GitHub releases, follow the next steps: 

1. Go to the Flank/flank-dashboard GitHub repository [releases page](https://github.com/Flank/flank-dashboard/releases). 
2. Find the version of the Coverage Converter tool you want to download.
3. Open the `Assets` collapsible section and choose the Coverage Converter file compatible with your OS.
4. Click to download.

## Downloading the latest snapshot release

To download the latest snapshot release, you should use the following links: 

 - [macOS download](https://github.com/Flank/flank-dashboard/releases/download/coverage-converter-snapshot/coverage_converter_macos)
 - [Linux download](https://github.com/Flank/flank-dashboard/releases/download/coverage-converter-snapshot/coverage_converter_linux)
 - [Windows download](https://github.com/Flank/flank-dashboard/releases/download/coverage-converter-snapshot/coverage_converter_windows) 

## Downloading using the command line commands

If you want to download the Coverage Converter tool you should follow the steps below: 

1. Open the GitHub repository releases and find the release you want to download, as described in the [Downloading using the GitHub GUI](#Downloading-using-the-GitHub-GUI) section.
2. Find the executable file compatible with your OS.
3. Right-click on this file and copy the link address. 

After these steps, you should obtain the download link similar to this one: 

`https://github.com/Flank/flank-dashboard/releases/download/v1.0.0-coverage-converter/coverage_converter_macos`

## Using the Coverage Converter tool

Once you've obtained the download link, you can download the Coverage Converter tool using the CLI tools. Let's consider the macOS command to download the Coverage Converter tool:

`curl -o <output> -k <url>`

Where the `<output>` is the file path where you want to download the coverage converter, and the `<url>` is the download URL obtained previously. Let's consider the example download command: 

`curl -o coverage_converter_macos -k https://github.com/Flank/flank-dashboard/releases/download/v1.0.0-coverage-converter/coverage_converter_macos`

So, when you've got the Coverage Converter executable, you probably, want to convert coverage to be readable by the CI integrations tool. To run the conversion process, you should have the coverage report in one of the supported formats: 

- `LCOV`
- `Istanbul`

Let's consider the command for converting the `LCOV` format for macOS: 

`./coverage_converter_macos lcov -i <YOUR_COVERAGE_REPORT_FILE> -o <COVERAGE_REPORT_OUTPUT_FILE.json>`

As you can see, the Coverage Converter CLI contains a separate command for each supported coverage format. So, to convert the `Istanbul` coverage report, you should replace the `lcov` command with `istanbul` and so on. See [Coverage Converter design](https://github.com/Flank/flank-dashboard/blob/master/metrics/coverage_converter/docs/01_coverage_converter_design.md#cli-design) document for a detailed description of the CLI arguments.

After the conversion process is finished, the command will create a `COVERAGE_REPORT_OUTPUT_FILE.json` file with the coverage report JSON readable by the CI integrations tool.

# Dependencies

> What is the project blocked on?

This project has no blockers.

> What will be impacted by the project?

Impacts the publishing approach of the Coverage Converter tool.

# Testing

> How will the project be tested?

This project will be tested manually. 

# Alternatives Considered

> Summarize alternative designs (pros & cons)

## Personal Package Archive (PPA), Homebrew, and Chocolatey.

The alternative of the GitHub Releases is to publish the CLI to the package managers of different platforms. So, we'll deploy the CLI to the following package managers: 

- `PPA` for the Linux users
- `Homebrew` for the macOS users
- `Chocolatey` for Windows users

This alternative is pretty complex in configuration, but it provides an easy way of installing the Coverage Converter tool using the single platform-unified command. So, let's consider the main Pros & Cons of this alternative: 

### Pros & Cons

Pros: 
- Easy to download the latest release.
- Makes the CLI global-accessible command after installation.

Cons: 
- Complex configuration process that requires a full configuration process for each platform (package manager).
- Some package management tools do not support publishing the compiled executables, so we should compile it on the user's machine.
- No existing integration with GitHub Actions.

## pub.dev publishing

Another alternative is to publish the Coverage Converter tool as a Dart package. It will allow users to install the CLI tool using the `pub global activate` command, but it requires the Dart SDK installed.

To publish the Dart package, you should: 

1. Create a Dart package project.
2. Publish the package using the `pub publish` command.

Let's consider the pros and cons of this publishing approach: 

### Pros & Cons

Pros: 
- Easy to publish.
- Easy to download and install the command-line application.
- Single publishing for all platforms.
- Does not require building before publishing.

Cons: 
- To install the package, a user should have the Dart SDK installed.
- The Coverage Converter tool will be built on the user's machine so, installation can take a bit more time.


# Timeline

> Document milestones and deadlines.

DONE:

  - Investigate the ways of publishing the Coverage Converter tool.
  - Explain the way of using the Coverage Converter tool.

NEXT:

  - Publish the Coverage Converter tool.
  
# Results

> What was the outcome of the project?

We've chosen where to publish the Coverage Converter tool.