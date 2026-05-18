# Sistema de Detecção de Hotspots em Painéis Fotovoltaicos via FPGA e Lógica Fuzzy

Este projeto implementa um sistema inteligente para a detecção e classificação de hotspots em painéis fotovoltaicos utilizando lógica fuzzy em hardware FPGA. A arquitetura foi adaptada de um controlador MPPT parametrizável para focar no diagnóstico de falhas térmicas e elétricas.

## Visão Geral

O sistema utiliza três entradas principais para diagnosticar a saúde do painel:
1.  **PPL (Power Loss Percentage):** Perda de potência em relação ao esperado.
2.  **$\Delta I_{sc}$:** Redução na corrente de curto-circuito.
3.  **$\Delta V_{oc}$:** Redução na tensão de circuito aberto.

A saída é um **Índice de Severidade de Hotspot (0-100%)**, que classifica o estado do painel entre Saudável, Hotspot Leve, Moderado ou Grave.

## Estrutura de Arquivos VHDL

| Arquivo | Descrição |
| :--- | :--- |
| `fixed_point_pkg.vhd` | Pacote para aritmética de ponto fixo. |
| `fuzzifier_ppl.vhd` | Módulo de fuzzificação para a entrada de perda de potência. |
| `fuzzifier_delta_isc.vhd` | Módulo de fuzzificação para a redução de corrente. |
| `fuzzifier_delta_voc.vhd` | Módulo de fuzzificação para a redução de tensão. |
| `fuzzy_rule_base.vhd` | Implementação da matriz de regras de diagnóstico. |
| `defuzzifier.vhd` | Cálculo do centróide para gerar o índice numérico final. |
| `hotspot_detector_top.vhd` | Módulo de nível superior que integra todos os componentes. |

## Guia de Implementação no Intel Quartus Prime

### 1. Configuração do Projeto
1.  Abra o **Intel Quartus Prime**.
2.  Vá em `File > New Project Wizard...` e siga as instruções para criar um novo projeto chamado `hotspot_detector`.
3.  Adicione todos os arquivos `.vhd` listados acima ao projeto.
4.  Selecione o dispositivo FPGA alvo (ex: Cyclone V).

### 2. Compilação e Síntese
1.  No `Project Navigator`, clique com o botão direito em `hotspot_detector_top.vhd` e selecione **Set as Top-Level Entity**.
2.  Inicie a compilação clicando no ícone de **Play** verde (`Start Compilation`).
3.  Verifique o `Compilation Report` para garantir que não existam erros de sintaxe ou de mapeamento.

### 3. Atribuição de Pinos
1.  Abra o **Pin Planner** (`Assignments > Pin Planner`).
2.  Atribua os pinos físicos do FPGA para as entradas (`clk`, `reset`, `ppl_raw`, etc.) e para a saída (`hotspot_idx`).
3.  Configure o **I/O Standard** de acordo com sua placa (ex: 3.3-V LVTTL).
4.  Recompile o projeto para aplicar as atribuições.

### 4. Simulação e Programação
1.  **Simulação:** Utilize o **ModelSim-Altera** para realizar simulações funcionais (RTL Simulation) injetando estímulos via testbench.
2.  **Programação:** Conecte sua placa via USB Blaster, abra o **Programmer** (`Tools > Programmer`), adicione o arquivo `.sof` gerado e clique em **Start**.

## Notas de Implementação
- **Aritmética:** O sistema utiliza o formato **Q8.8** para o índice de severidade e entradas, garantindo um equilíbrio entre precisão e uso de recursos.
- **Ajuste Fino:** As funções de pertinência nos módulos `fuzzifier_*.vhd` podem ser ajustadas para melhor se adequarem às especificações técnicas de diferentes modelos de painéis fotovoltaicos.

