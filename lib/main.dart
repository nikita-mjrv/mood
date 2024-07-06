import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting('ru_RU', null).then((_) {
    runApp(const MoodDiaryApp());
  });
}

class MoodDiaryApp extends StatelessWidget {
  const MoodDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Diary',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const MoodDiaryPage(),
    );
  }
}

class MoodDiaryPage extends StatefulWidget {
  const MoodDiaryPage({super.key});

  @override
  _MoodDiaryPageState createState() => _MoodDiaryPageState();
}

class _MoodDiaryPageState extends State<MoodDiaryPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String? selectedMood;
  double stressLevel = 0;
  double selfEsteem = 0;
  TextEditingController notesController = TextEditingController();
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _showCalendarModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            Expanded(child: _buildCalendar()),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if ((_formKey.currentState?.validate() ?? false) && selectedMood != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Анкета успешно отправлена'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Закрыть'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Заполните все поля!'),
            content: selectedMood == null
                ? const Text('Пожалуйста, выберите настроение.')
                : null,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Закрыть'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(DateFormat('dd MMMM HH:mm', 'ru_RU').format(DateTime.now())),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showCalendarModal,
          ),
        ],
        bottom: TabBar(
          labelColor: Colors.orange,
          dividerColor: Colors.orange,
          controller: _tabController,
          tabs: const [
            Tab(text: 'Дневник настроения'),
            Tab(text: 'Статистика'),
          ],
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMoodDiaryForm(),
          _buildStatisticsScreen(),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    );
  }

  Widget _buildMoodDiaryForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Что чувствуешь?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildToggleButton('Радость', 'assets/radost.png', 'Joy'),
                    const SizedBox(width: 8),
                    _buildToggleButton('Страх', 'assets/strax.png', 'Fear'),
                    const SizedBox(width: 8),
                    _buildToggleButton(
                        'Бешенство', 'assets/beshenstvo.png', 'Anger'),
                    const SizedBox(width: 8),
                    _buildToggleButton('Грусть', 'assets/grust.png', 'Sadness'),
                    const SizedBox(width: 8),
                    _buildToggleButton(
                        'Спокойствие', 'assets/spokoy.png', 'Calm'),
                    const SizedBox(width: 8),
                    _buildToggleButton('Сила', 'assets/sila.png', 'Strength'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Уровень стресса',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildLabeledSlider(
              stressLevel,
              (value) {
                setState(() {
                  stressLevel = value;
                });
              },
              'Низкий',
              'Высокий',
            ),
            const SizedBox(height: 20),
            const Text(
              'Самооценка',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildLabeledSlider(
              selfEsteem,
              (value) {
                setState(() {
                  selfEsteem = value;
                });
              },
              'Неуверенность',
              'Уверенность',
            ),
            const SizedBox(height: 20),
            const Text(
              'Заметки',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            TextFormField(
              controller: notesController,
              decoration: const InputDecoration(
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Напиши о том, как ты себя чувствуешь';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.orange),
                ),
                onPressed: _submitForm,
                child: const Text(
                  'Сохранить',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, String imagePath, String mood) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMood = mood;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedMood == mood ? Colors.orange : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            Image.asset(imagePath, width: 55, height: 60),
            Text(text, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledSlider(double value, ValueChanged<double> onChanged,
      String startLabel, String endLabel) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.orange,
                inactiveTrackColor: Colors.grey[300],
                trackHeight: 6.0,
                thumbColor: Colors.orange,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                overlayColor: Colors.orange.withAlpha(32),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 28.0),
                valueIndicatorColor: Colors.orange),
            child: Slider(
              value: value,
              onChanged: onChanged,
              min: 0,
              max: 10,
              divisions: 10,
              label: value.round().toString(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(startLabel, style: const TextStyle(color: Colors.grey)),
                Text(endLabel, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Статистика настроений',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 1),
                      const FlSpot(1, 2),
                      const FlSpot(2, 1),
                      const FlSpot(3, 4),
                      const FlSpot(4, 3),
                    ],
                    isCurved: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                borderData: FlBorderData(show: true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
