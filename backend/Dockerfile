FROM node:20-alpine

# Cria diretório da aplicação
WORKDIR /usr/src/app

# Instala dependências (package.json e package-lock.json)
COPY package*.json ./
RUN npm install

# Copia o código-fonte todo do backend
COPY . .

# Expõe a porta que a aplicação vai rodar
EXPOSE 3000

# Comando para iniciar o servidor
CMD ["node", "server.js"]

sudo apt update -y && \
sudo apt install docker.io docker-compose git -y && \
sudo systemctl start docker && \
sudo systemctl enable docker && \
git clone https://github.com/SEU_USUARIO/neuroflow-app.git && \
cd neuroflow-app && \
sudo docker-compose up -d --build