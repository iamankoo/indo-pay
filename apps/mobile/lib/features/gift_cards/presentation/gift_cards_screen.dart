import "package:flutter/material.dart";

import "../../../design_system/widgets/fintech_icon.dart";
import "../../../design_system/widgets/glass_card.dart";
import "../../../design_system/widgets/indo_pay_backdrop.dart";

class GiftCardsScreen extends StatelessWidget {
  const GiftCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brands = const ["Amazon", "Flipkart", "Myntra"];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Gift Cards"),
        backgroundColor: Colors.transparent,
      ),
      body: IndoPayBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: brands
              .map(
                (brand) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(brand),
                      subtitle: const Text("Wallet + UPI split supported"),
                      trailing: const FintechIcon(
                        FintechIconGlyph.chevronRight,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
