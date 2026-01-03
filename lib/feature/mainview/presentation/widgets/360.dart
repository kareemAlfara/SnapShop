import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/core/utils/components.dart';
import 'package:shop_app/feature/mainview/domain/entities/productEntity.dart';
import 'package:shop_app/feature/mainview/presentation/pages/review_list_page.dart';

import '../cubit/product_cubit/product_cubit.dart';

class ProductView360 extends StatefulWidget {
  const ProductView360({
    Key? key,
    required this.imageUrl,
    required this.product,
  }) : super(key: key);
  final String imageUrl;
  final ProductEntity product;
  @override
  State<ProductView360> createState() => _ProductView360State();
}

class _ProductView360State extends State<ProductView360>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isAutoRotating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleAutoRotation() {
    setState(() {
      isAutoRotating = !isAutoRotating;
      if (isAutoRotating) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onPanUpdate: (details) {
            // Manual rotation with finger drag
            setState(() {
              _controller.value += details.delta.dx / 500;
            });
          },
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // perspective
                  ..rotateY(_controller.value * 2 * 3.14159),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: screensize(context).width * 0.7,
                    height: screensize(context).width * 0.8,
                    decoration: BoxDecoration(
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black.withOpacity(0.2),
                      //     blurRadius: 20,
                      //     offset: const Offset(0, 10),
                      //   ),
                      // ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),

                      child: Image.network(
                        widget.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.error_outline,
                              size: 50,
                              color: Colors.red,
                            ),
                          );
                        },
                        // loadingBuilder: (context, child, loadingProgress) {
                        //   if (loadingProgress == null) return child;
                        //   return Center(
                        //     child: CircularProgressIndicator(
                        //       value: loadingProgress.expectedTotalBytes != null
                        //           ? loadingProgress.cumulativeBytesLoaded /
                        //                 loadingProgress.expectedTotalBytes!
                        //           : null,
                        //     ),
                        //   );
                        // },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              onPressed: toggleAutoRotation,
              icon: Icon(isAutoRotating ? Icons.pause : Icons.play_arrow),
              label: Text(isAutoRotating ? 'Pause' : 'Auto Rotate'),

              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(fontSize: 13),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            // ElevatedButton.icon(
            //   onPressed: () {
            //     navigat(context, widget: ReviewListPage(product: widget.product));
            //   },
            //   icon: Icon(Icons.rate_review_outlined,size: 25 ,),
            //   label: Text("Add Review"),
            //   style: ElevatedButton.styleFrom(
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 24,
            //       vertical: 12,
            //     ),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(30),
            //     ),
            //   ),
            // ),
            ElevatedButton.icon(
              onPressed: () async {
                // Navigate and wait for result
                final needsRefresh = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReviewListPage(product: widget.product),
                  ),
                );

                // If reviews were updated, refresh the product list
                if (needsRefresh == true && mounted) {
                  // Call your product cubit to reload products
                  context
                      .read<ProductCubit>()
                      .getproducts(); // Or whatever your method is called
                }
              },
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    widget.product.avgRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              label: Text("(${widget.product.reviewCount} reviews)",style: const TextStyle(fontSize: 13),),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),)
            ],
        ),

        const SizedBox(height: 10),
      ],
    );
  }
}
