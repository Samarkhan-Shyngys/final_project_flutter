enum OrderStatus { draft, inProgress, inDelivery, delivered }

extension OrderStatusLabel on OrderStatus {
  String get label => const {
    'draft':      'Черновик',
    'inProgress': 'В работе',
    'inDelivery': 'В доставке',
    'delivered':  'Выполнен',
  }[name]!;
}
