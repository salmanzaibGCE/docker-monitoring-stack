#!/bin/bash

set -e

echo "++++++++++++++++++++++++++++++"
echo "creating docker networking"
echo "++++++++++++++++++++++++++++++"


docker network create monitoring >/dev/null 2>&1 || true


echo "+++++++++++++++++++++++++++++++"
echo "creating prometheus configuration"
echo "+++++++++++++++++++++++++++++++++"


mkdir -p ~/prometheus


cat > ~/prometheus/prometheus.yml <<EOF
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "prometheus"

    static_configs:
      - targets:
          - localhsot:9090
  - job_name: "cadvisor"

    static_configs:
      - targets:
          - cadvisor:8080
EOF

echo "+++++++++++++++++++++++++"
echo "starting prometheus"
echo "+++++++++++++++++++++++++"

docker rm -f prometheus >/dev/null 2>&1 || true

docker run -d \
        --name prometheus \
        --restart unless-stopped \
        --network monitoring \
        -p 9090:9090 \
        -v ~/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
        prom/prometheus

echo "+++++++++++++++++++++++++++++++"
echo "creating grafana datasource"
echo "+++++++++++++++++++++++++++++++"


mkdir -p ~/grafana/provisioning/datasources

cat > ~/grafana/provisioning/datasources/prometheus.yml <<EOF
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
EOF

echo "+++++++++++++++++++++++++++++++++++"
echo "starting grafana"
echo "+++++++++++++++++++++++++++++++++++"

docker rm -f grafana >/dev/null 2>&1 || true

docker run -d \
        --name grafana \
        --restart unless-stopped \
        --network monitoring \
        -p 3000:3000 \
        -e GF_SECURITY_ADMIN_USER=admin \
        -e GF_SECURITY_ADMIN_PASSWORD=admin \
        -v ~/grafana/provisioning:/etc/grafana/provisioning \
        grafana/grafana

echo ""
echo "installation complete"
echo ""

echo "Grafana URL"
echo "http://13.63.175.1:3000"
echo ""

echo "Username: admin"
echo "Password: admin"
echo ""

echo "Prometheus URL:"
echo "http://13.63.175.1:9090"
echo ""

echo "Prometheus datasource has already been configured in grafana"
