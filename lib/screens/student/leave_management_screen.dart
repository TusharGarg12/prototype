import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../components/glass_card.dart';
import '../../components/status_pill.dart';
import '../../components/global_glass_scaffold.dart';

class LeaveManagementScreen extends StatefulWidget {
  const LeaveManagementScreen({super.key});

  @override
  State<LeaveManagementScreen> createState() => _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends State<LeaveManagementScreen> {
  int _currentMonth = 3; // April (0-indexed)
  final List<String> _monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  
  final List<Map<String, dynamic>> _leaves = [
    { 'dates': 'Apr 15 - Apr 17', 'reason': 'Medical', 'status': 'approved', 'days': 3 },
    { 'dates': 'Apr 22 - Apr 23', 'reason': 'Personal', 'status': 'pending', 'days': 2 },
    { 'dates': 'May 1 - May 3', 'reason': 'Family Event', 'status': 'rejected', 'days': 3 },
  ];

  void _showRequestForm() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: GlassCard(
            level: GlassLevel.level4,
            borderRadius: 28,
            margin: const EdgeInsets.only(top: 100),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text('Request Leave', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
                const SizedBox(height: 16),
                _buildInputLabel('From Date'),
                _buildInputField(hint: 'YYYY-MM-DD'),
                const SizedBox(height: 16),
                _buildInputLabel('To Date'),
                _buildInputField(hint: 'YYYY-MM-DD'),
                const SizedBox(height: 16),
                _buildInputLabel('Reason'),
                _buildInputField(hint: 'Enter reason for leave...', maxLines: 3),
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.70),
                      foregroundColor: const Color(0xFF2563EB),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Color(0xFF93C5FD), width: 0.5),
                      ),
                    ),
                    child: const Text('Submit Request', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
    );
  }

  Widget _buildInputField({required String hint, int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.60),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.70), width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.80), width: 0.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlobalGlassScaffold(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.60),
                      border: Border.all(color: Colors.white.withOpacity(0.70), width: 0.5),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
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
                  const SizedBox(width: 12),
                  const Text('Leave Management', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Request Leave Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _showRequestForm,
                        icon: const Icon(LucideIcons.plus, size: 20),
                        label: const Text('Request Leave', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.70),
                          foregroundColor: const Color(0xFF2563EB),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: Color(0xFF93C5FD), width: 0.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Calendar
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMonthNavButton(LucideIcons.chevronLeft, () {
                                setState(() => _currentMonth = (_currentMonth > 0) ? _currentMonth - 1 : 0);
                              }),
                              Text('${_monthNames[_currentMonth]} 2026', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
                              _buildMonthNavButton(LucideIcons.chevronRight, () {
                                setState(() => _currentMonth = (_currentMonth < 11) ? _currentMonth + 1 : 11);
                              }),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) => 
                              SizedBox(width: 32, child: Center(child: Text(day, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF475569)))))
                            ).toList(),
                          ),
                          const SizedBox(height: 8),
                          _buildCalendarGrid(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    const Text('LEAVE HISTORY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155), letterSpacing: 0.5)),
                    const SizedBox(height: 12),
                    
                    ..._leaves.map((leave) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(leave['dates'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
                                const SizedBox(height: 2),
                                Text('${leave['reason']} • ${leave['days']} days', style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
                              ],
                            ),
                            StatusPill(
                              text: (leave['status'] as String).substring(0, 1).toUpperCase() + (leave['status'] as String).substring(1),
                              variant: leave['status'] == 'approved' ? StatusVariant.success : leave['status'] == 'pending' ? StatusVariant.warning : StatusVariant.danger,
                            ),
                          ],
                        ),
                      ),
                    )),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthNavButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.50),
        border: Border.all(color: Colors.white.withOpacity(0.60), width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Icon(icon, size: 16, color: const Color(0xFF334155)),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    int daysInMonth = DateTime(2026, _currentMonth + 2, 0).day;
    int firstDay = DateTime(2026, _currentMonth + 1, 1).weekday % 7;
    
    List<Widget> days = [];
    
    for (int i = 0; i < firstDay; i++) {
      days.add(const SizedBox(height: 40));
    }
    
    for (int day = 1; day <= daysInMonth; day++) {
      bool isToday = _currentMonth == 3 && day == 20;
      bool isLeave = _currentMonth == 3 && [15, 16, 17, 22, 23].contains(day);
      
      days.add(
        Container(
          height: 40,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isToday)
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(color: Color(0xFF334155), shape: BoxShape.circle),
                ),
              Text(
                '$day',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: (isToday || isLeave) ? FontWeight.w500 : FontWeight.normal,
                  color: isToday ? Colors.white : isLeave ? const Color(0xFFB45309) : const Color(0xFF334155),
                ),
              ),
              if (isLeave)
                Positioned(
                  bottom: 4,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
        )
      );
    }
    
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      children: days,
    );
  }
}
