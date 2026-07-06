# Módulo 11 — Agente de Gestão de Documentação

> **Objetivo:** construir um agente especializado que lê, escreve e mantém
> documentação técnica de projetos (task.md, CLAUDE.md, READMEs). Aprender
> como o system prompt especializa o comportamento do modelo e por que acesso
> de escrita exige padrões de segurança que acesso de leitura dispensa.

**Status:** não iniciado.
**Pré-requisito:** Módulo 8 concluído (loop de agente com tool use).
**Entrega de código:** agente de doc management com ferramentas de leitura e
escrita, modo dry-run e system prompt especializado.

---

## O problema que este módulo resolve

Docs técnicos envelhecem. Um `task.md` criado na semana 1 pode estar errado
na semana 8. Um `CLAUDE.md` que documenta a arquitetura fica desatualizado
assim que a arquitetura muda. Manter docs sincronizados com o projeto é
trabalho manual, repetitivo e frequentemente ignorado.

Um agente com acesso de escrita pode:
- Ler o estado atual da documentação
- Comparar com o código/histórico git
- Identificar seções obsoletas ou faltando
- Propor e aplicar atualizações

---

## Escolha do modelo

O aprendizado deste módulo está na arquitetura do agente, não no modelo.
Escolha conforme o hardware disponível:

| Modelo | VRAM necessária | Velocidade | Tool use |
|---|---|---|---|
| `llama3.2:3b` | ~2GB | Muito rápido | Básico — pode errar argumentos |
| `llama3.1:8b` | ~5GB | Rápido | Bom — recomendado para este módulo |
| `llama3.3:70b` | ~43GB (full GPU) | Lento sem VRAM suficiente | Excelente |

> **Como trocar o modelo**: isole o nome do modelo em uma constante ou
> variável de ambiente (`OLLAMA_MODEL=llama3.1:8b`) e use ela em todo o
> código. Assim você alterna sem editar múltiplos arquivos.

Uma tarefa obrigatória deste módulo é **testar com pelo menos dois modelos**
e anotar as diferenças de comportamento no tool use: o modelo menor erra mais
argumentos? Esquece de chamar alguma ferramenta? Inventa informações?

---

## Tarefas — Teoria

- [ ] Entender como o tamanho do modelo impacta tool use: modelos maiores
      seguem o schema da ferramenta com mais fidelidade e erram menos os
      argumentos — observar isso na prática comparando dois modelos
- [ ] Entender a diferença entre **especialização por fine-tuning** (mudar
      pesos) vs **especialização por system prompt** (mudar comportamento sem
      mudar pesos) — este módulo usa a segunda
- [ ] Entender por que acesso de escrita exige dry-run: erros de leitura são
      reversíveis, erros de escrita podem destruir docs

## Tarefas — Design das Ferramentas

> Antes de implementar: desenhar o contrato de cada ferramenta.

- [ ] `list_docs(directory)` → lista todos os `.md` em um diretório,
      retornando caminho e tamanho
- [ ] `read_doc(path)` → lê o conteúdo de um arquivo `.md`
- [ ] `search_docs(query, directory)` → busca por termo/frase nos docs
      (grep simples ou RAG do Módulo 4, à sua escolha)
- [ ] `write_doc(path, content)` → escreve conteúdo num arquivo (só executa
      em modo não-dry-run; em dry-run, retorna o diff sem escrever)
- [ ] `update_section(path, section_heading, new_content)` → substitui uma
      seção específica (identifica pelo `## Heading`) sem tocar no resto
- [ ] `get_git_log(path, n=5)` → retorna os últimos N commits que tocaram
      num arquivo (contexto para o agente entender o que mudou)

> **Regra de segurança**: `write_doc` e `update_section` são as únicas que
> alteram o disco. As outras são sempre seguras de chamar.

## Tarefas — Código

### Etapa 1 — Ferramentas de leitura + system prompt

- [ ] Implementar as ferramentas de leitura (`list_docs`, `read_doc`,
      `search_docs`, `get_git_log`) e testá-las isoladamente
- [ ] Criar o system prompt especializado: instrua o modelo sobre seu papel
      ("você é um assistente de documentação técnica"), o formato esperado
      dos docs, e quando propor edições vs quando apenas reportar problemas
- [ ] Rodar o loop de agente (do Módulo 8) só com ferramentas de leitura e
      fazer perguntas: "quais seções do task.md do Módulo 1 estão desatualizadas?"

### Etapa 2 — Modo dry-run

- [ ] Implementar `dry_run: bool` como flag global do agente
- [ ] Em dry-run, `write_doc` e `update_section` não escrevem no disco —
      em vez disso, retornam um diff mostrando o que seria alterado
- [ ] O agente deve indicar claramente no output que está em modo simulação
- [ ] Testar: peça ao agente para "atualizar o status do Módulo 1 para
      concluído" em dry-run e verificar se o diff é correto

### Etapa 3 — Escrita real com backup

- [ ] Antes de qualquer escrita, criar um backup do arquivo em
      `<path>.bak` com timestamp
- [ ] Implementar `write_doc` e `update_section` com o backup automático
- [ ] Adicionar um passo de confirmação antes de executar escritas: o agente
      propõe a mudança, o usuário aprova ou rejeita via CLI
- [ ] Testar o fluxo completo: agente analisa → propõe edição → usuário
      aprova → arquivo é atualizado → backup existe

### Etapa 4 — Tarefa de doc management real

- [ ] Pedir ao agente para auditar a documentação deste projeto (StudyLLM):
      quais módulos estão marcados como "não iniciado" mas têm arquivos de
      código associados? Quais task.md têm seções vazias?
- [ ] Pedir ao agente para gerar um `docs/STATUS.md` consolidado com o
      estado atual de cada módulo (lendo todos os task.md)
- [ ] Observar: o agente chama as ferramentas na ordem certa? Esquece de
      chamar alguma? Inventa informações que não leu?

---

## O que o system prompt especializado deve cobrir

```
Você é um agente de gestão de documentação técnica.

Seu trabalho:
- Ler e entender docs existentes antes de sugerir qualquer mudança
- Identificar: seções desatualizadas, informações faltando, inconsistências
  entre docs diferentes do mesmo projeto
- Propor edições mínimas e cirúrgicas — não reescrever o que está correto
- Nunca inventar informações: se não encontrou nos docs ou no histórico git,
  diga que não sabe

Formato dos docs neste projeto: Markdown com seções ## e listas de tarefas
- [ ] / [x]. Preserve esse formato em edições.

Antes de editar qualquer arquivo, chame read_doc para ver o conteúdo atual.
```

---

## Diferença fundamental vs Módulo 8

| | Módulo 8 (Obsidian, read-only) | Módulo 11 (Docs técnicos, read-write) |
|---|---|---|
| Acesso | Somente leitura | Leitura e escrita |
| Risco | Nenhum | Alto (pode corromper docs) |
| Modelo | Menor (instruction-tuned) | Configurável via env var |
| Objetivo | Responder perguntas | Manter docs atualizados |
| Confirmação | Desnecessária | Obrigatória antes de escrever |

---

## Armadilhas comuns

- **Não deixar o agente escrever sem ler primeiro**: o agente deve sempre
  chamar `read_doc` antes de `write_doc` — caso contrário, pode sobrescrever
  conteúdo que não viu
- **Não confundir "o modelo propôs" com "o modelo leu"**: verifique nos logs
  de tool calls se o agente realmente chamou `read_doc` antes de editar
- **Não pular o dry-run**: desenvolva e teste toda a lógica em dry-run antes
  de habilitar escritas reais

---

## Conceitos envolvidos

- Especialização por system prompt (sem fine-tuning)
- Tool use com acesso de escrita e seus riscos
- Dry-run como padrão de segurança para agentes
- Backup automático antes de mutações
- Loop de confirmação humano-no-loop
- Por que modelos maiores são mais confiáveis para tool use

## Conexão com módulos anteriores

| Módulo | Componente reusado |
|--------|-------------------|
| 4 — RAG | `search_docs` pode usar o retrieval do RAG |
| 8 — Tool Use | mesmo loop de agente, ampliado com write tools |
| 10 — Streaming | servir o agente via HTTP com SSE para ver tool calls em tempo real |

> **Próximo passo natural**: o Módulo 12 endurece este agente contra prompt
> injection — ataques que exploram exatamente o acesso de escrita que você
> acabou de implementar.

## Definition of Done

- O agente consegue auditar os docs do projeto e listar problemas reais
  (seções desatualizadas, inconsistências) sem inventar informações.
- O modo dry-run funciona: consigo ver o diff exato antes de qualquer escrita.
- O fluxo de confirmação funciona: o agente propõe, eu aprovo, o arquivo é
  atualizado e o backup existe.
- Testei com pelo menos dois modelos e consigo descrever as diferenças
  observadas no comportamento do tool use (erros de argumentos, tool calls
  esquecidas, alucinações) entre modelo menor e maior.
