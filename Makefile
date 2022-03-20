dev:
	swift build

test:
	swift test

# generate canonical tests
canonical:
	# expects spec repository located in next to the parser's directory
	ruby Tests/CookInSwiftTests/generate_canonical_tests.rb ../spec/tests/canonical.yaml
