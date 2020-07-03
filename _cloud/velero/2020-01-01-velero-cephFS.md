---
title: "Velero backup CephFS"
excerpt: "How to use Velero to backup ceph file system Persistent Volume"
pagination:
  enabled: true
categories:
  - kubernetes
  - velero
tags:
  - velero
  - cephfs
  - demo
toc: true
toc_sticky: true
toc_label: "Velero backup CephFS PV"
sidebar:
  title: "Kubernetes"
  nav: kubernetes
---

Suppose that environment (k8s and velero) is already setup.
[Setup Velero](/kubernetes/velero/velero-setup)
>  Note: If you want to use Restic for backup and restore, velero must be installed with option --use-restic

### Create resources
Create yaml file (ex: velero-cephfs.yaml) with following...
 ```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ceph-velero
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: ceph-velero
  name: cephfs-pvc
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 100Mi
  # `csi-cephfs` storageClass must be created before creating PVC
  storageClassName: csi-cephfs
---
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: ceph-velero
  name: cephfs-nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: cephfs-nginx
  template:
    metadata:
      labels:
        app: cephfs-nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        volumeMounts:
        - name: cephfs
          mountPath: /mnt/cephfs
      volumes:
      - name: cephfs
        persistentVolumeClaim:
          claimName: cephfs-pvc
          readOnly: false
```

```shell
kubectl apply -f velero-cephfs.yaml
```

### Get info
```
root@node2:~# kubectl -n ceph-velero get all
NAME                               READY   STATUS    RESTARTS   AGE
pod/cephfs-nginx-b5865db74-4jttg   1/1     Running   0          3m
pod/cephfs-nginx-b5865db74-php67   1/1     Running   0          3m
```

### Simulate workload
Perform write/read on CephFS volume mountPath (/mnt/cephfs/)
```shell
kubectl -n ceph-velero exec cephfs-nginx-b5865db74-4jttg -it -- touch /mnt/cephfs/backup
kubectl -n ceph-velero exec cephfs-nginx-b5865db74-php67 -it -- ls /mnt/cephfs
```

### Perform Backup
1. Create annotation for each pod that contains volume you wish to backup:
```shell
kubectl -n ceph-velero annotate pod/cephfs-nginx-b5865db74-4jttg backup.velero.io/backup-volumes=cephfs
kubectl -n ceph-velero annotate pod/cephfs-nginx-b5865db74-php67 backup.velero.io/backup-volumes=cephfs
```

2. Execute velero backup command:
```shell
velero backup create my-backup --include-namespaces=ceph-velero
```

3. Check backup status:
```shell
kubectl -n velero get backups
velero backup get
velero backup describe my-backup --details
kubectl -n velero get podvolumebackups.velero.io -l velero.io/backup-name=my-backup -oyaml
```

### Perform Delete
Delete namespace that is already backed up
```shell
kubectl delete ns ceph-velero
kubectl get ns
```

### Perform Restore
1. Execute velero restore command:
```shell
velero restore create my-backup-restore --from-backup=my-backup
```

2. Check restore status:
```shell
kubectl -n velero get restores
velero restore get
velero restore describe my-backup-restore
kubectl -n velero get podvolumerestores -l velero.io/restore-name=my-backup-restore -o yaml
```

### Check restult
```shell
kubectl get ns
kubectl -n ceph-velero get all
kubectl -n ceph-velero exec cephfs-nginx-b5865db74-php67 -it -- ls /mnt/cephfs
```
