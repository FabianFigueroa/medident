import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';

/// Widget para configurar codigos de coercion (duress codes)
class DuressCodeConfigWidget extends StatefulWidget {
  const DuressCodeConfigWidget({super.key});

  @override
  State<DuressCodeConfigWidget> createState() => _DuressCodeConfigWidgetState();
}

class _DuressCodeConfigWidgetState extends State<DuressCodeConfigWidget> {
  final List<String> _enteredCode = [];
  bool _isSettingMode = false;
  String? _confirmCode;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.security, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Codigo de Coercion',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Si te obligan a desarmar la alarma, ingresa este codigo especial. '
              'La alarma se "desarmara" pero enviara una alerta silenciosa.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            // Codigo actual (oculto)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Codigo actual:'),
                  Text(
                    '******',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () {
                      setState(() {
                        _isSettingMode = true;
                        _enteredCode.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
            if (_isSettingMode) ...[
              const SizedBox(height: 16),
              const Text(
                'Ingresa nuevo codigo (6 digitos):',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              // Display de digitos ingresados
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 40,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: index < _enteredCode.length
                            ? Colors.orange
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        index < _enteredCode.length ? '*' : '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              // Teclado numerico
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  if (index == 9) {
                    return const SizedBox.shrink(); // Espacio vacio
                  } else if (index == 10) {
                    return _buildKey('0');
                  } else if (index == 11) {
                    return _buildKey('', isDelete: true);
                  } else {
                    return _buildKey('${index + 1}');
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isSettingMode = false;
                          _enteredCode.clear();
                        });
                      },
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _enteredCode.length == 6
                          ? () {
                              if (_confirmCode == null) {
                                _confirmCode = _enteredCode.join();
                                _enteredCode.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Confirma el codigo nuevamente'),
                                  ),
                                );
                              } else if (_confirmCode == _enteredCode.join()) {
                                setState(() {
                                  _isSettingMode = false;
                                  _enteredCode.clear();
                                  _confirmCode = null;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Codigo de coercition actualizado'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Los codigos no coinciden'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                _enteredCode.clear();
                                _confirmCode = null;
                              }
                            }
                          : null,
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildKey(String value, {bool isDelete = false}) {
    return InkWell(
      onTap: () {
        if (isDelete) {
          if (_enteredCode.isNotEmpty) {
            setState(() {
              _enteredCode.removeLast();
            });
          }
        } else if (_enteredCode.length < 6) {
          setState(() {
            _enteredCode.add(value);
          });
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
