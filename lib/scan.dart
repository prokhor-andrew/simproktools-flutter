//
//  scan.dart
//  simproktools
//
//  Created by Andrey Prokhorenko on 16.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

library simproktools;

import 'package:simprokmachine/simprokmachine.dart';
import 'package:simproktools/classic.dart';

class _ScanEmit<ParentInput, ParentOutput, ChildInput, ChildOutput> {
  final ChildInput? toMachine;
  final ScanInput<ParentInput, ChildOutput>? toReducer;
  final ParentOutput? out;

  _ScanEmit.toMachine(ChildInput value)
      : toMachine = value,
        toReducer = null,
        out = null;

  _ScanEmit.toReducer(ScanInput<ParentInput, ChildOutput> value)
      : toMachine = null,
        toReducer = value,
        out = null;

  _ScanEmit.out(ParentOutput value)
      : out = value,
        toMachine = null,
        toReducer = null;
}

/// A type that represents a behavior of `Machine.scan()` operator.
/// Received by `Machine.scan()`'s `reducer` as event.
class ScanInput<ParentInput, MachineOutput> {
  /// inner
  final MachineOutput? inner;

  /// outer
  final ParentInput? outer;

  /// Received from `this` object.
  ScanInput.inner(MachineOutput value)
      : inner = value,
        outer = null;

  /// Received from parent machine.
  ScanInput.outer(ParentInput value)
      : inner = null,
        outer = value;
}

/// A type that represents a behavior of `Machine.scan()` operator.
/// Returned from `Machine.scan()`'s `reducer` method.
class ScanOutput<ParentOutput, MachineInput> {
  final MachineInput? _state;
  final ParentOutput? _event;

  /// Changes current state of `Machine.scan()` into `MachineInput`
  ScanOutput.state(MachineInput value)
      : _state = value,
        _event = null;

  /// Emits an output object to the parent machine.
  ScanOutput.event(ParentOutput value)
      : _state = null,
        _event = value;
}

extension ScanMachine<Input, Output> on Machine<Input, Output> {
  /// Takes `this` and applies specific behavior.
  /// When parent machine sends new input, it is either reduced into new child
  /// state and sent to the `this` or mapped into parent output and emitted back.
  /// When child machine sends new output, it is either reduced into new child
  /// state and sent back to the `this` or mapped into parent output and emitted.
  /// parameter [initial] - initial state that is sent to the `this` machine when subscribed.
  /// parameter [reducer] - `BiMapper` that accepts current state as `Input`, new
  /// input as `ScanInput`, and returns `ScanOutput`.
  Machine<ParentInput, ParentOutput> scan<ParentInput, ParentOutput>({
    required Input initial,
    required BiMapper<Input, ScanInput<ParentInput, Output>,
            ScanOutput<ParentOutput, Input>>
        reducer,
  }) {
    final Machine<_ScanEmit<ParentInput, ParentOutput, Input, Output>,
            _ScanEmit<ParentInput, ParentOutput, Input, Output>> machine =
        outward((Output output) {
      return Ward<_ScanEmit<ParentInput, ParentOutput, Input, Output>>.single(
        _ScanEmit.toReducer(
          ScanInput.inner(output),
        ),
      );
    }).inward((_ScanEmit<ParentInput, ParentOutput, Input, Output> input) {
      final Input? toMachine = input.toMachine;
      if (toMachine != null) {
        return Ward.single(toMachine);
      } else {
        return Ward.ignore();
      }
    });

    final Machine<_ScanEmit<ParentInput, ParentOutput, Input, Output>,
            _ScanEmit<ParentInput, ParentOutput, Input, Output>>
        reducerMachine = ClassicMachine<Input, ScanInput<ParentInput, Output>,
            _ScanEmit<ParentInput, ParentOutput, Input, Output>>(
      initial: ClassicResult.single(
        state: initial,
        output: _ScanEmit<ParentInput, ParentOutput, Input, Output>.toMachine(
          initial,
        ),
      ),
      reducer: (state, event) {
        final ScanOutput<ParentOutput, Input> result = reducer(state, event);
        final Input? resultState = result._state;
        if (resultState != null) {
          return ClassicResult.single(
            state: resultState,
            output:
                _ScanEmit<ParentInput, ParentOutput, Input, Output>.toMachine(
              resultState,
            ),
          );
        } else {
          final ParentOutput? resultEvent = result._event;
          if (resultEvent != null) {
            return ClassicResult.single(
              state: state,
              output: _ScanEmit<ParentInput, ParentOutput, Input, Output>.out(
                  resultEvent),
            );
          } else {
            // this should never happen, but to prevent from compile time errors
            // and a magical possibility of this case happening - let's handle it
            return ClassicResult.ignore(state: state);
          }
        }
      },
    ).inward((_ScanEmit<ParentInput, ParentOutput, Input, Output> input) {
      final ScanInput<ParentInput, Output>? toReducer = input.toReducer;
      if (toReducer != null) {
        return Ward.single(toReducer);
      } else {
        return Ward.ignore();
      }
    });

    final Machine<_ScanEmit<ParentInput, ParentOutput, Input, Output>,
            _ScanEmit<ParentInput, ParentOutput, Input, Output>> merged =
        merge({reducerMachine, machine});

    final Machine<_ScanEmit<ParentInput, ParentOutput, Input, Output>,
            ParentOutput> m0 =
        merged.outward(
            (_ScanEmit<ParentInput, ParentOutput, Input, Output> output) {
      final ParentOutput? out = output.out;

      if (out != null) {
        return Ward.single(out);
      } else {
        return Ward.ignore();
      }
    });

    final Machine<ParentInput, ParentOutput> m1 =
        m0.inward((ParentInput input) {
      return Ward.single(
        _ScanEmit<ParentInput, ParentOutput, Input, Output>.toReducer(
          ScanInput<ParentInput, Output>.outer(input),
        ),
      );
    });

    return m1;
  }
}
