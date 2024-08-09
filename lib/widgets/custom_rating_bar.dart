import 'package:flutter/material.dart';

class CustomRatingBar extends StatefulWidget {
  final double initialRating;
  final Function(double) onRatingUpdate;
  final int itemCount;
  final double itemSize;
  final Color unratedColor;
  final Color ratedColor;

  // ignore: use_super_parameters
  const CustomRatingBar({
    Key? key,
    required this.initialRating,
    required this.onRatingUpdate,
    this.itemCount = 5,
    this.itemSize = 40.0,
    this.unratedColor = Colors.grey,
    this.ratedColor = Colors.amber,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CustomRatingBarState createState() => _CustomRatingBarState();
}

class _CustomRatingBarState extends State<CustomRatingBar> {
  late double rating;

  @override
  void initState() {
    super.initState();
    rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.itemCount, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              rating = index + 1.0;
            });
            widget.onRatingUpdate(rating);
          },
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            size: widget.itemSize,
            color: index < rating ? widget.ratedColor : widget.unratedColor,
          ),
        );
      }),
    );
  }
}
