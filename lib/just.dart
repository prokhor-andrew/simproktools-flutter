//
//  just.dart
//  simproktools
//
//  Created by Andrey Prokhorenko on 16.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

library simproktools;

import 'package:simprokmachine/simprokmachine.dart';

/// A machine that emits the injected value when subscribed and
/// every time input is received.
class JustMachine<Input, Output> extends ChildMachine<Input, Output> {
  final Output _value;

  /// parameter [value] - a value that is sent back every time input received
  JustMachine(Output value) : _value = value;

  /// `ChildMachine` class method
  @override
  void process(Input? input, Handler<Output> callback) {
    callback(_value);
  }
}
