# cooklang-swift

This project is an implementation of [Cook Language Spec](https://github.com/cooklang/spec) in Swift language.

## Key Features

- Full support of spec
- macOS/Linux compatible

## Install

Install via the [**Swift Package Manger**](https://swift.org/package-manager/) by declaring **cooklang-swift** as a dependency in your  `Package.swift`:

``` swift
.package(url: "https://github.com/cooklang/cooklang-swift", from: "0.1.0")
```

Remember to add **cooklang-swift** to your target as a dependency.

## Documentation

#### Using
Creating Swift datastructures from the string containing recipe markup:

```  swift
let parsedRecipe = try! Recipe.from(text: program)
```

#### Config parser
Creating Swift datastructures from the string containing cook config:

```  swift
func parseConfig(_ content: String) -> CookConfig {
    let parser = ConfigParser(textConfig)
    return parser.parse()
}
```

## Development

See [Contributing](CONTRIBUTING.md)
### Codespaces

- We are using the default Swift Community template from [microsoft/vscode-dev-containers](https://github.com/microsoft/vscode-dev-containers/tree/main/containers/swift)
  - build the package: `swift build --enable-test-discovery`
  - run the tests: `swift test --enable-test-discovery`
