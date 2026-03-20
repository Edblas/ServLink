CREATE TABLE usuarios (
    id BIGSERIAL PRIMARY KEY,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    data_criacao TIMESTAMP,
    data_atualizacao TIMESTAMP,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    telefone VARCHAR(50) NOT NULL,
    senha VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL
);

CREATE TABLE cidades (
    id BIGSERIAL PRIMARY KEY,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    data_criacao TIMESTAMP,
    data_atualizacao TIMESTAMP,
    nome VARCHAR(255) NOT NULL,
    estado VARCHAR(2) NOT NULL
);

CREATE TABLE categorias (
    id BIGSERIAL PRIMARY KEY,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    data_criacao TIMESTAMP,
    data_atualizacao TIMESTAMP,
    nome VARCHAR(255) NOT NULL,
    descricao VARCHAR(500)
);

CREATE TABLE profissionais (
    id BIGSERIAL PRIMARY KEY,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    data_criacao TIMESTAMP,
    data_atualizacao TIMESTAMP,
    usuario_id BIGINT NOT NULL UNIQUE,
    descricao VARCHAR(1000) NOT NULL,
    foto_url VARCHAR(1000),
    plano VARCHAR(50) NOT NULL,
    cidade_id BIGINT,
    categoria_id BIGINT,
    media_avaliacoes NUMERIC(3,2),
    CONSTRAINT fk_profissional_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios (id),
    CONSTRAINT fk_profissional_cidade FOREIGN KEY (cidade_id) REFERENCES cidades (id),
    CONSTRAINT fk_profissional_categoria FOREIGN KEY (categoria_id) REFERENCES categorias (id)
);

CREATE TABLE clientes (
    id BIGSERIAL PRIMARY KEY,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    data_criacao TIMESTAMP,
    data_atualizacao TIMESTAMP,
    usuario_id BIGINT NOT NULL UNIQUE,
    CONSTRAINT fk_cliente_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
);

CREATE TABLE avaliacoes (
    id BIGSERIAL PRIMARY KEY,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    data_criacao TIMESTAMP,
    data_atualizacao TIMESTAMP,
    cliente_id BIGINT NOT NULL,
    profissional_id BIGINT NOT NULL,
    nota INTEGER NOT NULL,
    comentario VARCHAR(1000),
    CONSTRAINT fk_avaliacao_cliente FOREIGN KEY (cliente_id) REFERENCES clientes (id),
    CONSTRAINT fk_avaliacao_profissional FOREIGN KEY (profissional_id) REFERENCES profissionais (id),
    CONSTRAINT ck_avaliacao_nota CHECK (nota >= 1 AND nota <= 5),
    CONSTRAINT uq_cliente_profissional UNIQUE (cliente_id, profissional_id)
);

CREATE TABLE assinaturas (
    id BIGSERIAL PRIMARY KEY,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    data_criacao TIMESTAMP,
    data_atualizacao TIMESTAMP,
    profissional_id BIGINT NOT NULL,
    plano VARCHAR(50) NOT NULL,
    valor NUMERIC(10,2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE,
    CONSTRAINT fk_assinatura_profissional FOREIGN KEY (profissional_id) REFERENCES profissionais (id)
);
