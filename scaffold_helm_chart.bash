#!/bin/bash
# Scaffolds the Helm chart for the RideShare Platform

echo "⛵ Bootstrapping Helm Chart..."

# 1. Create Chart Metadata
cat << 'EOF' > helm/rideshare-platform/Chart.yaml
apiVersion: v2
name: rideshare-platform
description: A Helm chart for the RideShare Multi-Service Platform
type: application
version: 1.0.0
appVersion: "1.0"
EOF

# 2. Create the Global Configuration (values.yaml)
cat << 'EOF' > helm/rideshare-platform/values.yaml
# Global Configuration for all microservices
namespace: rideshare-prod

# The Loop Array: Helm will iterate over this to build our resources
services:
  price-estimator:
    image: "rideshare/price-estimator:latest"
    port: 8000
    replicas: 2
    isPublic: true
    ingressPath: "/api/v1/estimate"

  payment-api:
    image: "rideshare/payment-api:latest"
    port: 8000
    replicas: 2
    isPublic: false # Strictly internal

  admin-api:
    image: "rideshare/admin-api:latest"
    port: 8000
    replicas: 1
    isPublic: false # Strictly internal

  payment-ui:
    image: "rideshare/payment-ui:latest"
    port: 80
    replicas: 2
    isPublic: true
    ingressPath: "/checkout"

  admin-ui:
    image: "rideshare/admin-ui:latest"
    port: 80
    replicas: 1
    isPublic: true
    ingressPath: "/admin"
EOF

# 3. Create the Generic Deployment Template
cat << 'EOF' > helm/rideshare-platform/templates/deployment.yaml
{{- range $name, $config := .Values.services }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ $name }}
  labels:
    app: {{ $name }}
spec:
  replicas: {{ $config.replicas }}
  selector:
    matchLabels:
      app: {{ $name }}
  template:
    metadata:
      labels:
        app: {{ $name }}
    spec:
      containers:
        - name: {{ $name }}
          image: "{{ $config.image }}"
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: {{ $config.port }}
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "250m"
              memory: "256Mi"
{{- end }}
EOF

# 4. Create the Generic Service Template
cat << 'EOF' > helm/rideshare-platform/templates/service.yaml
{{- range $name, $config := .Values.services }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ $name }}-svc
  labels:
    app: {{ $name }}
spec:
  selector:
    app: {{ $name }}
  ports:
    - protocol: TCP
      port: 80
      targetPort: {{ $config.port }}
  type: ClusterIP
{{- end }}
EOF

# 5. Create the Ingress Template (Routing Rules)
cat << 'EOF' > helm/rideshare-platform/templates/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rideshare-ingress
  annotations:
    kubernetes.io/ingress.class: "alb"
spec:
  rules:
    - http:
        paths:
          {{- range $name, $config := .Values.services }}
          {{- if $config.isPublic }}
          - path: {{ $config.ingressPath }}
            pathType: Prefix
            backend:
              service:
                name: {{ $name }}-svc
                port:
                  number: 80
          {{- end }}
          {{- end }}
EOF

echo "✅ Helm chart generated successfully!"