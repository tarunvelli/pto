#!/bin/bash

cat > pto-deployment.yaml <<EOF
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: ${MS_NAME}
spec:
  replicas: 2
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  minReadySeconds: 5
  template:
    metadata:
      labels:
        name: ${MS_NAME}
    spec:
      imagePullSecrets:
        - name: pto-registry-creds
      containers:
        - image: itsprdp/${MS_NAME}:${WERCKER_GIT_COMMIT}
          imagePullPolicy: Always
          name: ${MS_NAME}-webapp
          command: ["service", "nginx", "start"]
          ports:
            - containerPort: 8080
              name: ${MS_NAME}-web-server
              protocol: TCP
        # Change [INSTANCE_CONNECTION_NAME] here to include your GCP
        # project, the region of your Cloud SQL instance and the name
        # of your Cloud SQL instance. The format is
        # PROJECT:REGION:INSTANCE
        # Insert the port number used by your database.
        # [START proxy_container]
        - image: gcr.io/cloudsql-docker/gce-proxy:1.09
          name: cloudsql-proxy
          command:
          - "/cloud_sql_proxy"
          - "--dir=/cloudsql"
          - "-instances=${CSQL_INSTANCE_CONN_NAME}=tcp:3306"
          - "-credential_file=/secrets/cloudsql/credentials.json"

          volumeMounts:
            - name: cloudsql-instance-credentials
              mountPath: /secrets/cloudsql
              readOnly: true
            - name: ssl-certs
              mountPath: /etc/ssl/certs
            - name: cloudsql
              mountPath: /cloudsql
        # [END proxy_container]
      # [START volumes]
      volumes:
        - name: cloudsql-instance-credentials
          secret:
            secretName: cloudsql-instance-credentials
        - name: ssl-certs
          hostPath:
            path: /etc/ssl/certs
        - name: cloudsql
          emptyDir:
      # [END volumes]
EOF
