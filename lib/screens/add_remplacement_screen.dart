import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/remplacement.dart';
import '../providers/remplacement_provider.dart';

class AddRemplacementScreen extends StatefulWidget {
  final Remplacement? remplacement;

  const AddRemplacementScreen({super.key, this.remplacement});

  @override
  State<AddRemplacementScreen> createState() => _AddRemplacementScreenState();
}

enum MontantInputMode { avantRetro, apresRetro }

class _AddRemplacementScreenState extends State<AddRemplacementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medecinController = TextEditingController();
  final _montantController = TextEditingController();
  final _joursController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _dateDebut = DateTime.now();
  DateTime _dateFin = DateTime.now();
  int _tauxRetrocession = 70;
  String _modePaiement = 'Virement';
  String _statutPaiement = 'En attente';
  MontantInputMode _inputMode = MontantInputMode.avantRetro;

  bool get isEditing => widget.remplacement != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final r = widget.remplacement!;
      _medecinController.text = r.medecinRemplace;
      _montantController.text = r.montantAvantRetrocession.toString();
      _joursController.text = r.nombreJours.toString();
      _notesController.text = r.notes ?? '';
      _dateDebut = r.dateDebut;
      _dateFin = r.dateFin;
      _tauxRetrocession = r.tauxRetrocession;
      _modePaiement = r.modePaiement ?? 'Virement';
      _statutPaiement = r.statutPaiement;
    }
  }

  @override
  void dispose() {
    _medecinController.dispose();
    _montantController.dispose();
    _joursController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Calculs selon le mode de saisie
  double get _montantAvantRetro {
    final montantSaisi = double.tryParse(_montantController.text) ?? 0;
    if (_inputMode == MontantInputMode.avantRetro) {
      // Mode: Montant avant rétro → on retourne directement
      return montantSaisi;
    } else {
      // Mode: Montant après rétro → on calcule le montant avant
      // montant_avant = montant_apres / (taux / 100)
      final tauxDecimal = _tauxRetrocession / 100;
      return tauxDecimal > 0 ? montantSaisi / tauxDecimal : 0;
    }
  }

  double get _montantRetrocession {
    return _montantAvantRetro * (_tauxRetrocession / 100);
  }

  double get _montantApresRetro {
    final montantSaisi = double.tryParse(_montantController.text) ?? 0;
    if (_inputMode == MontantInputMode.avantRetro) {
      // Mode: Montant avant → on calcule après
      return montantSaisi * (_tauxRetrocession / 100);
    } else {
      // Mode: Montant après → on retourne directement
      return montantSaisi;
    }
  }

  double get _urssaf => _montantApresRetro * 0.22;
  double get _net => _montantApresRetro - _urssaf;

  Future<void> _selectDate(bool isDebut) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDebut ? _dateDebut : _dateFin,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isDebut) {
          _dateDebut = picked;
          if (_dateFin.isBefore(_dateDebut)) {
            _dateFin = _dateDebut;
          }
        } else {
          _dateFin = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final remplacement = Remplacement(
        id: widget.remplacement?.id,
        dateDebut: _dateDebut,
        dateFin: _dateFin,
        medecinRemplace: _medecinController.text.trim(),
        nombreJours: double.parse(_joursController.text),
        tauxRetrocession: _tauxRetrocession,
        montantAvantRetrocession: _montantAvantRetro,
        modePaiement: _modePaiement,
        statutPaiement: _statutPaiement,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        createdAt: widget.remplacement?.createdAt,
      );

      final provider = context.read<RemplacementProvider>();
      if (isEditing) {
        provider.updateRemplacement(remplacement);
      } else {
        provider.addRemplacement(remplacement);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing
              ? 'Remplacement modifié'
              : 'Remplacement ajouté'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    final provider = context.watch<RemplacementProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier' : 'Nouveau remplacement'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Médecin
            Autocomplete<String>(
              initialValue: TextEditingValue(text: _medecinController.text),
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return provider.medecins;
                }
                return provider.medecins.where((m) =>
                    m.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (selection) {
                _medecinController.text = selection;
              },
              fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Médecin remplacé',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Champ requis';
                    }
                    _medecinController.text = value;
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // Dates
            Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final borderColor = isDark ? Colors.grey.shade600 : Colors.grey.shade400;
                return Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Début'),
                        subtitle: Text(dateFormat.format(_dateDebut)),
                        leading: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(true),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: borderColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ListTile(
                        title: const Text('Fin'),
                        subtitle: Text(dateFormat.format(_dateFin)),
                        leading: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(false),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: borderColor),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Nombre de jours
            TextFormField(
              controller: _joursController,
              decoration: const InputDecoration(
                labelText: 'Nombre de jours',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Champ requis';
                if (double.tryParse(value) == null) return 'Nombre invalide';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Toggle pour choisir le mode de saisie
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mode de saisie du montant',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<MontantInputMode>(
                      segments: const [
                        ButtonSegment(
                          value: MontantInputMode.avantRetro,
                          label: Text('Montant brut'),
                          icon: Icon(Icons.account_balance_wallet_outlined),
                        ),
                        ButtonSegment(
                          value: MontantInputMode.apresRetro,
                          label: Text('Montant net'),
                          icon: Icon(Icons.payments_outlined),
                        ),
                      ],
                      selected: {_inputMode},
                      onSelectionChanged: (Set<MontantInputMode> newSelection) {
                        setState(() {
                          _inputMode = newSelection.first;
                        });
                      },
                      style: ButtonStyle(
                        textStyle: WidgetStateProperty.all(
                          const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _inputMode == MontantInputMode.avantRetro
                          ? 'Montant total avant rétrocession au médecin'
                          : 'Montant que vous allez toucher (après rétrocession)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Montant (label adapté selon le mode)
            TextFormField(
              controller: _montantController,
              decoration: InputDecoration(
                labelText: _inputMode == MontantInputMode.avantRetro
                    ? 'Montant brut (avant rétrocession)'
                    : 'Montant net (après rétrocession)',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.euro),
                suffixText: '€',
                helperText: _inputMode == MontantInputMode.avantRetro
                    ? 'Montant total facturé'
                    : 'Montant à recevoir après rétrocession',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Champ requis';
                if (double.tryParse(value) == null) return 'Montant invalide';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Taux de rétrocession
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Taux de rétrocession: $_tauxRetrocession%'),
                Slider(
                  value: _tauxRetrocession.toDouble(),
                  min: 50,
                  max: 100,
                  divisions: 50,
                  label: '$_tauxRetrocession%',
                  onChanged: (value) {
                    setState(() {
                      _tauxRetrocession = value.toInt();
                    });
                  },
                ),
              ],
            ),

            // Récapitulatif des calculs
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Calculs automatiques',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const Divider(),
                    // Si mode "après rétro", montrer le montant avant calculé
                    if (_inputMode == MontantInputMode.apresRetro)
                      _buildCalcRow('Montant brut (calculé)',
                          currencyFormat.format(_montantAvantRetro),
                          color: Colors.blue.shade700),
                    _buildCalcRow('Montant de la rétrocession ($_tauxRetrocession%)',
                        currencyFormat.format(_montantRetrocession)),
                    // Si mode "avant rétro", montrer le montant après calculé
                    if (_inputMode == MontantInputMode.avantRetro)
                      _buildCalcRow('Après rétrocession',
                          currencyFormat.format(_montantApresRetro),
                          color: Colors.blue.shade700),
                    _buildCalcRow(
                        'Charges URSSAF (22%)', currencyFormat.format(_urssaf)),
                    _buildCalcRow('Net après charges', currencyFormat.format(_net),
                        isBold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Mode de paiement
            DropdownButtonFormField<String>(
              value: _modePaiement,
              decoration: const InputDecoration(
                labelText: 'Mode de paiement',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payment),
              ),
              items: ['Virement', 'Chèque', 'Espèces']
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (value) {
                setState(() => _modePaiement = value!);
              },
            ),
            const SizedBox(height: 16),

            // Statut de paiement (seulement en édition)
            if (isEditing)
              DropdownButtonFormField<String>(
                value: _statutPaiement,
                decoration: const InputDecoration(
                  labelText: 'Statut de paiement',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.check_circle_outline),
                ),
                items: ['En attente', 'Payé', 'En retard']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) {
                  setState(() => _statutPaiement = value!);
                },
              ),
            if (isEditing) const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optionnel)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Bouton de soumission
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: Text(
                isEditing ? 'Enregistrer les modifications' : 'Ajouter le remplacement',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalcRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: color),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
