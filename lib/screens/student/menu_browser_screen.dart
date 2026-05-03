import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../components/glass_card.dart';
import '../../components/global_glass_scaffold.dart';

class MenuBrowserScreen extends StatefulWidget {
  const MenuBrowserScreen({super.key});

  @override
  State<MenuBrowserScreen> createState() => _MenuBrowserScreenState();
}

class _MenuBrowserScreenState extends State<MenuBrowserScreen> {
  int _selectedDay = 2; // Wed
  int _selectedMeal = 1; // Lunch

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> _meals = ['Breakfast', 'Lunch', 'Dinner'];

  final List<Map<String, dynamic>> _dishes = [
    { 'name': 'Dal Makhani', 'calories': '245 kcal', 'rating': 4.5, 'votes': 234, 'allergens': [], 'color': const Color(0xFFFBBF24) },
    { 'name': 'Paneer Butter Masala', 'calories': '320 kcal', 'rating': 4.8, 'votes': 456, 'allergens': ['dairy'], 'color': const Color(0xFFF97316) },
    { 'name': 'Jeera Rice', 'calories': '180 kcal', 'rating': 4.2, 'votes': 189, 'allergens': [], 'color': const Color(0xFF84CC16) },
    { 'name': 'Aloo Gobi', 'calories': '165 kcal', 'rating': 4.0, 'votes': 123, 'allergens': [], 'color': const Color(0xFFEAB308) },
    { 'name': 'Mixed Veg Raita', 'calories': '95 kcal', 'rating': 4.3, 'votes': 167, 'allergens': ['dairy'], 'color': const Color(0xFF22C55E) },
    { 'name': 'Gulab Jamun', 'calories': '275 kcal', 'rating': 4.9, 'votes': 589, 'allergens': ['dairy'], 'color': const Color(0xFFDC2626) },
  ];

  void _showDishDetails(Map<String, dynamic> dish) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return GlassCard(
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
              Text(dish['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
              const SizedBox(height: 8),
              Text(dish['calories'], style: const TextStyle(fontSize: 14, color: Color(0xFF334155))),
              const SizedBox(height: 16),
              _buildNutritionBar('Protein', '18g', 0.65, const Color(0xFF60A5FA)),
              const SizedBox(height: 12),
              _buildNutritionBar('Carbs', '32g', 0.45, const Color(0xFFFBBF24)),
              const SizedBox(height: 12),
              _buildNutritionBar('Fats', '12g', 0.30, const Color(0xFF34D399)),
              const SizedBox(height: 16),
              if ((dish['allergens'] as List).isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7).withOpacity(0.70),
                    border: Border.all(color: const Color(0xFFFDE68A), width: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(LucideIcons.alertCircle, size: 16, color: Color(0xFFD97706)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Allergen Alert', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF78350F))),
                            Text('Contains: ${(dish['allergens'] as List).join(', ')}', style: const TextStyle(fontSize: 10, color: Color(0xFFB45309))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNutritionBar(String label, String value, double fraction, Color color) {
    return Row(
      children: [
        SizedBox(width: 50, child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF334155)))),
        Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0).withOpacity(0.6),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fraction,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
      ],
    );
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
                  const Text('Weekly Menu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                ],
              ),
            ),
            
            // Days Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _days.asMap().entries.map((entry) {
                  final isSelected = _selectedDay == entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedDay = entry.key),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withOpacity(0.70) : Colors.white.withOpacity(0.60),
                          border: Border.all(
                            color: isSelected ? Colors.white.withOpacity(0.80) : Colors.white.withOpacity(0.70), 
                            width: 0.5
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isSelected ? 0.08 : 0.04), 
                              blurRadius: isSelected ? 16 : 8, 
                              offset: Offset(0, isSelected ? 4 : 2)
                            ),
                          ],
                        ),
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.w600, 
                            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF475569)
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Meals Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _meals.asMap().entries.map((entry) {
                  final isSelected = _selectedMeal == entry.key;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: entry.key == 2 ? 0 : 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedMeal = entry.key),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white.withOpacity(0.70) : Colors.white.withOpacity(0.60),
                            border: Border.all(
                              color: isSelected ? Colors.white.withOpacity(0.80) : Colors.white.withOpacity(0.70), 
                              width: 0.5
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isSelected ? 0.08 : 0.04), 
                                blurRadius: isSelected ? 16 : 8, 
                                offset: Offset(0, isSelected ? 4 : 2)
                              ),
                            ],
                          ),
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 12, 
                              fontWeight: FontWeight.w600, 
                              color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF475569)
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Veg'),
                  const SizedBox(width: 8),
                  _buildFilterChip('High Protein'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Dishes Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: _dishes.length,
                itemBuilder: (context, index) {
                  final dish = _dishes[index];
                  return GlassCard(
                    padding: const EdgeInsets.all(12),
                    onTap: () => _showDishDetails(dish),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 64,
                          decoration: BoxDecoration(
                            color: dish['color'],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4)),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            (dish['name'] as String).split(' ').first,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(dish['name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(dish['calories'], style: const TextStyle(fontSize: 9, color: Color(0xFF475569))),
                        
                        if ((dish['allergens'] as List).isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: (dish['allergens'] as List).map((a) => Container(
                                width: 6, height: 6,
                                margin: const EdgeInsets.only(right: 4),
                                decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle),
                              )).toList(),
                            ),
                          ),
                          
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(LucideIcons.star, size: 12, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 4),
                                Text('${dish['rating']}', style: const TextStyle(fontSize: 9, color: Color(0xFF334155))),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(LucideIcons.thumbsUp, size: 12, color: Color(0xFF94A3B8)),
                                const SizedBox(width: 4),
                                Text('${dish['votes']}', style: const TextStyle(fontSize: 9, color: Color(0xFF475569))),
                              ],
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.50),
        border: Border.all(color: Colors.white.withOpacity(0.60), width: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF334155))),
    );
  }
}
