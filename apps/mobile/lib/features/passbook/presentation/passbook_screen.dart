import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../design_system/indo_pay_colors.dart";
import "../../../design_system/indo_pay_typography.dart";
import "../../../design_system/widgets/fintech_icon.dart";
import "../../../design_system/widgets/fintech_shimmer.dart";
import "../../../design_system/widgets/glass_card.dart";
import "../../../design_system/widgets/indo_pay_backdrop.dart";
import "../data/passbook_repository.dart";
import "../domain/passbook_page.dart";

class PassbookScreen extends ConsumerStatefulWidget {
  const PassbookScreen({super.key});

  @override
  ConsumerState<PassbookScreen> createState() => _PassbookScreenState();
}

class _PassbookScreenState extends ConsumerState<PassbookScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<PassbookEntry> _items = <PassbookEntry>[];
  String? _selectedFilter;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  bool _exporting = false;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _loading = true;
      _items.clear();
      _page = 1;
    });

    final page = await ref.read(passbookRepositoryProvider).fetchPassbook(
          page: 1,
          category: _selectedFilter,
        );
    setState(() {
      _loading = false;
      _hasMore = page.hasMore;
      _page = page.nextPage ?? 1;
      _items.addAll(page.items);
    });
  }

  Future<void> _maybeLoadMore() async {
    if (!_hasMore || _loadingMore || !_scrollController.hasClients) {
      return;
    }

    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels < threshold) {
      return;
    }

    setState(() => _loadingMore = true);
    final page = await ref.read(passbookRepositoryProvider).fetchPassbook(
          page: _page,
          category: _selectedFilter,
        );
    setState(() {
      _loadingMore = false;
      _hasMore = page.hasMore;
      _page = page.nextPage ?? _page;
      _items.addAll(page.items);
    });
  }

  Future<void> _exportStatement() async {
    setState(() => _exporting = true);
    try {
      final now = DateTime.now();
      final fileUrl = await ref.read(passbookRepositoryProvider).exportStatement(
            fromDate: DateTime(now.year, now.month, 1),
            toDate: now,
          );
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            fileUrl.isEmpty ? "Statement export created." : "Statement ready: $fileUrl",
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Export failed: $error")),
      );
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const filters = <String>["RECHARGE", "CASHBACK", "QR_PAYMENT", "IMPS", "NEFT", "RTGS"];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Passbook"),
        backgroundColor: Colors.transparent,
      ),
      body: IndoPayBackdrop(
        child: RefreshIndicator(
          onRefresh: _loadInitial,
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: filters
                    .map(
                      (filter) => ChoiceChip(
                        label: Text(filter.replaceAll("_", " ")),
                        selected: _selectedFilter == filter,
                        onSelected: (_) {
                          setState(() {
                            _selectedFilter = _selectedFilter == filter ? null : filter;
                          });
                          _loadInitial();
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  onPressed: _exporting ? null : _exportStatement,
                  icon: const FintechIcon(
                    FintechIconGlyph.passbook,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: Text(_exporting ? "Exporting..." : "Export statement"),
                ),
              ),
              const SizedBox(height: 16),
              if (_loading)
                const Column(
                  children: [
                    FintechShimmer(height: 100),
                    SizedBox(height: 12),
                    FintechShimmer(height: 100),
                    SizedBox(height: 12),
                    FintechShimmer(height: 100),
                  ],
                )
              else if (_items.isEmpty)
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("No entries", style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      const Text("Payments will appear here."),
                    ],
                  ),
                )
              else
                ..._items.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: entry.direction == "credit"
                                  ? const Color(0x141BA97C)
                                  : const Color(0x14E04F5F),
                              child: FintechIcon(
                                entry.direction == "credit"
                                    ? FintechIconGlyph.credit
                                    : FintechIconGlyph.debit,
                                color: entry.direction == "credit"
                                    ? IndoPayColors.success
                                    : IndoPayColors.danger,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(entry.type.replaceAll("_", " ").toUpperCase()),
                                  const SizedBox(height: 4),
                                  Text(entry.referenceLabel ?? entry.status ?? "Recorded"),
                                ],
                              ),
                            ),
                            Text(
                              "INR ${entry.amount}",
                              style: IndoPayTypography.mono(
                                size: 13,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              if (_loadingMore)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
