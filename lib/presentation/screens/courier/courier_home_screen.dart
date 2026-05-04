import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/section_label.dart';
import '../../../domain/entities/order_status.dart';

class CourierHomeScreen extends StatelessWidget {
  const CourierHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildProgress()),
            SliverToBoxAdapter(child: _buildStats()),
            SliverToBoxAdapter(child: _buildDeliveries(context)),
            SliverToBoxAdapter(child: _buildStartButton()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20, right: 20, bottom: 32,
      ),
      color: AppColors.courierAmber,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Добрый день,', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
                const SizedBox(height: 4),
                const Text('Александр Курьеров 🚚',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 6),
                Text('📅 Понедельник, 16 марта',
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.6))),
              ],
            ),
          ),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            gradient: LinearGradient(
              colors: [AppColors.courierAmber.withValues(alpha: 0.9), const Color(0xFFD97706)],
            ),
          ),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Прогресс доставок',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text('2/3',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 2 / 3,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Доставлено: 2', style: TextStyle(fontSize: 12, color: Colors.white)),
                  Text('Осталось: 1', style: TextStyle(fontSize: 12, color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          Expanded(child: _StatTile(emoji: '📦', value: '3', label: 'Доставок',
              bg: AppColors.courierAmberLight, color: AppColors.courierAmber)),
          SizedBox(width: 8),
          Expanded(child: _StatTile(emoji: '🛒', value: '15', label: 'Закупить',
              bg: AppColors.primaryLight, color: AppColors.primary)),
          SizedBox(width: 8),
          Expanded(child: _StatTile(emoji: '🗺️', value: '13.3 км', label: 'Маршрут',
              bg: AppColors.adminBlueLight, color: AppColors.adminBlue)),
        ],
      ),
    );
  }

  Widget _buildDeliveries(BuildContext context) {
    final deliveries = [
      {'id': '1', 'name': 'ДС №12 «Берёзка»', 'addr': 'ул. Ленина 45',   'time': '09:00', 'items': 3, 'dist': '2.4 км', 'status': OrderStatus.inDelivery},
      {'id': '2', 'name': 'ДС №7 «Солнышко»', 'addr': 'ул. Пушкина 12',  'time': '11:00', 'items': 5, 'dist': '4.1 км', 'status': OrderStatus.inProgress},
      {'id': '3', 'name': 'ДС №23 «Радуга»',  'addr': 'ул. Гагарина 78', 'time': '14:00', 'items': 2, 'dist': '6.8 км', 'status': OrderStatus.inProgress},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('АКТИВНЫЕ ДОСТАВКИ'),
          const SizedBox(height: 12),
          ...List.generate(deliveries.length, (i) {
            final d = deliveries[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => context.push('/courier/delivery/${d['id']}'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(color: AppColors.courierAmberLight, borderRadius: BorderRadius.circular(12)),
                            child: const Center(child: Text('🏫', style: TextStyle(fontSize: 24))),
                          ),
                          Positioned(
                            top: 0, left: 0,
                            child: Container(
                              width: 20, height: 20,
                              decoration: BoxDecoration(color: AppColors.courierAmber, borderRadius: BorderRadius.circular(10)),
                              child: Center(child: Text('${i + 1}',
                                  style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w800))),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
                            const SizedBox(height: 4),
                            Row(children: [
                              const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 2),
                              Text(d['addr'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ]),
                            const SizedBox(height: 2),
                            Row(children: [
                              const Icon(Icons.access_time, size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 2),
                              Text(d['time'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              const SizedBox(width: 8),
                              const Icon(Icons.inventory_2_outlined, size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 2),
                              Text('${d['items']} поз.', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              const SizedBox(width: 8),
                              const Icon(Icons.map_outlined, size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 2),
                              Text(d['dist'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ]),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StatusChip(status: d['status'] as OrderStatus, size: ChipSize.sm),
                          const SizedBox(height: 4),
                          const Icon(Icons.chevron_right, color: AppColors.textLight),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.courierAmber,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x66BA7517), blurRadius: 16, offset: Offset(0, 4))],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text('Начать маршрут', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String emoji, value, label;
  final Color bg, color;
  const _StatTile({required this.emoji, required this.value, required this.label, required this.bg, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
