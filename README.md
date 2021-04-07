# CookInSwift

CookInSwift is implementation of [Cook Language Spec](https://github.com/cooklang/spec) in Swift language.

## Key Features

- Full support of spec
- Linux compatible?

## Install

Install via the [**Swift Package Manger**](https://swift.org/package-manager/) by declaring **CookInSwift** as a dependency in your  `Package.swift`:

``` swift
.package(url: "https://github.com/cooklang/CookInSwift", from: "1.0.0")
```

Remember to add **CookInSwift** to your target as a dependency.

## Documentation

#### Using
Creating Swift datastructures from the string containing recipe markup:

```  swift
func parseRecipe(_ content: String) -> SemanticRecipe {
    let parser = Parser(content)
    let node = parser.parse()
    let analyzer = SemanticAnalyzer()
    
    return analyzer.analyze(node: node)
}
```

#### Config parser
Creating Swift datastructures from the string containing cook config:

```  swift
func parseConfig(_ content: String) -> CookConfig {
    let parser = ConfigParser(textConfig)
    return parser.parse()
}
```
