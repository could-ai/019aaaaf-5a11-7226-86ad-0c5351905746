import 'package:flutter/material.dart';
import 'package:couldai_user_app/models/mold_models.dart';
import 'package:couldai_user_app/screens/create_mold_screen.dart';
import 'package:couldai_user_app/screens/mold_detail_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mold Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final molds = MoldRepository().molds;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Injection Mold Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: molds.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.precision_manufacturing_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No molds configured yet.',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text('Tap the + button to add a mold.'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: molds.length,
              itemBuilder: (context, index) {
                final mold = molds[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(mold.type == MoldType.type1K ? '1K' : '2K'),
                    ),
                    title: Text(mold.name),
                    subtitle: Text('${mold.insertType == InsertBlockType.single ? "Single" : "Double"} Block Inserts'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MoldDetailScreen(mold: mold),
                        ),
                      ).then((_) => setState(() {})); // Refresh on return
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateMoldScreen()),
          ).then((_) => setState(() {}));
        },
        label: const Text('Add Mold'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
