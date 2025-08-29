import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/database_factory.dart';
import '../models/finance.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../utils/bubble_notification.dart';
import 'finance_detail_screen.dart';

class FinanceSummaryScreen extends StatefulWidget {
  const FinanceSummaryScreen({super.key});

  @override
  State<FinanceSummaryScreen> createState() => _FinanceSummaryScreenState();
}

class _FinanceSummaryScreenState extends State<FinanceSummaryScreen> {
  FinanceSummary? _summary;
  double _investedAmount = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  Future<void> _loadFinancialData() async {
    setState(() => _isLoading = true);
    try {
      final summary = await DatabaseFactory.instance.getFinanceSummary();
      final invested = await DatabaseFactory.instance.calculateInvestedAmount();
      setState(() {
        _summary = summary;
        _investedAmount = invested;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        context.showErrorBubble('Error al cargar datos: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = AppTheme.getTheme(themeProvider.isDarkMode);
        
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadFinancialData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(theme),
                        const SizedBox(height: 24),
                        _buildSummaryCards(theme),
                        const SizedBox(height: 24),
                        _buildDetailCards(theme),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            theme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Resumen Financiero',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Patrimonio Total',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          Text(
            '\$${(_summary?.totalPatrimonio ?? 0.0).toStringAsFixed(2)}',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            theme,
            'Disponible',
            _summary?.totalDisponible ?? 0.0,
            Icons.monetization_on,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            theme,
            'Invertido',
            _investedAmount,
            Icons.trending_up,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    ThemeData theme,
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCards(ThemeData theme) {
    final cards = [
      {
        'title': 'Dinero Físico',
        'amount': _summary?.dineroFisico ?? 0.0,
        'icon': Icons.account_balance_wallet_outlined,
        'color': const Color(0xFF4CAF50),
        'type': 'fisico',
      },
      {
        'title': 'Utilidades',
        'amount': _summary?.utilidades ?? 0.0,
        'icon': Icons.trending_up,
        'color': const Color(0xFF2196F3),
        'type': 'utilidad',
      },
      {
        'title': 'Préstamos',
        'amount': _summary?.prestamos ?? 0.0,
        'icon': Icons.handshake_outlined,
        'color': const Color(0xFFFF9800),
        'type': 'prestamo',
      },
      {
        'title': 'Inversión en Medicinas',
        'amount': _investedAmount,
        'icon': Icons.medical_services_outlined,
        'color': const Color(0xFF9C27B0),
        'type': 'inversion',
      },
    ];

    return Column(
      children: cards.map((card) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildDetailCard(
          theme,
          card['title'] as String,
          card['amount'] as double,
          card['icon'] as IconData,
          card['color'] as Color,
          card['type'] as String,
        ),
      )).toList(),
    );
  }

  Widget _buildDetailCard(
    ThemeData theme,
    String title,
    double amount,
    IconData icon,
    Color color,
    String type,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FinanceDetailScreen(
                  type: type,
                  title: title,
                  color: color,
                ),
              ),
            ).then((_) => _loadFinancialData());
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${amount.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}