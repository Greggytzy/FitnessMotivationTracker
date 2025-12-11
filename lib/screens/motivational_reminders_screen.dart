import 'package:flutter/material.dart';
import '../models/quote.dart';
import '../services/storage_service.dart';

class MotivationalRemindersScreen extends StatefulWidget {
  const MotivationalRemindersScreen({super.key});

  @override
  State<MotivationalRemindersScreen> createState() =>
      _MotivationalRemindersScreenState();
}

class _MotivationalRemindersScreenState
    extends State<MotivationalRemindersScreen>
    with SingleTickerProviderStateMixin {
  List<Quote> _quotes = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadQuotes() async {
    final quotes = await StorageService.getQuotes();
    setState(() {
      _quotes = quotes;
    });
  }

  Future<void> _addQuote() async {
    final result = await showDialog<Quote>(
      context: context,
      builder: (context) => const AddQuoteDialog(),
    );

    if (result != null) {
      await StorageService.addQuote(result);
      await _loadQuotes();
    }
  }

  Future<void> _toggleFavorite(Quote quote) async {
    final updatedQuote = Quote(
      id: quote.id,
      text: quote.text,
      author: quote.author,
      isFavorite: !quote.isFavorite,
      dateAdded: quote.dateAdded,
    );
    await StorageService.updateQuote(updatedQuote);
    await _loadQuotes();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteQuotes = _quotes.where((q) => q.isFavorite).toList();
    final recentQuotes = _quotes.where((q) => !q.isFavorite).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Motivational Reminders')),
      body: _quotes.isEmpty
          ? const Center(
              child: Text('No quotes yet. Add your first motivational quote!'),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Daily Quote
                  if (_quotes.isNotEmpty) ...[
                    const Text(
                      'Quote of the Day',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Text(
                                _quotes.first.text,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '- ${_quotes.first.author}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        _toggleFavorite(_quotes.first),
                                    icon: Icon(
                                      _quotes.first.isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: _quotes.first.isFavorite
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Favorite Quotes
                  if (favoriteQuotes.isNotEmpty) ...[
                    const Text(
                      'Favorite Quotes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: favoriteQuotes.length,
                      itemBuilder: (context, index) {
                        final quote = favoriteQuotes[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(quote.text),
                            subtitle: Text('- ${quote.author}'),
                            trailing: IconButton(
                              onPressed: () => _toggleFavorite(quote),
                              icon: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],

                  // All Quotes
                  const Text(
                    'All Quotes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentQuotes.length,
                    itemBuilder: (context, index) {
                      final quote = recentQuotes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(quote.text),
                          subtitle: Text('- ${quote.author}'),
                          trailing: IconButton(
                            onPressed: () => _toggleFavorite(quote),
                            icon: Icon(
                              quote.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: quote.isFavorite
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addQuote,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddQuoteDialog extends StatefulWidget {
  const AddQuoteDialog({super.key});

  @override
  State<AddQuoteDialog> createState() => _AddQuoteDialogState();
}

class _AddQuoteDialogState extends State<AddQuoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _authorController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Motivational Quote'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _textController,
                decoration: const InputDecoration(labelText: 'Quote Text'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quote text';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Author'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter author name';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final quote = Quote(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                text: _textController.text,
                author: _authorController.text,
                dateAdded: DateTime.now(),
              );
              Navigator.of(context).pop(quote);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
