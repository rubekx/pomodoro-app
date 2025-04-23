# tomate

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

**Comandos chave do Flutter run.**
```
- `r` Recarregar rapidamente. 🔥🔥🔥
- `R` Reinício rápido.
- `v` Abrir Flutter DevTools.
- `s` Salvar uma captura de tela como `flutter.png`.
- `w` Exibir a hierarquia de widgets no console. (debugDumpApp)
- `t` Exibir a árvore de renderização no console. (debugDumpRenderTree)
- `L` Exibir a árvore de camadas no console. (debugDumpLayerTree)
- `S` Exibir a árvore de acessibilidade na ordem de travessia. (debugDumpSemantics)
- `U` Exibir a árvore de acessibilidade na ordem inversa de teste de toque. (debugDumpSemantics)
- `i` Alternar o inspetor de widgets. (WidgetsApp.showWidgetInspectorOverride)
- `p` Alternar a exibição de linhas de construção. (debugPaintSizeEnabled)
- `I` Alternar a inversão de imagens grandes. (debugInvertOversizedImages)
- `o` Simular diferentes sistemas operacionais. (defaultTargetPlatform)
- `b` Alternar o brilho da plataforma (modo escuro e claro). (debugBrightnessOverride)
- `P` Alternar sobreposição de desempenho. (WidgetsApp.showPerformanceOverlay)
- `a` Alternar eventos de linha do tempo para todos os métodos de construção de widgets. (debugProfileWidgetBuilds)
- `M` Escrever shaders SkSL em um arquivo único no diretório do projeto.
- `g` Executar geradores de código-fonte.
- `h` Repetir esta mensagem de ajuda.
- `d` Desconectar (encerrar "flutter run" mas manter a aplicação em execução).
- `c` Limpar a tela
- `q` Sair (encerrar a aplicação no dispositivo).
```

Para construir o pacote do aplicativo (release):
```sh
flutter build appbundle --release
```

Para construir o APK (release) para cada ABI:
```sh
flutter build apk --split-per-abi --release
```

**Comandos ADB**

1. Este comando para o servidor ADB (Android Debug Bridge): `adb kill-server`

2. Este comando inicia o servidor ADB (Android Debug Bridge): `adb start-server`

**Passos para configurar a conexão ADB via Wi-Fi**

1. Conecte o dispositivo e o computador à mesma rede Wi-Fi.
2. Conecte o dispositivo ao computador com um cabo USB para configurar a conexão.
3. Na linha de comando do computador, digite: `adb tcpip 5555`.
4. Na linha de comando do computador, digite: `adb shell ip addr show wlan0` e copie o endereço IP após o "inet" até a "/".
5. Alternativamente, recupere o endereço IP em Configurações → Sobre → Status no dispositivo.
6. Na linha de comando do computador, digite: `adb connect endereço-ip-do-dispositivo:5555`.
7. Você pode desconectar o cabo USB do dispositivo e verificar com `adb devices` se o dispositivo ainda está detectado.