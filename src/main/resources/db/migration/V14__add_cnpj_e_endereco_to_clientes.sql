ALTER TABLE clientes
    ADD COLUMN IF NOT EXISTS cnpj VARCHAR(14);

ALTER TABLE clientes
    ADD COLUMN IF NOT EXISTS endereco VARCHAR(255);

CREATE UNIQUE INDEX IF NOT EXISTS ux_clientes_cnpj
    ON clientes (cnpj);
