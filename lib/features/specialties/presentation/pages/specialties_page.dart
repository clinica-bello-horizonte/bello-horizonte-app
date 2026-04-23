import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state_widget.dart';
import '../providers/specialties_provider.dart';
import '../widgets/specialty_card.dart';

class SpecialtiesPage extends ConsumerWidget {
  const SpecialtiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final specialtiesAsync = ref.watch(specialtiesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Especialidades'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: specialtiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateWidget(message: e.toString()),
        data: (specialties) {
          if (specialties.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.medical_services_outlined,
              title: 'Sin especialidades',
              subtitle: 'No hay especialidades disponibles',
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: specialties.length,
            itemBuilder: (context, index) => SpecialtyCard(
              specialty: specialties[index],
              onTap: () => context.push('/specialties/${specialties[index].id}'),
            ),
          );
        },
      ),
    );
  }
}
