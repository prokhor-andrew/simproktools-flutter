//
//  process.dart
//  simproktools
//
//  Created by Andrey Prokhorenko on 16.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

library simproktools;

import 'package:simprokmachine/simprokmachine.dart';

/// A class that describes a machine with an injectable processing behavior over
/// the injected object. Exists for convenience.
class ProcessMachine<Input, Output> extends ChildMachine<Input, Output> {
  final BiHandler<Input?, Handler<Output>> processor;

  ProcessMachine._(this.processor);

  /// parameter [object] - object that is passed into
  /// the injected `processor()` function.
  /// parameter [processor] - triggered when `process()` method is triggered
  /// with an injected `object` passed in as the first parameter.
  static ProcessMachine<Input, Output> create<O, Input, Output>({
    required O object,
    required TriHandler<O, Input?, Handler<Output>> processor,
  }) {
    return ProcessMachine._(
      (input, callback) => processor(object, input, callback),
    );
  }

  /// `ChildMachine` abstract method
  @override
  void process(Input? input, Handler<Output> callback) {
    processor(input, callback);
  }
}
