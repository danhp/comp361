# Some broken things in Swift

### Optionals and the Short handle:

Swift starts crumbling when both are used together.

```swift
// This works
tile.unit?.type == Constants.Type.Unit.Peasant

// This will segfault the compiler
tile.unit?.type == .Peasant

// Here, Swift is clueless...
// It doesn't have the slightest idea how to resolve either case.
switch tile.unit?.type {
case .Peasant:
	// Do Something
case Constants.Type.Unit.Peasant:
	// Do Something
}
```
