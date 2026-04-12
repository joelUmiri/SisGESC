CREATE TABLE `tb_pessoa` (
  `pk_cpf` char(11) PRIMARY KEY NOT NULL COMMENT 'Check',
  `primeiro_nome` varchar(15) NOT NULL,
  `sobrenome` varchar(30) NOT NULL,
  `data_nasc` date NOT NULL COMMENT 'Check',
  `genero` enum(Masculino,Feminino,Outro) NOT NULL,
  `deficiencia` enum(Visual,Auditiva,Motora,Intelectual,Multipla,Nenhuma) NOT NULL DEFAULT 'Nenhuma',
  `etnia` enum(Branca,Preta,Parda,Amarela,Indígena,Outro/Prefiro não responder) NOT NULL
);

CREATE TABLE `tb_email` (
  `pk_email` varchar(40) PRIMARY KEY NOT NULL COMMENT 'check',
  `fk_cpf` char(11) NOT NULL COMMENT 'check'
);

CREATE TABLE `tb_telefone` (
  `pk_num_pais` char(3) NOT NULL DEFAULT '55' COMMENT 'check',
  `pk_ddd` char(2) NOT NULL COMMENT 'check',
  `pk_numero` char(9) NOT NULL COMMENT 'check',
  `pk_fk_cpf` char(11) NOT NULL,
  PRIMARY KEY (`pk_num_pais`, `pk_ddd`, `pk_numero`, `pk_fk_cpf`)
);

CREATE TABLE `tb_endereco` (
  `pk_cep` char(8) NOT NULL COMMENT 'check',
  `pk_numero` int NOT NULL COMMENT 'check',
  `complemento` varchar(20),
  PRIMARY KEY (`pk_cep`, `pk_numero`)
);

CREATE TABLE `tb_pessoa_endereco` (
  `pk_fk_cpf` char(11) NOT NULL,
  `pk_fk_cep` char(8) NOT NULL,
  `pk_fk_numero` int NOT NULL,
  PRIMARY KEY (`pk_fk_cpf`, `pk_fk_cep`, `pk_fk_numero`)
);

CREATE TABLE `tb_formacao` (
  `pk_id_formacao` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `nome_formacao` varchar(255) NOT NULL
);

CREATE TABLE `tb_departamento` (
  `pk_id_departamento` int PRIMARY KEY NOT NULL,
  `departamento` enum(Direção,Coordenação,Secretaria_ADM,Financeiro,Zeladoria,Inspetoria_Segurança,Biblioteca,Recursos_Humanos) NOT NULL
);

CREATE TABLE `tb_cargo` (
  `pk_id_cargo` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `nome_cargo` varchar(255) NOT NULL
);

CREATE TABLE `tb_cargo_departamento` (
  `pk_fk_id_cargo` int NOT NULL,
  `pk_fk_id_departamento` int NOT NULL,
  PRIMARY KEY (`pk_fk_id_cargo`, `pk_fk_id_departamento`)
);

CREATE TABLE `tb_funcionario` (
  `pk_n_contratacao` int PRIMARY KEY NOT NULL,
  `fk_cpf` char(11) UNIQUE NOT NULL,
  `status_funcionario` enum(Ativado,Desativado) NOT NULL COMMENT 'check',
  `dt_admissao` date NOT NULL,
  `dt_desligamento` date COMMENT 'check'
);

CREATE TABLE `tb_func_cargo` (
  `pk_fk_n_contratacao` int NOT NULL,
  `pk_fk_id_cargo` int NOT NULL,
  `pk_fk_id_departamento` int NOT NULL,
  `pk_data_inicio` date NOT NULL,
  `data_fim` date,
  PRIMARY KEY (`pk_fk_n_contratacao`, `pk_fk_id_cargo`, `pk_fk_id_departamento`, `pk_data_inicio`)
);

CREATE TABLE `tb_docente_detalhes` (
  `pk_fk_n_contratacao` int PRIMARY KEY NOT NULL,
  `categoria_docente` varchar(255) NOT NULL,
  `fk_id_formacao` int NOT NULL
);

CREATE TABLE `tb_ferias` (
  `pk_id_ferias` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `fk_n_contratacao` int NOT NULL,
  `dias_ferias` int NOT NULL DEFAULT 30 COMMENT 'check',
  `data_inicio` date NOT NULL,
  `data_fim` date NOT NULL COMMENT 'check',
  `status_ferias` enum(Agendada,Em_Andamento,Concluida,Cancelada) NOT NULL
);

CREATE TABLE `tb_ponto` (
  `pk_id_ponto` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `fk_n_contratacao` int NOT NULL,
  `data` date NOT NULL,
  `hora_entrada` time NOT NULL,
  `hora_saida` time COMMENT 'check'
);

CREATE TABLE `tb_folha_pagamento` (
  `pk_id_folha` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `fk_n_contratacao` int NOT NULL,
  `salario_base` decimal(10,2) NOT NULL COMMENT 'check',
  `data_pagamento` date NOT NULL
);

CREATE TABLE `tb_historico_pagamento` (
  `pk_id_historico` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `fk_n_contratacao` int NOT NULL,
  `salario_atual` decimal(10,2) NOT NULL COMMENT 'check',
  `data_alteracao` date NOT NULL
);

CREATE TABLE `tb_provento` (
  `pk_id_provento` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `fk_id_folha` int NOT NULL,
  `tipo` varchar(50) NOT NULL,
  `valor` decimal(10,2) NOT NULL COMMENT 'check'
);

CREATE TABLE `tb_desconto` (
  `pk_id_desconto` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `fk_id_folha` int NOT NULL,
  `tipo` varchar(50) NOT NULL,
  `valor` decimal(10,2) NOT NULL COMMENT 'check'
);

CREATE TABLE `tb_afastamento` (
  `pk_id_afastamento` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `fk_n_contratacao` int NOT NULL,
  `motivo` text NOT NULL,
  `status` enum(Em_Andamento,Concluído) NOT NULL,
  `data_inicio` date NOT NULL,
  `data_fim` date COMMENT 'check'
);

CREATE TABLE `tb_treinamento` (
  `pk_id_treinamento` int PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `fk_n_contratacao` int NOT NULL,
  `tipo_treinamento` varchar(255) NOT NULL,
  `carga_horaria` int NOT NULL COMMENT 'check',
  `data_inicio` date NOT NULL,
  `data_conclusao` date COMMENT 'check'
);

ALTER TABLE `tb_telefone` ADD FOREIGN KEY (`pk_fk_cpf`) REFERENCES `tb_pessoa` (`pk_cpf`);

ALTER TABLE `tb_funcionario` ADD FOREIGN KEY (`fk_cpf`) REFERENCES `tb_pessoa` (`pk_cpf`);

ALTER TABLE `tb_email` ADD FOREIGN KEY (`fk_cpf`) REFERENCES `tb_pessoa` (`pk_cpf`);

ALTER TABLE `tb_ponto` ADD FOREIGN KEY (`fk_n_contratacao`) REFERENCES `tb_funcionario` (`pk_n_contratacao`);

ALTER TABLE `tb_ferias` ADD FOREIGN KEY (`fk_n_contratacao`) REFERENCES `tb_funcionario` (`pk_n_contratacao`);

ALTER TABLE `tb_afastamento` ADD FOREIGN KEY (`fk_n_contratacao`) REFERENCES `tb_funcionario` (`pk_n_contratacao`);

ALTER TABLE `tb_folha_pagamento` ADD FOREIGN KEY (`fk_n_contratacao`) REFERENCES `tb_funcionario` (`pk_n_contratacao`);

ALTER TABLE `tb_treinamento` ADD FOREIGN KEY (`fk_n_contratacao`) REFERENCES `tb_funcionario` (`pk_n_contratacao`);

ALTER TABLE `tb_historico_pagamento` ADD FOREIGN KEY (`fk_n_contratacao`) REFERENCES `tb_funcionario` (`pk_n_contratacao`);

ALTER TABLE `tb_docente_detalhes` ADD FOREIGN KEY (`pk_fk_n_contratacao`) REFERENCES `tb_funcionario` (`pk_n_contratacao`);

ALTER TABLE `tb_docente_detalhes` ADD FOREIGN KEY (`fk_id_formacao`) REFERENCES `tb_formacao` (`pk_id_formacao`);

ALTER TABLE `tb_cargo_departamento` ADD FOREIGN KEY (`pk_fk_id_departamento`) REFERENCES `tb_departamento` (`pk_id_departamento`);

ALTER TABLE `tb_cargo_departamento` ADD FOREIGN KEY (`pk_fk_id_cargo`) REFERENCES `tb_cargo` (`pk_id_cargo`);

ALTER TABLE `tb_func_cargo` ADD FOREIGN KEY (`pk_fk_n_contratacao`) REFERENCES `tb_funcionario` (`pk_n_contratacao`);

ALTER TABLE `tb_func_cargo` ADD FOREIGN KEY (`pk_fk_id_cargo`, `pk_fk_id_departamento`) REFERENCES `tb_cargo_departamento` (`pk_fk_id_cargo`, `pk_fk_id_departamento`);

ALTER TABLE `tb_provento` ADD FOREIGN KEY (`fk_id_folha`) REFERENCES `tb_folha_pagamento` (`pk_id_folha`);

ALTER TABLE `tb_desconto` ADD FOREIGN KEY (`fk_id_folha`) REFERENCES `tb_folha_pagamento` (`pk_id_folha`);

ALTER TABLE `tb_pessoa_endereco` ADD FOREIGN KEY (`pk_fk_cpf`) REFERENCES `tb_pessoa` (`pk_cpf`);

ALTER TABLE `tb_pessoa_endereco` ADD FOREIGN KEY (`pk_fk_cep`, `pk_fk_numero`) REFERENCES `tb_endereco` (`pk_cep`, `pk_numero`);
