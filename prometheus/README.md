# prometheus operator for k3s

Based on https://github.com/coreos/kube-prometheus 

With ideas from https://github.com/carlosedp/cluster-monitoring

Basically provide Prometheus' relevant ServiceMonitors with endpoints for kubernetes controller manager
and kubernetes scheduler services.

Requirements:
1. [jsonnet](https://github.com/google/jsonnet)
2. [jsonnet bundler (jb)](https://github.com/jsonnet-bundler/jsonnet-bundler)

Inspect and adapt if needed [prometheus.jsonnet](https://github.com/jeka/k3s-stuff/blob/master/prometheus/prometheus.jsonnet)

Set your default kubernetes cluster context accordingly pointing to the target k3s cluster.

### Installation

* `bash $ jb update`
* `$ ./build`
* `$ kubectl apply -f manifests/setup`
*  Wait few seconds as previous commands creates all the CRDs needed by prometheus-operator
* `$ kubectl apply -f manifests`

You can follow the process with:
` $ kubectl -n monitoring get pods -w` for example


