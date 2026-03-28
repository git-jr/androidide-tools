# Build Tools for [AndroidIDE](https://github.com/AndroidIDEOfficial/AndroidIDE)

Fork de [AndroidIDEOfficial/androidide-tools](https://github.com/AndroidIDEOfficial/androidide-tools), mantido para dar continuidade ao suporte de novas versões do Android SDK após o arquivamento do repositório original.

Todas as releases estão hospedadas neste fork. O `manifest.json` e o `scripts/idesetup` foram atualizados para apontar para `git-jr/androidide-tools`.

---

## Uso

No terminal do AndroidIDE:

```bash
idesetup -c
```

Para uma versão específica:

```bash
idesetup -s 35.0.2 -c -j 17
```

### Opções do script

```
-i   Diretório de instalação. Padrão: $HOME
-s   Versão do Android SDK a baixar
-c   Baixar com command line tools
-m   URL do manifest. Padrão: manifest.json deste repositório
-j   Versão do OpenJDK: '17' ou '21'
-a   Arquitetura da CPU (detectada automaticamente via uname -m)
-p   Package manager. Padrão: pkg
-h   Exibe esta ajuda
```

---

## Versões disponíveis

| Versão | Arquiteturas | Release |
|---|---|---|
| 35.0.2 | aarch64, arm, x86_64 | [v35.0.2](https://github.com/git-jr/androidide-tools/releases/tag/v35.0.2) |
| 34.0.4 | aarch64, arm, x86_64 | [v34.0.4](https://github.com/git-jr/androidide-tools/releases/tag/v34.0.4) |
| 34.0.3 | aarch64, arm | [v34.0.3](https://github.com/git-jr/androidide-tools/releases/tag/v34.0.3) |
| 34.0.1 | aarch64, arm | [v34.0.1](https://github.com/git-jr/androidide-tools/releases/tag/v34.0.1) |
| 34.0.0 | aarch64, arm | [v34.0.0](https://github.com/git-jr/androidide-tools/releases/tag/v34.0.0) |
| 33.0.3 | aarch64, arm | [v33.0.3](https://github.com/git-jr/androidide-tools/releases/tag/v33.0.3) |
| 33.0.1 | aarch64, arm | [v33.0.1](https://github.com/git-jr/androidide-tools/releases/tag/v33.0.1) |

---

## Adicionando suporte a uma nova versão

### Pré-requisito

Verifique se [lzhiyong/android-sdk-tools](https://github.com/lzhiyong/android-sdk-tools/releases) já publicou os binários cross-compilados para a versão desejada.

### 1. Reempacotar os binários

```bash
cd scripts

./repackage.sh X.Y.Z aarch64
./repackage.sh X.Y.Z arm
./repackage.sh X.Y.Z x86_64
```

O script baixa o `.zip` do Lzhiyong e gera 6 arquivos `.tar.xz` no formato esperado pelo AndroidIDE.

### 2. Criar release e subir os arquivos

```bash
gh release create vX.Y.Z \
  build-tools-X.Y.Z-aarch64.tar.xz \
  build-tools-X.Y.Z-arm.tar.xz \
  build-tools-X.Y.Z-x86_64.tar.xz \
  platform-tools-X.Y.Z-aarch64.tar.xz \
  platform-tools-X.Y.Z-arm.tar.xz \
  platform-tools-X.Y.Z-x86_64.tar.xz \
  --repo git-jr/androidide-tools \
  --title "vX.Y.Z" \
  --notes "Android SDK build tools and platform tools X.Y.Z."
```

### 3. Atualizar `manifest.json`

Adicionar entradas `_X_Y_Z` em `build_tools` e `platform_tools` para cada arquitetura disponível, apontando para os assets do release criado acima.

### 4. Atualizar o default em `scripts/idesetup`

```bash
sdkver_org=X.Y.Z
```

### 5. Commit e push

```bash
git add manifest.json scripts/idesetup
git commit -m "add: support for build-tools X.Y.Z"
git push
```

### 6. Atualizar o AndroidIDE

Veja `ANDROID_35_36_SUPPORT.md` no repositório AndroidIDE para as mudanças necessárias em `Sdk.kt`, `ideSetupConfig.kt` e `idesetup.sh`.

---

## Créditos

- [@Lzhiyong](https://github.com/Lzhiyong) por [android-sdk-tools](https://github.com/lzhiyong/android-sdk-tools) — binários cross-compilados para ARM.
- [AndroidIDEOfficial](https://github.com/AndroidIDEOfficial) pelo repositório e scripts originais.
