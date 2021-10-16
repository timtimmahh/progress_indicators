import 'package:flutter/material.dart';

import 'package:progress_indicators/src/collection_animators.dart';

enum FadingTextDirection { forward, reverse, bidirectional }

/// Adds fading effect on each character in the [text] provided to it.
///
/// The animation is repeated continuously so this widget is ideal
/// to be used as progress indicator.
/// Although this widget does not put explicit limit on string character count,
/// however, it should be given such that it does not exceed a line.
///
/// The text displayed follows the default [TextStyle] of current theme, unless
/// otherwise specified.
class FadingText extends StatefulWidget {
  /// Text to animate
  final String text;

  /// Custom text style. If not specified, uses the default style.
  final TextStyle? style;

  /// Custom text align. If not specified uses the default alignment.
  final TextAlign? textAlign;

  /// The direction for text animation.
  final FadingTextDirection direction;

  /// The animation duration (in seconds).
  final int duration;

  /// Creates a fading continuous animation.
  ///
  /// The provided [text] is continuously animated using [FadeTransition].
  /// [text] must not be null.
  FadingText(this.text,
      {this.style,
      this.textAlign,
      this.direction = FadingTextDirection.bidirectional,
      this.duration = 2});

  @override
  _FadingTextState createState() => new _FadingTextState();
}

class _FadingTextState extends State<FadingText> with TickerProviderStateMixin {
  final _characters = <MapEntry<String, Animation>>[];
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration),
    );

    var start = 0.0;
    final duration = 0.6 / widget.text.length;
    widget.text.runes.forEach((int rune) {
      final character = new String.fromCharCode(rune);
      final animation = Tween(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          curve: Interval(start, start + duration, curve: Curves.easeInOut),
          parent: _controller,
        ),
      );
      _characters.add(MapEntry(character, animation));
      start += duration;
    });

    if (widget.direction == FadingTextDirection.reverse)
      _controller.addStatusListener((status) {
        _animate(status);
        /*if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }*/
      });
    _animate();
  }

  _animate([AnimationStatus? status]) {
    switch (widget.direction) {
      case FadingTextDirection.forward:
        // if (status == null)
        _controller.repeat();
        break;
      case FadingTextDirection.reverse:
        if (status == null || status == AnimationStatus.dismissed)
          _controller.reverse(from: _controller.upperBound);
        /*_controller.repeat(min: _controller.upperBound, max: _controller.lowerBound);*/
        break;
      case FadingTextDirection.bidirectional:
        _controller.repeat(reverse: true);
        // if (status == AnimationStatus.completed)
        //   _controller.reverse();
        // else if (status == null || status == AnimationStatus.dismissed)
        //   _controller.forward();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _characters
          .map(
            (entry) => FadeTransition(
              opacity: entry.value as Animation<double>,
              child: Text(entry.key, style: widget.style, textAlign: widget.textAlign),
            ),
          )
          .toList(),
    );
  }

  dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Adds jumping effect on each character in the [text] provided to it.
///
/// The animation is repeated continuously so this widget is ideal
/// to be used as progress indicator.
/// Although this widget does not put explicit limit on string character count,
/// however, it should be given such that it does not exceed a line.
///
/// The text displayed follows the default [TextStyle] of current theme, unless
/// otherwise specified.
class JumpingText extends StatelessWidget {
  final String text;
  final Offset begin = Offset(0.0, 0.0);
  final Offset end;
  final TextStyle? style;
  final int? duration;

  /// Creates a jumping text widget.
  ///
  /// Each character in [text] is animated to look like a jumping effect.
  /// The [end] is the target [Offset] for each character.
  JumpingText(this.text,
      {this.end = const Offset(0.0, -0.5), this.style, this.duration});

  @override
  Widget build(BuildContext context) {
    return CollectionSlideTransition(
        end: end,
        children: text.runes
            .map(
              (rune) => Text(String.fromCharCode(rune), style: style),
            )
            .toList(),
        duration: duration);
  }
}

/// Adds jumping effect on each character in the [text] provided to it.
///
/// The animation is repeated continuously so this widget is ideal
/// to be used as progress indicator.
/// Although this widget does not put explicit limit on string character count,
/// however, it should be given such that it does not exceed a line.
///
/// The text displayed follows the default [TextStyle] of current theme, unless
/// otherwise specified.
class ScalingText extends StatelessWidget {
  /// The text to add scaling effect to.
  final String text;
  final double begin = 1.0;
  final double end;
  final TextStyle? style;
  final int? duration;

  /// Creates a jumping text widget.
  ///
  /// Each character in [text] is scaled to [end].
  ScalingText(this.text, {this.end = 2.0, this.style, this.duration});

  @override
  Widget build(BuildContext context) {
    return CollectionScaleTransition(
        end: end,
        children: text.runes
            .map(
              (rune) => Text(String.fromCharCode(rune), style: style),
            )
            .toList(),
        duration: duration);
  }
}
