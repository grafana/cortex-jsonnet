local utils = import 'mixin-utils/utils.libsonnet';

(import 'dashboard-utils.libsonnet') {
  'cortex-reads-resources.json':
    ($.dashboard('Cortex / Reads Resources') + { uid: '2fd2cda9eea8d8af9fbc0a5960425120' })
    .addClusterSelectorTemplates(false)
    .addRowIf(
      $._config.cortex_gw_enabled,
      $.row('Gateway')
      .addPanel(
        $.containerCPUUsagePanel('CPU', $._config.job_names.gateway),
      )
      .addPanel(
        $.containerMemoryWorkingSetPanel('Memory (workingset)', $._config.job_names.gateway),
      )
      .addPanel(
        $.goHeapInUsePanel('Memory (go heap inuse)', $._config.job_names.gateway),
      )
    )
    .addRow(
      $.row('Query Frontend')
      .addPanel(
        $.containerCPUUsagePanel('CPU', 'query-frontend'),
      )
      .addPanel(
        $.containerMemoryWorkingSetPanel('Memory (workingset)', 'query-frontend'),
      )
      .addPanel(
        $.goHeapInUsePanel('Memory (go heap inuse)', $._config.job_names.query_frontend),
      )
    )
    .addRowIf(
      $._config.query_scheduler_enabled,
      $.row('Query Scheduler')
      .addPanel(
        $.containerCPUUsagePanel('CPU', 'query-scheduler'),
      )
      .addPanel(
        $.containerMemoryWorkingSetPanel('Memory (workingset)', 'query-scheduler'),
      )
      .addPanel(
        $.goHeapInUsePanel('Memory (go heap inuse)', $._config.job_names.query_scheduler),
      )
    )
    .addRow(
      $.row('Querier')
      .addPanel(
        $.containerCPUUsagePanel('CPU', 'querier'),
      )
      .addPanel(
        $.containerMemoryWorkingSetPanel('Memory (workingset)', 'querier'),
      )
      .addPanel(
        $.goHeapInUsePanel('Memory (go heap inuse)', $._config.job_names.querier),
      )
    )
    .addRow(
      $.row('Ingester')
      .addPanel(
        $.containerCPUUsagePanel('CPU', 'ingester'),
      )
      .addPanel(
        $.containerMemoryWorkingSetPanel('Memory (workingset)', 'ingester'),
      )
      .addPanel(
        $.goHeapInUsePanel('Memory (go heap inuse)', $._config.job_names.ingester),
      )
    )
    .addRowIf(
      $._config.ruler_enabled,
      $.row('Ruler')
      .addPanel(
        $.panel('Rules') +
        $.queryPanel(
          'sum by(%s) (cortex_prometheus_rule_group_rules{%s})' % [$._config.per_instance_label, $.jobMatcher($._config.job_names.ruler)],
          '{{%s}}' % $._config.per_instance_label
        ),
      )
      .addPanel(
        $.containerCPUUsagePanel('CPU', 'ruler'),
      )
    )
    .addRowIf(
      $._config.ruler_enabled,
      $.row('')
      .addPanel(
        $.containerMemoryWorkingSetPanel('Memory (workingset)', 'ruler'),
      )
      .addPanel(
        $.goHeapInUsePanel('Memory (go heap inuse)', $._config.job_names.ruler),
      )
    )
    .addRowIf(
      std.member($._config.storage_engine, 'blocks'),
      $.row('Store-gateway')
      .addPanel(
        $.containerCPUUsagePanel('CPU', 'store-gateway'),
      )
      .addPanel(
        $.containerMemoryWorkingSetPanel('Memory (workingset)', 'store-gateway'),
      )
      .addPanel(
        $.goHeapInUsePanel('Memory (go heap inuse)', $._config.job_names.store_gateway),
      )
    )
    .addRowIf(
      std.member($._config.storage_engine, 'blocks'),
      $.row('')
      .addPanel(
        $.containerDiskWritesPanel('Disk Writes', 'store-gateway'),
      )
      .addPanel(
        $.containerDiskReadsPanel('Disk Reads', 'store-gateway'),
      )
      .addPanel(
        $.containerDiskSpaceUtilization('Disk Space Utilization', $._config.instance_names.store_gateway),
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
