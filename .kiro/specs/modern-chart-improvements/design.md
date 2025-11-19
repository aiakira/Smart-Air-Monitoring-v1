# Design Document - Modern Chart Improvements

## Overview

Desain ini bertujuan untuk meningkatkan visualisasi grafik pada halaman analitik dengan menambahkan fitur-fitur modern seperti interaktivitas yang lebih baik, threshold lines, statistik ringkasan, dan kemampuan zoom/pan. Implementasi akan menggunakan library `fl_chart` yang sudah ada dengan kustomisasi tambahan untuk mencapai tampilan yang lebih modern dan informatif.

## Architecture

### Component Structure

```
AnalyticsPage (Existing - Modified)
├── TimeRangeSelector (New Widget)
├── SensorSelector (Existing - Enhanced)
├── ChartStatisticsCard (New Widget)
├── ModernLineChart (New Widget)
│   ├── ChartTouchHandler (New Class)
│   ├── ThresholdLinesRenderer (New Class)
│   └── ChartTooltip (New Widget)
└── HistoryTable (Existing - Keep as is)
```

### Data Flow

1. User memilih sensor dan time range
2. AnalyticsPage memuat data dari API atau sample data
3. Data diproses untuk menghitung statistik (min, max, avg, trend)
4. ModernLineChart menerima data dan konfigurasi threshold
5. User berinteraksi dengan chart (touch, zoom, pan)
6. ChartTouchHandler menangani interaksi dan menampilkan tooltip
7. Perubahan state memicu rebuild dengan animasi smooth

## Components and Interfaces

### 1. TimeRangeSelector Widget

Widget untuk memilih rentang waktu data yang ditampilkan.

```dart
class TimeRangeSelector extends StatelessWidget {
  final TimeRange selectedRange;
  final Function(TimeRange) onRangeChanged;
  
  // TimeRange options: 1h, 6h, 12h, 24h, 7d
}

enum TimeRange {
  oneHour(1, 'HH:mm'),
  sixHours(6, 'HH:mm'),
  twelveHours(12, 'HH:mm'),
  twentyFourHours(24, 'HH:mm'),
  sevenDays(168, 'dd/MM');
  
  final int hours;
  final String timeFormat;
}
```

**Design Decisions:**
- Menggunakan segmented button style untuk pilihan time range
- Menyimpan pilihan terakhir menggunakan SharedPreferences
- Format waktu pada sumbu X disesuaikan dengan rentang waktu

### 2. ChartStatisticsCard Widget

Widget untuk menampilkan statistik ringkasan data.

```dart
class ChartStatisticsCard extends StatelessWidget {
  final double minValue;
  final double maxValue;
  final double avgValue;
  final double? trendPercentage; // null jika tidak ada data sebelumnya
  final String unit;
  final Color color;
}

class StatisticItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Widget? trendIndicator;
}
```

**Design Decisions:**
- Menampilkan 3-4 statistik dalam row horizontal
- Menggunakan icon yang intuitif (arrow_downward untuk min, arrow_upward untuk max, show_chart untuk avg)
- Trend indicator menampilkan persentase perubahan dengan arrow up/down
- Responsive: stack vertical pada layar kecil

### 3. ModernLineChart Widget

Widget utama untuk menampilkan grafik dengan fitur modern.

```dart
class ModernLineChart extends StatefulWidget {
  final List<SensorData> data;
  final String sensorType; // 'CO₂', 'CO', 'Debu'
  final bool showThresholds;
  final bool enableZoom;
  final bool enableTooltip;
}

class _ModernLineChartState extends State<ModernLineChart> {
  int? touchedIndex;
  double minX = 0;
  double maxX = 0;
  double zoomLevel = 1.0;
  double panOffset = 0.0;
  
  // Methods
  void _handleTouch(FlTouchEvent event, LineTouchResponse? response);
  void _handleZoom(ScaleUpdateDetails details);
  void _handlePan(DragUpdateDetails details);
  void _resetZoom();
  List<HorizontalLine> _buildThresholdLines();
  LineChartBarData _buildLineChartBarData();
}
```

**Design Decisions:**
- Menggunakan GestureDetector untuk menangani zoom dan pan
- State management lokal untuk touch interaction
- Threshold lines dikonfigurasi berdasarkan sensor type
- Animasi smooth menggunakan AnimatedContainer dan Curves.easeInOut

### 4. ChartTouchHandler Class

Helper class untuk menangani touch interaction dan tooltip.

```dart
class ChartTouchHandler {
  static LineTouchData getTouchData({
    required Function(int?) onTouch,
    required BuildContext context,
    required String unit,
    required List<SensorData> data,
  }) {
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Colors.white,
        tooltipRoundedRadius: 8,
        tooltipPadding: EdgeInsets.all(12),
        getTooltipItems: (touchedSpots) => _buildTooltipItems(touchedSpots, unit, data),
      ),
      touchCallback: (event, response) => _handleTouchCallback(event, response, onTouch),
      handleBuiltInTouches: true,
    );
  }
  
  static List<LineTooltipItem> _buildTooltipItems(
    List<LineBarSpot> touchedSpots,
    String unit,
    List<SensorData> data,
  );
  
  static void _handleTouchCallback(
    FlTouchEvent event,
    LineTouchResponse? response,
    Function(int?) onTouch,
  );
}
```

**Design Decisions:**
- Tooltip menampilkan: nilai, unit, waktu, kategori kualitas udara
- Tooltip background putih dengan shadow untuk kontras
- Tooltip positioning otomatis untuk menghindari terpotong
- Haptic feedback saat touch (menggunakan HapticFeedback.selectionClick)

### 5. ThresholdLinesRenderer Class

Helper class untuk membuat threshold lines berdasarkan sensor type.

```dart
class ThresholdLinesRenderer {
  static List<HorizontalLine> getThresholdLines(String sensorType) {
    switch (sensorType) {
      case 'CO₂':
        return _getCO2Thresholds();
      case 'CO':
        return _getCOThresholds();
      case 'Debu':
        return _getDustThresholds();
      default:
        return [];
    }
  }
  
  static List<HorizontalLine> _getCO2Thresholds() {
    return [
      HorizontalLine(
        y: 800,
        color: Colors.green.withOpacity(0.3),
        strokeWidth: 2,
        dashArray: [5, 5],
        label: HorizontalLineLabel(
          show: true,
          labelResolver: (line) => 'BAIK',
          style: TextStyle(color: Colors.green, fontSize: 10),
        ),
      ),
      HorizontalLine(y: 1000, color: Colors.yellow.withOpacity(0.3), ...),
      HorizontalLine(y: 2000, color: Colors.orange.withOpacity(0.3), ...),
      HorizontalLine(y: 5000, color: Colors.red.withOpacity(0.3), ...),
    ];
  }
  
  // Similar methods for CO and Dust
}
```

**Design Decisions:**
- Threshold lines menggunakan dashed style untuk membedakan dari data line
- Warna threshold sesuai dengan kategori (hijau, kuning, orange, merah)
- Label threshold ditampilkan di sisi kanan grafik
- Opacity 0.3 agar tidak mengganggu pembacaan data line

### 6. Enhanced Chart Styling

Konfigurasi styling untuk grafik yang lebih modern.

```dart
class ChartStyling {
  static const double lineWidth = 3.0;
  static const double dotSize = 6.0;
  static const double touchedDotSize = 10.0;
  
  static LinearGradient getGradient(Color color) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withOpacity(0.3),
        color.withOpacity(0.05),
      ],
    );
  }
  
  static List<Color> getGradientColors(Color baseColor) {
    return [
      baseColor.withOpacity(0.8),
      baseColor.withOpacity(0.4),
    ];
  }
  
  static Shadow getLineShadow() {
    return Shadow(
      color: Colors.black.withOpacity(0.2),
      offset: Offset(0, 2),
      blurRadius: 4,
    );
  }
}
```

## Data Models

### ChartConfiguration Model

```dart
class ChartConfiguration {
  final String sensorType;
  final TimeRange timeRange;
  final bool showThresholds;
  final bool showStatistics;
  final bool enableZoom;
  final bool enableMultiSensor;
  final List<String> selectedSensors; // for multi-sensor view
  
  ChartConfiguration({
    required this.sensorType,
    this.timeRange = TimeRange.twentyFourHours,
    this.showThresholds = true,
    this.showStatistics = true,
    this.enableZoom = true,
    this.enableMultiSensor = false,
    this.selectedSensors = const [],
  });
  
  ChartConfiguration copyWith({...});
  
  // Save/load from SharedPreferences
  Map<String, dynamic> toJson();
  factory ChartConfiguration.fromJson(Map<String, dynamic> json);
}
```

### ChartStatistics Model

```dart
class ChartStatistics {
  final double minValue;
  final double maxValue;
  final double avgValue;
  final double? trendPercentage;
  final DateTime minTimestamp;
  final DateTime maxTimestamp;
  
  factory ChartStatistics.fromData(List<SensorData> data, String sensorType) {
    // Calculate statistics from data
  }
  
  String getTrendDescription() {
    if (trendPercentage == null) return 'Tidak ada data sebelumnya';
    if (trendPercentage! > 5) return 'Meningkat signifikan';
    if (trendPercentage! > 0) return 'Meningkat sedikit';
    if (trendPercentage! < -5) return 'Menurun signifikan';
    if (trendPercentage! < 0) return 'Menurun sedikit';
    return 'Stabil';
  }
}
```

## Error Handling

### Network Errors
- Tampilkan snackbar dengan pesan error
- Fallback ke sample data jika API tidak tersedia
- Retry button pada error state
- Cache data terakhir untuk offline viewing

### Invalid Data
- Validasi data sebelum render (check for null, NaN, infinity)
- Skip data points yang invalid
- Log warning untuk debugging
- Tampilkan pesan jika semua data invalid

### Touch/Gesture Conflicts
- Prioritas gesture: zoom > pan > touch
- Disable scroll parent saat interaksi dengan chart
- Debounce touch events untuk performa
- Cancel gesture jika keluar dari chart area

## Testing Strategy

### Unit Tests
1. Test ChartStatistics calculation (min, max, avg, trend)
2. Test ThresholdLinesRenderer untuk setiap sensor type
3. Test TimeRange enum dan format conversion
4. Test ChartConfiguration serialization/deserialization

### Widget Tests
1. Test TimeRangeSelector interaction dan callback
2. Test ChartStatisticsCard rendering dengan berbagai data
3. Test ModernLineChart dengan data kosong, data normal, data ekstrem
4. Test tooltip rendering dan positioning

### Integration Tests
1. Test full flow: pilih sensor → pilih time range → lihat grafik
2. Test zoom dan pan interaction
3. Test multi-sensor comparison
4. Test threshold lines visibility toggle
5. Test data refresh dan loading state

### Manual Testing Checklist
- [ ] Grafik terlihat smooth pada berbagai ukuran layar
- [ ] Tooltip tidak terpotong di edge layar
- [ ] Zoom dan pan bekerja dengan natural
- [ ] Threshold lines sesuai dengan standar sensor
- [ ] Statistik akurat dan update real-time
- [ ] Performa baik dengan data besar (1000+ points)
- [ ] Animasi smooth tanpa lag
- [ ] Responsive pada orientasi landscape dan portrait

## Implementation Notes

### Performance Optimization
1. **Data Sampling**: Untuk data > 100 points, lakukan sampling untuk mengurangi render load
2. **Lazy Loading**: Load data secara incremental untuk time range besar
3. **Memoization**: Cache calculated values (statistics, threshold lines)
4. **Debouncing**: Debounce zoom/pan events untuk mengurangi rebuild
5. **RepaintBoundary**: Wrap chart dengan RepaintBoundary untuk isolasi repaint

### Accessibility
1. Semantic labels untuk screen readers
2. Sufficient color contrast untuk threshold lines
3. Touch target minimal 44x44 pixel
4. Alternative text description untuk grafik
5. Support untuk text scaling

### Responsive Design
- Breakpoint untuk tablet: 600dp
- Breakpoint untuk desktop: 1024dp
- Font scaling: 0.8x untuk small, 1.0x untuk medium, 1.2x untuk large
- Chart height: 40% viewport height pada mobile, 60% pada tablet
- Hide detailed labels pada layar < 360dp width

### Animation Timing
- Chart data transition: 800ms dengan Curves.easeInOut
- Tooltip appear/disappear: 200ms dengan Curves.easeOut
- Zoom animation: 300ms dengan Curves.easeInOutCubic
- Statistics update: 400ms dengan Curves.easeInOut

## Migration Plan

### Phase 1: Core Chart Improvements (Priority High)
- Implement ModernLineChart dengan styling baru
- Add ChartTouchHandler untuk tooltip
- Add ThresholdLinesRenderer
- Update AnalyticsPage untuk menggunakan ModernLineChart

### Phase 2: Statistics and Time Range (Priority High)
- Implement ChartStatisticsCard
- Implement TimeRangeSelector
- Add statistics calculation logic
- Integrate dengan existing data loading

### Phase 3: Advanced Interactions (Priority Medium)
- Implement zoom dan pan functionality
- Add reset zoom button
- Optimize gesture handling
- Add haptic feedback

### Phase 4: Multi-Sensor Comparison (Priority Low)
- Implement multi-sensor selection
- Add dual Y-axis support
- Implement legend dengan toggle
- Add color coordination

### Phase 5: Polish and Optimization (Priority Medium)
- Performance optimization (sampling, memoization)
- Accessibility improvements
- Responsive design refinements
- Animation tuning

## Dependencies

Existing dependencies (no new dependencies required):
- `fl_chart: ^0.68.0` - Chart library
- `intl: ^0.19.0` - Date formatting
- `http: ^1.1.0` - API calls

Optional future dependencies:
- `shared_preferences` - For saving user preferences (time range, chart config)
- `flutter_svg` - If we want to add custom icons for statistics
