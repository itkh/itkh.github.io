---
title: "Velero with minio"
excerpt: "Set up velero with minio"
pagination:
  enabled: true
categories:
  - kubernetes
  - velero
tags:
  - velero
  - minio
  - demo
toc: true
toc_sticky: true
toc_label: "Setup Velero"
sidebar:
  title: "Kubernetes"
  nav: kubernetes
---

## Velero
> Velero is an open source tool to safely backup and restore, perform disaster recovery, and migrate Kubernetes cluster resources and persistent volumes. ([Read more](https://velero.io/){:target="\_blank"})

## Minio
>  MinIO is High Performance Object Storage released under Apache License v2.0. It is API compatible with Amazon S3 cloud storage service. Using MinIO build high performance infrastructure for machine learning, analytics and application data workloads. ([Read more](https://min.io/){:target="\_blank"})

## Installation

### Run Minio docker container
```shell
docker pull minio/minio
docker run -d -p 9000:9000 --rm --name minio -e "MINIO_ACCESS_KEY=nokor-it" -e "MINIO_SECRET_KEY=12341234" -v /mnt/data:/data minio/minio server /data
```

### Create bucket
Open browser 'localhost:9000' -> Create one bucket (ex: kubevelero)
[![minio-login](/assets/images/velero/minio_login.png)](/assets/images/velero/minio_login.png)
[![minio-bucket](/assets/images/velero/minio_bucket.png)](/assets/images/velero/minio_bucket.png)

### Download and install velero (v1.2.0 Release)
```shell
wget https://github.com/vmware-tanzu/velero/releases/download/v1.2.0/velero-v1.2.0-linux-amd64.tar.gz
tar zxf velero-v1.2.0-linux-amd64.tar.gz
mv velero*/velero /usr/local/bin
```

Enable tab completion bash
```shell
source <(velero completion bash)
```

### Create credential file
```shell
cat <<EOF>> minio.credentials
[default]
aws_access_key_id=nokor-it
aws_secret_access_key=12341234
EOF
```
### Install Velero into the Kubernetes Cluster
```shell
velero install \
   --provider aws \
   --bucket kubevelero \
   --secret-file ./minio.credentials \
   --use-volume-snapshots false \
   --backup-location-config region=minio,s3ForcePathStyle=true,s3Url=http://localhost:9000 \
   --plugins velero/velero-plugin-for-aws:v1.0.0 \
   --use-restic

# This will some resources in kubernetes cluster:
# - Namespace/velero: created
# - ClusterRoleBinding/velero: created
# - ServiceAccount/velero: created
# - Secret/cloud-credentials: created
# - BackupStorageLocation/default: created
# - VolumeSnapshotLocation/default: created
# - Deployment/velero: created

# Uninstall velero
kubectl delete namespace/velero clusterrolebinding/velero
kubectl delete crds -l component=velero
```

## Testing
### Velero resources
Check velero deployment/pod and waiting until it's running
```shell
kubectl -n velero get all
```
[![velero-install](/assets/images/velero/velero_install.png)](/assets/images/velero/velero_install.png)

### Create testing resources
Create testing namespace and nginx deployment
```shell
kubectl create ns testing
kubectl get ns
kubectl -n testing run nginx --image nginx --replicas 2
kubectl -n testing get all
```

### Perform Backup
Backup testing namespace with velero tool
```shell
velero backup create testing-backup --include-namespaces testing

# Check result
kubectl -n velero get backups
velero backup get
velero backup describe testing-backup
```
[![minio-backup](/assets/images/velero/minio_backup.png)](/assets/images/velero/minio_backup.png)

### Perform Delete
Delete testing namespace
```shell
kubectl delete ns testing
kubectl get ns
```

### Perform Restore
Restore testing namespace with velero tool
```shell
velero restore create testing-backup-restore --from-backup testing-backup

# Check restore result
kubectl -n velero get restores
velero restore get
velero restore describe testing-backup-restore
```
[![minio-restore](/assets/images/velero/minio_restore.png)](/assets/images/velero/minio_restore.png)

### Check result
Get deleted namespace after restore
```shell
kubectl get ns
kubectl -n testing get all
```

### Perform Schedule backup
Set schedule for backup
```shell
velero schedule get
velero schedule create testing-backup-schedule --schedule="@every 1m" --include-namespaces testing

# Check result
kubectl -n velero get schedules
velero schedule get
velero backup get
```
[![minio-schedule](/assets/images/velero/minio_schedule.png)](/assets/images/velero/minio_schedule.png)

### Delete Velero resources
Delete schedule, backup and restore
```shell
velero schedule delete testing-backup-schedule
velero backup delete --all
velero restore delete --all
```

## Velero Help
### backup and restore command lines
```shell
# using '$ velero backup[restore] --help' for more details

# Backup entire cluster
velero backup create NAME

# Backup entire cluster excluding namespaces
velero backup create NAME --exclude-namespaces testing

# Backup entire cluster excluding resources
velero backup create NAME --exclude-resources configmaps

# Backup entire cluster only some resources
velero backup create NAME --include-resources pods,deployments

# Backup entire namespaces
velero backup create NAME --include-namespaces testing

# Backup entire namespaces only some resources
velero backup create NAME --include-namespaces testing --include-resources pods,deployments

# Backup entire namespaces excluding some resources
velero backup create NAME --include-namespaces testing --exclude-resources pods,deployments

# restore same as backup
```
### schedule command lines
```shell
# using '$ velero schedule --help' for more details

velero schedule create NAME --schedule="* * * * *"
# */Minute */Hour */Day of Month */Month */Day of Week

# Create a backup every 6 hours
velero schedule create NAME --schedule="0 */6 * * *"

# Create a backup every 6 hours with the @every notation
velero create schedule NAME --schedule="@every 6h"
velero create schedule NAME --schedule="@every 1w"

# Create a daily backup of the web namespace
velero create schedule NAME --schedule="@every 24h" --include-namespaces web

# Create a weekly backup, each living for 90 days (2160 hours)
velero create schedule NAME --schedule="@every 168h" --ttl 2160h0m0s
```
