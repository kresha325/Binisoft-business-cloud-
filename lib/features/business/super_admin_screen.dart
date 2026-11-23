import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});
  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> {
  final name = TextEditingController();
  final ownerUid = TextEditingController();
  String type = 'restaurant';
  bool saving = false;
  String? error;

  @override
  void dispose() {
    name.dispose();
    ownerUid.dispose();
    super.dispose();
  }

  Future<void> addBusiness() async {
    final title = name.text.trim();
    final uid = ownerUid.text.trim();
    if (title.isEmpty || uid.isEmpty) {
      setState(() => error = 'Shkruaj emrin dhe UID e pronarit.');
      return;
    }
    setState(() { saving = true; error = null; });
    try {
      final db = FirebaseFirestore.instance;
      final owner = await db.collection('users').doc(uid).get();
      if (!owner.exists || owner.data()?['role'] != 'pending') {
        throw StateError('Pronari duhet të ketë profil ekzistues me status pending.');
      }
      final businessRef = db.collection('businesses').doc();
      final batch = db.batch();
      batch.set(businessRef, {
        'name': title,
        'type': type,
        'ownerId': uid,
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.update(db.collection('users').doc(uid), {
        'role': 'owner',
        'businessId': businessRef.id,
      });
      await batch.commit();
      name.clear();
      ownerUid.clear();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void openAddBusiness() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, refresh) => AlertDialog(
          title: const Text('Regjistro biznes të ri'),
          content: SizedBox(width: 380, child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: name, decoration: const InputDecoration(
                labelText: 'Emri i biznesit')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Industria'),
                items: const [
                  DropdownMenuItem(value: 'restaurant', child: Text('Restorant / Kafene')),
                  DropdownMenuItem(value: 'shop', child: Text('Dyqan')),
                  DropdownMenuItem(value: 'salon', child: Text('Sallon / Shërbime')),
                  DropdownMenuItem(value: 'hotel', child: Text('Hotel')),
                  DropdownMenuItem(value: 'other', child: Text('Tjetër')),
                ],
                onChanged: (v) => refresh(() => type = v ?? 'other'),
              ),
              const SizedBox(height: 12),
              TextField(controller: ownerUid, decoration: const InputDecoration(
                labelText: 'UID e llogarisë së pronarit')),
              if (error != null) Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),
            ]),
          )),
          actions: [
            TextButton(onPressed: saving ? null : () => Navigator.pop(dialogContext),
              child: const Text('Anulo')),
            FilledButton(onPressed: saving ? null : () async {
              await addBusiness();
              if (context.mounted) refresh(() {});
            }, child: Text(saving ? 'Duke ruajtur...' : 'Krijo biznesin')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Binisoft • Super Admin'),
        actions: [IconButton(
          tooltip: 'Dil', onPressed: () => FirebaseAuth.instance.signOut(),
          icon: const Icon(Icons.logout_outlined),
        )],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddBusiness, icon: const Icon(Icons.add),
        label: const Text('Biznes i ri')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('businesses')
          .orderBy('createdAt', descending: true).limit(30).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Gabim: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          return Center(child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 950),
            child: ListView(padding: const EdgeInsets.all(20), children: [
              Text('Bizneset', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text('${docs.length} të shfaqura · deri në 30 për këtë version'),
              const SizedBox(height: 20),
              if (docs.isEmpty) const Card(child: Padding(
                padding: EdgeInsets.all(24), child: Text('Nuk ka ende biznese.'))),
              for (final doc in docs) Card(child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.storefront_outlined)),
                title: Text(doc.data()['name']?.toString() ?? 'Biznes'),
                subtitle: Text('${doc.data()['type']} • UID: ${doc.data()['ownerId']}'),
                trailing: Icon(doc.data()['active'] == true
                  ? Icons.check_circle_outline : Icons.pause_circle_outline),
              )),
            ]),
          ));
        },
      ),
    );
  }
}
