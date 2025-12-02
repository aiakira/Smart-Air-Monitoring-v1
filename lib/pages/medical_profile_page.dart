import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
import '../models/medical_profile.dart';
import '../theme/app_theme.dart';
import '../services/report_service.dart';
import '../services/emergency_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MedicalProfilePage extends StatefulWidget {
  const MedicalProfilePage({super.key});

  @override
  State<MedicalProfilePage> createState() => _MedicalProfilePageState();
}

class _MedicalProfilePageState extends State<MedicalProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  
  String _gender = 'Laki-laki';
  List<String> _selectedAllergies = [];
  List<String> _selectedConditions = [];
  bool _isAsthmatic = false;
  bool _isSmoker = false;
  String _activityLevel = 'MODERATE';
  
  List<MedicationReminder> _medications = [];
  List<EmergencyContact> _emergencyContacts = [];
  
  final List<String> _availableAllergies = [
    'Debu',
    'Polusi Udara',
    'Serbuk Sari',
    'Asap Rokok',
    'Bulu Hewan',
    'Jamur',
    'Parfum/Pewangi',
  ];
  
  final List<String> _availableConditions = [
    'Asma',
    'PPOK',
    'Bronkitis Kronis',
    'Rhinitis Alergi',
    'Sinusitis',
    'Penyakit Jantung',
    'Hipertensi',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  void _loadExistingProfile() {
    final healthProvider = context.read<HealthProvider>();
    final profile = healthProvider.medicalProfile;
    
    if (profile != null) {
      _nameController.text = profile.name;
      _ageController.text = profile.age.toString();
      _gender = profile.gender;
      _selectedAllergies = List.from(profile.allergies);
      _selectedConditions = List.from(profile.medicalConditions);
      _isAsthmatic = profile.isAsthmatic;
      _isSmoker = profile.isSmoker;
      _activityLevel = profile.activityLevel;
      _medications = List.from(profile.medications);
      _emergencyContacts = List.from(profile.emergencyContacts);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Medis'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _exportReport();
                  break;
                case 'emergency':
                  _showEmergencyContacts();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_download),
                    SizedBox(width: 8),
                    Text('Export Laporan'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'emergency',
                child: Row(
                  children: [
                    Icon(Icons.emergency),
                    SizedBox(width: 8),
                    Text('Kontak Darurat'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildHealthConditionsSection(),
              const SizedBox(height: 24),
              _buildMedicationsSection(),
              const SizedBox(height: 24),
              _buildEmergencyContactsSection(),
              const SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Dasar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Usia',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Usia tidak boleh kosong';
                      }
                      final age = int.tryParse(value);
                      if (age == null || age < 1 || age > 120) {
                        return 'Usia tidak valid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: const InputDecoration(
                      labelText: 'Jenis Kelamin',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Laki-laki', 'Perempuan'].map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _activityLevel,
              decoration: const InputDecoration(
                labelText: 'Level Aktivitas',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'LOW', child: Text('Rendah - Jarang olahraga')),
                DropdownMenuItem(value: 'MODERATE', child: Text('Sedang - Olahraga rutin')),
                DropdownMenuItem(value: 'HIGH', child: Text('Tinggi - Atlet/Aktif')),
              ],
              onChanged: (value) {
                setState(() {
                  _activityLevel = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthConditionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kondisi Kesehatan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('Penderita Asma'),
              subtitle: const Text('Mempengaruhi threshold kualitas udara'),
              value: _isAsthmatic,
              onChanged: (value) {
                setState(() {
                  _isAsthmatic = value;
                });
              },
            ),
            
            SwitchListTile(
              title: const Text('Perokok'),
              subtitle: const Text('Mempengaruhi analisis kesehatan'),
              value: _isSmoker,
              onChanged: (value) {
                setState(() {
                  _isSmoker = value;
                });
              },
            ),
            
            const SizedBox(height: 16),
            const Text('Alergi:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableAllergies.map((allergy) {
                return FilterChip(
                  label: Text(allergy),
                  selected: _selectedAllergies.contains(allergy),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedAllergies.add(allergy);
                      } else {
                        _selectedAllergies.remove(allergy);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            const Text('Kondisi Medis:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableConditions.map((condition) {
                return FilterChip(
                  label: Text(condition),
                  selected: _selectedConditions.contains(condition),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedConditions.add(condition);
                      } else {
                        _selectedConditions.remove(condition);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Obat-obatan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addMedication,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_medications.isEmpty)
              const Text(
                'Belum ada obat yang ditambahkan',
                style: TextStyle(color: Colors.grey),
              )
            else
              ..._medications.map((medication) => _buildMedicationTile(medication)),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationTile(MedicationReminder medication) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.medication),
        title: Text(medication.medicationName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dosis: ${medication.dosage}'),
            Text('Waktu: ${medication.times.join(", ")}'),
            if (medication.notes != null && medication.notes!.isNotEmpty)
              Text('Catatan: ${medication.notes}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: medication.isActive,
              onChanged: (value) {
                setState(() {
                  final index = _medications.indexOf(medication);
                  _medications[index] = MedicationReminder(
                    id: medication.id,
                    medicationName: medication.medicationName,
                    dosage: medication.dosage,
                    times: medication.times,
                    frequency: medication.frequency,
                    isActive: value,
                    notes: medication.notes,
                  );
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  _medications.remove(medication);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kontak Darurat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addEmergencyContact,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_emergencyContacts.isEmpty)
              const Text(
                'Belum ada kontak darurat',
                style: TextStyle(color: Colors.grey),
              )
            else
              ..._emergencyContacts.map((contact) => _buildEmergencyContactTile(contact)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactTile(EmergencyContact contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          contact.isPrimary ? Icons.star : Icons.person,
          color: contact.isPrimary ? Colors.orange : null,
        ),
        title: Text(contact.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${contact.relationship} - ${contact.phoneNumber}'),
            if (contact.email != null && contact.email!.isNotEmpty)
              Text('Email: ${contact.email}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () => EmergencyService.makeEmergencyCall(contact.phoneNumber),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  _emergencyContacts.remove(contact);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _saveProfile,
        icon: const Icon(Icons.save),
        label: const Text('Simpan Profil Medis'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  void _addMedication() {
    showDialog(
      context: context,
      builder: (context) => _MedicationDialog(
        onSave: (medication) {
          setState(() {
            _medications.add(medication);
          });
        },
      ),
    );
  }

  void _addEmergencyContact() {
    showDialog(
      context: context,
      builder: (context) => _EmergencyContactDialog(
        onSave: (contact) {
          setState(() {
            _emergencyContacts.add(contact);
          });
        },
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final profile = MedicalProfile(
        userId: 'user_1', // In real app, get from auth
        name: _nameController.text,
        age: int.parse(_ageController.text),
        gender: _gender,
        allergies: _selectedAllergies,
        medicalConditions: _selectedConditions,
        medications: _medications,
        emergencyContacts: _emergencyContacts,
        personalThresholds: {
          'co2': _isAsthmatic ? 800.0 : 1000.0,
          'dust': _isAsthmatic ? 25.0 : 35.0,
        },
        isAsthmatic: _isAsthmatic,
        isSmoker: _isSmoker,
        activityLevel: _activityLevel,
      );

      context.read<HealthProvider>().saveMedicalProfile(profile);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil medis berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _exportReport() async {
    final healthProvider = context.read<HealthProvider>();
    
    try {
      final report = await ReportService.generateDoctorReport(
        medicalProfile: healthProvider.medicalProfile,
        healthData: healthProvider.healthData,
        symptoms: healthProvider.symptoms,
        sensorHistory: [], // Would get from sensor provider
        daysBack: 30,
      );
      
      final fileName = 'laporan_kesehatan_${DateTime.now().millisecondsSinceEpoch}';
      await ReportService.shareReport(report, fileName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEmergencyContacts() {
    if (_emergencyContacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belum ada kontak darurat yang tersimpan'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kontak Darurat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _emergencyContacts.map((contact) {
            return ListTile(
              leading: Icon(
                contact.isPrimary ? Icons.star : Icons.person,
                color: contact.isPrimary ? Colors.orange : null,
              ),
              title: Text(contact.name),
              subtitle: Text(contact.phoneNumber),
              trailing: IconButton(
                icon: const Icon(Icons.call, color: Colors.green),
                onPressed: () {
                  Navigator.pop(context);
                  EmergencyService.makeEmergencyCall(contact.phoneNumber);
                },
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

// Dialog for adding medication
class _MedicationDialog extends StatefulWidget {
  final Function(MedicationReminder) onSave;

  const _MedicationDialog({required this.onSave});

  @override
  State<_MedicationDialog> createState() => _MedicationDialogState();
}

class _MedicationDialogState extends State<_MedicationDialog> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();
  final List<String> _times = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Obat'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Obat'),
            ),
            TextField(
              controller: _dosageController,
              decoration: const InputDecoration(labelText: 'Dosis'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Waktu Minum:'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTime,
                ),
              ],
            ),
            ..._times.map((time) => ListTile(
              title: Text(time),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _times.remove(time);
                  });
                },
              ),
            )),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _nameController.text.isNotEmpty && _dosageController.text.isNotEmpty
              ? () {
                  final medication = MedicationReminder(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    medicationName: _nameController.text,
                    dosage: _dosageController.text,
                    times: _times,
                    frequency: 'DAILY',
                    isActive: true,
                    notes: _notesController.text.isEmpty ? null : _notesController.text,
                  );
                  widget.onSave(medication);
                  Navigator.pop(context);
                }
              : null,
          child: const Text('Simpan'),
        ),
      ],
    );
  }

  void _addTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (time != null) {
      setState(() {
        _times.add('${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
      });
    }
  }
}

// Dialog for adding emergency contact
class _EmergencyContactDialog extends StatefulWidget {
  final Function(EmergencyContact) onSave;

  const _EmergencyContactDialog({required this.onSave});

  @override
  State<_EmergencyContactDialog> createState() => _EmergencyContactDialogState();
}

class _EmergencyContactDialogState extends State<_EmergencyContactDialog> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String _relationship = 'Keluarga';
  bool _isPrimary = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Kontak Darurat'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Nomor Telepon'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email (opsional)'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _relationship,
              decoration: const InputDecoration(labelText: 'Hubungan'),
              items: ['Keluarga', 'Teman', 'Dokter', 'Tetangga', 'Lainnya']
                  .map((rel) => DropdownMenuItem(value: rel, child: Text(rel)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _relationship = value!;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Kontak Utama'),
              value: _isPrimary,
              onChanged: (value) {
                setState(() {
                  _isPrimary = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _nameController.text.isNotEmpty && _phoneController.text.isNotEmpty
              ? () {
                  final contact = EmergencyContact(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text,
                    relationship: _relationship,
                    phoneNumber: _phoneController.text,
                    email: _emailController.text.isEmpty ? null : _emailController.text,
                    isPrimary: _isPrimary,
                  );
                  widget.onSave(contact);
                  Navigator.pop(context);
                }
              : null,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}