# Módulo 14 — Projeto Final: Assistente Técnico Local

> **Objetivo:** construir um sistema completo e utilizável que integra todos
> os conceitos dos módulos anteriores em uma única aplicação coerente —
> um assistente que conhece seus projetos, responde perguntas sobre eles,
> atualiza documentação e roda inteiramente na sua máquina.

**Status:** não iniciado.
**Pré-requisito:** todos os módulos anteriores concluídos (ou ao menos
4, 8, 10 e 11 como mínimo viável).
**Entrega:** sistema rodando localmente, utilizável no dia a dia.

---

## O que você vai construir

Um assistente técnico local que:

- **Conhece seus projetos** via RAG sobre a documentação (Módulos 2, 4 e 5)
- **Age sobre os docs** via tool use com leitura e escrita (Módulos 8 e 11)
- **Responde em tempo real** via HTTP com streaming de tokens (Módulo 10)
- **Sabe seus próprios limites** e admite quando não tem informação (Módulo 13)
- **Roda 100% local** no llama3.1:8b, sem dados saindo da sua máquina

```
┌──────────────────────────────────────────────────────┐
│              Cliente (curl / browser / CLI)           │
└────────────────────┬─────────────────────────────────┘
                     │ HTTP + SSE
┌────────────────────▼─────────────────────────────────┐
│              FastAPI  +  asyncio.Queue               │
│                    (Módulo 10)                       │
└────────────────────┬─────────────────────────────────┘
                     │
┌────────────────────▼─────────────────────────────────┐
│              Loop de Agente                          │
│         llama3.1:8b  ·  system prompt                │
│              (Módulos 1 e 8)                         │
└──────┬─────────────────────────────┬─────────────────┘
       │ tool use                    │ tool use
┌──────▼──────┐               ┌──────▼──────────────────┐
│  RAG Search │               │      File Tools          │
│  (Módulo 4) │               │  list · read · write     │
│             │               │  git_log · search        │
│  Índice dos │               │     (Módulo 11)          │
│  seus docs  │               └─────────────────────────┘
└─────────────┘
```

---

## Fase 1 — Arquitetura (antes de escrever código)

> A decisão mais importante do projeto: o que o agente resolve com RAG e o
> que resolve com tool use? Definir isso antes de implementar evita retrabalho.

- [ ] Desenhar no papel o diagrama do sistema com os componentes que você
      vai reutilizar de cada módulo
- [ ] Definir a fronteira RAG vs tool use para este projeto:
  - RAG é melhor quando: a pergunta é sobre conteúdo difuso espalhado por
    vários docs, e busca por similaridade semântica faz sentido
  - Tool use é melhor quando: a ação é precisa (ler um arquivo específico,
    escrever numa seção), ou quando o agente precisa navegar antes de agir
- [ ] Listar as ferramentas que o agente vai ter acesso (não implementar
      ainda — só listar e descrever o contrato de cada uma)
- [ ] Definir o system prompt base: qual o papel do agente, o que ele pode
      e não pode fazer, quando deve admitir que não sabe

---

## Fase 2 — Base de Conhecimento (RAG)

- [ ] Indexar a documentação do(s) projeto(s) que o assistente vai cobrir
      (pode começar com este próprio repositório: os `task.md` de cada módulo)
- [ ] Reutilizar o pipeline do Módulo 4: chunking → embedding → armazenamento
- [ ] Expor o RAG como uma ferramenta do agente (`rag_search(query)`) em vez
      de pipeline fixo — o agente decide quando buscar
- [ ] Testar a ferramenta isolada: a busca retorna chunks relevantes para
      perguntas sobre os módulos?

---

## Fase 3 — Suite de Ferramentas

Reutilizar do Módulo 11, ajustando ao escopo do projeto:

- [ ] `rag_search(query)` — busca semântica na base de conhecimento
- [ ] `list_docs(directory)` — lista arquivos `.md` de um diretório
- [ ] `read_doc(path)` — lê o conteúdo de um arquivo
- [ ] `update_section(path, heading, content)` — atualiza seção específica
- [ ] `get_git_log(path, n)` — histórico de mudanças de um arquivo
- [ ] Garantir que todas as ferramentas retornam erros claros (arquivo não
      encontrado, diretório vazio) — o agente precisa saber quando falhou

---

## Fase 4 — Loop de Agente

- [ ] Montar o loop completo: prompt do usuário → modelo escolhe ferramentas
      → executa → devolve resultado → modelo responde (ou chama outra ferramenta)
- [ ] Implementar limite de iterações (ex: máximo 6 rounds de tool use por
      pergunta) para evitar loops infinitos
- [ ] Modo dry-run herdado do Módulo 11: escritas em disco só acontecem com
      confirmação explícita
- [ ] Testar com perguntas reais:
  - "Qual o status atual de cada módulo?"
  - "O que falta para eu concluir o Módulo 3?"
  - "Atualiza o status do Módulo 1 para concluído"
  - "Resuma o que aprendi sobre RAG"

---

## Fase 5 — Camada HTTP com Streaming

- [ ] Encapsular o loop de agente em um endpoint FastAPI com SSE
- [ ] Streamar não só os tokens da resposta final, mas também os eventos
      intermediários: `[tool_call] read_doc("modulo_1/task.md")`,
      `[tool_result] ...`, `[thinking] ...` — o usuário vê o agente agindo
- [ ] Reutilizar o `asyncio.Queue` + worker do Módulo 10 para serializar
      as chamadas ao Ollama
- [ ] Testar com `curl -N` e depois com uma interface mínima (pode ser
      HTML simples com `EventSource`)

---

## Fase 6 — Avaliação

> Um sistema que "parece funcionar" não é o mesmo que um sistema que funciona.

- [ ] Criar um conjunto de 10 perguntas de teste com as respostas esperadas
- [ ] Medir: quantas o agente responde corretamente? Em quantas ele inventa?
      Em quantas ele chama a ferramenta errada?
- [ ] Identificar os dois maiores pontos de falha do sistema e anotar
      a causa (retrieval ruim? tool use impreciso? system prompt vago?)
- [ ] Aplicar pelo menos uma melhoria com base nos resultados e medir de
      novo — comparar antes e depois

---

## Fase 7 — Reflexão Final

- [ ] Documentar as limitações reais do sistema construído (usando o
      framework do Módulo 13): o que não funciona por causa do knowledge
      cutoff? Onde o lost in the middle aparece? Qual a latência média?
- [ ] Responder: o que mudaria se você tivesse VRAM suficiente para rodar
      um modelo 70B inteiramente na GPU?
- [ ] Responder: o que mudaria se você usasse uma API cloud? O que você
      perderia (privacidade, custo fixo)? O que ganharia (velocidade,
      modelos maiores)?
- [ ] Escrever em 1 parágrafo: o que este projeto te ensinou que nenhum
      tutorial ensinaria

---

## O que NÃO fazer

- **Não construir tudo de zero**: reutilize o código dos módulos anteriores.
  O projeto final é integração, não reescrita.
- **Não pular a Fase 1**: definir a arquitetura no papel antes de codificar
  evita descobrir no meio que RAG e tool use estão duplicando trabalho.
- **Não considerar "funciona no teste feliz" como done**: o Definition of
  Done exige avaliação com casos adversariais.

---

## Conceitos integrados

| Módulo | Componente no projeto final |
|--------|----------------------------|
| 1 — Fundamentos | system prompt, structured output para tool use |
| 2 — Arquitetura | embeddings para o RAG |
| 3 — Sampling | controle de criatividade vs determinismo da geração |
| 4 — RAG | pipeline de indexação e busca semântica |
| 5 — Desafios | avaliação, hallucination, grounding no contexto |
| 6 — RAG Produção | vector DB e reranking para retrieval de qualidade |
| 7 — Fine-tuning | referência: por que não fine-tunamos aqui? |
| 8 — Tool Use | loop de agente, schema das ferramentas |
| 9 — Memória | estado conversacional entre turnos |
| 10 — Concorrência | FastAPI + SSE + asyncio.Queue |
| 11 — Doc Agent | ferramentas de leitura e escrita, dry-run |
| 12 — Segurança | guardrails contra prompt injection no agente |
| 13 — Limitações | documentação honesta do que o sistema não faz |

## Definition of Done

- O sistema roda localmente e responde perguntas sobre os seus projetos
  sem travar, sem loops infinitos e sem erros não tratados.
- O streaming funciona: consigo ver tokens e eventos de tool use chegando
  progressivamente no terminal.
- A avaliação está feita: tenho um número concreto de acertos/erros e
  sei explicar por que o sistema falha onde falha.
- Consigo demonstrar o sistema para alguém que não estudou os módulos
  e explicar cada decisão de arquitetura com base no que aprendi.
