# Desafio Bemobi

Este repositório contém uma pequena API Rails para processar pagamentos e criar recargas via um provedor externo.

## Sumário
- [Requisitos](#requisitos)
- [Inicialização (Docker)](#inicializa%C3%A7%C3%A3o-docker)
- [Inicialização (local)](#inicializa%C3%A7%C3%A3o-local)
- [Rotas importantes / Documentação (Postman)](#rotas-importantes--documenta%C3%A7%C3%A3o-postman)
- [Testes e Coverage](#testes-e-coverage)

---

## Requisitos
- Docker & Docker Compose (recomendado)
- Ruby 3.3 (se executar localmente)
- PostgreSQL (ou use o serviço `db` pelo Docker Compose)

---

## Inicialização Docker
1. Construa a imagem (recomendado na primeira vez ou se alterar o `Gemfile`/`Dockerfile`):

```bash
docker compose build --no-cache web
```

2. Instale gems (se necessário) e suba os serviços:

```bash
# instala gems no container (opcional se bundle install já fez durante o build)
docker compose run --rm web bundle install

# cria/migra o banco de dados (development e test)
docker compose run --rm web bin/rails db:create db:migrate RAILS_ENV=development
docker compose run --rm web bin/rails db:create db:migrate RAILS_ENV=test

# sobe todos os serviços (foreground)
docker compose up
# ou em background
# docker compose up -d
```

3. A API estará disponível em `http://localhost:3000`.

Observação sobre gems: o `docker-compose.yml` usa um volume nomeado para persistir gems instaladas. Se mudar dependências, reconstrua a imagem.

---

## Inicialização local
1. Instale dependências Ruby:

```bash
bundle install
```

2. Crie e migre o banco de dados (ajuste `config/database.yml` se necessário):

```bash
bin/rails db:create db:migrate
```

3. Rode o servidor Rails:

```bash
bin/rails server -p 3000
```

A API ficará disponível em `http://localhost:3000`.

---

## Rotas importantes / Documentação (Postman)
O endpoint principal criado neste projeto é:

- POST /api/v1/payments — cria um `Payment` e, dependendo do `status`, dispara a criação de uma `Recharge`.

Recomendação de body JSON (exemplo):

```json
{
	"phone_number": "21929999999",
	"amount_in_cents": 1000,
	"status": "paid",
	"external_id": "ext-123",
	"product": { "id": "product_uuid", "amount": 20, "unit": "GB" },
	"customer": { "id": "customer_uuid" },
	"payment_source": { "id": "psrc", "name": "card" }
}
```

Coleção do Postman:
- Link: https://documenter.getpostman.com/view/17758188/2sB3WpRMEe


---

## Testes e Coverage
Este projeto usa RSpec para testes e SimpleCov para coverage.

<img width="1828" height="563" alt="image" src="https://github.com/user-attachments/assets/28058ef2-cf04-4807-8276-717d36375b5a" />


Para rodar os testes localmente (sem Docker):

```bash
bundle install
RAILS_ENV=test bin/rails db:create db:migrate
bundle exec rspec
```

Para rodar dentro do container (modo recomendado):

```bash
# instalar gems e migrar (uma vez)
docker compose run --rm web bundle install
docker exec -it <container_name_or_id> bash -lc "bin/rails db:create db:migrate RAILS_ENV=test"

# rodar a suíte de testes
docker compose run --rm web bundle exec rspec --format documentation
```

Após os testes, o SimpleCov gera um relatório HTML em `coverage/index.html`.

- Para trazer o relatório do container para o host:

```bash
docker cp <container_name_or_id>:/app/coverage ./coverage
xdg-open coverage/index.html
```

---

## Notas e troubleshooting
- Se `bundle exec rspec` falhar com `cannot load such file -- rspec`, execute `bundle install` no ambiente correto (host ou container).
- Erro comum: ao usar volumes (`.:/app`), arquivos gerados durante o build podem ficar escondidos. Se gems estiverem faltando no runtime, reconstrua a imagem ou crie o volume para `/usr/local/bundle`.
- Verifique `config/routes.rb` e `app/controllers/api/v1/payments_controller.rb` para confirmar os endpoints e comportamentos esperados.

---
