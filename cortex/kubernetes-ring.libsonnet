local kausal = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet',
      deployment = kausal.apps.v1.deployment,
      policyRule = kausal.rbac.v1.policyRule,
      role = kausal.rbac.v1.role,
      roleBinding = kausal.rbac.v1.roleBinding,
      serviceAccount = kausal.core.v1.serviceAccount,
      statefulSet = kausal.apps.v1.statefulSet,
      subject = kausal.rbac.v1.subject;

{
  kubernetes_ring_service_account:
    serviceAccount.new($._config.ringServiceAccountName),

  kubernetes_ring_role:
    role.new($._config.ringServiceAccountName)
    + role.withRules([
      policyRule.withApiGroups([''])
      + policyRule.withResources(['configmaps'])
      + policyRule.withVerbs(['create', 'list', 'get', 'patch', 'watch']),
    ]),

  kubernetes_ring_role_binding:
    roleBinding.new()
    + roleBinding.metadata.withName($._config.ringServiceAccountName)
    + roleBinding.roleRef.withApiGroup('rbac.authorization.k8s.io')
    + roleBinding.roleRef.withKind('Role')
    + roleBinding.roleRef.withName($._config.ringServiceAccountName)
    + roleBinding.withSubjects([
      subject.new()
      + subject.withName($._config.ringServiceAccountName)
      + subject.withKind('ServiceAccount'),
    ]),
}
