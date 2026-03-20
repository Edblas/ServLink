CREATE TABLE vagas (
    id BIGSERIAL PRIMARY KEY,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    data_criacao TIMESTAMP,
    data_atualizacao TIMESTAMP,
    empresa_id BIGINT NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    descricao VARCHAR(2000) NOT NULL,
    valor NUMERIC(10,2) NOT NULL,
    cidade_id BIGINT NOT NULL,
    data_trabalho DATE NOT NULL,
    status VARCHAR(50) NOT NULL,
    categoria_id BIGINT NOT NULL,
    CONSTRAINT fk_vaga_empresa FOREIGN KEY (empresa_id) REFERENCES clientes (id),
    CONSTRAINT fk_vaga_cidade FOREIGN KEY (cidade_id) REFERENCES cidades (id),
    CONSTRAINT fk_vaga_categoria FOREIGN KEY (categoria_id) REFERENCES categorias (id)
);

CREATE TABLE candidaturas (
    id BIGSERIAL PRIMARY KEY,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    data_criacao TIMESTAMP,
    data_atualizacao TIMESTAMP,
    vaga_id BIGINT NOT NULL,
    profissional_id BIGINT NOT NULL,
    data_candidatura TIMESTAMP NOT NULL,
    status VARCHAR(50) NOT NULL,
    CONSTRAINT fk_candidatura_vaga FOREIGN KEY (vaga_id) REFERENCES vagas (id),
    CONSTRAINT fk_candidatura_profissional FOREIGN KEY (profissional_id) REFERENCES profissionais (id),
    CONSTRAINT uq_vaga_profissional UNIQUE (vaga_id, profissional_id)
);

