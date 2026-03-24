CREATE TABLE IF NOT EXISTS caronas (
    id BIGSERIAL PRIMARY KEY,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    data_criacao TIMESTAMP,
    data_atualizacao TIMESTAMP,
    usuario_id BIGINT REFERENCES usuarios(id),
    origem VARCHAR(255) NOT NULL,
    destino VARCHAR(255) NOT NULL,
    data_hora TIMESTAMP NOT NULL,
    vagas INT NOT NULL,
    valor NUMERIC(10,2),
    telefone VARCHAR(50) NOT NULL,
    observacao TEXT
);

CREATE INDEX IF NOT EXISTS idx_caronas_data_criacao ON caronas(data_criacao DESC);
