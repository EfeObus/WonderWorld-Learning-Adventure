import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class LetterCanvas extends StatefulWidget {
  final String letter;
  
  const LetterCanvas({
    super.key,
    required this.letter,
  });

  @override
  State<LetterCanvas> createState() => LetterCanvasState();
}

class LetterCanvasState extends State<LetterCanvas> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];

  void clear() {
    setState(() {
      _strokes.clear();
      _currentStroke = [];
    });
  }

  int getAccuracy() {
    // Simplified accuracy check - counts points within letter bounds
    if (_strokes.isEmpty) return 0;
    
    int totalPoints = 0;
    int pointsInsideLetter = 0;
    
    for (final stroke in _strokes) {
      for (final point in stroke) {
        totalPoints++;
        // Simplified - just check if point is within center area
        // Real implementation would compare to letter path
        if (point.dx > 50 && point.dx < 250 && point.dy > 50 && point.dy < 300) {
          pointsInsideLetter++;
        }
      }
    }
    
    if (totalPoints == 0) return 0;
    return ((pointsInsideLetter / totalPoints) * 100).toInt();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.literacyColor.withOpacity(0.3),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.literacyColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          children: [
            // Guide letter
            Center(
              child: Text(
                widget.letter,
                style: TextStyle(
                  fontSize: 280,
                  fontWeight: FontWeight.w300,
                  color: AppTheme.literacyColor.withOpacity(0.15),
                  fontFamily: 'Nunito',
                ),
              ),
            ),
            
            // Dotted letter outline
            Center(
              child: CustomPaint(
                painter: DottedLetterPainter(
                  letter: widget.letter,
                  color: AppTheme.literacyColor.withOpacity(0.4),
                ),
              ),
            ),
            
            // Drawing area
            GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _currentStroke = [details.localPosition];
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  _currentStroke.add(details.localPosition);
                });
              },
              onPanEnd: (details) {
                setState(() {
                  _strokes.add(List.from(_currentStroke));
                  _currentStroke = [];
                });
              },
              child: CustomPaint(
                painter: DrawingPainter(
                  strokes: _strokes,
                  currentStroke: _currentStroke,
                ),
                size: Size.infinite,
              ),
            ),
            
            // Helper text
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Text(
                'Trace the letter with your finger',
                style: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.5),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;

  DrawingPainter({
    required this.strokes,
    required this.currentStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryColor
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Draw completed strokes
    for (final stroke in strokes) {
      if (stroke.length > 1) {
        final path = Path();
        path.moveTo(stroke.first.dx, stroke.first.dy);
        for (int i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }

    // Draw current stroke
    if (currentStroke.length > 1) {
      final path = Path();
      path.moveTo(currentStroke.first.dx, currentStroke.first.dy);
      for (int i = 1; i < currentStroke.length; i++) {
        path.lineTo(currentStroke[i].dx, currentStroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return true;
  }
}

class DottedLetterPainter extends CustomPainter {
  final String letter;
  final Color color;

  DottedLetterPainter({
    required this.letter,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Simplified - in production would draw dotted path of letter
    // Using TextPainter for the letter outline
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontSize: 280,
          fontWeight: FontWeight.w400,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = color,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );
    
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant DottedLetterPainter oldDelegate) {
    return letter != oldDelegate.letter || color != oldDelegate.color;
  }
}
