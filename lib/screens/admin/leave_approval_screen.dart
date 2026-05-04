import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../components/glass_card.dart';
import '../../components/global_glass_scaffold.dart';
import '../../components/status_pill.dart';
import '../../core/models/leave_model.dart';
import '../../core/services/leave_service.dart';

class LeaveApprovalScreen extends StatefulWidget {
  const LeaveApprovalScreen({super.key});

  @override
  State<LeaveApprovalScreen> createState() => _LeaveApprovalScreenState();
}

class _LeaveApprovalScreenState extends State<LeaveApprovalScreen> {
  bool _isLoading = true;
  String? _processingId;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _statusOptions = const ['PENDING', 'APPROVED', 'REJECTED', 'ALL'];
  String _statusFilter = 'PENDING';
  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  List<LeaveModel> _leaves = [];

  @override
  void initState() {
    super.initState();
    _fetchLeaves(reset: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLeaves({required bool reset}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _page = 1;
        _hasMore = true;
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final status = _statusFilter == 'ALL' ? null : _statusFilter;
      final leaves = await leaveService.getAdminLeaves(status: status, page: _page, limit: 20);
      setState(() {
        if (reset) {
          _leaves = leaves;
        } else {
          _leaves = [..._leaves, ...leaves];
        }
        _hasMore = leaves.length == 20;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching leaves: $e')),
      );
    }
  }

  Future<void> _processLeave(String id, String status, {String? reviewNote}) async {
    try {
      setState(() => _processingId = id);
      await leaveService.processLeave(id, status, reviewNote: reviewNote);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Leave $status successfully')),
      );
      await _fetchLeaves(reset: true);
    } catch (e) {
      setState(() => _processingId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing leave: $e')),
      );
    }
  }

  List<LeaveModel> get _filteredLeaves {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _leaves;
    return _leaves.where((leave) {
      final name = (leave.userName ?? '').toLowerCase();
      final roll = (leave.rollNumber ?? '').toLowerCase();
      final email = (leave.userEmail ?? '').toLowerCase();
      return name.contains(query) || roll.contains(query) || email.contains(query);
    }).toList();
  }

  Future<void> _showReviewDialog(LeaveModel leave, String status) async {
    final controller = TextEditingController();
    final label = status == 'APPROVED' ? 'Approve Leave' : 'Reject Leave';
    final buttonText = status == 'APPROVED' ? 'Approve' : 'Reject';

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(label),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(leave.userName ?? 'Unknown Student', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('${_formatDate(leave.fromDate)} - ${_formatDate(leave.toDate)}', style: const TextStyle(color: Color(0xFF64748B))),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: Text(buttonText),
            ),
          ],
        );
      },
    );

    if (!mounted || result == null) return;
    await _processLeave(leave.id, status, reviewNote: result);
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    return GlobalGlassScaffold(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Row(
                children: [
                   Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.60),
                        border: Border.all(color: Colors.white.withOpacity(0.70), width: 0.5),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => context.pop(),
                          child: const Icon(LucideIcons.arrowLeft, size: 20, color: Color(0xFF334155)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text('Leave Approval Inbox', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                ],
              ),
            ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search by name, roll, or email',
                        prefixIcon: const Icon(LucideIcons.search, size: 18),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.6)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.6)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Status', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: _statusFilter,
                          items: _statusOptions
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _statusFilter = value);
                            _fetchLeaves(reset: true);
                          },
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _isLoading ? null : () => _fetchLeaves(reset: true),
                          icon: const Icon(LucideIcons.refreshCcw, size: 16),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredLeaves.isEmpty
                      ? const Center(child: Text('No leaves found.', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredLeaves.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _filteredLeaves.length) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12, top: 8),
                                child: Center(
                                  child: ElevatedButton(
                                    onPressed: _isLoadingMore
                                        ? null
                                        : () {
                                            _page += 1;
                                            _fetchLeaves(reset: false);
                                          },
                                    child: Text(_isLoadingMore ? 'Loading...' : 'Load more'),
                                  ),
                                ),
                              );
                            }

                            final leave = _filteredLeaves[index];
                            final name = leave.userName ?? 'Unknown Student';
                            final roll = leave.rollNumber ?? leave.userEmail ?? 'No roll number';
                            final isProcessing = _processingId == leave.id;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GlassCard(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF0F172A))),
                                              const SizedBox(height: 4),
                                              Text(roll, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                            ],
                                          ),
                                        ),
                                        StatusPill(
                                          text: leave.status,
                                          variant: leave.isPending
                                              ? StatusVariant.warning
                                              : leave.isApproved
                                                  ? StatusVariant.success
                                                  : StatusVariant.danger,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text('From: ${_formatDate(leave.fromDate)}', style: const TextStyle(color: Color(0xFF334155), fontSize: 12)),
                                    Text('To: ${_formatDate(leave.toDate)}', style: const TextStyle(color: Color(0xFF334155), fontSize: 12)),
                                    if (leave.reason != null && leave.reason!.trim().isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text('Reason: ${leave.reason}', style: const TextStyle(color: Color(0xFF475569), fontSize: 12)),
                                    ],
                                    const SizedBox(height: 16),
                                    if (leave.isPending)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: isProcessing ? null : () => _showReviewDialog(leave, 'APPROVED'),
                                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF047857)),
                                              child: Text(isProcessing ? 'Processing...' : 'Approve', style: const TextStyle(color: Colors.white)),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: isProcessing ? null : () => _showReviewDialog(leave, 'REJECTED'),
                                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBE123C)),
                                              child: Text(isProcessing ? 'Processing...' : 'Reject', style: const TextStyle(color: Colors.white)),
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: null,
                                              child: Text(leave.status),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            )
          ],
        ),
      ),
    );
  }
}