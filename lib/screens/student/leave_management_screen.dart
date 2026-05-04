import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../components/glass_card.dart';
import '../../components/global_glass_scaffold.dart';
import '../../core/models/leave_model.dart';
import '../../core/services/leave_service.dart';

class LeaveManagementScreen extends StatefulWidget {
  const LeaveManagementScreen({super.key});
  @override
  State<LeaveManagementScreen> createState() => _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends State<LeaveManagementScreen> {
  List<LeaveModel> _leaves = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaves();
  }

  Future<void> _loadLeaves() async {
    try {
      final leaves = await leaveService.getMyLeaves();
      if (mounted) setState(() { _leaves = leaves; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showCreateLeaveDialog() async {
    DateTime? from;
    DateTime? to;
    String reason = '';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Apply for Leave', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _datePicker('From Date', from, (d) => setDialogState(() => from = d)),
              const SizedBox(height: 12),
              _datePicker('To Date', to, (d) => setDialogState(() => to = d)),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => reason = v,
                decoration: InputDecoration(
                  hintText: 'Reason (optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: (from == null || to == null) ? null : () async {
                Navigator.pop(ctx);
                try {
                  await leaveService.createLeave(
                    fromDate: from!.toIso8601String().split('T')[0],
                    toDate: to!.toIso8601String().split('T')[0],
                    reason: reason.isEmpty ? null : reason,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Leave request submitted ✅'), backgroundColor: Color(0xFF10B981)),
                    );
                    _loadLeaves();
                  }
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.redAccent),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _datePicker(String label, DateTime? value, Function(DateTime) onPicked) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 90)),
        );
        if (d != null) onPicked(d);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(LucideIcons.calendar, size: 16, color: Color(0xFF64748B)),
            const SizedBox(width: 8),
            Text(
              value != null ? '${value.day}/${value.month}/${value.year}' : label,
              style: TextStyle(fontSize: 13, color: value != null ? const Color(0xFF0F172A) : const Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'APPROVED': return const Color(0xFF10B981);
      case 'REJECTED': return const Color(0xFFEF4444);
      case 'CANCELLED': return const Color(0xFF94A3B8);
      default: return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlobalGlassScaffold(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.60), border: Border.all(color: Colors.white.withOpacity(0.70), width: 0.5)),
                        child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(20), onTap: () => context.pop(), child: const Icon(LucideIcons.arrowLeft, size: 20, color: Color(0xFF334155)))),
                      ),
                      const SizedBox(width: 12),
                      const Text('Leave Requests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                    ],
                  ),
                  GestureDetector(
                    onTap: _showCreateLeaveDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.70),
                        border: Border.all(color: const Color(0xFF93C5FD), width: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('+ Apply', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1D4ED8))),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _leaves.isEmpty
                  ? const Center(child: Text('No leave requests yet', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _leaves.length,
                      itemBuilder: (context, i) {
                        final leave = _leaves[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${leave.fromDate.day}/${leave.fromDate.month}/${leave.fromDate.year} – ${leave.toDate.day}/${leave.toDate.month}/${leave.toDate.year}',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                                      ),
                                      if (leave.reason != null) ...[
                                        const SizedBox(height: 4),
                                        Text(leave.reason!, style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                                      ],
                                      if (leave.reviewNote != null) ...[
                                        const SizedBox(height: 4),
                                        Text('Note: ${leave.reviewNote}', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
                                      ],
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _statusColor(leave.status).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _statusColor(leave.status).withOpacity(0.40)),
                                  ),
                                  child: Text(
                                    leave.status,
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _statusColor(leave.status)),
                                  ),
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
      ),
    );
  }
}
