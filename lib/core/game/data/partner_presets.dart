import '../models/ai_profile.dart';

class PartnerPresets {
  static const List<AiProfile> partners = [
    AiProfile(
      name: 'El Prudente',
      boldness: 0.2, // Muy conservador
      bluffing: 0.1, // Casi nunca farolea
      avatarUrl: 'assets/avatars/prudente.png',
    ),
    AiProfile(
      name: 'La Temeraria',
      boldness: 0.9, // Acepta casi todo
      bluffing: 0.8, // Farolea mucho
      avatarUrl: 'assets/avatars/temeraria.png',
    ),
    AiProfile(
      name: 'El Calculador',
      boldness: 0.5, // Equilibrado
      bluffing: 0.3, // Farolea poco, solo cuando tiene sentido
      avatarUrl: 'assets/avatars/calculador.png',
    ),
    AiProfile(
      name: 'El Farolero',
      boldness: 0.7,
      bluffing: 0.95, // Todo son faroles
      avatarUrl: 'assets/avatars/farolero.png',
    ),
  ];
}
