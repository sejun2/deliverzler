import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:deliverzler/core/presentation/utils/riverpod_framework.dart';
import 'package:deliverzler/l10n/l10n.dart';

Future<BuildContext> setUpLocalizationsContext(WidgetTester t) async {
  late BuildContext result;
  await t.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      supportedLocales: L10n.all,
      localizationsDelegates: L10n.localizationsDelegates,
      home: Material(
        child: Builder(
          builder: (BuildContext context) {
            result = context;
            return Container();
          },
        ),
      ),
    ),
  );
  return result;
}

ProviderContainer setUpContainer({
  ProviderContainer? parent,
  List<Override> overrides = const [],
  List<ProviderObserver>? observers,
}) {
  final container = ProviderContainer(
    parent: parent,
    overrides: overrides,
    observers: observers,
  );
  addTearDown(container.dispose);
  return container;
}

// Using mockito to keep track of when a provider notify its listeners
class Listener<T> extends Mock {
  void call(T? previous, T value);
}

Listener<T> setUpListener<T>(
  ProviderContainer container,
  ProviderListenable<T> provider, {
  bool fireImmediately = true,
}) {
  final listener = Listener<T>();
  container.listen(provider, listener, fireImmediately: fireImmediately);
  return listener;
}

typedef VerifyOnly = VerificationResult Function<T>(
  Mock mock,
  T Function() matchingInvocations,
);

/// Syntax sugar for:
///
/// ```dart
/// verify(mock()).called(1);
/// verifyNoMoreInteractions(mock);
/// ```
VerifyOnly get verifyOnly {
  return <T>(mock, invocation) {
    final result = verify(invocation);
    result.called(1);
    verifyNoMoreInteractions(mock);
    return result;
  };
}
