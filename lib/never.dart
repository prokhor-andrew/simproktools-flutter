//
//  never.dart
//  simproktools
//
//  Created by Andrey Prokhorenko on 16.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

library simproktools;

import 'package:simprokmachine/simprokmachine.dart';

/// A machine that when subscribed or receives input - ignores it, never emitting output.
class NeverMachine<Input, Output> extends ChildMachine<Input, Output> {
  /// `ChildMachine` class method
  @override
  void process(Input? input, Handler<Output> callback) {
    // do nothing
  }
}
