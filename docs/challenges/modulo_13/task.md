# Módulo 13 — Limitações Reais de LLMs Locais

> **Objetivo:** sentir na prática — não só saber na teoria — os limites de um
> LLM local: knowledge cutoff, degradação por contexto longo, latência
> estrutural e o trade-off privacidade vs cloud. Sair deste módulo com um
> critério claro de quando usar local, quando usar cloud e quando nenhum dos
> dois resolve.

**Status:** não iniciado.
**Pré-requisito:** Módulo 1 concluído. Os demais módulos enriquecem o
contexto mas não são obrigatórios.
**Entrega:** anotações práticas de cada experimento + tabela de decisão
pessoal (local vs cloud vs RAG vs fine-tuning).

---

## Por que um módulo separado para limitações

Os módulos anteriores cobrem limitações pontualmente — hallucination no 5,
instruction following no 1, VRAM no 11. Mas você nunca parou para **medir e
comparar** todas de uma vez. A diferença entre "saber que existe" e "ter
visto acontecer" é enorme quando você for decidir a arquitetura de um sistema
real.

Você já viveu a limitação de VRAM com o llama3.3 (10/81 camadas na GPU).
Este módulo faz o mesmo para as outras.

---

## Limitação 1 — Knowledge Cutoff

O modelo foi treinado até uma data. Ele não sabe de nada que aconteceu
depois, e às vezes não sabe que não sabe — o que é mais perigoso que admitir
ignorância.

**Experimentos:**

- [ ] Perguntar ao modelo a data do próprio knowledge cutoff: ele responde
      com confiança? A resposta é correta?
- [ ] Perguntar sobre um evento recente (pós-cutoff) sem dar contexto:
      o modelo inventa, admite que não sabe, ou mistura os dois?
- [ ] Perguntar sobre o mesmo evento mas fornecendo a informação correta no
      prompt: o modelo usa o contexto ou insiste no que "aprendeu"?
- [ ] Anotar: em quais situações o cutoff importa pouco (tarefas de
      raciocínio, código) e em quais é crítico (notícias, preços, versões
      de software)

> **Conexão com RAG**: o Módulo 4 resolve exatamente este problema —
> injetar contexto atualizado no prompt. Mas RAG não funciona se você não
> souber que o modelo tem um cutoff.

---

## Limitação 2 — Lost in the Middle

Modelos de linguagem prestam mais atenção ao início e ao fim do contexto.
Informações no meio de um contexto longo tendem a ser "esquecidas" — o
modelo as ignora mesmo estando lá.

**Experimentos:**

- [ ] Criar um documento de teste com ~20 parágrafos; esconder um fato
      específico e inventado no parágrafo 10 (ex: "a senha secreta é 7749")
- [ ] Enviar o documento inteiro no prompt e perguntar pela senha: o modelo
      encontra?
- [ ] Repetir colocando o fato no primeiro e no último parágrafo; comparar
      a taxa de acerto
- [ ] Aumentar o documento para ~50 parágrafos e repetir: a degradação
      piora?
- [ ] Anotar: qual o tamanho de contexto em que você começa a observar
      perda de informação com o seu modelo local

> **Implicação prática**: sistemas de RAG que retornam muitos chunks podem
> estar enviando a informação relevante para o "meio" do prompt e perdendo
> qualidade. A ordem dos chunks importa.

---

## Limitação 3 — Latência Estrutural

Mesmo com GPU cheia, um LLM local é mais lento que uma API cloud para
respostas longas. Isso não é bug — é física: tokens por segundo têm um teto
determinado pelo modelo e pelo hardware.

**Experimentos:**

- [ ] Medir tokens/segundo do seu modelo local com `ollama run llama3.1:8b`
      em três cenários: resposta curta (~50 tokens), média (~200 tokens),
      longa (~500 tokens)

      ```bash
      # O Ollama imprime estatísticas ao final de cada geração
      # Procure por: "eval rate" nos logs ou use /api/generate e leia
      # o campo "eval_duration" e "eval_count" da resposta JSON
      ```

- [ ] Comparar com uma API cloud gratuita (Groq, Together AI ou similar)
      na mesma pergunta: quantas vezes mais rápido?
- [ ] Identificar o seu caso de uso: respostas de que tamanho você vai gerar
      no Módulo 11? A latência local é aceitável para isso?
- [ ] Anotar: em quais cenários a latência local vira problema real
      (chat interativo, streaming ao usuário, pipeline com muitas chamadas
      encadeadas)

---

## Limitação 4 — Privacidade vs Cloud: o Trade-off Real

Usar LLM local significa que seus dados não saem da máquina. Usar cloud
significa velocidade e modelos maiores, mas seus prompts vão para servidores
de terceiros. Nenhum dos dois é sempre certo.

**Reflexão prática (sem código):**

- [ ] Listar três tipos de dados que você **nunca** enviaria para uma API
      cloud (ex: código proprietário, dados de clientes, informações médicas)
- [ ] Listar três casos onde privacidade não importa e cloud seria melhor
      (ex: perguntas genéricas, prototipagem com dados fictícios)
- [ ] Ler os termos de uso de uma API cloud que você cogita usar: os dados
      são usados para treino por padrão? Existe opt-out? Quanto tempo ficam
      armazenados?
- [ ] Definir para o seu projeto atual (StudyLLM): local ou cloud? Por quê?

---

## Limitação 5 — VRAM como Teto Duro

Você já viveu isso com o llama3.3. O objetivo aqui é formalizar o aprendizado.

- [ ] Documentar o que aconteceu: 10/81 camadas na GPU, 70 na CPU, ~3–5 t/s
      de velocidade
- [ ] Calcular: para rodar llama3.3 70B inteiramente na GPU, quantos GB de
      VRAM seriam necessários? (fórmula: parâmetros × bits_por_peso / 8)
- [ ] Mapear modelos que cabem inteiros na sua RTX 4060 8GB:
      - llama3.2:3b Q4 → ~2GB ✓
      - llama3.1:8b Q4 → ~5GB ✓
      - llama3.1:8b Q8 → ~9GB ✗
      - llama3.3:70b Q4 → ~43GB ✗
- [ ] Entender por que Q4 vs Q8 muda mais que o número de parâmetros em
      termos de velocidade (bandwidth da VRAM é o gargalo, não FLOPS)

---

## Tabela de Decisão Final

Ao final do módulo, preencha com base nos seus experimentos:

| Situação | Melhor abordagem | Por quê |
|---|---|---|
| Dados sensíveis/privados | | |
| Respostas em tempo real (<1s) | | |
| Conhecimento desatualizado | | |
| Contexto muito longo (>50k tokens) | | |
| Tarefa repetitiva com padrão fixo | | |
| Prototipagem rápida | | |
| Produção com custo previsível | | |

---

## Conceitos envolvidos

- Knowledge cutoff e suas consequências práticas
- Lost in the middle (atenção não é uniforme no contexto)
- Tokens/segundo como métrica de latência
- VRAM bandwidth vs FLOPS (por que Q4 é mais rápido que Q8 além de menor)
- Trade-off privacidade vs performance
- Quando RAG resolve e quando não resolve

## Conexão com módulos anteriores

| Módulo | Limitação aprofundada aqui |
|--------|---------------------------|
| 1 — Fundamentos | instruction following + formato JSON |
| 4 — RAG | RAG como solução para knowledge cutoff |
| 5 — Desafios | hallucination + context window |
| 10 — Concorrência | latência serial da inferência local |
| 11 — Doc Agent | VRAM como teto duro (caso llama3.3) |

## Definition of Done

- Provoquei e observei cada uma das cinco limitações na prática.
- Preenchi a tabela de decisão com base em experiência real, não em teoria.
- Consigo explicar, dado um requisito de sistema, por que escolheria local,
  cloud, RAG ou fine-tuning — e qual limitação tornaria cada opção inviável.
