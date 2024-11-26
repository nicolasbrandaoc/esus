#!/bin/bash

# Este é um script para instalar o Prometheus e Node Exporter em uma máquina Linux

# Ativar debug para mostrar os comandos executados
set -x

echo "ESTE SCRIPT É DESTINADO PARA CONFIGURAÇÃO DO PROMETHEUS NO E-SUS"

sleep 5

# Passo 1: Baixar o Prometheus
echo "Baixando o Prometheus..."
wget https://github.com/prometheus/prometheus/releases/download/v2.53.2/prometheus-2.53.2.linux-amd64.tar.gz

# Verificar se o download foi bem-sucedido
if [[ $? -ne 0 ]]; then
    echo "Erro ao baixar o Prometheus."
    exit 1
fi

# Passo 2: Descompactar o arquivo
echo "Descompactando o arquivo do Prometheus..."
tar xzf prometheus-2.53.2.linux-amd64.tar.gz

# Passo 3: Mover arquivos para o diretório apropriado
echo "Movendo arquivos para /etc/prometheus..."
sudo mv prometheus-2.53.2.linux-amd64 /etc/prometheus

# Passo 4: Criar o arquivo de serviço para o Prometheus
echo "Criando o arquivo de serviço prometheus.service..."
cat <<EOL | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/etc/prometheus/prometheus --config.file=/etc/prometheus/prometheus.yml
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Passo 5: Recarregar systemd
echo "Recarregando o systemd..."
sudo systemctl daemon-reload

# Passo 6: Reiniciar o Prometheus
echo "Reiniciando o Prometheus..."
sudo systemctl restart prometheus

# Passo 7: Habilitar o Prometheus para iniciar automaticamente
echo "Habilitando o Prometheus para iniciar automaticamente..."
sudo systemctl enable prometheus

# Passo 8: Iniciar o Prometheus
echo "Iniciando o Prometheus..."
sudo systemctl start prometheus

echo "Instalação do Prometheus concluída!"

sleep 5

echo "__________________________Agora será instalado o Node exporter__________________________"

sleep 5

# Passo 1: Baixar o Node Exporter
echo "Baixando o Node Exporter..."
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz

# Verificar se o download foi bem-sucedido
if [[ $? -ne 0 ]]; then
    echo "Erro ao baixar o Node Exporter."
    exit 1
fi

# Passo 2: Descompactar o Node Exporter
echo "Descompactando o arquivo do Node Exporter..."
tar xzf node_exporter-1.8.2.linux-amd64.tar.gz

# Passo 3: Mover arquivos para o diretório apropriado
echo "Movendo arquivos para /etc/node_exporter..."
sudo mv node_exporter-1.8.2.linux-amd64 /etc/node_exporter

# Passo 4: Criar o arquivo de serviço para o Node Exporter
echo "Criando o arquivo de serviço node_exporter.service..."
cat <<EOL | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/etc/node_exporter/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Passo 5: Recarregar systemd
echo "Recarregando o systemd..."
sudo systemctl daemon-reload

# Passo 6: Reiniciar o Node Exporter
echo "Reiniciando o Node Exporter..."
sudo systemctl restart node_exporter

# Passo 7: Habilitar o Node Exporter para iniciar automaticamente
echo "Habilitando o Node Exporter para iniciar automaticamente..."
sudo systemctl enable node_exporter

# Passo 8: Iniciar o Node Exporter
echo "Iniciando o Node Exporter..."
sudo systemctl start node_exporter

echo "Instalação do Node Exporter concluída!"

echo "\n\n\n===================== AJUSTANDO REGRAS DE FIREWALL... ==================="
sleep 5

# Ajuste das regras de firewall (CSF)
linha_pesquisa=$(grep -n 'TCP_IN' /etc/csf/csf.conf | cut -f1 -d: | head -1)
linha_remover=$linha_pesquisa'd'

# Modifica a configuração do CSF
sed -i "$linha_remover" /etc/csf/csf.conf
sed -i "$linha_pesquisa iTCP_IN = \"80,443,5433,7770:7800,8443,10050,44445,55556,9988,9090\"" /etc/csf/csf.conf

# Aplicar a nova configuração no CSF
csf -r

echo "Regras de firewall ajustadas!"

sleep 5

# Obtendo o IP da interface de rede
echo "Obtendo o IP da interface de rede..."
ip=$(ip addr show eth0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)

# Verifica se o IP foi encontrado
if [ -z "$ip" ]; then
    echo "Não foi possível encontrar o IP da interface eth0."
    exit 1
fi

# Exibe o IP
echo "O seu IP é: $ip"

sleep 5

# Passo 3: Remover o arquivo prometheus.yml existente
echo "Removendo o arquivo prometheus.yml..."
sudo rm -r /etc/prometheus/prometheus.yml

# Passo 4: Criar um novo arquivo prometheus.yml com o IP
echo "Criando um novo arquivo prometheus.yml..."
cat <<EOL | sudo tee /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
- job_name: node
  static_configs:
  - targets: ['$ip:9100']
EOL

# Ajustando permissões de segurança para o arquivo
sudo chmod 600 /etc/prometheus/prometheus.yml

# Reiniciar o serviço do Prometheus para aplicar as alterações
echo "Reiniciando o Prometheus..."
sudo systemctl restart prometheus

# Verificando o status do Prometheus
echo "Verificando o status do Prometheus..."
sudo systemctl status prometheus

echo "Configuração final do Prometheus concluída!"

# Limpeza de arquivos temporários (opcional)
echo "Limpando arquivos temporários..."
rm -f prometheus-2.53.2.linux-amd64.tar.gz
rm -f node_exporter-1.8.2.linux-amd64.tar.gz

echo "Instalação e configuração concluídas com sucesso!"

# Desabilitar o debug (opcional)
set +x
