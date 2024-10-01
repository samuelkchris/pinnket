import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/pass_model.dart';
import '../../services/pass_service.dart';
import '../../widgets/avator.dart';
import '../../widgets/blurcontainer.dart';
import '../../widgets/text.dart';
import '../app/main_screen.dart';

class PassScreen extends StatelessWidget {
  final String tagCode;

  const PassScreen({
    super.key,
    required this.tagCode,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    String formatDate(String dateStr) {
      try {
        DateTime parsedDate = DateTime.parse(dateStr);
        print("dateStr: $dateStr");
        print("parsedDate: $parsedDate");
        return DateFormat('d MMMM, y').format(parsedDate);
      } catch (e) {
        print("Error parsing date: $e");
        return "Invalid date:$dateStr";
      }
    }

    final PassService passService = PassService();
    return MainScreen(showSearchFAB: false, bodySliver: [
      SliverToBoxAdapter(
          child: Container(
              padding: const EdgeInsets.all( 20,),
              width: 300,
              height: 500,
              child: FutureBuilder<PassInfo>(
                future: passService.validatePass(tagCode),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildShimmerLoader(context);
                  } else if (snapshot.hasError) {
                    final Size size = MediaQuery.of(context).size;

                    final String message = snapshot.error.toString();

                    return Center(
                      child: Column(
                        children: [
                          Lottie.asset(
                            'assets/lottie/nothing.json',
                            width: size.width * 0.5,
                            height: size.height * 0.5,
                          ),
                          Text(
                            message,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    );
                  } else {
                    final snapshotData = snapshot.data;
                    print("data:${snapshotData?.name}");
                    return Center(
                      child: BlurryContainer(
                        color: theme.colorScheme.surface.withOpacity(0.15),
                        blur: 30,
                        elevation: 6,
                        height: 500,
                        width: 310,
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 50,
                          bottom: 20,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const SizedBox(height: 10),
                            NameText(
                              themeData: theme,
                              text: snapshotData!.event!.name!,
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 10),
                            NameText(
                              themeData: theme,
                              text: snapshotData.event!.eventdescription!,
                              style: theme.textTheme.bodySmall,
                            ),
                            AvatarWidget(
                              width: 100,
                              height: 100,
                              imagePath: snapshot.data!.face ?? "",
                            ),
                            const SizedBox(height: 10),
                            buildNameRow(
                              context,
                              'Name:',
                              [
                                TextSpan(
                                  text: snapshot.data!.name,
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                              Iconsax.user,
                            ),
                            const SizedBox(height: 10),
                            buildNameRow(
                              context,
                              'Valid Through:',
                              [
                                TextSpan(
                                  text: formatDate(
                                      snapshot.data!.event!.endtime!),
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                              Iconsax.calendar,
                            ),
                            const SizedBox(height: 10),
                            buildNameRow(
                              context,
                              'Category:',
                              [
                                TextSpan(
                                  text: snapshot.data!.eventPassCategory?.name,
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                              Iconsax.category,
                            ),
                            const SizedBox(height: 10),
                            buildNameRow(
                              context,
                              'Access Type:',
                              snapshot
                                  .data!.eventPassCategory!.passCategoryZones
                                  .where((zone) => zone.pstate)
                                  .map((zone) => TextSpan(
                                        text: zone.eventZone.name +
                                            (zone ==
                                                    snapshot
                                                        .data!
                                                        .eventPassCategory
                                                        ?.passCategoryZones
                                                        .last
                                                ? ''
                                                : ', '),
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: snapshot.data!.pstatus ?? false
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.error,
                                        ),
                                      ))
                                  .toList(),
                              Iconsax.key,
                            ),
                            const SizedBox(height: 10),
                            buildNameRow(
                              context,
                              'Status:',
                              [
                                TextSpan(
                                  text: snapshot.data!.pstatus ?? false
                                      ? 'Active'
                                      : 'Inactive',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: snapshot.data!.pstatus ?? false
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.error,
                                  ),
                                )
                              ],
                              Iconsax.status,
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(),
                              child: SizedBox(
                                width: 900,
                                height: 50,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: SfBarcodeGenerator(
                                    textAlign: TextAlign.justify,
                                    value:
                                        'http://c.pinnitags.com/pass/verify/$tagCode',
                                    symbology: Code128B(module: 3),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              tagCode,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              )))
    ]);
  }

  Widget buildNameRow(BuildContext context, String text1,
      List<TextSpan> textSpans, IconData icon,
      {TextStyle? style}) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon,
            size: 24,
            color: theme.iconTheme.color,
          ),
          const SizedBox(width: 10),
          NameText(
            themeData: theme,
            text: text1,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: textSpans,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildShimmerLoader(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Shimmer.fromColors(
        baseColor: theme.colorScheme.surface,
        highlightColor: theme.colorScheme.onSurface.withOpacity(0.1),
        child: BlurryContainer(
          color: theme.colorScheme.surface.withOpacity(0.15),
          blur: 30,
          elevation: 6,
          height: 500,
          width: 310,
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 50,
            bottom: 20,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 10),
              Container(
                width: 200,
                height: 20,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Container(
                width: 150,
                height: 15,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 20),
              ...List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 200,
                        height: 15,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 250,
                height: 50,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Container(
                width: 100,
                height: 15,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
