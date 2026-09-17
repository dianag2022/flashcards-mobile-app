import 'dart:math';

class MotivationalCopy {
  const MotivationalCopy({
    required this.headline,
    required this.body,
  });

  final String headline;
  final String body;
}

class MotivationalMessages {
  MotivationalMessages._();

  static final _random = Random();

  static const success = [
    MotivationalCopy(
      headline: '¡Excelente trabajo!',
      body:
          'Dominas gran parte de este contenido. Un último repaso te dejará aún más seguro.',
    ),
    MotivationalCopy(
      headline: '¡Lo estás logrando!',
      body:
          'Tu constancia se nota. Sigue así y estos conceptos quedarán bien afianzados.',
    ),
    MotivationalCopy(
      headline: '¡Impresionante!',
      body:
          'Respondiste con mucha claridad. Un breve repaso consolidará lo que ya sabes.',
    ),
    MotivationalCopy(
      headline: '¡Gran ronda!',
      body:
          'Estás muy cerca de dominar este tema. Confía en lo que ya aprendiste.',
    ),
    MotivationalCopy(
      headline: '¡Sigue así!',
      body:
          'Este ritmo te lleva lejos. Celebra el avance y continúa con calma.',
    ),
    MotivationalCopy(
      headline: '¡Qué buen dominio!',
      body:
          'La mayoría de las ideas ya están claras. Un refuerzo corto te dará aún más seguridad.',
    ),
    MotivationalCopy(
      headline: '¡Vas con mucha solidez!',
      body:
          'Se nota el estudio. Mantén este paso y el examen se sentirá más cercano.',
    ),
    MotivationalCopy(
      headline: '¡Brillante!',
      body:
          'Acertaste casi todo. Repasa lo pendiente y cierra el círculo con confianza.',
    ),
  ];

  static const mixed = [
    MotivationalCopy(
      headline: '¡Vas muy bien!',
      body:
          'Sigue repasando para fortalecer los conceptos que aún no dominas.',
    ),
    MotivationalCopy(
      headline: 'Buen avance',
      body:
          'Ya hay una base sólida. Vuelve sobre lo que se te escapó y verás el cambio.',
    ),
    MotivationalCopy(
      headline: 'Vas por buen camino',
      body:
          'Cada ronda deja algo más claro. Sigue con calma: el progreso ya está ocurriendo.',
    ),
    MotivationalCopy(
      headline: '¡Sigue construyendo!',
      body:
          'Acertaste una buena parte. Refuerza lo pendiente y el conjunto se ordenará.',
    ),
    MotivationalCopy(
      headline: 'Hay ritmo',
      body:
          'No hace falta acertar todo hoy. Lo importante es volver y afinar lo que falta.',
    ),
    MotivationalCopy(
      headline: 'Paso a paso',
      body:
          'Estás avanzando de forma constante. Un repaso extra de lo fallado te ayudará mucho.',
    ),
    MotivationalCopy(
      headline: '¡Bien encaminado!',
      body:
          'Ya reconoces varios conceptos. Practica los que se resistieron y ganarás seguridad.',
    ),
    MotivationalCopy(
      headline: 'Se ve el progreso',
      body:
          'No estás empezando de cero. Retoma las tarjetas difíciles y sigue sumando.',
    ),
  ];

  static const unsuccessful = [
    MotivationalCopy(
      headline: 'Sigue practicando',
      body:
          'Cada sesión cuenta. Vuelve a intentarlo y verás cómo se afianzan las ideas.',
    ),
    MotivationalCopy(
      headline: 'No te detengas',
      body:
          'Fallar también enseña. Revisa con calma lo que se te escapó y vuelve a intentarlo.',
    ),
    MotivationalCopy(
      headline: 'El esfuerzo vale',
      body:
          'Hoy fue una ronda exigente. Eso no resta mérito: seguir es lo que construye dominio.',
    ),
    MotivationalCopy(
      headline: 'Vas a lograrlo',
      body:
          'Nadie domina un tema a la primera. Un nuevo intento, sin prisa, hará la diferencia.',
    ),
    MotivationalCopy(
      headline: 'Respira y continúa',
      body:
          'Está bien no acertar ahora. El aprendizaje se sostiene en la repetición serena.',
    ),
    MotivationalCopy(
      headline: 'Esta ronda suma',
      body:
          'Aunque el resultado sea bajo, ya viste las ideas. El próximo intento partirá de más cerca.',
    ),
    MotivationalCopy(
      headline: 'Ánimo, sigue',
      body:
          'Los conceptos difíciles se ganan con práctica. Vuelve cuando quieras; el progreso llega.',
    ),
    MotivationalCopy(
      headline: 'Un tropiezo no define',
      body:
          'Lo importante es volver. Revisa las tarjetas y verás que no son tan lejanas.',
    ),
  ];

  static const perfect = [
    MotivationalCopy(
      headline: '¡Ronda perfecta!',
      body:
          'Acertaste todas. Ese nivel de claridad es el que buscas para el examen.',
    ),
    MotivationalCopy(
      headline: '¡Sin fallos!',
      body:
          'Dominaste cada tarjeta de esta ronda. Sigue con esa misma atención.',
    ),
    MotivationalCopy(
      headline: '¡Impecable!',
      body:
          'Todas correctas. Confía en lo que sabes y mantén este ritmo de estudio.',
    ),
    MotivationalCopy(
      headline: '¡Excelente precisión!',
      body:
          'No se te escapó ninguna. Un dominio así se construye con constancia como la tuya.',
    ),
  ];

  static const adaptiveClear = [
    MotivationalCopy(
      headline: '¡Ronda limpia!',
      body:
          'No fallaste ninguna en esta ronda. Comprobaremos si ya dominas el resto.',
    ),
    MotivationalCopy(
      headline: '¡Sin pendientes aquí!',
      body:
          'Esta tanda salió completa. Ahora veremos si el tema ya está dominado.',
    ),
    MotivationalCopy(
      headline: '¡Muy bien en esta ronda!',
      body:
          'Acertaste todo lo de ahora. El siguiente paso es confirmar el dominio del contenido.',
    ),
  ];

  static MotivationalCopy pick({
    required double accuracy,
    bool adaptiveClearRound = false,
  }) {
    if (adaptiveClearRound) return _from(adaptiveClear);
    if (accuracy >= 1) return _from(perfect);
    if (accuracy >= 0.8) return _from(success);
    if (accuracy >= 0.4) return _from(mixed);
    return _from(unsuccessful);
  }

  static MotivationalCopy _from(List<MotivationalCopy> pool) {
    return pool[_random.nextInt(pool.length)];
  }
}
