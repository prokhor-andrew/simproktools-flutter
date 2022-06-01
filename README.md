# simproktools

```simproktools``` is a small library consisting of useful machines for [simprokmachine](https://github.com/simprok-dev/simprokmachine-flutter) framework. 

## Installation

Add the line into pubspec.yaml:

```
dependencies:
    simproktools: ^1.1.2
```

## BasicMachine

In your Dart code use:

```Dart
import 'package:simproktools/basic.dart';
```

A machine with an injectable processing behavior.

```Dart
final Machine<Input, Output> machine = BasicMachine(
    processor: (Input input, Handler<Output> callback) {
        // processing goes here
    }
);
```

## BasicWidgetMachine

In your Dart code use:

```Dart
import 'package:simproktools/basic.dart';
```

A class that describes a widget machine with an injectable child widget.

```Dart
final WidgetMachine<Input, Output> machine = BasicWidgetMachine(child: MyWidget());
```

## ProcessMachine

In your Dart code use:

```Dart
import 'package:simproktools/process.dart';
```

A machine with an injectable processing behavior over the injected object.

```Dart
final Object object = ...;

final Machine<Input, Output> machine = ProcessMachine.create(
    object: object,
    processor: (Object object, Input, input, Handler<Output> callback) {
        // processing goes here
    }
);
```

## JustMachine

In your Dart code use:

```Dart
import 'package:simproktools/just.dart';
```

A machine that accepts a value which is passed back into the callback every time an event is received.

```Dart
final Machine<Input, int> _ = JustMachine(0); // int can be replaced with any type
```

## SingleMachine

In your Dart code use:

```Dart
import 'package:simproktools/single.dart';
```

A machine that accepts a value which is passed back into the callback *THE FIRST* time an event is received.

```Dart
final Machine<Input, int> _ = SingleMachine(0); // int can be replaced with any type
```

## ValueMachine

In your Dart code use:

```Dart
import 'package:simproktools/value.dart';
```

A machine that accepts a value as an input and immediately passes it back into the callback as an output.

```Dart
final Machine<T, T> _ = ValueMachine();
```

## NeverMachine

In your Dart code use:

```Dart
import 'package:simproktools/never.dart';
```

A machine that accepts an input and ignores it never passing back any output.

```Dart
final Machine<Input, Output> _ = NeverMachine();
```

## ReducerMachine

In your Dart code use:

```Dart
import 'package:simproktools/reducer.dart';
```

A machine that receives input, reduces it into state and emits it.

```Dart

// bool and int can be replaced with any types

final Machine<bool, int> _ = ReducerMachine<bool, int>(initial: 0, reducer: (int state, bool event) {
    // return ReducerResult.set(0); // 0 will be a new State and will be passed as output 
    // return ReducerResult.skip(); // state won't be changed and passed as output
});

```

## ClassicMachine

In your Dart code use:

```Dart
import 'package:simproktools/classic.dart';
```

A machine that receives input, reduces it into state and array of outputs that are emitted.

```Dart

// bool, String, and int can be replaced with any types

final Machine<String, int> _ = ClassicMachine<bool, String, int>(
    initial: ClassicResult<bool, int>.values(state: false, outputs: [0, 1, 2]), // initial state and initial outputs that are emitted when machine is subscribed to
    reducer: (bool state, String event) {
        return ClassicResult<bool, int>.values(state: true, outputs: [3, 4, 5]); // new state `true` and outputs `3, 4, 5` 
    }
);
```

## Scan operator

In your Dart code use:

```Dart
import 'package:simproktools/scan.dart';
```

Takes `this` and applies specific behavior.
When parent machine sends new input, it is either reduced into new child state and sent to the `this` or mapped into parent output and emitted back.
When child machine sends new output, it is either reduced into new child state and sent back to the `this` or mapped into parent output and emitted.

```Dart

// All the types can be replaced with anything else.

final Machine<bool, int> machine = ...

final Machine<String, double> result = machine.scan(initial: true, reducer: (bool state, ScanInput<String, int> event) {
    // event has either come from parent as input or from child as output.
    // output should either go to the parent as output or to the child as new input and state.
    
    // Return
    // ScanOutput<double, bool>.state(true); // when input has to be sent to the child machine AND state has to be changed.
    // ScanOutput<double, bool>.event(11.11); // when output has to be sent to the parent machine. 
    ...
});
```

## ConnectableMachine

In your Dart code use:

```Dart
import 'package:simproktools/connectable.dart';
```

A machine for dynamic creation and connection of other machines.

```Dart
final Machine<Input, Output> = ConnectableMachine<Input, Output, BasicConnection<Input, Output>>(
    initial: BasicConnection<Input, Output>({ /* machines go here */ }),
    reducer: (BasicConnection<Input, Output> connection, Input input) {
        // ConnectionType.reduce() // to connect new machines
        // ConnectionType.inward() // to send input to the connected machines
    }
);
```