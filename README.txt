Bloco de Notas — Turma B

Continuação do projeto da professora: https://github.com/LopesBrendinha/bloco_de_nota_turma_B, a partir do commit 0a64a61. O aplicativo permite organizar notas e manter uma cópia no aparelho e outra no Firebase.

Foram mantidos Flutter, as telas de login e cadastro, o visual roxo, o modelo Note, o banco DatabaseHelper e o uso de setState.

Funcionalidades

- Cadastro e login com e-mail e senha pelo Firebase Authentication.
- Criação, consulta, edição e exclusão de notas no SQLite e no Cloud Firestore.
- Categorias Estudos, Trabalho e Pessoal, com opção de criar outra no formulário.
- Pesquisa por título ou conteúdo, sem diferenciar maiúsculas de minúsculas.
- Notas separadas por usuário.
- Recuperação das notas da nuvem ao entrar em outra instalação.
- Alterações sem conexão ficam pendentes no aparelho.

As duas funcionalidades adicionais são:

1. Ordenação por data: escolher data de criação ou última atualização, sempre da mais recente para a mais antiga.
2. Arquivamento: arquivar e desarquivar sem perder o conteúdo. O filtro “Arquivadas” também permite pesquisar essas notas.

Não há checklist, lembrete nem lixeira com recuperação. Excluir é definitivo. Arquivar mantém a nota.

Tecnologias

Flutter e Dart; firebase_core, firebase_auth, cloud_firestore, sqflite e path. As versões estão em pubspec.yaml e pubspec.lock.

Os testes usam flutter_test e sqflite_common_ffi. O package.json serve somente para testar as regras do Firestore; Node.js não faz parte do aplicativo.

Configuração e execução

Use Flutter compatível com Dart 3.12.2 ou superior. Para Android, instale o Android Studio e prepare um emulador ou aparelho com depuração USB.

flutter doctor
flutter pub get

Se o flutter doctor indicar licenças do Android pendentes, execute flutter doctor --android-licenses e leia os termos antes de aceitar.

Firebase

É necessário usar seu próprio projeto. A configuração do Firebase da professora foi retirada desta versão.

1. No console do Firebase: https://console.firebase.google.com/, crie um projeto.
2. Em Authentication, habilite o provedor E-mail/senha.
3. Em Firestore Database, crie o banco padrão (default), escolhendo uma região.
4. Instale as ferramentas abaixo. No Windows, use o CMD para os comandos do npm, como indicado nas instruções da professora.

npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
dart pub global run flutterfire_cli:flutterfire configure --project=SEU_PROJETO --platforms=android

Troque SEU_PROJETO pelo ID real do projeto. Mantenha o identificador Android com.example.blocodenotasturmab. O comando deve substituir o arquivo de exemplo lib/firebase_options.dart e gerar android/app/google-services.json. Sem essa configuração, o aplicativo ainda não está pronto para executar no Android.

Publique as regras fornecidas:

firebase deploy --only firestore:rules --project=SEU_PROJETO

Também é possível copiar firestore.rules para a aba Regras do Firestore e clicar em Publicar. Não deixe regras que liberem o banco inteiro.

Depois de configurar:

flutter pub get
flutter devices
flutter run -d ID_DO_DISPOSITIVO

Substitua ID_DO_DISPOSITIVO pelo identificador Android exibido. Para iOS, configure também a plataforma ios pelo FlutterFire e execute em um Mac com Xcode. A implementação de SQLite usada aqui é para Android/iOS; as pastas web da base não significam que o banco funcione no navegador.

O arquivo firebase_options.dart gerado contém a configuração pública do aplicativo cliente. A proteção dos dados depende da autenticação e das regras. Não coloque senha, chave privada ou arquivo de conta de serviço no repositório. google-services.json, .firebaserc, .env e arquivos comuns de conta de serviço estão no .gitignore; a configuração deve ser gerada novamente em cada ambiente.

Organização e alterações

Arquivo/pasta — Responsabilidade
lib/main.dart — Inicia o Firebase, mantém o tema e abre as notas se já houver sessão.
lib/models/note.dart — Representa a nota e converte seus dados para SQLite e Firestore.
lib/database/database_helper.dart — CRUD local, categorias, busca, ordenação, arquivamento e migração do banco.
lib/services/auth_service.dart — Login, cadastro e saída, como na base.
lib/services/firestore_service.dart — Consulta e grava as notas do usuário no Firestore.
lib/services/sync_service.dart — Envia as pendências e traz as notas da nuvem para o SQLite.
lib/screens/ — Telas de login, cadastro, listagem e formulário.
lib/widgets/note_card.dart — Mostra a nota, a categoria, a data e o menu de ações.
firestore.rules — Limita acesso ao dono e valida os campos.
test/ — Testes do banco, sincronização, formulário, cartão e regras.

A organização segue a base: telas, modelo, banco e serviços. DatabaseHelper.instance mantém o padrão Singleton usado pela professora, com uma instância do acesso ao banco. Os serviços separam os comandos de autenticação e nuvem da interface. As telas continuam usando StatefulWidget e setState. Não foi acrescentado um gerenciador de estado.

Também foram corrigidos os nomes divergentes da instância do banco na base. As senhas são enviadas como digitadas, sem remover espaços. Login, cadastro, gravação e sincronização tratam falhas e apresentam mensagens.

Armazenamento e sincronização

O SQLite continua sendo o banco consultado pelas telas. Cada nota tem o id local e um remoteId aleatório, usado também no Firestore:

users / UID_DO_USUARIO / notes / REMOTE_ID

O documento guarda uid, title, content, category, createdAt, updatedAt, archived e deleted. As datas são números inteiros em microssegundos desde 1970. O campo pendingSync existe somente no SQLite.

1. Salvar, editar, arquivar ou excluir altera primeiro o SQLite e marca pendingSync = 1.
2. Ao abrir as notas, voltar ao aplicativo, retornar do formulário ou usar o botão de sincronizar, o serviço tenta enviar as pendências daquele usuário.
3. A gravação usa uma transação do Firestore. Só depois da resposta do servidor a pendência correspondente é retirada.
4. O serviço consulta as notas do usuário no servidor e atualiza o SQLite. Assim, uma instalação nova recupera as notas já sincronizadas.
5. Se uma nota for recusada por permissão ou dados inválidos, ela continua pendente, mas as outras notas ainda são enviadas e recuperadas. A tela informa a quantidade não enviada. Se houver um novo pedido durante uma sincronização, ele é executado depois da tentativa atual.
6. Se ocorrer falha ou demora excessiva, o aplicativo informa o problema e mantém os dados locais. Após recuperar a conexão, use Sincronizar ou reabra o aplicativo. Não há tarefa de sincronização em segundo plano.

Se a mesma nota for editada em dois aparelhos, fica a versão com maior updatedAt. Em empate, fica a versão já existente na nuvem. Isso depende do relógio dos aparelhos; mantenha data e hora automáticas. Uma edição feita enquanto outra está sendo enviada continua pendente para a próxima tentativa.

Na exclusão, título, conteúdo e categoria são apagados. Permanece um registro com deleted = true, sem opção de recuperação, para informar a exclusão a aparelhos que estavam desconectados. Uma exclusão prevalece sobre edições pendentes e não permite recriar a mesma nota. Esse registro não é uma lixeira.

As categorias personalizadas são guardadas junto com as notas. Uma categoria fica disponível nas próximas notas depois de salvar uma nota com ela. Não existe cadastro separado de categorias vazias. A pesquisa considera o título e o conteúdo das notas locais, incluindo as já recuperadas da nuvem; acentos continuam significativos.

O banco foi atualizado da versão 1 para a 2 sem apagar as notas anteriores. Como a base guardava apenas uma data, a migração usa essa data como criação e atualização das notas antigas, atribui a categoria Pessoal e prepara o envio para a nuvem.

Autenticação e segurança

As consultas e alterações locais usam o UID. Na nuvem, firestore.rules permite acesso apenas quando o usuário autenticado é o dono do caminho users/{uid}/notes. As regras também validam os campos e impedem alterar o dono ou a data de criação.

É preciso conexão para criar uma conta ou fazer um novo login. Uma sessão já salva permite abrir as notas locais sem conexão. As notas pendentes só existem naquele aparelho até sincronizar; não desinstale o aplicativo antes disso. As regras do Firestore não criptografam o arquivo SQLite do aparelho.

Testes

flutter analyze
flutter test

Os testes de Flutter usam SQLite real em arquivos temporários e uma conexão simulada no lugar do Firestore. Verificam CRUD, pesquisa, isolamento por usuário, categorias, as duas ordenações, arquivamento, migração, falha de rede, recuperação em outro banco, exclusão pendente e edição durante um envio. Os testes de interface verificam as ações do cartão e o salvamento com categoria criada.

Para conferir as regras em um emulador local, instale Node.js compatível com as dependências e Java 21:

npm ci
npm run test:rules

Esse comando usa o projeto fictício demo-bloco-notas, sem acessar um projeto real. Testa o acesso do dono, a recusa de outros usuários e de usuários sem login, e a validação dos dados.

Verificação desta versão: a análise estática e os testes locais foram executados. Os resultados finais estão em VALIDACAO.txt. A revisão e as quatro correções estão em REVISAO.txt. Ainda é necessário testar o aplicativo em um aparelho com o seu Firebase e produzir as capturas reais. Os testes locais não substituem essa etapa.

Capturas e entrega

As capturas reais ainda não estão incluídas porque o projeto Firebase do aluno precisa ser criado. O roteiro e os nomes sugeridos estão em docs/evidencias/README.txt. Depois de produzi-las, inclua as imagens nesta seção, mostrando o aplicativo e os documentos no Firestore.

Os comandos divididos em commits, o fork e o PR estão em COMMITS.txt.

O enunciado cita A e B em partes diferentes. Esta implementação segue a turma B, conforme a escolha do aluno. O destino previsto do fork e do PR é LopesBrendinha/bloco_de_nota_turma_B, branch main; confirme essa divergência com a professora antes da entrega. Envie no Classroom os links do fork e do PR, pois o enunciado menciona ambos.
