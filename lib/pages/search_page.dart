import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash/widgets/stash_item_card.dart';
import 'package:stash/data/repos/stash_repo.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(stashSearchProvider(_query));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Hero(
          tag: 'search-bar',
          child: Material(
            type: MaterialType.transparency,
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search your stash...',
                border: InputBorder.none,
              ),
              onChanged: (query) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  setState(() {
                    _query = query;
                  });
                });
              },
            ),
          ),
        ),
      ),
      body: searchResults.when(
        data: (items) {
          if (_query.isEmpty) {
            return const Center(child: Text('Start typing to search.'));
          }
          if (items.isEmpty) {
            return const Center(child: Text('No results found.'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return StashItemCard(stashItem: item);
            },
          );
        },
        error: (err, stackTrace) {
          return Center(child: Text('An error occurred: $err'));
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
