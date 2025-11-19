# Implementation Plan

- [ ] 1. Setup helper classes dan utilities untuk chart
- [ ] 1.1 Buat ChartStyling class dengan konstanta styling modern
  - Definisikan line width, dot size, colors, gradients, dan shadows
  - Buat method untuk generate gradient colors berdasarkan base color
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [ ] 1.2 Buat ThresholdLinesRenderer class untuk threshold lines
  - Implementasi method getThresholdLines yang return list HorizontalLine berdasarkan sensor type
  - Buat private methods untuk CO₂, CO, dan Debu thresholds dengan warna dan label yang sesuai
  - Gunakan dashed line style dan opacity untuk threshold lines
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ] 1.3 Buat ChartConfiguration model untuk menyimpan konfigurasi chart
  - Definisikan properties: sensorType, timeRange, showThresholds, enableZoom, dll
  - Implementasi copyWith method untuk immutable updates
  - Implementasi toJson dan fromJson untuk persistence
  - _Requirements: 4.5_

- [ ] 1.4 Buat ChartStatistics model untuk statistik data
  - Implementasi factory method fromData untuk calculate min, max, avg dari sensor data
  - Tambahkan logic untuk calculate trend percentage dengan membandingkan periode sebelumnya
  - Buat method getTrendDescription untuk deskripsi trend yang user-friendly
  - _Requirements: 5.1, 5.2, 5.3, 5.5_

- [ ] 2. Implementasi TimeRange enum dan TimeRangeSelector widget
- [ ] 2.1 Buat TimeRange enum dengan options dan properties
  - Definisikan enum values: oneHour, sixHours, twelveHours, twentyFourHours, sevenDays
  - Tambahkan properties hours dan timeFormat untuk setiap value
  - Buat helper methods untuk conversion dan formatting
  - _Requirements: 4.1, 4.4_

- [ ] 2.2 Buat TimeRangeSelector widget dengan segmented button style
  - Implementasi UI dengan SegmentedButton atau custom button group
  - Handle onRangeChanged callback saat user memilih time range
  - Tambahkan visual indicator untuk selected range
  - Style dengan rounded corners dan colors yang sesuai tema
  - _Requirements: 4.1, 4.2, 8.2_

- [ ] 3. Implementasi ChartStatisticsCard widget
- [ ] 3.1 Buat StatisticItem widget untuk menampilkan satu statistik
  - Implementasi layout dengan icon, label, value, dan optional trend indicator
  - Gunakan colors yang sesuai untuk setiap type statistik
  - Tambahkan responsive sizing untuk berbagai ukuran layar
  - _Requirements: 5.1, 5.2, 5.4, 8.1_

- [ ] 3.2 Buat ChartStatisticsCard widget yang menampilkan semua statistik
  - Layout horizontal dengan Row untuk desktop/tablet, vertical dengan Column untuk mobile
  - Tampilkan min, max, avg values dengan icons yang intuitif
  - Tampilkan trend indicator dengan arrow dan percentage
  - Implementasi auto-update saat data berubah
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 8.2, 8.3_

- [ ] 4. Implementasi ChartTouchHandler untuk interaktivitas
- [ ] 4.1 Buat ChartTouchHandler class dengan static methods
  - Implementasi getTouchData method yang return LineTouchData configuration
  - Buat _buildTooltipItems method untuk custom tooltip content
  - Implementasi _handleTouchCallback untuk handle touch events
  - _Requirements: 2.1, 2.2, 2.3_

- [ ] 4.2 Implementasi custom tooltip dengan informasi lengkap
  - Tampilkan nilai sensor, unit, timestamp, dan kategori kualitas udara
  - Style tooltip dengan background putih, rounded corners, dan shadow
  - Implementasi positioning logic agar tooltip tidak terpotong di edge layar
  - Tambahkan animasi smooth untuk appear/disappear
  - _Requirements: 2.1, 2.2, 2.4, 2.5_

- [ ] 4.3 Tambahkan visual indicator pada touched data point
  - Tampilkan dot dengan size lebih besar pada data point yang di-touch
  - Gunakan warna yang kontras untuk visibility
  - Implementasi smooth transition saat berpindah antar data points
  - _Requirements: 2.3_

- [ ] 5. Implementasi ModernLineChart widget dengan fitur modern
- [ ] 5.1 Buat ModernLineChart StatefulWidget dengan state management
  - Definisikan properties: data, sensorType, showThresholds, enableZoom, enableTooltip
  - Setup state variables: touchedIndex, minX, maxX, zoomLevel, panOffset
  - Implementasi initState dan dispose untuk lifecycle management
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [ ] 5.2 Implementasi _buildLineChartBarData method untuk styling garis grafik
  - Gunakan ChartStyling constants untuk line width dan colors
  - Implementasi gradient untuk area di bawah garis dengan BarAreaData
  - Set isCurved true untuk smooth curve dengan cubic bezier
  - Tambahkan shadow effect pada garis grafik
  - Configure dots untuk show/hide berdasarkan zoom level
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [ ] 5.3 Implementasi grid lines dan axis titles yang jelas
  - Configure FlGridData dengan warna abu-abu transparan
  - Setup AxisTitles untuk left dan bottom dengan formatting yang sesuai
  - Implementasi dynamic label formatting berdasarkan time range
  - Hide labels yang terlalu padat pada layar kecil
  - _Requirements: 1.4, 4.4, 8.4_

- [ ] 5.4 Integrasikan ThresholdLinesRenderer untuk menampilkan threshold lines
  - Panggil ThresholdLinesRenderer.getThresholdLines berdasarkan sensorType
  - Tambahkan threshold lines ke LineChartData extraLinesData
  - Implementasi toggle untuk show/hide thresholds
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ] 5.5 Integrasikan ChartTouchHandler untuk tooltip interactivity
  - Setup LineTouchData menggunakan ChartTouchHandler.getTouchData
  - Pass callback untuk update touchedIndex state
  - Implementasi haptic feedback saat touch menggunakan HapticFeedback.selectionClick
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [ ] 5.6 Implementasi zoom dan pan functionality
  - Wrap LineChart dengan GestureDetector untuk handle pinch dan swipe
  - Implementasi _handleZoom method untuk ScaleUpdateDetails
  - Implementasi _handlePan method untuk DragUpdateDetails
  - Buat _resetZoom method dan button untuk reset ke default view
  - Batasi zoom min/max dan pan boundaries
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [ ] 5.7 Implementasi animasi smooth untuk transisi data
  - Gunakan AnimatedContainer atau ImplicitlyAnimatedWidget
  - Set duration 800ms dengan Curves.easeInOut untuk data changes
  - Implementasi animation untuk zoom dan pan dengan duration 300ms
  - _Requirements: 2.4_

- [ ] 6. Update AnalyticsPage untuk menggunakan komponen baru
- [ ] 6.1 Refactor AnalyticsPage untuk integrate TimeRangeSelector
  - Tambahkan TimeRangeSelector widget di atas sensor selector
  - Implementasi onRangeChanged callback untuk load data dengan time range baru
  - Update _loadHistoricalData method untuk accept hours parameter dari TimeRange
  - _Requirements: 4.1, 4.2, 4.3_

- [ ] 6.2 Integrate ChartStatisticsCard di atas grafik
  - Calculate statistics menggunakan ChartStatistics.fromData
  - Tampilkan ChartStatisticsCard dengan data yang calculated
  - Implementasi auto-update saat sensor atau time range berubah
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ] 6.3 Replace existing LineChart dengan ModernLineChart
  - Ganti _buildLineChart method untuk return ModernLineChart widget
  - Pass semua required properties: data, sensorType, showThresholds, dll
  - Remove old chart building logic yang sudah tidak dipakai
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.2, 2.3, 3.1, 3.2_

- [ ] 6.4 Implementasi loading state dan error handling yang lebih baik
  - Tampilkan skeleton loader saat loading data
  - Improve error message display dengan actionable retry button
  - Tambahkan pull-to-refresh functionality
  - _Requirements: 4.3_

- [ ] 7. Implementasi responsive design untuk berbagai ukuran layar
- [ ] 7.1 Tambahkan MediaQuery checks untuk responsive layout
  - Definisikan breakpoints untuk mobile, tablet, desktop
  - Adjust chart height berdasarkan viewport size
  - Implement responsive font sizing untuk labels dan titles
  - _Requirements: 8.1, 8.2_

- [ ] 7.2 Implementasi layout adaptations untuk orientasi landscape
  - Maximize chart area saat landscape orientation
  - Adjust statistics card layout untuk landscape
  - Ensure controls tetap accessible di landscape mode
  - _Requirements: 8.3_

- [ ] 7.3 Optimize untuk layar kecil
  - Hide atau simplify labels pada layar < 360dp width
  - Ensure touch targets minimal 44x44 pixel
  - Test scrolling dan interaction pada small screens
  - _Requirements: 8.4, 8.5_

- [ ] 8. Performance optimization dan polish
- [ ] 8.1 Implementasi data sampling untuk dataset besar
  - Buat method untuk sample data jika points > 100
  - Maintain data accuracy dengan smart sampling algorithm
  - Test performa dengan 1000+ data points
  - _Requirements: Performance optimization_

- [ ] 8.2 Tambahkan memoization untuk expensive calculations
  - Cache calculated statistics untuk avoid recalculation
  - Memoize threshold lines generation
  - Use const constructors where possible
  - _Requirements: Performance optimization_

- [ ] 8.3 Wrap chart dengan RepaintBoundary untuk isolasi repaint
  - Add RepaintBoundary around ModernLineChart
  - Test repaint performance dengan Flutter DevTools
  - _Requirements: Performance optimization_

- [ ] 8.4 Implementasi debouncing untuk zoom/pan events
  - Debounce gesture events untuk reduce rebuild frequency
  - Optimize gesture handling untuk smooth interaction
  - _Requirements: 6.1, 6.2, Performance optimization_

- [ ]* 9. Testing dan quality assurance
- [ ]* 9.1 Write unit tests untuk helper classes
  - Test ChartStatistics calculation accuracy
  - Test ThresholdLinesRenderer untuk semua sensor types
  - Test ChartConfiguration serialization
  - _Requirements: All requirements_

- [ ]* 9.2 Write widget tests untuk UI components
  - Test TimeRangeSelector interaction
  - Test ChartStatisticsCard rendering
  - Test ModernLineChart dengan berbagai data scenarios
  - Test tooltip rendering dan positioning
  - _Requirements: All requirements_

- [ ]* 9.3 Perform manual testing pada berbagai devices
  - Test pada small phone, large phone, tablet
  - Test pada Android dan iOS
  - Test zoom, pan, dan touch interactions
  - Verify threshold lines accuracy
  - Check responsive behavior
  - _Requirements: All requirements_

- [ ]* 9.4 Performance testing dan optimization
  - Profile dengan Flutter DevTools
  - Test dengan large datasets (1000+ points)
  - Measure frame rendering time
  - Optimize bottlenecks jika ditemukan
  - _Requirements: Performance optimization_
