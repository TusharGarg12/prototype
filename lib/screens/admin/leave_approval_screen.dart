import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../components/glass_card.dart';
import '../../components/global_glass_scaffold.dart';
import '../../core/services/leave_service.dart';

class LeaveApprovalScreen extends StatefulWidget {
  const LeaveApprovalScreen({super.key});

  @override
  State<LeaveApprovalScreen> createState() => _LeaveApprovalScreenState();
}

class _LeaveApprovalScreenState extends State<LeaveApprovalScreen> {
  bool _isLoading = true;
  List<dynamic> _pendingLeaves = [];

  @override
  void initState() {
    super.initState();
    _fetchPendingLeaves();
  }

  Future<void> _fetchPendingLeaves() async {
    setState(() => _isLoading = true);
    try {
      final leaves = await leaveService.getPendingLeaves();
      setState(() {
        _pendingLeaves = leaves;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching leaves: $e')),
      );
    }
  }

  Future<void> _processLeave(String id, String status) async {
    try {
      await leaveService.processLeave(id, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Leave $status successfully')),
      );
      _fetchPendingLeaves();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing leave: $e')),
      );
    }
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
                  const Text('Pending Leave Requests', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ),
            
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : _pendingLeaves.isEmpty 
                  ? Center(child: Text("No pending leaves.", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _pendingLeaves.length,
                      itemBuilder: (context, index) {
                        final leave = _pendingLeaves[index];
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
                                    Text(leave['student']?['name'] ?? 'Unknown Student', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white)),
                                    const Text('Pending', style: TextStyle(color: Color(0xFFFCD34D), fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Start Data: ${leave['startDate'].toString().substring(0, 10)}', style: const TextStyle(color: Colors.white70)),
                                Text('End Data: ${leave['endDate'].toString().substring(0, 10)}', style: const TextStyle(color: Colors.white70)),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => _processLeave(leave['id'], 'APPROVED'),
                                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF047857)),
                                        child: const Text('Approve', style: TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => _processLeave(leave['id'], 'REJECTED'),
                                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBE123C)),
                                        child: const Text('Reject', style: TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                  ),
            )
          ],
        ),
      ),
    );
  }
}