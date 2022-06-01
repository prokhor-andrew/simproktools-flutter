//
//  connectable.dart
//  simproktools
//
//  Created by Andrey Prokhorenko on 16.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

library simproktools;

import 'package:simprokmachine/simprokmachine.dart';

// extensions

extension _MapCopyAdd<Key, Value> on Map<Key, Value> {
  Map<Key, Value> copyAdd(Key key, Value value) {
    final Map<Key, Value> copied = map((key, value) => MapEntry(key, value));
    copied[key] = value;
    return copied;
  }
}

class _EmitterInput<T> {
  final T value;

  _EmitterInput(this.value);
}

class _EmitterOutput<Input, Output> {
  final Input? _input;
  final Output? _output;

  _EmitterOutput.toConnected(Input input)
      : _input = input,
        _output = null;

  _EmitterOutput.fromConnected(Output output)
      : _input = null,
        _output = output;
}

class _EmitterMachine<Input, Output>
    extends ChildMachine<_EmitterInput<Input>, _EmitterOutput<Input, Output>> {
  Handler<_EmitterOutput<Input, Output>>? _callback;

  void send(Input input) {
    final callback = _callback;
    if (callback != null) {
      callback(_EmitterOutput.toConnected(input));
    }
  }

  @override
  void process(
    _EmitterInput<Input>? input,
    Handler<_EmitterOutput<Input, Output>> callback,
  ) {
    _callback = callback;
  }
}

class _ConnectablePair<Input, Output> {
  final RootMachine<_EmitterInput<Input>, Output> subscription;
  final _EmitterMachine<Input, Output> emitter;

  _ConnectablePair(this.subscription, this.emitter);
}

/// An object that represents state in `ConnectableMachine`'s reducer
abstract class Connection<Input, Output> {
  /// Machines that are connected in `ConnectableMachine`.
  Set<Machine<Input, Output>> machines();
}

/// Basic implementation of `Connection` class
class BasicConnection<Input, Output> extends Connection<Input, Output> {
  /// `Connection` class property
  final Set<Machine<Input, Output>> set;

  BasicConnection(this.set);

  /// `Connection` class method
  @override
  Set<Machine<Input, Output>> machines() {
    return set;
  }
}

/// A type that represents a behavior of `ConnectableMachine`
class ConnectionType<Input, Output, C extends Connection<Input, Output>> {
  final C? _connection;

  /// Returning this value from `ConnectableMachine`'s `reducer` method
  /// ensures that `machines` specified in the object of `C extends Connection`
  /// type will be connected and all of them will receive subscription event.
  ConnectionType.reduce(C connection) : _connection = connection;

  /// Returning this value from `ConnectableMachine`'s `reducer` method ensures
  /// that `machines` currently being connected will receive an input
  /// object of `(C extends Connection).Input` type.
  ConnectionType.inward() : _connection = null;
}

/// The machine for dynamic creation and connection of other machines
class ConnectableMachine<Input, Output, C extends Connection<Input, Output>>
    extends ChildMachine<Input, Output> {
  Map<int, _ConnectablePair<Input, Output>> _map = {};
  C _state;
  final BiMapper<C, Input, ConnectionType<Input, Output, C>> _reducer;

  ConnectableMachine._(this._state, this._reducer);

  /// `ChildMachine` class method
  @override
  void process(Input? input, Handler<Output> callback) {
    if (input != null) {
      final connection = _reducer(_state, input)._connection;
      if (connection != null) {
        // reduce
        _state = connection;
        _connect(callback);
      } else {
        // inward
        _send(input);
      }
    } else {
      _connect(callback);
    }
  }

  void _connect(Handler<Output> callback) {
    _map = _state.machines().fold({}, (cur, machine) {
      final int id = machine.hashCode;
      if (cur[id] != null) {
        return cur;
      } else {
        final item = _map[id];
        if (item != null) {
          return cur.copyAdd(id, item);
        } else {
          final _EmitterMachine<Input, Output> emitter = _EmitterMachine();

          final Machine<Input, _EmitterOutput<Input, Output>> m0 =
              machine.outward((Output output) {
            return Ward.single(
              _EmitterOutput<Input, Output>.fromConnected(output),
            );
          });

          final Machine<_EmitterInput<Input>, _EmitterOutput<Input, Output>>
              m1 = m0.inward((_EmitterInput<Input> input) {
            return Ward.single(input.value);
          });

          final Machine<_EmitterInput<Input>, _EmitterOutput<Input, Output>>
              merged = merge({emitter, m1});

          final Machine<_EmitterInput<Input>, _EmitterOutput<Input, Output>>
              merged1 = merged.redirect((_EmitterOutput<Input, Output> output) {
            final input = output._input;
            if (input != null) {
              return Direction<_EmitterInput<Input>>.back(
                Ward<_EmitterInput<Input>>.single(
                  _EmitterInput<Input>(input),
                ),
              );
            } else {
              return Direction<_EmitterInput<Input>>.prop();
            }
          });

          final Machine<_EmitterInput<Input>, Output> merged2 =
              merged1.outward((_EmitterOutput<Input, Output> item) {
            final output = item._output;
            if (output != null) {
              return Ward<Output>.single(output);
            } else {
              return Ward<Output>.ignore();
            }
          });

          final RootMachine<_EmitterInput<Input>, Output> subscription =
              RootMachine(merged2);

          subscription.start();

          return cur.copyAdd(id, _ConnectablePair(subscription, emitter));
        }
      }
    });
  }

  void _send(Input input) {
    _map.forEach((_, value) {
      value.emitter.send(input);
    });
  }

  /// parameter [initial] - initial state. After subscription to the
  /// `ConnectableMachine` all the `machines` in `initial` object will be
  /// connected and subscribed to.
  /// parameter [reducer] - reducer method that is triggered every time input
  /// is received by `ConnectableMachine`.
  /// Accepts current state, incoming input and returns an object of
  /// `ConnectionType<C>` type.
  /// Either new `machines` are connected to the `ConnectableMachine` or
  /// current `machines` receive input, depending on the returned value.
  static ConnectableMachine<Input, Output, C>
      create<Input, Output, C extends Connection<Input, Output>>(
    C initial,
    BiMapper<C, Input, ConnectionType<Input, Output, C>> reducer,
  ) {
    return ConnectableMachine._(initial, reducer);
  }
}
