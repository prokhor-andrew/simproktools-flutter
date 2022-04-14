//
//  classic.dart
//  simproktools
//
//  Created by Andrey Prokhorenko on 16.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

library simproktools;

import 'package:simprokmachine/simprokmachine.dart';

/// A machine that receives input, reduces it into state and
/// array of outputs that are emitted.
class ClassicMachine<State, Input, Output> extends ChildMachine<Input, Output> {
  final BiMapper<State, Input, ClassicResult<State, Output>> _reducer;
  ClassicResult<State, Output> _state;

  /// parameter [initial] - initial state and array of outputs that are
  /// emitted when machine is subscribed to.
  /// parameter [reducer] - a `BiMapper` object that accepts current state,
  /// received input and returns an object of `ClassicResult` type that contains
  /// new state and emitted array of outputs.
  ClassicMachine({
    required ClassicResult<State, Output> initial,
    required BiMapper<State, Input, ClassicResult<State, Output>> reducer,
  })  : _state = initial,
        _reducer = reducer;

  /// `ChildMachine` class method
  @override
  void process(Input? input, Handler<Output> callback) {
    if (input != null) {
      _state = _reducer(_state.state, input);
    }

    for (var element in _state.outputs) {
      callback(element);
    }
  }
}

/// A type that represents a behavior of `ClassicMachine`.
class ClassicResult<State, Output> {
  /// State
  final State state;
  /// Outputs
  final List<Output> outputs;

  /// Creates a `ClassicResult` object that is when returned from `ClassicMachine`
  /// reducer changes state and emits outputs.
  /// parameter [state] - new state.
  /// parameter [output] emitted output.
  ClassicResult.single({
    required this.state,
    required Output output,
  }) : outputs = [output];

  /// Creates a `ClassicResult` object that is when returned from `ClassicMachine`
  /// reducer changes state and emits outputs.
  /// parameter [state] - new state.
  /// parameter [outputs] emitted outputs.
  ClassicResult.values({
    required this.state,
    required this.outputs,
  });

  /// Creates a `ClassicResult` object that is when returned from `ClassicMachine`
  /// reducer changes state and does not emit outputs.
  ClassicResult.ignore({
    required this.state,
  }) : outputs = [];
}
