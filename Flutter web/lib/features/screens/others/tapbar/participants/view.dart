import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() {
  setUrlStrategy(PathUrlStrategy());
  runApp(const ParticipantsTapbarScreen());
}

class ParticipantsTapbarScreen extends StatelessWidget {
  const ParticipantsTapbarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Participant List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const ParticipantListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ParticipantListScreen extends StatefulWidget {
  const ParticipantListScreen({super.key});

  @override
  State<ParticipantListScreen> createState() => _ParticipantListScreenState();
}

class _ParticipantListScreenState extends State<ParticipantListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFirstNameFilter = 'All';
  String _selectedLastNameFilter = 'All';
  bool _selectAll = false;
  final List<bool> _selectedParticipants = List.generate(30, (index) => false);
  String _searchQuery = '';

  final List<Participant> allParticipants = [
    Participant(id: 1, firstName: 'Frances', lastName: 'Banks', role: 'Student', group: 'No groups', lastAccess: '51 days 12 hours', weight: 78.06, avatarUrl: 'https://picsum.photos/seed/frances/100/100.jpg'),
    Participant(id: 2, firstName: 'Angela', lastName: 'Bowman', role: 'Student', group: 'GroupA', lastAccess: 'Never', weight: 0, avatarUrl: 'https://picsum.photos/seed/angela/100/100.jpg'),
    Participant(id: 3, firstName: 'Brian', lastName: 'Cooper', role: 'Teacher', group: 'No groups', lastAccess: '23 days 5 hours', weight: 65.43, avatarUrl: 'https://picsum.photos/seed/brian/100/100.jpg'),
    Participant(id: 4, firstName: 'Mohammed', lastName: 'Ahmed', role: 'Student', group: 'GroupB', lastAccess: '12 days 3 hours', weight: 85.2, avatarUrl: 'https://picsum.photos/seed/mohammed/100/100.jpg'),
    Participant(id: 5, firstName: 'Sarah', lastName: 'Johnson', role: 'Student', group: 'No groups', lastAccess: 'Never', weight: 45.0, avatarUrl: 'https://picsum.photos/seed/sarah/100/100.jpg'),
    Participant(id: 6, firstName: 'David', lastName: 'Miller', role: 'Teacher', group: 'GroupA', lastAccess: '5 days 8 hours', weight: 92.5, avatarUrl: 'https://picsum.photos/seed/david/100/100.jpg'),
    Participant(id: 7, firstName: 'Emily', lastName: 'Wilson', role: 'Student', group: 'No groups', lastAccess: '30 days 2 hours', weight: 70.0, avatarUrl: 'https://picsum.photos/seed/emily/100/100.jpg'),
    Participant(id: 8, firstName: 'Ahmed', lastName: 'Hassan', role: 'Student', group: 'GroupB', lastAccess: 'Never', weight: 55.5, avatarUrl: 'https://picsum.photos/seed/ahmed/100/100.jpg'),
    Participant(id: 9, firstName: 'Jessica', lastName: 'Taylor', role: 'Student', group: 'No groups', lastAccess: '18 days 6 hours', weight: 80.0, avatarUrl: 'https://picsum.photos/seed/jessica/100/100.jpg'),
    Participant(id: 10, firstName: 'Michael', lastName: 'Brown', role: 'Teacher', group: 'GroupA', lastAccess: '2 days 14 hours', weight: 88.0, avatarUrl: 'https://picsum.photos/seed/michael/100/100.jpg'),
    Participant(id: 11, firstName: 'Fatima', lastName: 'Ali', role: 'Student', group: 'GroupB', lastAccess: 'Never', weight: 60.0, avatarUrl: 'https://picsum.photos/seed/fatima/100/100.jpg'),
    Participant(id: 12, firstName: 'Robert', lastName: 'Davis', role: 'Student', group: 'No groups', lastAccess: '25 days 10 hours', weight: 75.0, avatarUrl: 'https://picsum.photos/seed/robert/100/100.jpg'),
    Participant(id: 13, firstName: 'Lisa', lastName: 'Garcia', role: 'Student', group: 'No groups', lastAccess: '8 days 4 hours', weight: 68.5, avatarUrl: 'https://picsum.photos/seed/lisa/100/100.jpg'),
    Participant(id: 14, firstName: 'Youssef', lastName: 'Mohamed', role: 'Student', group: 'GroupB', lastAccess: 'Never', weight: 50.0, avatarUrl: 'https://picsum.photos/seed/youssef/100/100.jpg'),
    Participant(id: 15, firstName: 'Jennifer', lastName: 'Martinez', role: 'Teacher', group: 'GroupA', lastAccess: '15 days 7 hours', weight: 90.0, avatarUrl: 'https://picsum.photos/seed/jennifer/100/100.jpg'),
    Participant(id: 16, firstName: 'William', lastName: 'Anderson', role: 'Student', group: 'No groups', lastAccess: '40 days 1 hour', weight: 72.5, avatarUrl: 'https://picsum.photos/seed/william/100/100.jpg'),
    Participant(id: 17, firstName: 'Maria', lastName: 'Thomas', role: 'Student', group: 'No groups', lastAccess: 'Never', weight: 58.0, avatarUrl: 'https://picsum.photos/seed/maria/100/100.jpg'),
    Participant(id: 18, firstName: 'Omar', lastName: 'Ibrahim', role: 'Student', group: 'GroupB', lastAccess: '22 days 9 hours', weight: 82.0, avatarUrl: 'https://picsum.photos/seed/omar/100/100.jpg'),
    Participant(id: 19, firstName: 'Patricia', lastName: 'Jackson', role: 'Student', group: 'No groups', lastAccess: '6 days 11 hours', weight: 76.5, avatarUrl: 'https://picsum.photos/seed/patricia/100/100.jpg'),
    Participant(id: 20, firstName: 'Christopher', lastName: 'White', role: 'Teacher', group: 'GroupA', lastAccess: '3 days 5 hours', weight: 95.0, avatarUrl: 'https://picsum.photos/seed/christopher/100/100.jpg'),
    Participant(id: 21, firstName: 'Nour', lastName: 'Said', role: 'Student', group: 'GroupB', lastAccess: 'Never', weight: 65.0, avatarUrl: 'https://picsum.photos/seed/nour/100/100.jpg'),
    Participant(id: 22, firstName: 'Linda', lastName: 'Harris', role: 'Student', group: 'No groups', lastAccess: '28 days 3 hours', weight: 71.0, avatarUrl: 'https://picsum.photos/seed/linda/100/100.jpg'),
    Participant(id: 23, firstName: 'Daniel', lastName: 'Martin', role: 'Student', group: 'No groups', lastAccess: '11 days 8 hours', weight: 79.5, avatarUrl: 'https://picsum.photos/seed/daniel/100/100.jpg'),
    Participant(id: 24, firstName: 'Aisha', lastName: 'Khan', role: 'Student', group: 'GroupB', lastAccess: 'Never', weight: 53.0, avatarUrl: 'https://picsum.photos/seed/aisha/100/100.jpg'),
    Participant(id: 25, firstName: 'Matthew', lastName: 'Thompson', role: 'Student', group: 'No groups', lastAccess: '19 days 6 hours', weight: 84.0, avatarUrl: 'https://picsum.photos/seed/matthew/100/100.jpg'),
    Participant(id: 26, firstName: 'Sophie', lastName: 'Garcia', role: 'Teacher', group: 'GroupA', lastAccess: '7 days 12 hours', weight: 91.5, avatarUrl: 'https://picsum.photos/seed/sophie/100/100.jpg'),
    Participant(id: 27, firstName: 'Kevin', lastName: 'Martinez', role: 'Student', group: 'No groups', lastAccess: '35 days 4 hours', weight: 67.0, avatarUrl: 'https://picsum.photos/seed/kevin/100/100.jpg'),
    Participant(id: 28, firstName: 'Hana', lastName: 'Abdullah', role: 'Student', group: 'GroupB', lastAccess: 'Never', weight: 61.5, avatarUrl: 'https://picsum.photos/seed/hana/100/100.jpg'),
    Participant(id: 29, firstName: 'Richard', lastName: 'Robinson', role: 'Student', group: 'No groups', lastAccess: '14 days 9 hours', weight: 77.0, avatarUrl: 'https://picsum.photos/seed/richard/100/100.jpg'),
    Participant(id: 30, firstName: 'Olivia', lastName: 'Clark', role: 'Student', group: 'No groups', lastAccess: '4 days 2 hours', weight: 86.5, avatarUrl: 'https://picsum.photos/seed/olivia/100/100.jpg'),
  ];

  late List<Participant> _filteredParticipants;

  @override
  void initState() {
    super.initState();
    _filteredParticipants = List.from(allParticipants);

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _applyFilters();
      });
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredParticipants = allParticipants.where((participant) {
        final nameMatch = participant.firstName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            participant.lastName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            participant.role.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            participant.group.toLowerCase().contains(_searchQuery.toLowerCase());

        final firstNameMatch = _selectedFirstNameFilter == 'All' ||
            participant.firstName.toUpperCase().startsWith(_selectedFirstNameFilter);

        final lastNameMatch = _selectedLastNameFilter == 'All' ||
            participant.lastName.toUpperCase().startsWith(_selectedLastNameFilter);

        return nameMatch && firstNameMatch && lastNameMatch;
      }).toList();

      _selectedParticipants.clear();
      _selectedParticipants.addAll(List.generate(_filteredParticipants.length, (index) => false));
      _selectAll = false;
    });
  }

  Widget _buildFilterChips(String type, String selectedFilter, Function(String) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by $type first letter:',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('All'),
                selected: selectedFilter == 'All',
                onSelected: (selected) {
                  onSelected('All');
                  _applyFilters();
                },
                backgroundColor: Colors.grey[100],
                selectedColor: Colors.blue[100],
              ),
              const SizedBox(width: 8),
              ...List.generate(26, (index) {
                final letter = String.fromCharCode(65 + index);
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: FilterChip(
                    label: Text(letter),
                    selected: selectedFilter == letter,
                    onSelected: (selected) {
                      onSelected(letter);
                      _applyFilters();
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    backgroundColor: Colors.grey[100],
                    selectedColor: Colors.blue[100],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Participants', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name, role, or group...',
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14.0,
                    horizontal: 16.0,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterChips('first name', _selectedFirstNameFilter, (value) {
                    setState(() {
                      _selectedFirstNameFilter = value;
                    });
                  }),
                  const SizedBox(height: 16),
                  _buildFilterChips('last name', _selectedLastNameFilter, (value) {
                    setState(() {
                      _selectedLastNameFilter = value;
                    });
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Icon(Icons.people_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  '${_filteredParticipants.length} participants found',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                    fontSize: 16,
                  ),
                ),
                if (_searchQuery.isNotEmpty || _selectedFirstNameFilter != 'All' || _selectedLastNameFilter != 'All')
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                          _selectedFirstNameFilter = 'All';
                          _selectedLastNameFilter = 'All';
                          _applyFilters();
                        });
                      },
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Clear filters'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red[600],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Card(
            elevation: 2,
            child: Column(
              children: [

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 40),
                      SizedBox(width: 40),
                      Expanded(flex: 2, child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('Weight', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('Group', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('Last Access', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),

                _filteredParticipants.isEmpty
                    ? Container(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No participants found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your filters or search query',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredParticipants.length,
                  itemBuilder: (context, index) {
                    final participant = _filteredParticipants[index];
                    return ParticipantListItem(
                      participant: participant,
                      isSelected: index < _selectedParticipants.length ? _selectedParticipants[index] : false,
                      onSelectedChanged: (selected) {
                        setState(() {
                          if (index < _selectedParticipants.length) {
                            _selectedParticipants[index] = selected;
                          }
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                        _selectedFirstNameFilter = 'All';
                        _selectedLastNameFilter = 'All';
                        _applyFilters();
                      });
                    },
                    icon: const Icon(Icons.list),
                    label: Text('Show all ${allParticipants.length}'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),

                  OutlinedButton.icon(
                    onPressed: _filteredParticipants.isEmpty ? null : () {
                      setState(() {
                        _selectAll = !_selectAll;
                        _selectedParticipants.clear();
                        _selectedParticipants.addAll(List.generate(
                          _filteredParticipants.length,
                              (index) => _selectAll,
                        ));
                      });
                    },
                    icon: Icon(_selectAll ? Icons.check_box : Icons.check_box_outline_blank),
                    label: Text('Select all ${_filteredParticipants.length}'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),


                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const IconButton(
                        onPressed: null,
                        icon: Icon(Icons.chevron_left),
                        color: Colors.grey,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue[700],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '1',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const IconButton(
                        onPressed: null,
                        icon: Icon(Icons.chevron_right),
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Participant {

  Participant({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.group,
    required this.lastAccess,
    required this.weight,
    required this.avatarUrl,
  });
  final int id;
  final String firstName;
  final String lastName;
  final String role;
  final String group;
  final String lastAccess;
  final double weight;
  final String avatarUrl;
}

class ParticipantListItem extends StatelessWidget {

  const ParticipantListItem({
    super.key,
    required this.participant,
    required this.isSelected,
    required this.onSelectedChanged,
  });
  final Participant participant;
  final bool isSelected;
  final Function(bool) onSelectedChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    onSelectedChanged(value ?? false);
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),


              CircleAvatar(
                backgroundImage: NetworkImage(participant.avatarUrl),
                radius: 18,
              ),

              const SizedBox(width: 12),

              Expanded(
                flex: 2,
                child: Text(
                  '${participant.firstName} ${participant.lastName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),

              Expanded(
                child: participant.weight > 0
                    ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getWeightColor(participant.weight).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${participant.weight.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: _getWeightColor(participant.weight),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                )
                    : const Text(
                  '-',
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              Expanded(
                child: Row(
                  children: [
                    Icon(
                      participant.role == 'Teacher' ? Icons.school : Icons.person,
                      size: 16,
                      color: participant.role == 'Teacher' ? Colors.purple[600] : Colors.blue[600],
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        participant.role,
                        style: TextStyle(
                          color: participant.role == 'Teacher' ? Colors.purple[600] : Colors.blue[600],
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: participant.group == 'No groups'
                        ? Colors.grey[100]
                        : Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    participant.group,
                    style: TextStyle(
                      color: participant.group == 'No groups'
                          ? Colors.grey[600]
                          : Colors.green[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              Expanded(
                child: Row(
                  children: [
                    Icon(
                      participant.lastAccess == 'Never' ? Icons.do_not_disturb : Icons.access_time,
                      size: 16,
                      color: participant.lastAccess == 'Never' ? Colors.red[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        participant.lastAccess,
                        style: TextStyle(
                          color: participant.lastAccess == 'Never'
                              ? Colors.red[500]
                              : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (participant.id != 30)
          const Divider(height: 1, indent: 88),
      ],
    );
  }

  Color _getWeightColor(double weight) {
    if (weight >= 80) return Colors.green[600]!;
    if (weight >= 60) return Colors.orange[600]!;
    return Colors.red[600]!;
  }
}