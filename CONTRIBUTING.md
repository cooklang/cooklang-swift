# Contributing

## Getting Started

### Some Ways to Contribute

* Report potential bugs.
* Suggest parser enhancements.
* Increase our test coverage.
* Fix a [bug](https://github.com/cooklang/cooklang-swift/labels/bug).
* Implement a requested [enhancement](https://github.com/cooklang/cooklang-swift/labels/enhancement).

### Reporting an Issue

> Note: Issues on GitHub for `cooklang-swift` are intended to be related to bugs or feature requests.
> Questions should be directed to [Spec Discussions](https://github.com/cooklang/spec/discussions).

* Check existing issues (both open and closed) to make sure it has not been
reported previously.

* Provide a reproducible test case. If a contributor can't reproduce an issue,
then it dramatically lowers the chances it'll get fixed.

* Aim to respond promptly to any questions made by the `cooklang-swift` team on your
issue. Stale issues will be closed.

### Issue Lifecycle

1. The issue is reported.

2. The issue is verified and categorized by a `cooklang-swift` maintainer.
   Categorization is done via tags. For example, bugs are tagged as "bug".

3. Unless it is critical, the issue is left for a period of time (sometimes many
   weeks), giving outside contributors a chance to address the issue.

4. The issue is addressed in a pull request or commit. The issue will be
   referenced in the commit message so that the code that fixes it is clearly
   linked. Any change a `cooklang-swift` user might need to know about will include a
   changelog entry in the PR.

5. The issue is closed.

## Making Changes to `cooklang-swift`

### Prerequisites

If you wish to work on `cooklang-swift` itself, you'll first need to:
- install [Swift](https://www.swift.org/download/#releases) for macOS, Linux or Windows.
- [fork the `cooklang-swift` repo](../Docs/Forking.md)

### Building `cooklang-swift`

`cooklang-swift` is a library intended to used by other programs. Sometimes to validate you might want to build `cooklang-swift`, do it by running `swift build`.

>Note: `swift build` will build for your local machine's os/architecture.

### Testing

Examples (run from the repository root):
- `swift test` will run all tests
- `swift test --filter CookInSwiftTests.LexerTests` will run all tests in `Lexer` module.

All available options for skipping and filtering tests available via `swift test --help`.

When a pull request is opened CI will run all tests to verify the change.

### Canonical tests

If your changes of the parser that should be generalized (for other parsers too), consider updating [Canonical tests](https://github.com/cooklang/spec/tree/main/tests).

### Submitting a Pull Request

Before writing any code, we recommend:
- Create a Github issue if none already exists for the code change you'd like to make.
- Write a comment on the Github issue indicating you're interested in contributing so
maintainers can provide their perspective if needed.

Keep your pull requests (PRs) small and open them early so you can get feedback on
approach from maintainers before investing your time in larger changes.

When you're ready to submit a pull request:
1. Include evidence that your changes work as intended (e.g., add/modify unit tests;
   describe manual tests you ran, in what environment,
   and the results including screenshots or terminal output).
2. Open the PR from your fork against base repository `cooklang/cooklang-swift` and branch `main`.
   - [Link the PR to its associated issue](https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue).
3. Include any specific questions that you have for the reviewer in the PR description
   or as a PR comment in Github.
   - If there's anything you find the need to explain or clarify in the PR, consider
   whether that explanation should be added in the source code as comments.
   - You can submit a [draft PR](https://github.blog/2019-02-14-introducing-draft-pull-requests/)
   if your changes aren't finalized but would benefit from in-process feedback.
6. After you submit, the `cooklang-swift` maintainers team needs time to carefully review your
   contribution and ensure it is production-ready, considering factors such as: correctness,
   backwards-compatibility, potential regressions, etc.
7. After you address `cooklang-swift` maintainer feedback and the PR is approved, a `cooklang-swift` maintainer
   will merge it. Your contribution will be available from the next minor release.
