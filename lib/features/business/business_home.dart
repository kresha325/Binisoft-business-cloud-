import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../dashboard/dashboard_screen.dart';
import '../catalog/catalog_screen.dart';
import 'super_admin_screen.dart';

/// Server-authorized admin status is determined by an immutable Firestore doc,
/// never by an email address or a client-editable role.
class BusinessHome extends StatelessWidget {
  const BusinessHome({super.key, this.showCatalog = false});
  final bool showCatalog;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final db = FirebaseFirestore.instance;
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: db.collection('platformAdmins').doc(user.uid).snapshots(),
      builder: (context, admin) {
        if (admin.hasError) return _ErrorState(error: admin.error);
        if (!admin.hasData) return const _Loading();
        if (admin.data!.exists && admin.data!.data()?['enabled'] == true) {
          return const SuperAdminScreen();
        }
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: db.collection('users').doc(user.uid).snapshots(),
          builder: (context, profile) {
            if (profile.hasError) return _ErrorState(error: profile.error);
            if (!profile.hasData) return const _Loading();
            if (!profile.data!.exists) return _PendingScreen(user: user, missingProfile: true);
            final data = profile.data!.data()!;
            if (data['role'] == 'owner' && (data['businessId'] as String? ?? '').isNotEmpty) {
              return showCatalog ? const CatalogScreen() : const DashboardScreen();
            }
            return _PendingScreen(user: user, missingProfile: false);
          },
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({this.error});
  final Object? error;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Binisoft Business Cloud')),
    body: Center(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text('Nuk u lexuan të dhënat. Aktivizo Firestore dhe publiko rregullat e sigurisë.\n\n$error',
        textAlign: TextAlign.center),
    )),
  );
}

class _PendingScreen extends StatefulWidget {
  const _PendingScreen({required this.user, required this.missingProfile});
  final User user;
  final bool missingProfile;
  @override
  State<_PendingScreen> createState() => _PendingScreenState();
}

class _PendingScreenState extends State<_PendingScreen> {
  bool working = false;
  bool checkingAdmin = false;
  String? error;
  String? adminDiagnostic;

  Future<void> diagnoseAdmin() async {
    if (checkingAdmin) return;
    setState(() { checkingAdmin = true; adminDiagnostic = null; });
    final projectId = Firebase.app().options.projectId;
    final uid = widget.user.uid;
    final path = 'platformAdmins/$uid';
    try {
      // Force a server read to distinguish a missing document from stale cache.
      final doc = await FirebaseFirestore.instance
          .collection('platformAdmins').doc(uid)
          .get(const GetOptions(source: Source.server));
      final enabled = doc.data()?['enabled'];
      if (!mounted) return;
      setState(() {
        adminDiagnostic = 'Firebase project: $projectId\n'
            'Authenticated UID: $uid\n'
            'Document path: $path\n'
            'Server document exists: ${doc.exists}\n'
            'enabled: ${doc.exists ? enabled : 'not found'}\n'
            'Source: Firestore server\n'
            '${doc.exists && enabled == true ? 'Admin document is valid. Refresh or sign in again.' : 'Check the document ID and enabled field in this project.'}';
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() => adminDiagnostic =
          'Firebase project: $projectId\nDocument path: $path\n'
          'Server error: ${e.code}\n${e.message ?? ''}');
    } catch (e) {
      if (!mounted) return;
      setState(() => adminDiagnostic =
          'Firebase project: $projectId\nDocument path: $path\nError: $e');
    } finally {
      if (mounted) setState(() => checkingAdmin = false);
    }
  }

  Future<void> createProfile() async {
    setState(() { working = true; error = null; });
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).set({
        'email': widget.user.email,
        'role': 'pending',
        'businessId': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => working = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Binisoft Business Cloud'), actions: [
      IconButton(tooltip: 'Dil', onPressed: () => FirebaseAuth.instance.signOut(),
        icon: const Icon(Icons.logout)),
    ]),
    body: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: SingleChildScrollView(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.verified_user_outlined, size: 54, color: Color(0xFF6557F5)),
          const SizedBox(height: 20),
          Text(widget.missingProfile ? 'Përfundo regjistrimin' : 'Llogaria në pritje',
            style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(widget.missingProfile
            ? 'Krijo profilin fillestar për të kërkuar aktivizimin e biznesit.'
            : 'Super Admin do ta lidhë llogarinë tënde me biznesin. Nuk jepen automatikisht privilegje administratori.',
            textAlign: TextAlign.center),
          const SizedBox(height: 16),
          SelectableText('UID: ${widget.user.uid}'),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: checkingAdmin ? null : diagnoseAdmin,
            icon: const Icon(Icons.fact_check_outlined),
            label: Text(checkingAdmin ? 'Duke kontrolluar...' : 'Kontrollo Super Admin'),
          ),
          if (adminDiagnostic != null) ...[
            const SizedBox(height: 12),
            SelectableText(adminDiagnostic!,
              style: Theme.of(context).textTheme.bodySmall),
          ],
          if (widget.missingProfile) ...[
            const SizedBox(height: 20),
            FilledButton(onPressed: working ? null : createProfile,
              child: const Text('Krijo profilin')),
          ],
          if (error != null) Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ]),
      )),
    )),
  );
}
