//
//  reducer.dart
//  simproktools
//
//  Created by Andrey Prokhorenko on 16.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

library simproktools;

import 'package:simprokmachine/simprokmachine.dart';
import 'package:simproktools/classic.dart';

/// A machine that receives input, reduces it into state and emits it.
class ReducerMachine<Event, State> extends ParentMachine<Event, State> {
  final Machine<Event, State> _machine;

  /// parameter [initial] - initial state and array of outputs that are
  /// emitted when machine is subscribed to.
  /// parameter [reducer] - a `BiMapper` object that accepts current state,
  /// received input and returns an object of `ReducerResult` type depending on
  /// which the state is either changed or not.
  ReducerMachine({
    required State initial,
    required BiMapper<State, Event, ReducerResult<State>> reducer,
  }) : _machine = ClassicMachine<State, Event, State>(
          initial: ClassicResult<State, State>.single(
            state: initial,
            output: initial,
          ),
          reducer: (State state, Event event) {
            final State? result = reducer(state, event).value;
            if (result != null) {
              return ClassicResult<State, State>.single(
                state: result,
                output: result,
              );
            } else {
              return ClassicResult<State, State>.ignore(state: state);
            }
          },
        );

  /// `ParentMachine` class method
  @override
  Machine<Event, State> child() {
    return _machine;
  }
}

/// A type that represents a behavior of `ReducerMachine`.
class ReducerResult<T> {

  /// value
  final T? value;

  /// Returning this value from `ReducerMachine`'s `reducer` method ensures
  /// that the state *won't* be changed and emitted .
  ReducerResult.skip() : value = null;

  /// Returning this value from `ReducerMachine`'s `reducer` method ensures
  /// that the state *will* be changed and emitted.
  ReducerResult.set(T val) : value = val;
}
