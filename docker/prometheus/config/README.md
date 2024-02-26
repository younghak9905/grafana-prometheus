# 알림설정
## prometheus/config/alertmanager.yaml
연결할 slack API_URL을 넣습니다. 
```yaml
receivers:
- name: 'slack-notifications'
  slack_configs:
  - api_url: 'Slack_webhook_URL'    #write_down
    channel: '#infra-ops' # Slack channel 이름 앞에 '#'을 붙여야 합니다.
    username: "Prometheus"
    send_resolved: true
    text: "summary: {{ .CommonAnnotations.summary }}\ndescription: {{ .CommonAnnotations.description }}"
```

## set Rule
규칙을 확인하고 새로 추가할 규칙들을 구성하세요  (prometheus/config/rules/~)

description의 {grafana} 부분에 그라파나 ip-address를 입력하여 모니터링에 용이하게 설정할 수 있습니다.
```yaml
#container check
- name: instance-down
  rules:
  - alert: InstanceDown
    expr: (time() - container_last_seen{name!="prometheus", name!="prometheus-alertmanager-1"}) > 100
    for: 30s
    labels:
      severity: critical
    annotations:
      summary: "{{ $labels.name }} is down!!!  addr = {{ $labels.instance}}"
      description: " check log http://{grafana-ip-address}:3000/d/cb461949-7a3e-4908-8ff3-1c8f4f0b5dd2/docker?orgId=1&refresh=5m"
```

## ckeck alert
``http://prometheus-ip-address/9090/alerts``

 Prometheus Alerts 탭에서 추가한 Alert rule을 확인할 수 있습니다. 
또한 alert 발생 시 ``http://alert-manager-ip-address:9093`` alert-maneger에서 알람 현황을 확인, 제어할 수 있습니다.
