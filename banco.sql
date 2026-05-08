DROP DATABASE IF EXISTS DB_INFINITY_SCHOOL;
CREATE DATABASE DB_INFINITY_SCHOOL;
USE DB_INFINITY_SCHOOL;

-- TABELAS CENTRAIS --------INICIO--------
CREATE TABLE `tb_pessoa` (
  `pk_cpf` char(11) PRIMARY KEY NOT NULL,
  `primeiro_nome` varchar(15) NOT NULL,
  `sobrenome` varchar(30) NOT NULL,
  `data_nasc` date NOT NULL,
  `genero` enum('Masculino','Feminino','Outro') not null,
  `deficiencia` enum('Visual','Auditiva','Motora','Intelectual','Multipla','Nenhuma') DEFAULT 'Nenhuma' not null,
  `etnia` enum('Branca','Preta','Parda','Amarela','Indígena','Outro/Prefiro não responder') not null,

  -- CHECA, COM O OPERADOR REGEXP, SE, DO INICIO AO FIM DO VALOR, TEM SOMENTE DIGITOS DO 0-9  E SE SÃO EXATOS 11 DIGITOS
  CHECK (pk_cpf REGEXP '^[0-9]{11}$')
);

CREATE TABLE `tb_email` (
  `pk_email` varchar(40) PRIMARY KEY NOT NULL,
  `fk_cpf` char(11) NOT NULL,
  
  -- FK QUE ASSOCIA O(S) EMAIL(S) À PESSOA
  FOREIGN KEY (fk_cpf)
  REFERENCES tb_pessoa(pk_cpf) ON DELETE CASCADE ON UPDATE CASCADE,
  
  -- RESTRIÇÃO QUE CHECA SE O EMAIL ESTÁ NO MODELO: <ALGO ANTES DO '@'> <@> <ALGO DEPOIS DO '@'> <.> <ALGO DEPOIS DO '.'> 
  CHECK (pk_email REGEXP '^[^@]+@[^@]+\\.[^@]+$')
);

CREATE TABLE `tb_telefone` (
  `pk_num_pais` char(3) NOT NULL DEFAULT '55',
  `pk_ddd` char(2) NOT NULL,
  `pk_numero` char(9) NOT NULL,
  `pk_fk_cpf` char(11) NOT NULL,
  
  -- CHAVE COMPOSTA DO NÚMERO DO TELEFONE + SEU DDD + SEU CODIGO DE PAIS + O CPF DA PESSOA ASSOCIADA
  PRIMARY KEY (`pk_num_pais`, `pk_ddd`, `pk_numero`, `pk_fk_cpf`),
  
  -- A PESSOA ASSOCIADA AO TELEFONE
  FOREIGN KEY (pk_fk_cpf)
  REFERENCES tb_pessoa(pk_cpf) ON DELETE CASCADE ON UPDATE CASCADE,
  
  -- RESTRINGE O CÓDIGO DO PAÍS A UM NÚMERO DE 1 A 3 DÍGITOS
  CHECK (pk_num_pais REGEXP '^[0-9]{1,3}$'),
  -- RESTRINGE O DD A UM NÚMERO DE DOIS DÍGITOS
  CHECK (pk_ddd REGEXP '^[0-9]{2}$'),
  -- RESTRINGE O NÚMERO DO TELEFONE À UM NÚMERO DE 8 A 9 DÍGITOS (FIXO E CELULAR)
  CHECK (pk_numero REGEXP '^[0-9]{8,9}$')
);

CREATE TABLE `tb_endereco` (
	`pk_cep` char(8) NOT NULL,
	`pk_numero` int NOT NULL,
	`complemento` varchar(20),
    
    PRIMARY KEY (`pk_cep`, `pk_numero`),
  -- GARANTE QUE O CEP É UM VALOR DE 8 DIGITOS COMPOSTO APENAS POR NÚMEROS
  CHECK (pk_cep REGEXP '^[0-9]{8}$'),
  -- GARANTE QUE O NÚMERO RESIDENCIAL NÃO É NEGATIVO
  CHECK (pk_numero >= 0)
);

CREATE TABLE `tb_pessoa_endereco` (
	`pk_fk_cpf` char(11) NOT NULL,
	`pk_fk_cep` char(8) NOT NULL,
	`pk_fk_numero` int NOT NULL,
  
  -- CHAVE PRIMÁRIA COMPOSTA DO CPF E DO ENDEREÇO DA PESSOA
  PRIMARY KEY (`pk_fk_cpf`, `pk_fk_cep`, `pk_fk_numero`),
  
  -- CHAVES ESTRANGEIRAS QUE APONTAM PARA O ENDEREÇO E A PESSOA
  FOREIGN KEY (`pk_fk_cpf`) REFERENCES tb_pessoa(`pk_cpf`)ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`pk_fk_cep`, `pk_fk_numero`) REFERENCES tb_endereco(`pk_cep`, `pk_numero`) ON DELETE CASCADE ON UPDATE CASCADE
);

-- TABELAS CENTRAIS --------FIM--------

-- TABELAS RH --------INICIO--------

CREATE TABLE `tb_formacao` (
  `pk_id_formacao` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `nome_formacao` varchar(255) NOT NULL UNIQUE
);

CREATE TABLE `tb_departamento` (
  `pk_id_departamento` int PRIMARY KEY NOT NULL,
  `departamento` enum('Direção','Coordenação','Secretaria_ADM','Financeiro','Zeladoria','Inspetoria_Segurança','Biblioteca','Recursos_Humanos') not null
);

CREATE TABLE `tb_cargo` (

  `pk_id_cargo` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `nome_cargo` varchar(255) NOT NULL UNIQUE
);

CREATE TABLE `tb_cargo_departamento` (
  `pk_fk_id_cargo` int NOT NULL,
  `pk_fk_id_departamento` int NOT NULL,
  PRIMARY KEY (`pk_fk_id_cargo`, `pk_fk_id_departamento`),
  
  -- FKs QUE REFERENCIAM O CARGO E SEU DEPARTAMENTO
  FOREIGN KEY (pk_fk_id_cargo)
  REFERENCES tb_cargo(pk_id_cargo)ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (pk_fk_id_departamento)
  REFERENCES tb_departamento(pk_id_departamento)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE `tb_funcionario` (
  `pk_n_contratacao` int PRIMARY KEY NOT NULL,
  `fk_cpf` char(11) UNIQUE NOT NULL,
  `status_funcionario` enum('Ativado','Desativado') NOT NULL,
  `dt_admissao` date NOT NULL,
  `dt_desligamento` date,
  
  -- DECLARA FK
  FOREIGN KEY (fk_cpf)
  REFERENCES tb_pessoa(pk_cpf)ON DELETE CASCADE ON UPDATE CASCADE,

  -- GARANTE QUE, SE OCORRER DESLIGAMENTO, ELE É DEPOIS DA DATA DE ADMISSÃO, SE NÃO, PERMANECER NULO
  CHECK (dt_desligamento IS NULL OR dt_desligamento >= dt_admissao),
  
  -- SE O FUNCIONÁRIO ESTÁ ATIVO, SUA DATA DE DESLIGAMENTO NÃO EXISTE, SE SIM, ELA É OBRIGATÓRIA
  CHECK(
    (status_funcionario = 'Ativado' AND dt_desligamento IS NULL)
    OR
    (status_funcionario = 'Desativado' AND dt_desligamento IS NOT NULL)
  )
);

CREATE TABLE `tb_func_cargo` (
  `pk_fk_n_contratacao` int NOT NULL,
  `pk_fk_id_cargo` int NOT NULL,
  `pk_fk_id_departamento` int NOT NULL,
  `pk_data_inicio` date NOT NULL,
  `data_fim` date,
  PRIMARY KEY (`pk_fk_n_contratacao`, `pk_fk_id_cargo`, `pk_fk_id_departamento`, `pk_data_inicio`),
  
  -- INDICAM AS FKs, pois é uma tabela com chave composta.
  FOREIGN KEY (pk_fk_n_contratacao)
  REFERENCES tb_funcionario(pk_n_contratacao)ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (pk_fk_id_cargo, pk_fk_id_departamento)
  REFERENCES tb_cargo_departamento(pk_fk_id_cargo, pk_fk_id_departamento)ON DELETE CASCADE ON UPDATE CASCADE,
  
  -- GARANTE QUE OU O CARGO ESTÁ ATIVO, OU ELE TEM UMA DATA DE FIM
  CHECK (
  data_fim IS NULL 
  OR data_fim >= pk_data_inicio
  )
);

CREATE TABLE `tb_docente_detalhes` (
  `pk_fk_n_contratacao` int PRIMARY KEY NOT NULL,
  `categoria_docente` varchar(255) NOT NULL,
  `fk_id_formacao` int NOT NULL,
  
  -- FKs QUE APONTAM O FUNCIONÁRIO E SUA FORMAÇÃO
  FOREIGN KEY (pk_fk_n_contratacao)
  REFERENCES tb_funcionario(pk_n_contratacao)ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (fk_id_formacao)
  REFERENCES tb_formacao(pk_id_formacao)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE `tb_ferias` (
  `pk_id_ferias` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `fk_n_contratacao` int NOT NULL,
  `dias_ferias` int NOT NULL DEFAULT 30,
  `data_inicio` date NOT NULL,
  `data_fim` date NOT NULL,
  `status_ferias` enum('Agendada','Em_Andamento','Concluida','Cancelada') not null,
  
  -- DECLARA A FK ASSOCIANDO AS FÉRIAS A UM FUNCIONÁRIO
  FOREIGN KEY (fk_n_contratacao)
  REFERENCES tb_funcionario(pk_n_contratacao)ON DELETE CASCADE ON UPDATE CASCADE,
  
  -- CHECA SE A DATA DE FIM É MAIOR QUE A DE INÍCIO
  CHECK (data_fim >= data_inicio),
  
  -- GARANTE QUE AS FÉRIAS DUREM AO MENOS UM DIA
  CHECK (dias_ferias > 0),
  
  UNIQUE (data_inicio, fk_n_contratacao)
);

CREATE TABLE `tb_ponto` (
  `pk_id_ponto` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `fk_n_contratacao` int NOT NULL,
  `data` date NOT NULL,
  `hora_entrada` time NOT NULL,
  `hora_saida` time,
  
  -- DECLARA A FK DO PONTO AO FUNCIONÁRIO RELACIONADO
  FOREIGN KEY (fk_n_contratacao)
  REFERENCES tb_funcionario(pk_n_contratacao)ON DELETE RESTRICT ON UPDATE CASCADE,
  
  -- CHECA SE O HORARIO SE SAIDA FOI GERADO, SE SIM, O PONTO DEVE SER DEPOIS DA ENTRADA
  CHECK (
  hora_saida IS NULL 
  OR hora_saida > hora_entrada
  ),
  
  UNIQUE(fk_n_contratacao,hora_entrada,`data`) 
);

CREATE TABLE `tb_folha_pagamento` (
  `pk_id_folha` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `fk_n_contratacao` int NOT NULL,
  `salario_base` decimal(10,2) NOT NULL,
  `data_pagamento` date NOT NULL,
  
  -- FKs QUE INDICAM O FUNCIONÁRIO DA FOLHA
  FOREIGN KEY (fk_n_contratacao)
  REFERENCES tb_funcionario(pk_n_contratacao)ON DELETE RESTRICT ON UPDATE CASCADE,
  
  -- CHECA QUE NENHUM SALÁRIO É MENOR QUE ZERO
  CHECK (salario_base >= 0),
  
  -- IMPEDE QUE UM FUNCIONÁRIO RECEBA UM PAGAMENTO NO MESMO DIA, EVITANDO ERROS
  UNIQUE (fk_n_contratacao, data_pagamento)
);

CREATE TABLE `tb_historico_pagamento` (
  `pk_id_historico` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `fk_n_contratacao` int NOT NULL,
  `salario_atual` decimal(10,2) NOT NULL,
  `data_alteracao` date NOT NULL,
  
  -- INDICA O FUNCIONÁRIO CUJO SALÁRIO FOI ALTERADO
  FOREIGN KEY (fk_n_contratacao)
  REFERENCES tb_funcionario(pk_n_contratacao)ON DELETE CASCADE ON UPDATE CASCADE,
  
  -- CHECA SE O SALÁRIO ATUAL É MAIOR OU IGUAL A ZERO. AFINAL, NÃO DEVE SER MENOR.
  CHECK (salario_atual >= 0),
  
  UNIQUE(fk_n_contratacao, data_alteracao)
);

CREATE TABLE `tb_provento` (
  `pk_id_provento` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `fk_id_folha` int NOT NULL,
  `tipo` varchar(50) NOT NULL,
  `valor` decimal(10,2) NOT NULL,
  
  -- INDICA A QUAL FOLHA ESSE PROVENTO PERTENCE
  FOREIGN KEY (fk_id_folha)
  REFERENCES tb_folha_pagamento(pk_id_folha)ON DELETE CASCADE ON UPDATE CASCADE,
  
  -- GARANTE QUE O VALOR DO PROVENTO NÃO SEJA NEGATIVO
  CHECK (valor >= 0),
  
  UNIQUE (fk_id_folha, tipo)
);

CREATE TABLE `tb_desconto` (
  `pk_id_desconto` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `fk_id_folha` int NOT NULL,
  `tipo` varchar(50) NOT NULL,
  `valor` decimal(10,2) NOT NULL,
  
  -- INDICA A QUAL FOLHA ESSE DESCONTO PERTENCE
  FOREIGN KEY (fk_id_folha)
  REFERENCES tb_folha_pagamento(pk_id_folha)ON DELETE CASCADE ON UPDATE CASCADE,
  
  -- GARANTE QUE O VALOR DO DESCONTO NÃO SEJA NEGATIVO
  CHECK (valor >= 0),
  
  UNIQUE (fk_id_folha, tipo)
);

CREATE TABLE `tb_afastamento` (
  `pk_id_afastamento` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `fk_n_contratacao` int NOT NULL,
  `motivo` text NOT NULL,
  `status` enum('Em_Andamento','Concluído'),
  `data_inicio` date NOT NULL,
  `data_fim` date COMMENT 'check',
  
  -- INDICA AS FKs QUE ASSOCIAM OS AFASTAMENTOS AO FUNCIONÁRIO
  FOREIGN KEY (fk_n_contratacao)
  REFERENCES tb_funcionario(pk_n_contratacao)ON DELETE CASCADE ON UPDATE CASCADE,
  
  -- CONFERE QUE A DATA DE FIM É OU VAZIO, OU MAIOR QUE A DE INÍCIO
  CHECK (
    data_fim IS NULL 
    OR data_fim >= data_inicio
  ),
  UNIQUE (fk_n_contratacao, data_inicio)
);

CREATE TABLE `tb_treinamento` (
  `pk_id_treinamento` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `fk_n_contratacao` int NOT NULL,
  `tipo_treinamento` varchar(255) NOT NULL,
  `carga_horaria` int NOT NULL,
  `data_inicio` date NOT NULL,
  `data_conclusao` date,
  
  -- FKs QUE INDICAM O FUNCIONÁRIO RECEBENDO O TREINAMENTO
  FOREIGN KEY (fk_n_contratacao)
  REFERENCES tb_funcionario(pk_n_contratacao)ON DELETE CASCADE ON UPDATE CASCADE,
  
  -- GARANTIA DE QUE A CARGA HORÁRIO É VÁLIDA, SENDO MAIOR QUE 0
  CHECK (carga_horaria > 0),
  
  -- DEFINE QUE, QUANDO NÃO NULA, A DATA DE CONCLUSÃO DO TREINAMENTO DEVE SER MAIOR QUE A DE INÍCIO
  CHECK (
    data_conclusao IS NULL 
    OR data_conclusao >= data_inicio
  ),
  UNIQUE(fk_n_contratacao, data_inicio)
);

-- TABELAS RH --------FIM--------

-- TABELAS ACADEMICO --------INICIO--------

CREATE TABLE `tb_unidade` (
  `pk_id_unidade` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `nome_unidade` varchar(50) UNIQUE NOT NULL,
  `logradouro` varchar(100) NOT NULL,
  `num_logradouro` varchar(10) NOT NULL,
  `complemento` varchar(50)
);

CREATE TABLE `tb_curso` (
  `pk_id_curso` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `nome_curso` varchar(50) UNIQUE NOT NULL,
  `duracao_meses` int NOT NULL,
  `idade_min` int NOT NULL,
  `idade_max` int,
  
  -- GARANTE QUE O CURSO DURA AO MENOS UM MES
  CHECK (duracao_meses > 0),
  -- GARANTE QUE A IDADE MÍNIMA PARA CURSAR É VÁLIDA
  CHECK (idade_min >= 0),
  -- GARANTE QUE A IDADE MÁXIMA, CASO NÃO FOR NULA, FOR MAIOR QUE A MÍNIMA
  CHECK (idade_max IS NULL OR idade_max >= idade_min)
);

CREATE TABLE `tb_aluno` (
  `pk_ra` varchar(10) PRIMARY KEY NOT NULL,
  `fk_cpf` char(11) UNIQUE NOT NULL,
  
  -- FK QUE LIGA O ALUNO AO SEU VÍNCULO ACADÊMICO
  FOREIGN KEY (fk_cpf)
  REFERENCES tb_pessoa(pk_cpf)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE `tb_disciplina` (
  pk_fk_id_curso int NOT NULL,
  pk_id_disciplina int NOT NULL,
  disciplina varchar(50) NOT NULL,
  
  -- CHAVE COMPOSTA DO CURSO E DA DISCIPLINA, AFINAL, UMA DISCIPLINA PERTENCE APENAS À UM CURSO
  PRIMARY KEY (pk_fk_id_curso, pk_id_disciplina),
  
  -- ESTRANGEIRA QUE APONTA PARA O DITO CURSO
  FOREIGN KEY (pk_fk_id_curso)
  REFERENCES tb_curso(pk_id_curso)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE `tb_turma` (
  pk_id_turma INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
  fk_n_contratacao INT NOT NULL,
  fk_id_curso INT NOT NULL,
  fk_id_disciplina INT NOT NULL,
  fk_id_unidade INT NOT NULL,
  data_inicio DATE NOT NULL,
  turno ENUM('Matutino','Vespertino','Noturno') NOT NULL,
  
  -- FK QUE APONTA PARA UMA PK COMPOSTA, NA TABELA DISCIPLINA
  FOREIGN KEY (fk_id_curso, fk_id_disciplina)
  REFERENCES tb_disciplina(pk_fk_id_curso, pk_id_disciplina)ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (fk_n_contratacao)
  REFERENCES tb_funcionario(pk_n_contratacao)ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (fk_id_unidade)
  REFERENCES tb_unidade(pk_id_unidade)ON DELETE CASCADE ON UPDATE CASCADE,
  
  UNIQUE (fk_id_curso, fk_id_unidade, data_inicio)
);

CREATE TABLE `tb_matricula` (
  pk_fk_ra VARCHAR(10) NOT NULL,
  pk_fk_id_turma INT NOT NULL,
  data_matricula DATE NOT NULL,
  status_matricula ENUM('Cursando','Aprovado','Reprovado','Trancado','Evadido') NOT NULL DEFAULT 'Cursando',
  nota1 DECIMAL(4,2),
  nota2 DECIMAL(4,2),
  nota3 DECIMAL(4,2),
  nota4 DECIMAL(4,2),
  total_faltas INT DEFAULT 0,
  
  -- CHAVE COMPOSTA DO ALUNO E DA TURMA EM QUE ELE SE ENCONTRA
  PRIMARY KEY (pk_fk_ra, pk_fk_id_turma),
  
  -- CHAVES ESTRANGEIRAS QUE ASSOCIAM O ALUNO E A TURMA NO BANCO
  FOREIGN KEY (pk_fk_ra)
  REFERENCES tb_aluno(pk_ra)ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (pk_fk_id_turma)
  REFERENCES tb_turma(pk_id_turma)ON DELETE CASCADE ON UPDATE CASCADE,
  
  -- GARANTE QUE A NOTA FINAL É UM NÚMERO ENTRE 0 E 10
	check ((nota1 BETWEEN 0 AND 10 OR nota1 IS NULL) AND
    (nota2 BETWEEN 0 AND 10 OR nota2 IS NULL) AND
    (nota3 BETWEEN 0 AND 10 OR nota3 IS NULL) AND
    (nota4 BETWEEN 0 AND 10 OR nota4 IS NULL))
);

CREATE TABLE `tb_grade_horaria` (
  pk_fk_id_turma INT NOT NULL,
  pk_dia_semana ENUM('seg','ter','qua','qui','sex') NOT NULL,
  pk_hora_inicio TIME NOT NULL,
  hora_fim TIME NOT NULL,
  
  -- CHAVE ESTRANGEIRA QUE GARANTO QUE UMA TURMA NÃO TENHA DUAS AULAS AO MESMO TEMPO
  PRIMARY KEY (pk_fk_id_turma, pk_dia_semana, pk_hora_inicio),
  
  -- IDENTIFICA A TURMA POR MEIO DE UMA CHAVE ESTRANGEIRA
  FOREIGN KEY (pk_fk_id_turma)
  REFERENCES tb_turma(pk_id_turma)ON DELETE CASCADE ON UPDATE CASCADE,
  
  -- CHECA SE A HORA DE FIM DA AULA É DEPOIS DA DE INÍCIO
  CHECK (hora_fim > pk_hora_inicio)
);

-- TABELAS ACADEMICO --------FIM--------

-- TABELAS FINANCEIRO --------INICIO--------

CREATE TABLE `tb_contrato` (
  `pk_registro_nrcontrato` int PRIMARY KEY AUTO_INCREMENT,
  `fk_ra` varchar(10) NOT NULL,
  `fk_id_turma` int NOT NULL,
  `data_inicio` date NOT NULL,
  `data_fim` date NOT NULL,
  `status_contrato` enum('Ativo','Bloqueado','Trancado') NOT NULL DEFAULT 'Ativo',
  
  -- FKs QUE ASSOCIAM O CONTRATO AO ALUNO E A TURMA EM QUE ELE ESTÁ
  FOREIGN KEY (`fk_ra`)
  REFERENCES tb_aluno(`pk_ra`)ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (`fk_id_turma`)
  REFERENCES tb_turma(`pk_id_turma`)ON DELETE RESTRICT ON UPDATE CASCADE,
  
  -- GARANTE QUE A DATA DE FIM NÃO É MENOR QUE A DE INÍCIO
  CHECK (`data_fim` >= `data_inicio`),
  
  UNIQUE (fk_ra, fk_id_turma, data_inicio)
);

CREATE TABLE `tb_mensalidade` (
  `pk_nsu` int PRIMARY KEY AUTO_INCREMENT,
  `fk_registro_nrcontrato` int NOT NULL,
  `data_emissao` date NOT NULL,
  `data_vencimento` date NOT NULL,
  `valor` decimal(10,2) NOT NULL,
  `status_mensalidade` enum('Pendente','Pago','Atrasado') NOT NULL DEFAULT 'Pendente',
  
  -- CHAVE ESTRANGEIRA QUE LIGA A MENSALIDADE AO REGISTRO DE CONTRATO
  FOREIGN KEY (`fk_registro_nrcontrato`)
  REFERENCES tb_contrato(`pk_registro_nrcontrato`)ON DELETE CASCADE ON UPDATE CASCADE,
  
  -- RESTRIÇÃO QUE GARANTE QUE A DATA DE VENCIMENTO É DEPOIS DA EMISSÃO
  CHECK (`data_vencimento` >= `data_emissao`),
  -- GARANTTE QUE O VALOR DE UMA MENSALIDADE É MAIOR QUE 0
  CHECK (`valor` > 0),
  
  UNIQUE (fk_registro_nrcontrato, data_emissao)
);

CREATE TABLE `tb_inadimplencia` (
  `pk_id_inadimplencia` int PRIMARY KEY AUTO_INCREMENT,
  `fk_nsu` int UNIQUE NOT NULL,
  `data_registro` date NOT NULL,
  `multa` decimal(10,2) NOT NULL DEFAULT 0,
  `juros` decimal(10,2) NOT NULL DEFAULT 0,
  
  -- FK QUE LIGA A INADIMPLENCIA À MENSALIDADE
  FOREIGN KEY (`fk_nsu`)
  REFERENCES tb_mensalidade(`pk_nsu`)ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE `tb_produto` (
  `pk_id_produto` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `nome_produto` varchar(45) NOT NULL UNIQUE
);

CREATE TABLE `tb_fornecedor` (
  `pk_cnpj` char(14) PRIMARY KEY,
  `razao_social` varchar(100) NOT NULL,
  `nome_fantasia` varchar(45) NOT NULL,
  -- GARANTE QUE O CNPJ SEJA UM VALOR DE 14 DIGITOS DE 0 A 9
  CHECK (pk_cnpj REGEXP '^[0-9]{14}$')
);

CREATE TABLE `tb_email_fornecedor` (
  `pk_email` varchar(100) PRIMARY KEY NOT NULL,
  `fk_cnpj` char(14) NOT NULL,
  FOREIGN KEY (fk_cnpj) REFERENCES tb_fornecedor(pk_cnpj) ON DELETE CASCADE ON UPDATE CASCADE,
  CHECK (pk_email REGEXP '^[^@]+@[^@]+\\.[^@]+$')
);

CREATE TABLE `tb_telefone_fornecedor` (
  `pk_ddd` char(2) NOT NULL,
  `pk_numero` char(9) NOT NULL,
  `fk_cnpj` char(14) NOT NULL,
  PRIMARY KEY (`pk_ddd`, `pk_numero`),
  FOREIGN KEY (fk_cnpj) REFERENCES tb_fornecedor(pk_cnpj) ON DELETE CASCADE ON UPDATE CASCADE,
  CHECK (pk_ddd REGEXP '^[0-9]{2}$'),
  CHECK (pk_numero REGEXP '^[0-9]{8,9}$')
);

CREATE TABLE `tb_compra` (
  `pk_nfe` char(44) PRIMARY KEY,
  `fk_cnpj` char(14) NOT NULL,
  
  -- CHAVE ESTRANGEIRA QUE CONECTA UMA COMPRA À UMA EMPRESA
  FOREIGN KEY (`fk_cnpj`)
  REFERENCES tb_fornecedor(`pk_cnpj`)ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE `tb_servico` (
  `pk_id_servico` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `desc_servico` varchar(45) NOT NULL,
  `valor_servico` decimal(10,2) NOT NULL,
  `fk_cpf` char(11) NOT NULL,
  `data_hora` datetime NOT NULL,
  
  -- LIGA O SERVIÇO A UM PRESTADOR
  FOREIGN KEY (fk_cpf)
  REFERENCES tb_pessoa(pk_cpf)ON DELETE RESTRICT ON UPDATE CASCADE,
  
  -- GARANTE QUE O VALOR DO SERVIÇO NÃO É NEGATIVO
  CHECK (valor_servico >= 0),
  
  UNIQUE (fk_cpf, data_hora)
);

CREATE TABLE `tb_conta_pagar` (
  `pk_cod_despesa` int PRIMARY KEY AUTO_INCREMENT,
  `fk_nfe` char(44),
  `fk_id_servico` int,
  `data_pagamento` date NOT NULL,
  `data_vencimento` date NOT NULL,
  
  FOREIGN KEY (`fk_nfe`)
  REFERENCES tb_compra(`pk_nfe`)
  ON DELETE RESTRICT
  ON UPDATE RESTRICT,

  FOREIGN KEY (`fk_id_servico`)
  REFERENCES tb_servico(`pk_id_servico`)
  ON DELETE RESTRICT
  ON UPDATE RESTRICT,
  
  CHECK (
    (fk_nfe IS NOT NULL AND fk_id_servico IS NULL)
    OR
    (fk_nfe IS NULL AND fk_id_servico IS NOT NULL)
  ),
    UNIQUE (fk_nfe, data_pagamento),
    UNIQUE (fk_id_servico, data_pagamento)
);

CREATE TABLE `tb_item_compra` (
  `pk_fk_nfe` char(44) NOT NULL,
  `pk_fk_id_produto` int NOT NULL,
  `valor_unitario` decimal(10,2) NOT NULL,
  `qtd` int NOT NULL,
  
  -- INDICA A CHAVE PRIMÁRIA, QUE É COMPOSTA DO IDENTIFICADOR DE UM ITEM E DE UMA COMPRA
  PRIMARY KEY (`pk_fk_nfe`, `pk_fk_id_produto`),
  
  -- IDENTIFICA TANTO O ITEM, QUANTO A COMPRA, EM SUAS RESPECTIVAS TABELAS
  FOREIGN KEY (`pk_fk_nfe`)
  REFERENCES tb_compra(`pk_nfe`)ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (`pk_fk_id_produto`)
  REFERENCES tb_produto(`pk_id_produto`)ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE `tb_conta_receber` (
  `pk_id_conta_receber` int PRIMARY KEY AUTO_INCREMENT,
  `fk_nsu` int NOT NULL UNIQUE,
  `data_prevista` date NOT NULL,
  `data_recebimento` date,
  
  -- FK QUE FAZ TB_CONTA_RECEBER SE LIGAR COM SUA RESPECTIVA MENSALIDADE
  FOREIGN KEY (`fk_nsu`)
  REFERENCES tb_mensalidade(`pk_nsu`)ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE `tb_pagamento` (
  `pk_id_pagamento` int PRIMARY KEY AUTO_INCREMENT NOT NULL,
  `fk_id_conta_receber` int NOT NULL,
  `valor_pago` decimal(10,2) NOT NULL,
  `data_pagamento` date NOT NULL,
  `forma_pagamento` ENUM('pix','dinheiro', 'debito', 'credito', 'boleto') NOT NULL,
  
  -- CHAVE ESTRANGEIRA QUE LIGA O PAGAMENTO COM A CONTA A RECEBER
  FOREIGN KEY (`fk_id_conta_receber`)
  REFERENCES tb_conta_receber(`pk_id_conta_receber`)ON DELETE RESTRICT ON UPDATE CASCADE,

  CHECK (`valor_pago` > 0),
  UNIQUE (fk_id_conta_receber, data_pagamento)
);

-- TABELAS FINANCEIRO --------FIM--------

-- TABELAS DE DIMENSÃO --------INICIO--------

CREATE TABLE dim_aluno (
    sk_aluno INT PRIMARY KEY AUTO_INCREMENT,
    ra VARCHAR(10) NOT NULL,
    cpf CHAR(11) NOT NULL unique,
    nome_completo VARCHAR(150) NOT NULL,
    genero varchar(10),
    etnia varchar(50),
    deficiencia varchar(20),
    data_nascimento DATE NOT NULL
);

CREATE TABLE dim_funcionario (
	sk_funcionario int PRIMARY KEY AUTO_INCREMENT,
	n_contratacao INT NOT NULL,
	cpf CHAR(11) NOT NULL UNIQUE,
	nome_completo VARCHAR(150) NOT NULL,
    genero varchar(10),
    etnia varchar(50),
    deficiencia varchar(20),
    data_nascimento DATE NOT NULL,
	status_funcionario VARCHAR(20),
	cargo VARCHAR(50),
	departamento varchar(50),
	formacao VARCHAR(255)
);

CREATE TABLE dim_unidade (
	sk_unidade INT PRIMARY KEY AUTO_INCREMENT,
    id_unidade INT UNIQUE,
	nome_unidade varchar(50),
	logradouro varchar(100),
	num_logradouro varchar(10),
	complemento varchar(50)
);

CREATE TABLE dim_turma (
    sk_turma INT PRIMARY KEY AUTO_INCREMENT,
    id_turma int unique,
    cod_turma_operacional VARCHAR(120), -- Ex: 'ADS-101-2026'
    nome_disciplina VARCHAR(50),       -- Atributo da disciplina
    nome_curso VARCHAR(50),            -- Atributo do curso
    turno varchar(20),
    nome_professor_titular varchar(150),
    data_inicio_turma DATE,
    duracao_meses_curso INT,
    carga_horaria_disciplina INT
);

CREATE TABLE dim_forma_pagamento (
    sk_forma_pagamento INT PRIMARY KEY AUTO_INCREMENT,
    forma_pagamento VARCHAR(30) NOT NULL unique -- Ex: 'Cartão de Crédito', 'Pix'
);

CREATE TABLE dim_fornecedor (
    sk_fornecedor INT PRIMARY KEY AUTO_INCREMENT,
    cnpj CHAR(14) NOT NULL unique,
    razao_social VARCHAR(100),
    nome_fantasia VARCHAR(45)
);

CREATE TABLE dim_produto (
    sk_produto INT PRIMARY KEY AUTO_INCREMENT,
    codigo_produto_operacional INT unique, -- O ID que está na tb_produto
    nome_produto VARCHAR(45)
    -- categoria_produto VARCHAR(30)   -- Ex: 'Limpeza', 'Escritório', 'Informática'
);

CREATE TABLE dim_status (
    sk_status INT PRIMARY KEY AUTO_INCREMENT,
    status_nome VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE dim_tempo (
    sk_tempo INT PRIMARY KEY, -- Formato YYYYMMDD (Ex: 20260506)
    data_completa DATE NOT NULL,
    dia INT,
    mes INT,
    nome_mes VARCHAR(15),
    trimestre INT,
    ano INT,
    dia_semana VARCHAR(15),
    semestre INT,
    flag_feriado TINYINT(1) DEFAULT 0, -- 1 para Sim, 0 para Não
    nome_feriado VARCHAR(50)
);
-- TABELAS DE DIMENSÃO --------FIM--------

-- TABELAS FATO --------INICIO--------

-- 1. Fato Acadêmico-> Granularidade: Um registro por aluno, por turma e por trimestre.
CREATE TABLE fato_academico (
    sk_aluno INT NOT NULL,
    sk_turma INT NOT NULL,  -- Esta chave agora traz Curso e Disciplina junto
    sk_unidade INT NOT NULL,
    sk_tempo INT NOT NULL,
    sk_status int not null,
    
    nota DECIMAL(4,2), -- Métrica não-aditiva
    total_faltas INT DEFAULT 0, -- Métrica aditiva
    
    qtd_matricula INT DEFAULT 1, -- Métrica aditiva
    
    FOREIGN KEY (sk_aluno) REFERENCES dim_aluno(sk_aluno),
    FOREIGN KEY (sk_turma) REFERENCES dim_turma(sk_turma),
    FOREIGN KEY (sk_unidade) REFERENCES dim_unidade(sk_unidade),
    FOREIGN KEY (sk_tempo) REFERENCES dim_tempo(sk_tempo),
    FOREIGN KEY (sk_status) REFERENCES dim_status(sk_status),
    
    UNIQUE (sk_aluno,sk_turma,sk_tempo),
    
    PRIMARY KEY (
        sk_aluno,
        sk_turma,
        sk_tempo
    )
);

-- 2. Fato Financeiro-> Granularidade: Uma linha por transação financeira (seja entrada de mensalidade
-- ou saída para compra de material/serviço) por unidade e por data.
CREATE TABLE fato_financeiro (
    sk_tempo INT NOT NULL,
    sk_unidade INT NOT NULL,
    sk_forma_pagamento INT NOT NULL,
    sk_aluno INT DEFAULT 0,      -- Se for saída (compra), pode ser 0 ou NULL
    sk_fornecedor INT DEFAULT 0, -- Se for entrada (mensalidade), pode ser 0 ou NULL
    sk_produto INT DEFAULT 0,    -- Usado apenas para compras de material
    
    valor_pago DECIMAL(10,2) DEFAULT 0.00, -- Métrica aditiva
    valor_total_encargos DECIMAL(10,2) DEFAULT 0.00, -- Juros e multas recebidos, métrica aditiva
    qtd_mensalidade_paga INT DEFAULT 0, -- Métrica aditiva
    
    valor_total_compra DECIMAL(10,2) DEFAULT 0.00, -- Métrica aditiva
    quantidade_comprada INT DEFAULT 0, -- Métrica aditiva
    
    FOREIGN KEY (sk_tempo) REFERENCES dim_tempo(sk_tempo),
    FOREIGN KEY (sk_unidade) REFERENCES dim_unidade(sk_unidade),
    FOREIGN KEY (sk_forma_pagamento) REFERENCES dim_forma_pagamento(sk_forma_pagamento),
    FOREIGN KEY (sk_aluno) REFERENCES dim_aluno(sk_aluno),
    FOREIGN KEY (sk_fornecedor) REFERENCES dim_fornecedor(sk_fornecedor),
    FOREIGN KEY (sk_produto) REFERENCES dim_produto(sk_produto)
    
    -- pk
);

-- 3. Fato RH-> Granularidade: Um registro por funcionário, por unidade e por mês de referência.
-- socorro
CREATE TABLE fato_rh (
    sk_funcionario INT NOT NULL,
    sk_unidade INT NOT NULL,
    sk_tempo INT NOT NULL,
    
    -- Métricas Financeiras de RH
    salario_base DECIMAL(10,2),  -- Métrica semi-aditiva
    total_proventos DECIMAL(10,2), -- Métrica aditiva
    total_descontos DECIMAL(10,2), -- Métrica aditiva
    salario_liquido DECIMAL(10,2), -- Métrica semi-aditiva
    
    -- Métricas de Frequência e Horas
    horas_trabalhadas DECIMAL(6,2),  -- Métrica aditiva
    horas_extra DECIMAL(6,2), -- Métrica aditiva
    qtd_faltas_ponto INT DEFAULT 0, -- Métrica aditiva
    
    -- Flags de Status no Período
    flag_ferias TINYINT(1) DEFAULT 0, -- Métrica não-aditiva
    flag_afastamento TINYINT(1) DEFAULT 0, -- Métrica não-aditiva
    
    -- Métricas de Desenvolvimento
    qtd_treinamentos INT DEFAULT 0, -- Métrica aditiva
    horas_treinamento DECIMAL(6,2) DEFAULT 0.00, -- Métrica aditiva

    FOREIGN KEY (sk_funcionario) REFERENCES dim_funcionario(sk_funcionario),
    FOREIGN KEY (sk_unidade) REFERENCES dim_unidade(sk_unidade),
    FOREIGN KEY (sk_tempo) REFERENCES dim_tempo(sk_tempo)
);

-- TABELAS FATO --------FIM--------
