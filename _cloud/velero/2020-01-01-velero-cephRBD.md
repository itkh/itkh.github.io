---
title: "Velero backup CephRBD"
excerpt: "How to use Velero to backup ceph RBD Persistent Volume"
pagination:
  enabled: true
categories:
  - kubernetes
  - velero
tags:
  - velero
  - cephRBD
  - demo
toc: true
toc_sticky: true
toc_label: "Velero backup CephRBD PV"
sidebar:
  title: "Kubernetes"
  nav: kubernetes
---

Suppose that environment (k8s and velero) is already setup.
[Setup Velero](/kubernetes/velero/velero-setup)
>  Note: If you want to use Restic for backup and restore, velero must be installed with option --use-restic

### Create resources
Create yaml file (ex: velero-cephrbd.yaml) with following...
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: rbd-velero
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: rbd-pvc
  namespace: rbd-velero
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  # This storageClassName must be created before creating PVC
  storageClassName: rook-ceph-block
---
apiVersion: v1
kind: Pod
metadata:
  name: busybox-rbd-velero
  namespace: rbd-velero
  annotations:
    backup.velero.io/backup-volumes: rbd-vol
spec:
  containers:
  - name: busybox
    image: busybox
    command:
    - sleep
    - infinity
    volumeMounts:
      - name: rbd-vol
        mountPath: /mnt/rbd
  volumes:
   - name: rbd-vol
     persistentVolumeClaim:
       claimName: rbd-pvc
       readOnly: false
```
Run kubectl apply to create resources
```bash
kubectl apply -f velero-cephrbd.yaml
```

### Get info
```
root@node2:~# kubectl -n rbd-velero get pod,pvc
NAME                     READY   STATUS    RESTARTS   AGE
pod/busybox-rbd-velero   1/1     Running   0          2m12s

NAME                            STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      AGE
persistentvolumeclaim/rbd-pvc   Bound    pvc-193dd1a4-579c-44d7-a55d-a51e1aad09ff   1Gi        RWO            rook-ceph-block   2m12s
```

### Simulate workload
Writing data to rbd PVC
```shell
kubectl -n rbd-velero exec busybox-rbd-velero -it -- touch /mnt/rbd/hello-rbd-velero
```
Reading data from rbd PVC
```shell
kubectl -n rbd-velero exec busybox-rbd-velero -it -- ls /mnt/rbd
```

### Back up
1. Create annotation for each pod that contains volume you wish to backup:
```shell
kubectl -n rbd-velero annotation pod/busybox-rbd-velero backup.velero.io/backup-volumes=rbd-vol
```

2. Execute backup command:
```shell
velero create backup rbd-backup --include-namespaces=rbd-velero
```

3. Check backup status:
```shell
kubectl -n velero get backups
velero backup get
velero backup describe rbd-backup --details
```

### Perform Delete
Delete rbd-velero namespace
```shell
kubectl delete ns rbd-velero
kubectl get ns
```

### Perform Restore
1. Execute velero restore command:
```shell
velero restore create rbd-backup-restore --from-backup=rbd-backup
```

2. Check restore status:
```shell
kubectl -n velero get restores
velero restore get
velero restore describe rbd-backup-restore
```

### Check result
```shell
kubectl get ns
kubectl -n rbd-velero get pod,pvc
kubectl -n rbd-velero exec busybox-rbd-velero -it -- ls /mnt/rbd
```
