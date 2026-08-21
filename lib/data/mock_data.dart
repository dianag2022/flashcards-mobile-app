import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../models/topic.dart';

class MockData {
  MockData._();

  static const List<Topic> topics = [
    Topic(
      id: 'teorias',
      title: 'Teorías psicológicas',
      subtitle: 'Conductismo, Psicoanálisis...',
      icon: Icons.psychology_outlined,
      progress: 0.80,
      cards: teoriasCards,
    ),
    Topic(
      id: 'autores',
      title: 'Autores clave',
      subtitle: 'Freud, Piaget, Skinner...',
      icon: Icons.groups_outlined,
      progress: 0.35,
      cards: autoresCards,
    ),
    Topic(
      id: 'salud',
      title: 'Salud mental',
      subtitle: 'Trastornos, intervenciones...',
      icon: Icons.monitor_heart_outlined,
      progress: 0.60,
      cards: saludCards,
    ),
    Topic(
      id: 'conceptos',
      title: 'Conceptos básicos',
      subtitle: 'Memoria, percepción...',
      icon: Icons.lightbulb_outline,
      progress: 0.15,
      cards: conceptosCards,
    ),
  ];

  static const List<Flashcard> teoriasCards = [
    Flashcard(
      tag: 'CONDUCTISMO',
      question: '¿Qué plantea el conductismo sobre el comportamiento humano?',
      answer:
          'El conductismo plantea que la psicología debe estudiar el comportamiento observable y medible.',
      explanation:
          'Esta corriente, impulsada por autores como Watson y Skinner, sostiene que los procesos mentales internos no pueden observarse de forma objetiva. Por eso el conductismo se centra en estímulos, respuestas y el aprendizaje por condicionamiento.',
    ),
    Flashcard(
      tag: 'PSICOANÁLISIS',
      question: '¿Cuál es el principal objeto de estudio del psicoanálisis?',
      answer:
          'El psicoanálisis estudia el inconsciente y cómo influye en el pensamiento, la emoción y la conducta.',
      explanation:
          'Freud propuso que gran parte de la vida psíquica ocurre fuera de la conciencia. Conflictos reprimidos, sueños y actos fallidos serían vías para acceder a esos contenidos.',
    ),
    Flashcard(
      tag: 'HUMANISMO',
      question: '¿Qué enfatiza la psicología humanista en el desarrollo de la persona?',
      answer:
          'La psicología humanista enfatiza la tendencia innata hacia el crecimiento, la autorrealización y la experiencia subjetiva.',
      explanation:
          'Autores como Rogers y Maslow subrayan la libertad, la autenticidad y el potencial humano, en contraste con visiones deterministas del psicoanálisis y el conductismo.',
    ),
    Flashcard(
      tag: 'COGNITIVISMO',
      question: '¿Cómo explica el enfoque cognitivo la conducta humana?',
      answer:
          'El enfoque cognitivo explica la conducta a partir de procesos mentales como la atención, la memoria y el pensamiento.',
      explanation:
          'La mente se entiende como un sistema que procesa información. Pensamientos, esquemas y creencias mediarían entre el estímulo y la respuesta observable.',
    ),
    Flashcard(
      tag: 'GESTALT',
      question: '¿Qué principio central defiende la psicología de la Gestalt?',
      answer:
          'La Gestalt sostiene que la experiencia se organiza en totalidades significativas, no como suma de partes aisladas.',
      explanation:
          'Leyes como proximidad, semejanza y cierre describen cómo percibimos formas completas. El lema clásico es que el todo es distinto a la suma de las partes.',
    ),
  ];

  static const List<Flashcard> autoresCards = [
    Flashcard(
      tag: 'FREUD',
      question: '¿Qué estructura de la personalidad propuso Sigmund Freud?',
      answer:
          'Freud describió la personalidad como el dinamismo entre ello, yo y superyó.',
      explanation:
          'El ello opera por el principio de placer, el yo por el de realidad y el superyó por normas e ideales morales internalizados.',
    ),
    Flashcard(
      tag: 'PIAGET',
      question: '¿Qué describió Jean Piaget sobre el desarrollo infantil?',
      answer:
          'Piaget describió estadios del desarrollo cognitivo: sensoriomotor, preoperacional, operaciones concretas y formales.',
      explanation:
          'El niño construye conocimiento mediante asimilación y acomodación. Cada estadio implica formas cualitativamente distintas de pensar.',
    ),
    Flashcard(
      tag: 'SKINNER',
      question: '¿Cuál es el aporte central de B. F. Skinner?',
      answer:
          'Skinner desarrolló el conductismo radical y el análisis del condicionamiento operante.',
      explanation:
          'Según este modelo, la conducta se mantiene o debilita por sus consecuencias: reforzamiento, castigo y extinción.',
    ),
    Flashcard(
      tag: 'VYGOTSKY',
      question: '¿Qué concepto clave introdujo Lev Vygotsky?',
      answer:
          'Vygotsky introdujo la zona de desarrollo próximo y el papel del lenguaje en el pensamiento.',
      explanation:
          'El aprendizaje ocurre primero en el plano social y luego se interioriza. El andamiaje de un otro más experto permite avanzar más allá de lo que se logra en solitario.',
    ),
    Flashcard(
      tag: 'BANDURA',
      question: '¿Qué plantea Albert Bandura sobre el aprendizaje?',
      answer:
          'Bandura plantea que las personas también aprenden observando modelos, no solo por ensayo y error.',
      explanation:
          'La teoría sociocognitiva incluye atención, retención, reproducción y motivación, además de la autoeficacia como predictor de la conducta.',
    ),
  ];

  static const List<Flashcard> saludCards = [
    Flashcard(
      tag: 'ANSIEDAD',
      question: '¿Qué caracteriza a un trastorno de ansiedad?',
      answer:
          'Se caracteriza por miedo o preocupación excesivos, persistentes y desproporcionados, con interferencia en la vida diaria.',
      explanation:
          'Puede incluir síntomas fisiológicos (taquicardia, tensión) y conductuales (evitación). No es solo un nerviosismo puntual ante un estrés real.',
    ),
    Flashcard(
      tag: 'DEPRESIÓN',
      question: '¿Cuáles son síntomas nucleares de un episodio depresivo?',
      answer:
          'Ánimo deprimido y/o pérdida de interés o placer, junto con cambios en sueño, energía, concentración o pensamiento.',
      explanation:
          'Para el diagnóstico clínico estos síntomas deben ser persistentes y generar malestar o deterioro significativo, no solo tristeza circunstancial.',
    ),
    Flashcard(
      tag: 'INTERVENCIÓN',
      question: '¿Qué busca una intervención psicológica basada en evidencia?',
      answer:
          'Reducir el malestar y recuperar el funcionamiento mediante técnicas con respaldo empírico, adaptadas a la persona.',
      explanation:
          'Incluye formulación del caso, objetivos claros y evaluación continua. Ejemplos: reestructuración cognitiva, exposición o activación conductual.',
    ),
    Flashcard(
      tag: 'ESTIGMA',
      question: '¿Por qué el estigma afecta la salud mental?',
      answer:
          'El estigma retrasa la búsqueda de ayuda y aumenta el aislamiento, la vergüenza y el deterioro del bienestar.',
      explanation:
          'Puede ser público (prejuicio social) o internalizado. La psicoeducación y el contacto con personas recuperadas ayudan a reducirlo.',
    ),
    Flashcard(
      tag: 'PREVENCIÓN',
      question: '¿Qué distingue la prevención primaria en salud mental?',
      answer:
          'La prevención primaria actúa antes de que aparezca el trastorno, reduciendo factores de riesgo y fortaleciendo protectores.',
      explanation:
          'Ejemplos: programas escolares de habilidades socioemocionales. La secundaria detecta precozmente; la terciaria evita recaídas y cronicidad.',
    ),
  ];

  static const List<Flashcard> conceptosCards = [
    Flashcard(
      tag: 'MEMORIA',
      question: '¿Qué procesos básicos componen la memoria?',
      answer:
          'Codificación, almacenamiento y recuperación de la información.',
      explanation:
          'Si falla alguno de estos procesos, el recuerdo se vuelve incompleto o inaccesible. También se distinguen memoria sensorial, de trabajo y de largo plazo.',
    ),
    Flashcard(
      tag: 'PERCEPCIÓN',
      question: '¿En qué se diferencia sensación y percepción?',
      answer:
          'La sensación es el registro de estímulos; la percepción es la organización e interpretación de esa información.',
      explanation:
          'Un mismo estímulo puede percibirse de formas distintas según atención, experiencia y contexto. La percepción es activa, no una copia fiel del mundo.',
    ),
    Flashcard(
      tag: 'ATENCIÓN',
      question: '¿Qué función cumple la atención en el procesamiento cognitivo?',
      answer:
          'Selecciona información relevante y asigna recursos limitados al procesamiento consciente.',
      explanation:
          'Puede ser sostenida, selectiva o dividida. Sin atención, muchos estímulos se registran de forma superficial y no se consolidan en memoria.',
    ),
    Flashcard(
      tag: 'EMOCIÓN',
      question: '¿Qué componentes suele incluir una emoción?',
      answer:
          'Una emoción integra valoración, cambios fisiológicos, expresión y tendencia a la acción.',
      explanation:
          'No es solo un “sentimiento”. Modelos como el de Schachter-Singer o las teorías de valoración destacan el papel del significado que se atribuye al evento.',
    ),
    Flashcard(
      tag: 'APRENDIZAJE',
      question: '¿Qué es el aprendizaje desde la psicología?',
      answer:
          'Es un cambio relativamente persistente en la conducta o el conocimiento como resultado de la experiencia.',
      explanation:
          'Incluye condicionamiento clásico y operante, aprendizaje observacional y formas cognitivas. No todo cambio (por ejemplo, por fatiga) cuenta como aprendizaje.',
    ),
  ];
}
