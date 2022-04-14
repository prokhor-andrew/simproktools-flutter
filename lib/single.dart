//
//  single.dart
//  simproktools
//
//  Created by Andrey Prokhorenko on 16.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

library simproktools;

import 'package:simprokmachine/simprokmachine.dart';

/// A machine that emits the injected value *when subscribed*.
class SingleMachine<Input, Output> extends ChildMachine<Input, Output> {
  final Output _value;

  /// parameter [value] - a value that is emitted when machine is subscribed to.
  SingleMachine(Output value) : _value = value;

  /// `ChildMachine` class method
  @override
  void process(Input? input, Handler<Output> callback) {
    if (input == null) {
      callback(_value);
    }
  }
}
