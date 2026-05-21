import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/services/admin_service.dart';
import '../../../providers/auth_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _users = [];
  Map<String, int> _summary = {
    'total': 0,
    'active': 0,
    'banned': 0,
    'admins': 0,
  };
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers({bool refreshOnly = false}) async {
    if (mounted) {
      setState(() {
        _isLoading = !refreshOnly;
        _isRefreshing = refreshOnly;
      });
    }

    try {
      final dashboard = await _adminService.getDashboard();
      if (!mounted) return;
      setState(() {
        _users = dashboard.users;
        _summary = dashboard.summary;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar usuarios: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _setUserBanned(Map<String, dynamic> user, bool banned) async {
    final userId = _readUserId(user['id']);
    if (userId == null) return;

    final name = _readText(user['name'] ?? user['username'], 'Usuario');
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(banned ? 'Banir usuario' : 'Reativar usuario'),
        content: Text(
          banned
              ? 'Banir $name bloqueia o login e invalida sessoes futuras.'
              : 'Reativar $name permite que a conta volte a acessar o app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: banned ? const Color(0xFFB42318) : const Color(0xFF047857),
            ),
            child: Text(banned ? 'Banir' : 'Reativar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _adminService.setUserBanned(userId, banned);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(banned ? 'Usuario banido com sucesso.' : 'Usuario reativado com sucesso.'),
          ),
        );
      }
      await _fetchUsers(refreshOnly: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(banned ? 'Erro ao banir usuario: $e' : 'Erro ao reativar usuario: $e')),
        );
      }
    }
  }

  Future<void> _deleteUser(Map<String, dynamic> user) async {
    final userId = _readUserId(user['id']);
    if (userId == null) return;

    final name = _readText(user['name'] ?? user['username'], 'Usuario');
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar conta'),
        content: Text('Apagar $name remove a conta e todos os dados vinculados. Esta acao nao pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB42318)),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _adminService.deleteUser(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario apagado com sucesso.')),
        );
      }
      await _fetchUsers(refreshOnly: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao apagar usuario: $e')),
        );
      }
    }
  }

  Future<void> _promoteUserToAdmin(Map<String, dynamic> user) async {
    final userId = _readUserId(user['id']);
    if (userId == null) return;

    final name = _readText(user['name'] ?? user['username'], 'Usuario');
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tornar admin'),
        content: Text(
          '$name tera acesso ao painel administrativo e podera gerenciar usuarios.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
            child: const Text('Tornar admin'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _adminService.promoteUserToAdmin(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario promovido a admin.')),
        );
      }
      await _fetchUsers(refreshOnly: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao tornar admin: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    final query = _searchController.text.trim().toLowerCase();
    return _users.whereType<Map>().map((user) => Map<String, dynamic>.from(user)).where((user) {
      final status = _readStatus(user);
      if (_statusFilter != 'all' && status != _statusFilter) {
        return false;
      }

      if (query.isEmpty) return true;

      final searchable = [
        user['name'],
        user['username'],
        user['email'],
        user['role'],
        user['status'],
      ].map((value) => value?.toString().toLowerCase() ?? '').join(' ');

      return searchable.contains(query);
    }).toList();
  }

  int? _readUserId(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  String _readText(dynamic value, String fallback) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  String _readStatus(Map<String, dynamic> user) {
    return user['status'] == 'banned' ? 'banned' : 'active';
  }

  bool _canModerate(Map<String, dynamic> user) {
    return user['role'] != 'admin' && _readUserId(user['id']) != null;
  }

  String _formatDate(dynamic value) {
    final parsed = value != null ? DateTime.tryParse(value.toString()) : null;
    if (parsed == null) return 'Sem data';
    return DateFormat('dd/MM/yyyy HH:mm').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredUsers = _filteredUsers;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        title: const Text('Admin'),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : () => _fetchUsers(refreshOnly: true),
            tooltip: 'Atualizar',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (!context.mounted) return;
              navigator.pushNamedAndRemoveUntil('/login', (route) => false);
            },
            tooltip: 'Sair',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _fetchUsers(refreshOnly: true),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                children: [
                  Text(
                    'Painel de usuarios',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Acompanhe contas cadastradas, status de acesso e moderacao.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 18),
                  _SummaryGrid(summary: _summary),
                  const SizedBox(height: 18),
                  _Toolbar(
                    controller: _searchController,
                    statusFilter: _statusFilter,
                    onStatusChanged: (value) => setState(() => _statusFilter = value),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${filteredUsers.length} usuario${filteredUsers.length == 1 ? '' : 's'} encontrado${filteredUsers.length == 1 ? '' : 's'}',
                    style: theme.textTheme.labelLarge?.copyWith(color: const Color(0xFF475569)),
                  ),
                  const SizedBox(height: 10),
                  if (filteredUsers.isEmpty)
                    const _EmptyState()
                  else
                    ...filteredUsers.map(
                      (user) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _UserRow(
                          user: user,
                          canModerate: _canModerate(user),
                          status: _readStatus(user),
                          createdAt: _formatDate(user['created_at']),
                          onBan: () => _setUserBanned(user, true),
                          onUnban: () => _setUserBanned(user, false),
                          onMakeAdmin: () => _promoteUserToAdmin(user),
                          onDelete: () => _deleteUser(user),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary});

  final Map<String, int> summary;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _MetricData('Contas', summary['total'] ?? 0, Icons.people_alt_outlined, const Color(0xFF2563EB)),
      _MetricData('Ativas', summary['active'] ?? 0, Icons.verified_user_outlined, const Color(0xFF059669)),
      _MetricData('Banidas', summary['banned'] ?? 0, Icons.block_outlined, const Color(0xFFDC2626)),
      _MetricData('Admins', summary['admins'] ?? 0, Icons.admin_panel_settings_outlined, const Color(0xFF7C3AED)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 820 ? 4 : constraints.maxWidth >= 520 ? 2 : 1;
        return GridView.builder(
          itemCount: cards.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 112,
          ),
          itemBuilder: (context, index) => _MetricCard(data: cards[index]),
        );
      },
    );
  }
}

class _MetricData {
  const _MetricData(this.label, this.value, this.icon, this.color);

  final String label;
  final int value;
  final IconData icon;
  final Color color;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(data.icon, color: data.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.value.toString(),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  data.label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.controller,
    required this.statusFilter,
    required this.onStatusChanged,
  });

  final TextEditingController controller;
  final String statusFilter;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final search = TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Buscar por nome, email ou perfil',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Limpar busca',
                      onPressed: controller.clear,
                    ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          );

          final filter = SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'all', label: Text('Todos'), icon: Icon(Icons.groups_outlined)),
              ButtonSegment(value: 'active', label: Text('Ativos'), icon: Icon(Icons.check_circle_outline)),
              ButtonSegment(value: 'banned', label: Text('Banidos'), icon: Icon(Icons.block_outlined)),
            ],
            selected: {statusFilter},
            onSelectionChanged: (selection) => onStatusChanged(selection.first),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                search,
                const SizedBox(height: 10),
                SingleChildScrollView(scrollDirection: Axis.horizontal, child: filter),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: search),
              const SizedBox(width: 12),
              filter,
            ],
          );
        },
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({
    required this.user,
    required this.canModerate,
    required this.status,
    required this.createdAt,
    required this.onBan,
    required this.onUnban,
    required this.onMakeAdmin,
    required this.onDelete,
  });

  final Map<String, dynamic> user;
  final bool canModerate;
  final String status;
  final String createdAt;
  final VoidCallback onBan;
  final VoidCallback onUnban;
  final VoidCallback onMakeAdmin;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final name = _text(user['name'] ?? user['username'], 'Usuario sem nome');
    final email = _text(user['email'], 'Sem email');
    final role = _text(user['role'], 'user');
    final banned = status == 'banned';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: banned ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: banned ? const Color(0xFFFEE2E2) : const Color(0xFFE0F2FE),
            foregroundColor: banned ? const Color(0xFFB42318) : const Color(0xFF0369A1),
            child: Text(name.substring(0, 1).toUpperCase()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    _StatusChip(label: role == 'admin' ? 'Admin' : 'Usuario', color: const Color(0xFF475569)),
                    _StatusChip(
                      label: banned ? 'Banido' : 'Ativo',
                      color: banned ? const Color(0xFFB42318) : const Color(0xFF047857),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 14,
                  runSpacing: 4,
                  children: [
                    _InlineInfo(icon: Icons.mail_outline, text: email),
                    _InlineInfo(icon: Icons.calendar_today_outlined, text: createdAt),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Acoes',
            enabled: canModerate,
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'ban') onBan();
              if (value == 'unban') onUnban();
              if (value == 'makeAdmin') onMakeAdmin();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => [
              if (role != 'admin' && !banned)
                const PopupMenuItem(
                  value: 'makeAdmin',
                  child: ListTile(
                    leading: Icon(Icons.admin_panel_settings_outlined, color: Color(0xFF2563EB)),
                    title: Text('Tornar admin'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              PopupMenuItem(
                value: banned ? 'unban' : 'ban',
                child: ListTile(
                  leading: Icon(banned ? Icons.lock_open_outlined : Icons.block_outlined),
                  title: Text(banned ? 'Reativar' : 'Banir'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline, color: Color(0xFFB42318)),
                  title: Text('Apagar'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _text(dynamic value, String fallback) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? fallback : text;
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InlineInfo extends StatelessWidget {
  const _InlineInfo({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)),
        const SizedBox(width: 5),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        children: [
          Icon(Icons.manage_search_outlined, size: 38, color: Color(0xFF64748B)),
          SizedBox(height: 10),
          Text(
            'Nenhum usuario encontrado',
            style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF111827)),
          ),
          SizedBox(height: 4),
          Text(
            'Ajuste a busca ou o filtro de status.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
