//
//  value.dart
//  simproktools
//
//  Created by Andrey Prokhorenko on 16.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

library simproktools;

import 'package:simprokmachine/simprokmachine.dart';

/// A machine that accepts a value as input and immediately emits it as output.
/// When subscribed - emits `null`.
class ValueMachine<T> extends ChildMachine<T, T?> {
  /// `ChildMachine` class method
  @override
  void process(T? input, Handler<T?> callback) {
    callback(input);
  }
}
