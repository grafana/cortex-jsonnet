local utils = import 'mixin-utils/utils.libsonnet';

(import 'dashboard-utils.libsonnet') {
  'cortex-compactor-resources.json':
    ($.dashboard('Cortex / Compactor Resources') + { uid: 'df9added6f1f4332f95848cca48ebd99' })
    .addClusterSelectorTemplates()
    .addRow(
      $.row('CPU and Memory')
      .addPanel(
        $.containerCPUUsagePanel('CPU', 'compactor'),
      )
      .addPanel(
        $.containerMemoryWorkingSetPanel('Memory (workingset)', 'compactor'),
      )
      .addPanel(
        $.goHeapInUsePanel('Memory (go heap inuse)', $._config.job_names.compactor),
      )
    )
    .addRow(
      $.row('Network')
      .addPanel(
        $.containerNetworkReceiveBytesPanel($._config.instance_names.compactor),
      )
      .addPanel(
        $.containerNetworkTransmitBytesPanel($._config.instance_names.compactor),
      )
    )
    .addRow(
      $.row('Disk')
      .addPanel(
        $.containerDiskWritesPanel('Disk Writes', 'compactor'),
      )
      .addPanel(
        $.containerDiskReadsPanel('Disk Reads', 'compactor'),
      )
      .addPanel(
        $.containerDiskSpaceUtilization('Disk Space Utilization', 'compactor'),
      )
    ) + {
      templating+: {
        list: [
          // Do not allow to include all clusters/namespaces otherwise this dashboard
          // risks to explode because it shows resources per pod.
          l + (if (l.name == 'cluster' || l.name == 'namespace') then { includeAll: false } else {})
          for l in super.list
        ],
      },
    },
}
