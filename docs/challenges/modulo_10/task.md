# Módulo 10 — Concorrência e Streaming: HTTP ↔ LLM Local

> **Objetivo:** entender os problemas reais de servir um LLM local via HTTP —
> por que requisições precisam de fila, como tokens gerados pelo Llama chegam
> ao cliente em tempo real, e quais primitivas do `asyncio` coordenam tudo isso.

**Status:** não iniciado.
**Pré-requisito:** Módulo 4 concluído (RAG funcional) + Ollama rodando.
**Entrega de código:** endpoint HTTP assíncrono com pooling de inferência e
streaming de tokens via SSE.

---

## O problema que este módulo resolve

Quando você tem um LLM rodando localmente e múltiplos clientes fazendo
perguntas ao mesmo tempo, surgem dois problemas que nenhuma camada anterior
resolveu:

1. **Problema de capacidade**: o Ollama roda inferência de forma serial (uma
   geração por vez na GPU/CPU). Se dez clientes chamam ao mesmo tempo, o que
   acontece? Sem controle, todas as chamadas competem e degradam juntas.

2. **Problema de experiência**: gerar uma resposta demora segundos. O cliente
   precisa esperar a resposta completa antes de ver qualquer coisa? Não — o
   Llama gera token por token e o cliente pode receber cada token assim que sai.

---

## Conceito central — o triângulo do problema

```
Cliente HTTP          Fila / Pool          Llama (Ollama)
─────────────         ───────────          ──────────────
GET /ask       ──►   asyncio.Queue   ──►  /api/generate
               ◄──   SSE (tokens)   ◄──   stream=True
```

- **Fila** (`asyncio.Queue`): desacopla a chegada de requisições da
  capacidade de inferência. Clientes enfileiram; um worker processa uma a uma.
- **Semáforo** (`asyncio.Semaphore`): alternativa à fila quando você quer
  limitar concorrência sem serializar completamente (ex: 2 modelos na GPU).
- **SSE** (Server-Sent Events): protocolo HTTP simples para o servidor empurrar
  eventos ao cliente enquanto a geração acontece. Cada token = um evento.
- **Event** (`asyncio.Event`): sinalização simples — "a resposta está pronta"
  sem precisar de poll.

---

## Tarefas — Teoria

- [ ] Entender por que o Ollama serializa inferência: GPU é um recurso único,
      paralelismo real exige múltiplas instâncias ou hardware diferente
- [ ] Entender SSE: diferença entre request-response normal vs streaming HTTP
      (chunked transfer, `text/event-stream`, `data:` lines)
- [ ] Entender `asyncio.Queue` como padrão produtor-consumidor: quem produz,
      quem consome, e o que acontece quando a fila está cheia (backpressure)
- [ ] Entender `asyncio.Semaphore`: quando usar no lugar da fila (sem ordering
      garantido, mas com concorrência limitada)

## Tarefas — Código

> Progressão: implementar do mais simples ao mais completo.

### Etapa 1 — Streaming direto (sem fila)

- [ ] Criar um endpoint FastAPI `GET /ask?q=...` que chama o Ollama com
      `stream=True` e retorna `StreamingResponse` com `media_type="text/event-stream"`
- [ ] Cada token gerado deve emitir um evento SSE: `data: <token>\n\n`
- [ ] Emitir um evento final `data: [DONE]\n\n` ao terminar
- [ ] Testar com `curl -N "http://localhost:8000/ask?q=ola"` e observar tokens
      chegando progressivamente

> **Ponto de reflexão**: o que acontece se você abrir 10 terminais fazendo
> curl ao mesmo tempo? Observe o comportamento do Ollama sem nenhuma fila.

### Etapa 2 — Pooling com Semáforo

- [ ] Adicionar um `asyncio.Semaphore(1)` para garantir que só uma inferência
      acontece por vez (ou `Semaphore(N)` para N paralelas)
- [ ] Observar que clientes agora aguardam em vez de competir
- [ ] Adicionar um timeout: se o cliente esperar mais de X segundos na fila,
      retornar 503 em vez de bloquear indefinidamente
- [ ] Comparar com e sem semáforo sob carga (mesmo que manual, com 3-4 curls)

### Etapa 3 — Fila com Worker Dedicado

- [ ] Criar uma `asyncio.Queue` e um worker que fica consumindo jobs
- [ ] Cada job carrega: a pergunta, e uma `asyncio.Queue` de resposta onde o
      worker deposita os tokens gerados
- [ ] O endpoint HTTP enfileira o job e passa a ler da fila de resposta,
      repassando tokens ao cliente via SSE
- [ ] Esse padrão desacopla completamente: o endpoint não espera o Ollama
      diretamente — ele espera a fila de resposta que o worker alimenta

```
Endpoint             job_queue           Worker
─────────            ─────────           ──────
job = Job(q, prompt)
job_queue.put(job)──►  Job ────────────► Ollama stream
for token in q:◄─────────────── q.put(token) ◄─ tokens
  yield SSE(token)
```

### Etapa 4 — Observabilidade mínima

- [ ] Endpoint `GET /status` que retorna: tamanho atual da fila, se o worker
      está ocupado, quantas requisições foram processadas
- [ ] Logar: quando cada job entra na fila, quando começa a inferência, quando
      termina (com tempo de espera e tempo de geração separados)

---

## O que NÃO fazer (armadilhas comuns)

- **Não usar `threading`**: o Ollama tem cliente HTTP assíncrono; misturar
  threads e asyncio cria problemas de deadlock difíceis de debugar
- **Não acumular toda a resposta antes de fazer stream**: isso anula o benefício
  do streaming — o cliente só veria a resposta completa de uma vez
- **Não ignorar backpressure**: se a fila crescer sem limite, a memória explode;
  defina `maxsize` na Queue e decida o que fazer quando cheia (rejeitar ou bloquear)

---

## Conceitos envolvidos

- `asyncio.Queue` — padrão produtor-consumidor
- `asyncio.Semaphore` — limitação de concorrência
- `asyncio.Event` — sinalização entre coroutines
- SSE (Server-Sent Events) — streaming HTTP simples
- Backpressure — o que acontece quando produção > consumo
- Chunked transfer encoding
- Separação entre latência de fila e latência de geração

## Conexão com módulos anteriores

| Módulo | Componente reusado aqui |
|--------|------------------------|
| 4 — RAG | o `query_service` pode ser o "job" enfileirado |
| 8 — Tool Use | o loop de agente pode ser um worker que consome uma fila |
| 7 — Go (opcional) | reescrever o worker em Go com `channel` no lugar de `asyncio.Queue` |

## Definition of Done

- Consigo abrir 5 clientes simultâneos e ver que eles esperam sua vez na fila
  em vez de degradar a qualidade uns dos outros.
- Consigo ver tokens aparecendo progressivamente no terminal (sem esperar a
  resposta completa) via `curl -N`.
- Consigo explicar a diferença entre usar `Semaphore` e usar `Queue + worker`
  e quando cada um é mais adequado.
