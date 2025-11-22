import 'package:flutter/material.dart';
import 'package:couldai_user_app/models/mold_models.dart';

class MoldDetailScreen extends StatefulWidget {
  final Mold mold;

  const MoldDetailScreen({super.key, required this.mold});

  @override
  State<MoldDetailScreen> createState() => _MoldDetailScreenState();
}

class _MoldDetailScreenState extends State<MoldDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.mold.sides.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showInsertDetails(InsertPosition position) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Insert Position: ${position.id}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Insert: ${position.currentInsertId}', 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text('Initial Insert: ${position.initialInsertId}'),
              const SizedBox(height: 16),
              const Text('Change History:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              if (position.history.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No changes recorded.'),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: position.history.length,
                    itemBuilder: (context, index) {
                      final change = position.history[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Replaced with: ${change.insertId}'), 
                        subtitle: Text('${change.date.toString().split('.')[0]}\nReason: ${change.reason}'),
                        isThreeLine: true,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _showReplaceDialog(position);
            },
            child: const Text('Replace Insert'),
          ),
        ],
      ),
    );
  }

  void _showReplaceDialog(InsertPosition position) {
    final idController = TextEditingController();
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Replace Insert'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: idController,
                decoration: const InputDecoration(labelText: 'New Insert ID'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(labelText: 'Reason for change'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  position.replaceInsert(idController.text, reasonController.text);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Save Change'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mold.name),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: widget.mold.sides.map((s) => Tab(text: s.name)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: widget.mold.sides.map((side) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('${side.rows} x ${side.columns} Grid', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: side.columns,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: widget.mold.insertType == InsertBlockType.double ? 0.8 : 1.0, 
                    ),
                    itemCount: side.positions.length,
                    itemBuilder: (context, index) {
                      final pos = side.positions[index];
                      final isChanged = pos.isChanged;
                      
                      return InkWell(
                        onTap: () => _showInsertDetails(pos),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isChanged ? Colors.orange.shade100 : Colors.grey.shade200,
                            border: Border.all(
                              color: isChanged ? Colors.orange : Colors.grey,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isChanged ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                                color: isChanged ? Colors.orange : Colors.green,
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text(
                                  pos.currentInsertId,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.mold.insertType == InsertBlockType.double)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4.0),
                                  child: Text('(2 Cavities)', style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
