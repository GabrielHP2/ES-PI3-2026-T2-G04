// João Pedro Panza Mainieri - RA: 25006642

import { FieldValue } from "firebase-admin/firestore";
import { Startup } from "../types/startupType";

import { db } from "../shared/firebase";

const startupCol = db.collection("startups");

export async function getStartupById(id: string): Promise<Startup> {
  const snapshot = await startupCol.doc(id).get();

  if (!snapshot.exists) {
    throw new Error(`Startup com id: "${id}" não encontrada`);
  }

  const startupData = snapshot.data() as Startup;
  return startupData;
}

const demoStartups = [
  {
    id: "fin-nova",
    name: "FinNova",
    token_symbol: "FNV",
    icon: "savings",
    status: "ativa",
    stage: "operacao",
    visibility: "publica",
    tags: ["fintech", "gestão financeira", "IA"],
    last_price: 1.25,
    short_description:
      "Plataforma de gestão financeira pessoal com IA para análise de gastos e metas de investimento.",
    full_description:
      "FinNova é uma plataforma que ajuda usuários a gerenciar finanças pessoais com análises baseadas em IA, sugestões de orçamento e metas de investimento automatizadas. Integra contas bancárias, cartões e investimentos para fornecer uma visão consolidada e recomendações personalizadas.",
    executive_summary:
      "Solução B2C de gestão financeira pessoal que utiliza ML para categorização automática, previsões de fluxo de caixa e recomendações de investimento.",
    corporate_structure: [
      {
        name: "Thiago Mendes",
        role: "CEO",
        equity_percent: 55,
        bio: "Fundador com 10 anos de experiência em finanças e produtos digitais.",
      },
      {
        name: "Beatriz Carvalho",
        role: "CTO",
        equity_percent: 45,
        bio: "Engenheira de software especializada em ML e infraestrutura financeira.",
      },
    ],
    pitch_video_url: "https://exemplo.com/finnova/demo",
    website: "https://exemplo.com/finnova",
    founded_at: "2021-05-05T00:00:00Z",
    current_raised: 280000,
    tokens_issued: 95000,
    investors_count: 18,
  },
  {
    id: "saude-ai",
    name: "SaudeAI",
    token_symbol: "SAI",
    icon: "monitor_heart",
    status: "ativa",
    stage: "operacao",
    visibility: "publica",
    tags: ["healthtech", "triagem médica", "IA"],
    last_price: 2.1,
    short_description:
      "Triagem clínica assistida por IA para reduzir tempo de espera em pronto atendimento.",

    full_description:
      "SaudeAI fornece um sistema de triagem inicial por IA para pronto atendimento, priorizando casos com base em sintomas e sinais vitais e entregando orientação para profissionais de saúde. O produto integra com prontuários eletrônicos e otimiza fluxo de pacientes.",
    executive_summary:
      "Ferramenta para hospitais e clínicas que diminui tempo de espera e melhora a alocação de recursos clínicos por meio de triagem automatizada.",
    corporate_structure: [
      {
        name: "Bruno Almeida",
        role: "CEO",
        equity_percent: 55,
        bio: "Médico e empreendedor com experiência em gestão hospitalar.",
      },
      {
        name: "Camila Rocha",
        role: "Head of ML",
        equity_percent: 45,
        bio: "Pesquisadora em IA aplicada à saúde, especialista em visão computacional e NLP clínico.",
      },
    ],
    pitch_video_url: "https://exemplo.com/saudeai/demo",
    website: "https://exemplo.com/saudeai",
    founded_at: "2020-03-01T00:00:00Z",
    current_raised: 450000,
    tokens_issued: 150000,
    investors_count: 27,
  },
  {
    id: "logi-chain",
    name: "LogiChain",
    token_symbol: "LGC",
    icon: "local_shipping",
    status: "ativa",
    stage: "expansao",
    visibility: "publica",
    tags: ["logtech", "blockchain", "rastreabilidade"],
    last_price: 3.5,
    short_description:
      "Rastreabilidade de logística com blockchain e auditoria de cadeia de suprimentos.",
    full_description:
      "LogiChain oferece rastreabilidade fim-a-fim para cadeias de suprimento usando blockchain para garantir imutabilidade e auditoria. Foca em entregas críticas, compliance e redução de perdas.",
    executive_summary:
      "Plataforma para indústrias e operadores logísticos que traz transparência e prova de procedência via ledger distribuído.",
    corporate_structure: [
      {
        name: "Diego Santos",
        role: "CEO",
        equity_percent: 40,
        bio: "Executivo do setor logístico com histórico em operações e supply chain.",
      },
      {
        name: "Fernanda Melo",
        role: "COO",
        equity_percent: 35,
        bio: "Especialista em operações e integração de sistemas ERP.",
      },
      {
        name: "Igor Ribeiro",
        role: "Head of Blockchain",
        equity_percent: 25,
        bio: "Arquiteto de soluções distribuídas com foco em segurança e criptografia.",
      },
    ],
    pitch_video_url: "https://exemplo.com/logichain/demo",
    website: "https://exemplo.com/logichain",
    founded_at: "2018-09-20T00:00:00Z",
    current_raised: 80000,
    tokens_issued: 250000,
    investors_count: 34,
  },
  {
    id: "edu-flex",
    name: "EduFlex",
    token_symbol: "EDX",
    icon: "workspace_premium",
    status: "ativa",
    stage: "nova",
    visibility: "publica",
    tags: ["edtech", "microlearning", "capacitação corporativa"],
    last_price: 0.4,
    short_description:
      "Microcursos adaptativos para capacitação corporativa com trilhas personalizadas.",
    full_description:
      "EduFlex fornece microlearning adaptativo para empresas com trilhas personalizadas, avaliações contínuas e integração com sistemas de RH para medir impacto no desempenho.",
    executive_summary:
      "Produto focado em upskilling corporativo utilizando conteúdo modular e adaptação por performance do usuário.",
    corporate_structure: [
      {
        name: "Juliana Pires",
        role: "Co-founder / Head Product",
        equity_percent: 50,
        bio: "Product manager com experiência em design instrucional e L&D.",
      },
      {
        name: "Marcos Vinicius",
        role: "Co-founder / CTO",
        equity_percent: 50,
        bio: "Desenvolvedor full-stack focado em plataformas educacionais.",
      },
    ],
    pitch_video_url: "https://exemplo.com/eduflex/demo",
    website: "https://exemplo.com/eduflex",
    founded_at: "2025-01-10T00:00:00Z",
    current_raised: 120000,
    tokens_issued: 60000,
    investors_count: 9,
  },
  {
    id: "agor-sense",
    name: "AgroSense",
    token_symbol: "AGR",
    icon: "agriculture",
    status: "ativa",
    stage: "operacao",
    visibility: "publica",
    tags: ["agritech", "sensores", "irrigação inteligente"],
    last_price: 1.1,
    short_description:
      "Sensoriamento de solo e irrigação inteligente para pequenas e médias fazendas.",
    full_description:
      "AgroSense fornece sensores de solo, análise de dados e controle automatizado de irrigação para aumentar produtividade e reduzir consumo de água em pequenas e médias propriedades.",
    executive_summary:
      "Solução IoT + ML para otimização de irrigação e manejo de nutrientes, com painel para tomada de decisão por produtores.",
    corporate_structure: [
      {
        name: "Larissa Teixeira",
        role: "CEO",
        equity_percent: 34,
        bio: "Engenheira agrônoma com experiência em tecnologia agrícola.",
      },
      {
        name: "Pedro Henrique",
        role: "CTO",
        equity_percent: 33,
        bio: "Especialista em IoT e sistemas embarcados.",
      },
      {
        name: "Rafaela Duarte",
        role: "Head of Data",
        equity_percent: 33,
        bio: "Cientista de dados com foco em modelos preditivos agrícolas.",
      },
    ],
    pitch_video_url: "https://exemplo.com/agrosense/demo",
    website: "https://exemplo.com/agrosense",
    founded_at: "2021-05-05T00:00:00Z",
    current_raised: 520000,
    tokens_issued: 180000,
    investors_count: 22,
  },
];

export async function seedDemoStartups() {
  const batch = db.batch();

  for (const startup of demoStartups) {
    const { id, ...data } = startup;
    const startupRef = startupCol.doc(id);

    batch.set(
      startupRef,
      {
        ...data,
        createdt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  }

  await batch.commit();

  return demoStartups.map((startup) => startup.id);
}
