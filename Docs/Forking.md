# Forking cooklang-swift

Community members wishing to contribute code to `cooklang-swift` must fork the `cooklang-swift` project
(`your-github-username/cooklang-swift`). Branches pushed to that fork can then be submitted
as pull requests to the upstream project (`cooklang/cooklang-swift`).

To locally clone the repo so that you can pull the latest from the upstream project
(`cooklang/cooklang-swift`) and push changes to your own fork (`your-github-username/cooklang-swift`):

1. [Create the forked repository](https://docs.github.com/en/get-started/quickstart/fork-a-repo#forking-a-repository) (`your-github-username/cooklang-swift`)
2. Clone the `cooklang/cooklang-swift` repository and `cd` into the folder
3. Make `cooklang/cooklang-swift` the `upstream` remote rather than `origin`:
   `git remote rename origin upstream`.
4. Add your fork as the `origin` remote. For example:
   `git remote add origin https://github.com/myusername/cooklang-swift`
5. Checkout a feature branch: `git checkout -t -b new-feature`
6. [Make changes](../CONTRIBUTING.md#prerequisites).
7. Push changes to the fork when ready to [submit a PR](../CONTRIBUTING.md#submitting-a-pull-request):
   `git push -u origin new-feature`
