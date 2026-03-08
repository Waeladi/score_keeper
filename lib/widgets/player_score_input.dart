import 'package:flutter/material.dart';
import '../utils/constants.dart';

class PlayerScoreInput extends StatefulWidget {
  final int playerIndex;
  final String playerName;
  final int currentScore;
  final TextEditingController scoreController;
  final FocusNode scoreFocusNode;
  final bool isNegative;
  final bool isLandscape;
  final Function(int, String) onPlayerNameChanged;
  final VoidCallback onToggleSign;

  const PlayerScoreInput({
    super.key,
    required this.playerIndex,
    required this.playerName,
    required this.currentScore,
    required this.scoreController,
    required this.scoreFocusNode,
    required this.isNegative,
    this.isLandscape = false,
    required this.onPlayerNameChanged,
    required this.onToggleSign,
  });

  @override
  State<PlayerScoreInput> createState() => _PlayerScoreInputState();
}

class _PlayerScoreInputState extends State<PlayerScoreInput> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.playerName);
  }

  @override
  void didUpdateWidget(PlayerScoreInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playerName != widget.playerName) {
      _nameController.text = widget.playerName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Color get _signColor => widget.isNegative
      ? AppConstants.negativeScoreColor
      : AppConstants.positiveScoreColor;

  Widget _buildNameField({double? height, EdgeInsetsGeometry? contentPadding}) {
    return SizedBox(
      height: height ?? AppConstants.playerRowHeight,
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Player Name',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        controller: _nameController,
        onChanged: (value) => widget.onPlayerNameChanged(widget.playerIndex, value),
        onTap: () {
          _nameController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _nameController.text.length,
          );
        },
        textInputAction: TextInputAction.done,
        onEditingComplete: () => FocusScope.of(context).unfocus(),
      ),
    );
  }

  Widget _buildScoreDisplay({required double height}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          '${widget.currentScore}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: widget.currentScore < 0
                ? AppConstants.negativeScoreColor
                : AppConstants.positiveScoreColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildScoreField({required double height, EdgeInsetsGeometry? contentPadding}) {
    return SizedBox(
      height: height,
      child: TextField(
        controller: widget.scoreController,
        focusNode: widget.scoreFocusNode,
        decoration: InputDecoration(
          labelText: 'Score',
          labelStyle: const TextStyle(fontSize: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _signColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _signColor, width: 2),
          ),
          contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          alignLabelWithHint: true,
          floatingLabelAlignment: FloatingLabelAlignment.center,
        ),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: _signColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSignToggle({required double height, double? iconSize}) {
    return SizedBox(
      height: height,
      width: 44,
      child: InkWell(
        onTap: widget.onToggleSign,
        child: Container(
          decoration: BoxDecoration(
            color: _signColor.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Image.asset(
              'assets/icon/plus_minus.png',
              width: iconSize ?? 24,
              height: iconSize ?? 24,
              fit: BoxFit.contain,
              semanticLabel: 'Toggle Score Sign',
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: widget.isLandscape ? _buildLandscapeLayout() : _buildPortraitLayout(),
    );
  }

  Widget _buildPortraitLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: _buildNameField()),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: _buildScoreDisplay(height: AppConstants.playerRowHeight)),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: _buildScoreField(height: AppConstants.playerRowHeight)),
          const SizedBox(width: 8),
          _buildSignToggle(height: AppConstants.playerRowHeight),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    const double inputHeight = AppConstants.playerRowHeight - 15;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameField(
              height: inputHeight,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildScoreDisplay(height: inputHeight)),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildScoreField(
                    height: inputHeight,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                ),
                const SizedBox(width: 8),
                _buildSignToggle(height: inputHeight, iconSize: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
