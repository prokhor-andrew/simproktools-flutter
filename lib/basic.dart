//
//  basic.dart
//  simproktools
//
//  Created by Andrey Prokhorenko on 16.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

library simproktools;

import 'package:flutter/widgets.dart';
import 'package:simprokmachine/simprokmachine.dart';

/// A class that describes a machine with an injectable processing behavior.
class BasicMachine<Input, Output> extends ChildMachine<Input, Output> {
  final BiHandler<Input?, Handler<Output>> _processor;

  /// parameter [processor] - triggered when `process()` method is triggered.
  BasicMachine({
    required BiHandler<Input?, Handler<Output>> processor,
  }) : _processor = processor;

  /// `ChildMachine` abstract method
  @override
  void process(Input? input, Handler<Output> callback) {
    _processor(input, callback);
  }
}

/// A class that describes a widget machine with an injectable child widget.
class BasicWidgetMachine<Input, Output>
    extends ChildWidgetMachine<Input, Output> {
  final Widget _child;

  /// A [widget] that is returned from `Widget.child()`.
  BasicWidgetMachine({required Widget child}) : _child = child;

  /// Returns injected child widget.
  @override
  Widget child() {
    return _child;
  }
}
