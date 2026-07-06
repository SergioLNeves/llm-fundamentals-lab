
    ███████╗████████╗██╗   ██╗██████╗ ██╗     ██╗     ███╗   ███╗
    ██╔════╝╚══██╔══╝██║   ██║██╔══██╗╚██╗   ██╔╝    ████╗ ████║
    ███████╗   ██║   ██║   ██║██║  ██║ ╚████████╔╝    ██╔████╔██║
    ╚════██║   ██║   ██║   ██║██║  ██║  ╚██╔═██╔╝     ██║╚██╔╝██║
    ███████║   ██║   ╚██████╔╝██████╔╝   ██║ ██║      ██║ ╚═╝ ██║
    ╚══════╝   ╚═╝    ╚═════╝ ╚═════╝    ╚═╝ ╚═╝      ╚═╝     ╚═╝

    Uma trilha de estudo pratico de LLMs, do fundamento probabilistico
    ate um assistente tecnico rodando inteiramente na sua maquina.


# StudyLLM

Este projeto e uma trilha de estudo construida de dentro pra fora: antes de
usar uma biblioteca de alto nivel ou um framework de agentes, voce implementa
cada conceito manualmente. O objetivo e que, ao final, voce seja capaz de
explicar cada decisao de arquitetura com base em experiencia pratica, nao em
documentacao que voce leu uma vez.

O modelo que roda ao longo de toda a trilha e local, via Ollama. Nenhuma
chamada a API externa e necessaria. Isso significa que voce controla o
hardware, os dados nunca saem da sua maquina, e voce sente na pratica as
vantagens e os limites de rodar um LLM sem depender de nuvem.

A trilha tem 14 modulos organizados em quatro arcos. Cada modulo tem um
arquivo `task.md` com tarefas de teoria, codigo e reflexao, alem de um
"Definition of Done" claro para voce saber quando avancou de verdade.


## A trilha

```
  Arco 1           Arco 2              Arco 3                Arco 4
  Fundamentos      Conhecimento        Agentes e Sistemas    Consolidacao

  [M1]             [M4]                [M8]                  [M13]
  [M2]  -------->  [M5]  ----------->  [M9]  ------------>   [M14]
  [M3]             [M6]                [M10]
                   [M7]                [M11]
                                       [M12]
```

### Arco 1 — Fundamentos

| Modulo | Topico | O que voce aprende |
|--------|--------|--------------------|
| 1 | Fundamentos de IA/LLM | Por que o modelo e probabilistico, nao deterministico. Limites de instruction following. A diferenca entre restringir por prompt e restringir estruturalmente. |
| 2 | Tokenizacao, Embeddings e Attention | Como texto vira numero, como o modelo relaciona tokens, e o que torna dois textos "semanticamente proximos". |
| 3 | Sampling Parameters | Como temperature, top-p, top-k e repeat_penalty controlam o comportamento da geracao. Quando usar determinismo e quando deixar o modelo ser criativo. |

### Arco 2 — Conhecimento e RAG

| Modulo | Topico | O que voce aprende |
|--------|--------|--------------------|
| 4 | Tipos de LLM e RAG funcional | Pretraining, fine-tuning, quantizacao, modelos densos vs MoE. Implementacao de um RAG completo: indexar um documento e responder perguntas sobre ele. |
| 5 | Desafios Reais de LLM | Hallucination, limite de contexto, retrieval ruim. Construir uma camada minima de avaliacao para entender quando o problema esta no retrieval e quando esta na geracao. |
| 6 | RAG de Producao | Vector DB persistente, indice HNSW, busca hibrida (semantica + keyword) e reranking. A diferenca de qualidade que cada camada adiciona sobre o RAG basico. |
| 7 | Fine-tuning e LoRA | Quando ajustar os pesos do modelo faz sentido. Como LoRA torna o fine-tuning viavel em hardware comum. O que melhora com RAG, o que melhora com fine-tuning, e o que so melhora com modelo maior. |

### Arco 3 — Agentes e Sistemas

| Modulo | Topico | O que voce aprende |
|--------|--------|--------------------|
| 8 | Tool Use / Agentes | Function calling: o modelo nao executa nada, ele pede para uma ferramenta ser chamada. O loop do agente. Contraste entre RAG (contexto empurrado) e tool use (contexto puxado). |
| 9 | Memoria Conversacional | Como tornar agentes stateful. Janela deslizante vs sumarizacao de historico. O impacto da memoria no context window e na qualidade das respostas. |
| 10 | Concorrencia e Streaming | Por que o Ollama serializa inferencia e como gerenciar multiplas requisicoes com `asyncio.Queue` e `Semaphore`. Como streamar tokens para o cliente em tempo real via SSE. |
| 11 | Agente de Gestão de Documentacao | Um agente com acesso de escrita sobre arquivos `.md` do projeto. System prompt como mecanismo de especializacao. Dry-run e confirmacao humana antes de qualquer mutacao. |
| 12 | Seguranca de Agentes | Prompt injection via conteudo de documentos. Exfiltracao de dados via ferramentas. Como implementar defesas: separacao instrucao/dado, allowlist de caminhos, logging de tool calls. |

### Arco 4 — Consolidacao

| Modulo | Topico | O que voce aprende |
|--------|--------|--------------------|
| 13 | Limitacoes de LLMs Locais | Knowledge cutoff, lost in the middle, latencia estrutural, trade-off privacidade vs cloud, VRAM como teto duro. Sai deste modulo com um criterio proprio de quando usar local vs cloud vs RAG vs fine-tuning. |
| 14 | Projeto Final | Integrar todos os componentes em um assistente tecnico local: RAG sobre seus projetos, tool use com leitura e escrita, streaming HTTP, memoria conversacional. Avaliacao com casos adversariais. |


## O que se torna possivel depois

Concluir esta trilha nao significa que voce sabe tudo sobre LLMs. Significa
que voce sabe o suficiente para tomar decisoes arquiteturais com base em
raciocinio proprio, nao em buzz. Algumas coisas que se tornam naturais:

**Assistente privado sobre os seus proprios dados.** Voce sabe indexar
qualquer conjunto de documentos, construir o pipeline de retrieval e servir
um agente que responde sobre eles sem que nada saia da sua maquina.

**Agentes de automacao com tool use.** Voce sabe implementar o loop de
agente, definir ferramentas com contratos claros, e adicionar guardrails de
seguranca para agentes que escrevem no disco, chamam APIs ou executam codigo.

**Criterio para escolher a arquitetura certa.** RAG, fine-tuning, modelo
maior, API cloud ou LLM local: voce ja provocou cada limitacao na pratica e
sabe explicar qual tecnica resolve cada tipo de problema.

**Base para sistemas de IA em producao.** Streaming, filas de inferencia,
avaliacao de qualidade, observabilidade: os modulos de infraestrutura preparam
o terreno para contribuir em sistemas reais, nao apenas em demos.


## Como comecar

### Pre-requisitos

- Python 3.10 ou superior
- [Ollama](https://ollama.ai) instalado e rodando
- Modelo recomendado: `llama3.1:8b` (cabe inteiro em 8 GB de VRAM)

```bash
ollama pull llama3.1:8b
ollama pull nomic-embed-text   # usado nos modulos de RAG
```

### Setup do projeto

```bash
git clone <url>
cd StudyLLM

make install   # cria venv e instala dependencias
make run       # sobe o servidor FastAPI com hot reload
```

O servidor sobe em `http://localhost:8000`.

### Navegando pelos modulos

Cada modulo esta em `docs/challenges/modulo_N/task.md`. Leia o `task.md`,
execute as tarefas na ordem e so avance quando o "Definition of Done" estiver
satisfeito. Nao ha ordem errada para consultar modulos anteriores.


## Estrutura do projeto

```
StudyLLM/
├── README.md
├── Makefile
├── requirements.txt
│
├── app/
│   ├── api/
│   │   └── main.py          # FastAPI: entry point da aplicacao
│   └── frontend/
│       ├── static/          # CSS compilado (Tailwind)
│       └── templates/       # Jinja2 templates
│
├── docs/
│   └── challenges/
│       ├── modulo_1/task.md
│       ├── modulo_2/task.md
│       ├── ...
│       └── modulo_14/task.md
│
└── tests/
```


## Filosofia

Este projeto nao usa frameworks de agente, orquestradores de RAG nem
abstrações de LLM prontas. Cada camada e implementada a mao antes de
qualquer biblioteca de conveniencia ser introduzida. O motivo e simples:
voce nao consegue depurar o que voce nao entende, e voce nao entende o que
nunca implementou.

Quando voce chegar ao Modulo 14 e o assistente estiver respondendo perguntas
sobre os seus proprios projetos, voce vai saber exatamente o que esta
acontecendo em cada linha do caminho.
