import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import 'number_pad.dart';

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
  bool _isEditingName = false;

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

  // Player avatar circle with first initial
  static const List<Color> _avatarColors = [
    AppConstants.primary,
    AppConstants.secondary,
    AppConstants.tertiary,
    AppConstants.primaryDim,
  ];

  Widget _buildAvatar() {
    final color = _avatarColors[widget.playerIndex % _avatarColors.length];
    final initial = widget.playerName.isNotEmpty
        ? widget.playerName[0].toUpperCase()
        : '${widget.playerIndex + 1}';

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _finishEditingName() {
    // A blank name would show as an empty header in History and Graph.
    if (_nameController.text.trim().isEmpty) {
      widget.onPlayerNameChanged(widget.playerIndex, 'Player ${widget.playerIndex + 1}');
    }
    setState(() => _isEditingName = false);
    FocusScope.of(context).unfocus();
  }

  Widget _buildPlayerInfo() {
    if (_isEditingName) {
      return SizedBox(
        height: 36,
        child: TextField(
          controller: _nameController,
          autofocus: true,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppConstants.onSurface,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppConstants.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppConstants.primary, width: 2),
            ),
          ),
          onChanged: (value) => widget.onPlayerNameChanged(widget.playerIndex, value),
          onEditingComplete: _finishEditingName,
          onTapOutside: (_) => _finishEditingName(),
        ),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _isEditingName = true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.playerName.isEmpty
                ? 'Player ${widget.playerIndex + 1}'
                : widget.playerName,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppConstants.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay() {
    return Text(
      '${widget.currentScore}',
      style: GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: widget.currentScore < 0
            ? AppConstants.error
            : AppConstants.primary,
      ),
    );
  }

  void _showNumberPad() {
    bool localIsNegative = widget.isNegative;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return NumberPad(
              controller: widget.scoreController,
              isNegative: localIsNegative,
              onToggleSign: () {
                localIsNegative = !localIsNegative;
                setSheetState(() {});
                widget.onToggleSign();
              },
              onDone: () => Navigator.of(ctx).pop(),
            );
          },
        );
      },
    );
  }

  Widget _buildScoreEntry() {
    final scoreText = widget.scoreController.text;
    final displayValue = scoreText.isEmpty ? '0' : scoreText;
    final hasValue = scoreText.isNotEmpty;

    return GestureDetector(
      onTap: _showNumberPad,
      child: Container(
        width: 56,
        height: 40,
        decoration: BoxDecoration(
          color: hasValue
              ? (widget.isNegative ? AppConstants.secondaryContainer : AppConstants.primaryContainer)
              : AppConstants.surfaceContainer,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
          widget.isNegative && hasValue ? '-$displayValue' : displayValue,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: hasValue
                ? (widget.isNegative ? AppConstants.onSecondaryContainer : AppConstants.onPrimaryContainer)
                : AppConstants.onSurfaceVariant.withValues(alpha: 0.5),
            ),
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
    // Alternate card backgrounds per design: even = white, odd = surfaceContainerLow
    final bgColor = widget.playerIndex.isEven
        ? AppConstants.surfaceContainerLowest
        : AppConstants.surfaceContainerLow;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        ),
        child: Row(
          children: [
            // Left: avatar + name
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(child: _buildPlayerInfo()),
            // Right: total score + score entry
            _buildScoreDisplay(),
            const SizedBox(width: 16),
            _buildScoreEntry(),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    final bgColor = widget.playerIndex.isEven
        ? AppConstants.surfaceContainerLowest
        : AppConstants.surfaceContainerLow;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 10),
              Expanded(child: _buildPlayerInfo()),
              _buildScoreDisplay(),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: _buildScoreEntry(),
          ),
        ],
      ),
    );
  }
}
