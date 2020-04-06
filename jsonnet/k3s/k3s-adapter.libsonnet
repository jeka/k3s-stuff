local k = import 'ksonnet/ksonnet.beta.4/k.libsonnet';
local service = k.core.v1.service;
local servicePort = k.core.v1.service.mixin.spec.portsType;

{
  _config+:: {
    k3s: {
      master_ips:[],
    },
  },

  prometheus+: {
    kubeControllerManagerPrometheusDiscoveryService:
      service.new('kube-controller-manager-prometheus-discovery', null, servicePort.newNamed('http-metrics', 10252, 10252)) +
      service.mixin.metadata.withNamespace('kube-system') +
      service.mixin.metadata.withLabels({ 'k8s-app': 'kube-controller-manager' }) +
      service.mixin.spec.withClusterIp('None'),

    kubeSchedulerPrometheusDiscoveryService:
      service.new('kube-scheduler-prometheus-discovery', null, servicePort.newNamed('http-metrics', 10251, 10251)) +
      service.mixin.metadata.withNamespace('kube-system') +
      service.mixin.metadata.withLabels({ 'k8s-app': 'kube-scheduler' }) +
      service.mixin.spec.withClusterIp('None'),

    kubeControllerManagerPrometheusDiscoveryEndpoints:
      local endpoints = k.core.v1.endpoints;
      local endpointSubset = endpoints.subsetsType;
      local endpointPort = endpointSubset.portsType;
      local kubeSchedulerPort = endpointPort.new() +
              endpointPort.withName('http-metrics') +
              endpointPort.withPort(10252) +
              endpointPort.withProtocol('TCP');
      local subset = endpointSubset.new() + 
              endpointSubset.withAddresses([
                { ip: k3sMasterIP }
                for k3sMasterIP in $._config.k3s.master_ips
              ]) +
              endpointSubset.withPorts(kubeSchedulerPort);
      endpoints.new() +
      endpoints.mixin.metadata.withName('kube-controller-manager-prometheus-discovery') +
      endpoints.mixin.metadata.withNamespace('kube-system') +
      endpoints.mixin.metadata.withLabels({ 'k8s-app': 'kube-controller-manager' }) +
      endpoints.withSubsets(subset),

    kubeSchedulerPrometheusDiscoveryEndpoints:
      local endpoints = k.core.v1.endpoints;
      local endpointSubset = endpoints.subsetsType;
      local endpointPort = endpointSubset.portsType;
      local kubeSchedulerPort = endpointPort.new() +
              endpointPort.withName('http-metrics') +
              endpointPort.withPort(10251) +
              endpointPort.withProtocol('TCP');
      local subset = endpointSubset.new() + 
              endpointSubset.withAddresses([
                { ip: k3sMasterIP }
                for k3sMasterIP in $._config.k3s.master_ips
              ]) +
              endpointSubset.withPorts(kubeSchedulerPort);
      endpoints.new() +
      endpoints.mixin.metadata.withName('kube-scheduler-prometheus-discovery') +
      endpoints.mixin.metadata.withNamespace('kube-system') +
      endpoints.mixin.metadata.withLabels({ 'k8s-app': 'kube-scheduler' }) +
      endpoints.withSubsets(subset),
  }
}