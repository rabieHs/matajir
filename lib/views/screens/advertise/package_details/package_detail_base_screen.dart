import 'package:flutter/material.dart';
import 'package:matajir/constants/app_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PackageDetailBaseScreen extends StatefulWidget {
  final String title;
  final String price;
  final String description;
  final IconData icon;
  final List<String> features;
  final Widget customContent;
  final VoidCallback onSubscribe;

  const PackageDetailBaseScreen({
    super.key,
    required this.title,
    required this.price,
    required this.description,
    required this.icon,
    required this.features,
    required this.customContent,
    required this.onSubscribe,
  });

  @override
  State<PackageDetailBaseScreen> createState() =>
      _PackageDetailBaseScreenState();
}

class _PackageDetailBaseScreenState extends State<PackageDetailBaseScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF673AB7), Color(0xFF311B92)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                pinned: true,
                floating: true,
                snap: false,
                expandedHeight: 120.0,
                collapsedHeight: 60.0,
                automaticallyImplyLeading: false,
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    // Calculate the percentage of expansion (1.0 = fully expanded, 0.0 = collapsed)
                    final double expandRatio = ((constraints.maxHeight - 60.0) /
                            (120.0 - 60.0))
                        .clamp(0.0, 1.0);

                    return FlexibleSpaceBar(
                      background: Stack(
                        children: [
                          // Back button that fades out when scrolling
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 8,
                            left: 16.0,
                            child: Opacity(
                              opacity: expandRatio,
                              child: GestureDetector(
                                onTap:
                                    expandRatio > 0.5
                                        ? () {
                                          Navigator.pop(context);
                                        }
                                        : null,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(26),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back,
                                    color: Color(0xFF673AB7),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Title in the center when collapsed
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 16,
                            left: 0,
                            right: 0,
                            child: Opacity(
                              opacity: 1.0 - expandRatio,
                              child: Center(
                                child: Text(
                                  widget.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Package Header Card
                      Card(
                        elevation: 8,
                        shadowColor: Colors.black.withAlpha(76),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(26),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Package name with icon
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor.withAlpha(
                                        30,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      widget.icon,
                                      color: AppColors.primaryColor,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.title,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF673AB7),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          widget.price,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.accentColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Description
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  widget.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Features Card
                      Card(
                        elevation: 8,
                        shadowColor: Colors.black.withAlpha(76),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(26),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Features header
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_outline,
                                    size: 20,
                                    color: Color(0xFF673AB7),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    localizations.features,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF673AB7),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Features list
                              ...widget.features.asMap().entries.map((entry) {
                                final index = entry.key;
                                final feature = entry.value;
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: AppColors.primaryColor,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              feature,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (index < widget.features.length - 1)
                                      const Divider(
                                        color: Colors.black12,
                                        height: 1,
                                      ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Custom content
                      widget.customContent,

                      const SizedBox(height: 24),

                      // Subscribe button
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.buttonPrimary.withAlpha(76),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.onSubscribe,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.shopping_cart_outlined,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                localizations.subscribeNow,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
