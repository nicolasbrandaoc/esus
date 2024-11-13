

#!/bin/bash

# Este é um script para instalar o Prometheus em uma máquina Linux


echo "ESTE SCRIPT É DESTINADO PARA CONFIGURAÇÃO DO PROMETHEUS NO E-SUS"

sleep 5


# Passo 1: Faça o download do agente do Prometheus no Linux
echo "Baixando o Prometheus..."
wget https://github.com/prometheus/prometheus/releases/download/v2.53.2/prometheus-2.53.2.linux-amd64.tar.gz

# Passo 2: Descompacte o arquivo do agente
echo "Descompactando o arquivo..."
tar xzf prometheus-3.0.0-beta.0.linux-amd64.tar.gz

# Passo 3: Mova os arquivos para o diretório apropriado
echo "Movendo arquivos para /etc/prometheus..."
sudo mv prometheus-3.0.0-beta.0.linux-amd64 /etc/prometheus

# Passo 4: Crie o arquivo prometheus.service
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


# Passo 5: Rode o reload
echo "Recarregando o systemd..."
sudo systemctl daemon-reload

# Passo 6: Rode o restart
echo "Reiniciando o Prometheus..."
sudo systemctl restart prometheus

# Passo 7: Rode o enable
echo "Habilitando o Prometheus para iniciar automaticamente..."
sudo systemctl enable prometheus

# Passo 8: Rode o start
echo "Iniciando o Prometheus..."
sudo systemctl start prometheus

echo "Instalação do Prometheus concluída!"


sleep 5

echo "__________________________Agora será instalado o Node exporter__________________________"

sleep 5

# Passo 1: Faça o download do Node Exporter
echo "Baixando o Node Exporter..."
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz

# Passo 2: Descompacte o Node Exporter
echo "Descompactando o arquivo..."
tar xzf node_exporter-1.8.2.linux-amd64.tar.gz

# Passo 3: Mova os arquivos para o diretório apropriado
echo "Movendo arquivos para /etc/node_exporter..."
sudo mv node_exporter-1.8.2.linux-amd64 /etc/node_exporter

# Passo 4: Crie o arquivo de serviço node_exporter.service
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


# Passo 5: Rode o reload
echo "Recarregando o systemd..."
sudo systemctl daemon-reload

# Passo 6: Rode o restart
echo "Reiniciando o Node Exporter..."
sudo systemctl restart node_exporter

# Passo 7: Rode o enable
echo "Habilitando o Node Exporter para iniciar automaticamente..."
sudo systemctl enable node_exporter

# Passo 8: Rode o start
echo "Iniciando o Node Exporter..."
sudo systemctl start node_exporter

echo "Instalação do Node Exporter concluída!"


echo "\n\n\n===================== AJUSTANDO REGRAS DE FIREWALL... ==================="
sleep 5


linha_pesquisa=$(grep -n 'TCP_IN' /etc/csf/csf.conf | cut -f1 -d: | head -1);
linha_remover=$linha_pesquisa'd';


sed -i "$linha_remover" /etc/csf/csf.conf;
sed -i "$linha_pesquisa iTCP_IN = \"80,443,5433,7770:7800,8443,10050,44445,55556,9988,9090"\" /etc/csf/csf.conf;

csf -r


# Este script realiza a configuração final do Prometheus


echo "_________________Este script realiza a configuração final do Prometheus_________________"


sleep 5


# Passo 1: Obtém o IP da interface de rede eth0
ip=$(ip addr show eth0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)

# Verifica se o IP foi encontrado
if [ -z "$ip" ]; then
    echo "Não foi possível encontrar o IP da interface eth0."
    exit 1
fi

# Passo 2: Exibe o IP
echo "O seu IP é: $ip"

# Pausa por 5 segundos
sleep 5

# Passo 3: Remove o arquivo prometheus.yml
echo "Removendo o arquivo prometheus.yml..."
sudo rm -r /etc/prometheus/prometheus.yml

# Passo 4: Cria um novo arquivo prometheus.yml com o IP
echo "Criando um novo arquivo prometheus.yml..."
cat <<EOL | sudo tee /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
- job_name: node
  static_configs:
  - targets: ['$ip:9100']
EOL


# Reinicia o serviço Prometheus
echo "Reiniciando o Prometheus..."
sudo systemctl restart prometheus

# Verifica o status do serviço Prometheus
echo "Verificando o status do Prometheus..."
sudo systemctl status prometheus

echo "Configuração final do Prometheus concluída!"



enX0