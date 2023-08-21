# python3.9 --> define a imagem base como uma imagem Pyhon 3.9 - alpine3.13 --> se refere a distribuição Alpine Linux na versão 3.13, mais leve e minimalista
FROM python:3.9-alpine3.13 

# LABEL --> adicionando um rótulo a imagem - mantainer="geila" --> mantenedor com o valor geila por exemplo
LABEL mantainer="geila"

# ENV --> define um ambiente virtual - PYTHONUNBUFFERED 1 --> verifica as mensagens de log em tempo real
ENV PYTHONUNBUFFERED 1

# Copia o arquivo requirements.txt do host para uma pasta temporária (tmp) para o ambiente de produção
COPY ./requirements.txt /tmp/requirements.txt

# semelhante ao comando anterior, com uma diferença que o esse está relacionado ao ambiente de desenvolvimento local
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

# copia o nome do projeto que foi criado para o ambiente de produção
COPY ./app /app

# Diretório de trabalho dentro do container
WORKDIR /app

# Documenta qual porta o contêiner está configurado para escutar/expõe.
EXPOSE 8000

# variável de argumento false para instalar pacotes adicionais de desenvolvimento
ARG DEV=false

# CONFIGURA O AMBIENTE DENTRO DO CONTÊINER
# linha 29 - cria um ambiente virtual chamado "py" - && --> encadeia comando na mesma linha
# /py/bin/pip install --upgrade pip && \--> atualiza o pip dentro do ambiente virtual criado
# apk add --update --no-cache postgresql-client && \ --> Instala o cliente PostgreSQL dentro do contêiner / util para seu aplicativo se comunicar com banco de dados
# apk add --update --no-cache --virtual .tmp-build-deps \ --> Instala pacotes necessários para compilar e instalar bibliotecas e dependências
# build-base postgresql-dev musl-dev && \ --> instala as dependências do arquivo requirements dentro do ambiente virtual
# if [ $DEV = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt ; fi && \ --> condicional que verifica se a variável de argumento DEV é igual a "true"
# rm -rf /tmp && \ --> remove o diretório temporário - ideal para economizar espaço no container após sua a instalação das dependências
# também remove pacotes temporários 
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
    build-base postgresql-dev musl-dev && \ 
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
    then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps

# Cria um usuário chamado "django-user" - desabilita senha e não cria diretório para esse usuário - esse usuário executa aplicativos ou serviços dentro de um container
RUN adduser \
    --disabled-password \
    --no-create-home \
    django-user

# define uma variável chamada PATH, no container em construção - 
ENV PATH="/py/bin:$PATH"

# define o usuário padrão do django 
USER django-user
