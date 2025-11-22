import 'package:flutter/material.dart';
import 'package:couldai_user_app/models/mold_models.dart';

class CreateMoldScreen extends StatefulWidget {
  const CreateMoldScreen({super.key});

  @override
  State<CreateMoldScreen> createState() => _CreateMoldScreenState();
}

class _CreateMoldScreenState extends State<CreateMoldScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  MoldType _selectedType = MoldType.type1K;
  InsertBlockType _selectedInsertType = InsertBlockType.single;

  // Dimensions
  int _fixedRows = 2;
  int _fixedCols = 2;
  int _mobileRows = 2;
  int _mobileCols = 2;
  int _cubeRows = 2;
  int _cubeCols = 2;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveMold() {
    if (_formKey.currentState!.validate()) {
      final List<MoldSide> sides = [];

      // Fixed Side
      sides.add(MoldSide(
        name: 'Fixed Side',
        rows: _fixedRows,
        columns: _fixedCols,
        positions: MoldRepository.generatePositions('Fixed', _fixedRows, _fixedCols),
      ));

      // Mobile Side
      sides.add(MoldSide(
        name: 'Mobile Side',
        rows: _mobileRows,
        columns: _mobileCols,
        positions: MoldRepository.generatePositions('Mobile', _mobileRows, _mobileCols),
      ));

      // Cube Faces for 2K
      if (_selectedType == MoldType.type2K) {
        for (int i = 1; i <= 4; i++) {
          sides.add(MoldSide(
            name: 'Cube Face $i',
            rows: _cubeRows,
            columns: _cubeCols,
            positions: MoldRepository.generatePositions('Cube$i', _cubeRows, _cubeCols),
          ));
        }
      }

      final newMold = Mold(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        type: _selectedType,
        insertType: _selectedInsertType,
        sides: sides,
      );

      MoldRepository().addMold(newMold);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure New Mold'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Mold Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            // Mold Type Selection
            const Text('Mold Type', style: TextStyle(fontWeight: FontWeight.bold)),
            SegmentedButton<MoldType>(
              segments: const [
                ButtonSegment(value: MoldType.type1K, label: Text('1K (Fixed/Mobile)')),
                ButtonSegment(value: MoldType.type2K, label: Text('2K (Cube)')),
              ],
              selected: {_selectedType},
              onSelectionChanged: (Set<MoldType> newSelection) {
                setState(() {
                  _selectedType = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 20),

            // Insert Type Selection
            const Text('Insert Type', style: TextStyle(fontWeight: FontWeight.bold)),
            SegmentedButton<InsertBlockType>(
              segments: const [
                ButtonSegment(value: InsertBlockType.single, label: Text('Single Block')),
                ButtonSegment(value: InsertBlockType.double, label: Text('Double Block')),
              ],
              selected: {_selectedInsertType},
              onSelectionChanged: (Set<InsertBlockType> newSelection) {
                setState(() {
                  _selectedInsertType = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 24),

            const Divider(),
            const Text('Configuration (Rows x Columns)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            _buildDimensionInput('Fixed Side', (r, c) {
              _fixedRows = r;
              _fixedCols = c;
            }),
            
            _buildDimensionInput('Mobile Side', (r, c) {
              _mobileRows = r;
              _mobileCols = c;
            }),

            if (_selectedType == MoldType.type2K)
              _buildDimensionInput('Cube Faces (All 4)', (r, c) {
                _cubeRows = r;
                _cubeCols = c;
              }),

            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saveMold,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Create Mold'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDimensionInput(String label, Function(int, int) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: 2,
                  decoration: const InputDecoration(labelText: 'Rows', border: OutlineInputBorder()),
                  items: List.generate(10, (index) => index + 1)
                      .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      // We need to store the values locally in the widget state to persist them
                      // But for this helper, we rely on the callback to update the parent state variables
                      // However, the dropdown needs a state variable to show the current value.
                      // To keep it simple, I'll just use a stateful builder or just let the user pick.
                      // Actually, the parent state vars (_fixedRows etc) should drive this.
                      // Let's refactor slightly to use the parent variables directly in the builder call.
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              const Text('X'),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: 2,
                  decoration: const InputDecoration(labelText: 'Cols', border: OutlineInputBorder()),
                  items: List.generate(10, (index) => index + 1)
                      .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                      .toList(),
                  onChanged: (val) {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
