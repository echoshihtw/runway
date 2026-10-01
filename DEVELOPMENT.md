# Development

A Melos workspace. `domain` has no Flutter dependency, which is what keeps the
runway calculation testable without a widget tree.

```
packages/
  domain/          Pure Dart. Entities, logic, repository interfaces.
  data/            Drift + SQLCipher. Repository implementations.
  application/     Riverpod providers and use cases.
  design_system/   Tokens, theme, components, localisations.
  presentation/    Screens and widgets.
app/               The Flutter app that wires them together.
```

```bash
make setup        # melos bootstrap
make gen          # Drift and Riverpod codegen
make gen-l10n     # regenerate localisations from the .arb files
make analyze      # every package
make test         # every package
make run          # on a connected device
```

`CONTRACTS.md` holds the decisions the code is expected to keep, including the
ones that were reversed and why.
