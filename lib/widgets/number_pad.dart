import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class NumberPad extends StatefulWidget {
  final TextEditingController controller;
  final bool isNegative;
  final VoidCallback onToggleSign;
  final VoidCallback onDone;

  const NumberPad({
    super.key,
    required this.controller,
    required this.isNegative,
    required this.onToggleSign,
    required this.onDone,
  });

  @override
  State<NumberPad> createState() => _NumberPadState();
}

class _NumberPadState extends State<NumberPad> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  void _onDigit(String digit) {
    final current = widget.controller.text;
    // Replace a lone leading zero instead of producing "07".
    final next = current == '0' ? digit : current + digit;
    if (int.parse(next) > AppConstants.maxScoreValue) return;
    widget.controller.text = next;
    widget.controller.selection =
        TextSelection.collapsed(offset: widget.controller.text.length);
  }

  void _onBackspace() {
    if (widget.controller.text.isNotEmpty) {
      widget.controller.text =
          widget.controller.text.substring(0, widget.controller.text.length - 1);
      widget.controller.selection =
          TextSelection.collapsed(offset: widget.controller.text.length);
    }
  }

  void _onClear() {
    widget.controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = GoogleFonts.spaceGrotesk(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppConstants.onSurface,
    );

    return Container(
      // Keep the Done button clear of the gesture/navigation bar.
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 24 + MediaQuery.of(context).viewPadding.bottom),
      decoration: const BoxDecoration(
        color: AppConstants.surfaceContainerLow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppConstants.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Current value preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppConstants.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppConstants.cardRadius),
            ),
            child: Text(
              widget.controller.text.isEmpty
                  ? '0'
                  : '${widget.isNegative ? '-' : ''}${widget.controller.text}',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: widget.isNegative
                    ? AppConstants.secondary
                    : AppConstants.primary,
              ),
            ),
          ),
          // Row 1: 1, 2, 3
          _buildRow(['1', '2', '3'], buttonStyle),
          const SizedBox(height: 8),
          // Row 2: 4, 5, 6
          _buildRow(['4', '5', '6'], buttonStyle),
          const SizedBox(height: 8),
          // Row 3: 7, 8, 9
          _buildRow(['7', '8', '9'], buttonStyle),
          const SizedBox(height: 8),
          // Row 4: +/- toggle, 0, backspace
          Row(
            children: [
              Expanded(child: _buildToggleButton()),
              const SizedBox(width: 8),
              Expanded(child: _buildDigitButton('0', buttonStyle)),
              const SizedBox(width: 8),
              Expanded(child: _buildBackspaceButton()),
            ],
          ),
          const SizedBox(height: 12),
          // Done button
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: widget.onDone,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppConstants.primaryDim, AppConstants.primary],
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.chipRadius),
                ),
                child: Text(
                  'DONE',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> digits, TextStyle style) {
    return Row(
      children: digits.map((d) {
        final list = <Widget>[Expanded(child: _buildDigitButton(d, style))];
        if (d != digits.last) list.add(const SizedBox(width: 8));
        return list;
      }).expand((e) => e).toList(),
    );
  }

  Widget _buildDigitButton(String digit, TextStyle style) {
    return GestureDetector(
      onTap: () => _onDigit(digit),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppConstants.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        ),
        child: Center(child: Text(digit, style: style)),
      ),
    );
  }

  Widget _buildToggleButton() {
    return GestureDetector(
      onTap: widget.onToggleSign,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: widget.isNegative
              ? AppConstants.secondaryContainer
              : AppConstants.primaryContainer,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        ),
        child: Center(
          child: Image.asset(
            'assets/icon/plus_minus.png',
            width: 32,
            height: 32,
            fit: BoxFit.contain,
            semanticLabel: widget.isNegative ? 'Negative' : 'Positive',
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return GestureDetector(
      onTap: _onBackspace,
      onLongPress: _onClear,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppConstants.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        ),
        child: const Center(
          child: Icon(
            Icons.backspace_outlined,
            size: 24,
            color: AppConstants.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
