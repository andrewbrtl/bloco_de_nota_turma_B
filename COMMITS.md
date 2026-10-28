# BlocoDeNotas — comandos para enviar

O repositório **local** já foi criado nesta pasta, preservando o histórico da professora. A branch atual é `melhorias-bloco-notas`. As alterações estão prontas para você fazer os commits; nenhum fork ou commit novo foi criado em sua conta.

## 1. Criar o fork pelo GitHub

Na conta `andrewbrtl`, abra:

[Criar fork da turma B](https://github.com/LopesBrendinha/bloco_de_nota_turma_B/fork)

No campo **Repository name**, use **BlocoDeNotas** e clique em **Create fork**. O resultado esperado é `andrewbrtl/BlocoDeNotas`. Isso mantém o vínculo com a professora necessário ao PR.

O enunciado menciona as turmas A e B. Foi usada a turma B, conforme sua escolha; confirme o destino com a professora antes da entrega.

## 2. Entrar na pasta local e ligar ao fork

No PowerShell:

```powershell
cd "C:\Users\Andrew\Documents\Codex\2026-10-27\ten\outputs\BlocoDeNotas"
git switch melhorias-bloco-notas
git remote add origin https://github.com/andrewbrtl/BlocoDeNotas.git
git remote -v
```

`upstream` já aponta para a professora. Execute `git remote add origin` só uma vez. Se precisar corrigir um endereço já cadastrado, use `git remote set-url origin https://github.com/andrewbrtl/BlocoDeNotas.git`.

Se o Git pedir nome/e-mail para os commits, configure sua autoria neste repositório:

```sh
git config user.name "SEU NOME"
git config user.email "SEU EMAIL OU EMAIL NOREPLY DO GITHUB"
```

## 3. Configurar e testar

Siga o README para criar seu Firebase, gerar a configuração, publicar as regras e executar no aparelho. Os testes locais também podem ser executados antes dessa configuração:

```sh
flutter pub get
flutter analyze
flutter test
git status
```

## 4. Commit do aplicativo

```sh
git add -A -- lib android/app pubspec.yaml pubspec.lock .gitignore firebase.json firestore.rules
git diff --cached --stat
git commit -m "Implementar sincronizacao, categorias, pesquisa e organizacao das notas"
```

Esse commit reúne os arquivos que dependem uns dos outros: banco, serviços, telas, regras e dependências. Inclui as correções da revisão. A configuração pública do app é gerada em `firebase_options.dart`; nunca inclua senha ou credenciais administrativas.

## 5. Commit dos testes do aplicativo

```sh
git add test/notes_test.dart test/note_card_test.dart test/note_form_test.dart test/notes_page_test.dart
git commit -m "Testar notas, falhas e sincronizacao durante alteracoes"
```

## 6. Commit dos testes das regras

```sh
git add package.json package-lock.json test/firestore_rules.test.cjs analysis_options.yaml
git commit -m "Testar permissoes e validacoes do Firestore"
```

## 7. Commit da documentação

```sh
git add README.md COMMITS.md VALIDACAO.md REVISAO.md docs/evidencias
git commit -m "Documentar configuracao, revisao e entrega do aplicativo"
```

Depois de produzir as capturas reais indicadas em `docs/evidencias/README.md`, adicione as imagens no README e faça um commit separado:

```sh
git add docs/evidencias README.md
git commit -m "Adicionar capturas do aplicativo e das notas no Firebase"
```

## 8. Enviar e abrir o PR

```sh
git status
git log --oneline -5
git push -u origin melhorias-bloco-notas
```

No GitHub, clique em **Compare & pull request** e confira:

- Destino: `LopesBrendinha/bloco_de_nota_turma_B`, branch `main`.
- Origem: `andrewbrtl/BlocoDeNotas`, branch `melhorias-bloco-notas`.

Título sugerido: **Adicionar sincronização, categorias e organização das notas**.

Descreva SQLite/Firestore, categorias, pesquisa, ordenação e arquivamento. Informe os testes realmente executados e inclua as evidências. Abra o PR e envie no Classroom o link do fork e o link do PR.

## Se usar apenas o ZIP em outro computador

O ZIP contém o código sem `.git`. Primeiro faça o fork acima e clone:

```sh
git clone https://github.com/andrewbrtl/BlocoDeNotas.git
cd BlocoDeNotas
git switch -c melhorias-bloco-notas
git remote add upstream https://github.com/LopesBrendinha/bloco_de_nota_turma_B.git
git rm android/app/google-services.json
```

Copie o conteúdo da pasta `BlocoDeNotas` do ZIP para a raiz desse clone, incluindo `.gitignore`, substituindo os arquivos correspondentes. A configuração da professora removida pelo `git rm` deve ser substituída pela sua, seguindo o README. Não use `git init` sobre um projeto sem histórico. Prossiga pelos comandos dos commits a partir da etapa 3.
