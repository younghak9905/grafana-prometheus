# Grafana Prometheus Setup Guide

This guide outlines the steps to set up Grafana with Prometheus for monitoring and logging purposes.

## Docker Installation

To install Docker, follow these steps:

1. Update package lists:
    ```bash
    sudo apt update
    ```

2. Create a shell script named `docker.sh` and paste the following content:
    ```bash
    #!/bin/bash
    sudo apt update
    sudo apt -y install ca-certificates curl gnupg lsb-release
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    docker --version
    # Docker Compose Installation
    sudo apt update
    sudo curl -SL https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    docker-compose --version
    ```

3. Make the script executable and run it:
    ```bash
    sudo chmod +x docker.sh
    sudo ./docker.sh
    ```

## Grafana Prometheus Installation

1. Clone the Grafana Prometheus repository:
    ```bash
    cd /srv
    sudo chown <USERNAME>:<USERNAME> ./
    git clone https://github.com/younghak9905/grafana-prometheus.git
    cd grafana-prometheus/docker/prometheus
    ```

2. Modify the `prometheus.yml` configuration file.

3. Execute the following command to start the Prometheus server:
    ```bash
    cd grafana-prometheus/docker/prometheus
    ./run.sh  # docker-compose up --build -d
    ```

## Exporter Configuration

The following sections provide configuration details for various exporters in the Prometheus setup. (prometheus.yml)

  ### Node Exporter

  서버의 **하드웨어 및 OS** 수준의 메트릭을 수집합니다.

`Agent`를 추가할 때마다 해당  IP 주소를 `node-export`를 올린 포트로 추가해 주어야 합니다.
  ```yaml
- job_name: 'node_exporter'
  static_configs:
    - targets:
        - agent-ip-address:9100 # Target for where Prometheus agent is installed
```
  ### LOKI
 로그 데이터를 수집하고 저장하는 **로깅 백엔드**입니다.

최초 설치 시 해당 서버의 IP 주소를 Loki를 올린 포트로 추가해야 합니다.
```yaml
- job_name: 'loki'
  static_configs:
    - targets: ['loki-ip-address:3100']   # Targeting the Grafana Prometheus server
```

  ### SSL Exporter
 **SSL/TLS 인증서**의 **만료**와 **유효성**을 체크하는 Exporter입니다.

검증할 `domain`주소를 추가해야 합니다. `replacement` 자리에는  `grafana-prometheus` 서버 내의 `ssl-exporter-ip`를 집어 넣습니다.
```yaml
- job_name: "ssl"
  metrics_path: /probe
  static_configs:
    - targets:          # SSL validation
        - target-domain
        - target-ip-address
  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - target_label: __address__
      replacement: prometheus-server-ip-address:9219 # Replaced with SSL Exporter service
```
  ### Cadvisor
**컨테이너**의 리소스 사용량과 성능 통계,등 상태 정보를 수집합니다.

`Agent`를 추가할 때마다 해당  IP 주소를 `cadvisor`를 올린 포트로 추가해 주어야 합니다.
```yaml
- job_name: 'cadvisor'
  static_configs:
    - targets:
        - agent-ip-address:8080
  relabel_configs:
    - source_labels: [container_name]
      target_label: name
```
  ### Blackbox Exporter
  서비스의 **엔드포인트**에 대한 **헬스 체크**를 수행합니다.

헬스 체크할 도메인을 targets에 추가합니다. `internal service`의 경우 `job_name`을 새로 추가하고  `replacement`에 해당 서버IP를 넣습니다.  외부 접속이 가능한 경우 `grafana-prometheus` 서버 IP로 대체 합니다.
```yaml
- job_name: 'blackbox-exporter-domain'
  scrape_interval: 5s
  metrics_path: /probe
  params:
    module: [http_2xx]
  static_configs:
    - targets:
        - target-domain
  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - target_label: __address__
      replacement: prometheus-server-ip-address:9115 # blackbox ip:port
```

## Grafana Loki Installation


1. Navigate to the Grafana Prometheus directory:
    ```bash
    cd /srv/grafana-prometheus/docker/grafana
    ```
2. connect datasource
   ```bash
    cd /srv/grafana-prometheus/docker/grafana/provisioning/datasource
    vi datasources
    ```
    ```yaml
    # config file version
    apiVersion: 1

    datasources:
    - name: Loki-123.203
      type: loki
      access: proxy
      url: http://{loki}:3000  
      jsonData:
        maxLines: 1000   

    - name: prom-123.203
      type: prometheus
      access: proxy
      url: http://{prometheus}:9090
      jsonData:
        maxLines: 1000
    ```

3. Execute the following command to start Grafana with Loki:
    ```bash
    ./run.sh      # docker-compose up --build -d
    ```

## Additional Configuration

- If external server logs are not collected, ensure port forwarding for port 3100 (Loki).

## Monitoring

To monitor logs, execute the following command:
```bash
docker logs --follow promtail-promtail-1
