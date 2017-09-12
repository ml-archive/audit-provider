# Audit 🕵️‍
[![Swift Version](https://img.shields.io/badge/Swift-3.1-brightgreen.svg)](http://swift.org)
[![Vapor Version](https://img.shields.io/badge/Vapor-2-F6CBCA.svg)](http://vapor.codes)
[![Linux Build Status](https://img.shields.io/circleci/project/github/nodes-vapor/audit.svg?label=Linux)](https://circleci.com/gh/nodes-vapor/audit)
[![macOS Build Status](https://img.shields.io/travis/nodes-vapor/audit.svg?label=macOS)](https://travis-ci.org/nodes-vapor/audit)
[![codecov](https://codecov.io/gh/nodes-vapor/bugsnag/branch/master/graph/badge.svg)](https://codecov.io/gh/nodes-vapor/audit)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](http://opensource.org/licenses/MIT)

Track model creations, updates and deletions.

## 📦 Installation


### Integrating Audit in your project

Update your `Package.swift` using Vapor toolbox's provider command.

```
vapor provider add nodes-vapor/audit
```


## Getting started 🚀
There are two primary interfaces for reporting a model event: the static interface through `Audit` and the static interface through a type of `Model`.

### The `M.audit` interface
Audit provides an extension for all types conforming to `Model` that allows them to report an event without having to manually pass in type information.
```swift
try Post.audit(user, event: .created, severity: .normal)
```

or with a custom event:

```swift
try Post.audit(user, event: "liked a post")
```

There may be a time where you have an enumeration of custom events and you would like to use their identifiers in your report. Auditor makes this possible, just call the overload with the parameter `eventTypeId: UInt8`. 

> *note*: values 0-3 are used by Audit. Use the values 4-255 if you want you want to be able to differentiate your events from Audit's builtin events.
```swift
enum MyEvents: UInt8 {
    // start at `4` so we can tell the difference between `.something` and `Event.created`
    case something = 4
    case another
}

try Post.audit(user, event: "did something with a post", eventTypeId: MyEvents.something.rawValue)
```

### The `Audit` interface
```swift
try Audit.report(user, itemType: Post.self, event: .deleted, severity: .danger)
```

## Event types

### .created
A new instance of `M` was created.

### .updated
An instance of `M` was updated.

### .deleted
An instance of `M` was deleted.

### .custom(message: String, eventTypeId: UInt8)
For custom events, you have to define the message and the event's type's identifier.

> *note*: values 0-3 are used by Audit. Use the values 4-255 if you want you want to be able to differentiate your events from Audit's builtin events.

## Severity Levels

### .debug

### .normal

### .important

### .danger

### .custom(severityLevelId: UInt8)

> *note*: values 0-4 are used by Audit. Use the values 5-255 if you want you want to be able to differentiate your severity levels from Audit's builtin levels.

## Custom audit description
By default the generated messages use the model's `name`. If you wish to override this behaviour, you can conform to the protocol `AuditCustomDescribable`.
```swift
extension Post: AuditCustomDescribable {
    var auditDescription: String {
        return "blog post"      
    }
}

try Post.audit(user, event: .created) // Brett created a/an blog post
```

## Author
In order to report events with your custom user model, you need to conform it to `Author`. `Author` is a simple protocol that just expects a name.
```swift
public protocol Author: Model {
    var name: String { get }
}
```

## 🏆 Credits

This package is developed and maintained by the Vapor team at [Nodes](https://www.nodesagency.com).
The package owner for this project is [Brett](https://github.com/BrettRToomey).


## 📄 License

This package is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT)