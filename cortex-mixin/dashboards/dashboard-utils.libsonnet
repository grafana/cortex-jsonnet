local utils = import 'mixin-utils/utils.libsonnet';

(import 'grafana-builder/grafana.libsonnet') {

  _config:: error 'must provide _config',

  // Override the dashboard constructor to add:
  // - default tags,
  // - some links that propagate the selectred cluster.
  dashboard(title)::
    super.dashboard(title) + {
      addRowIf(condition, row)::
        if condition
        then self.addRow(row)
        else self,

      addClusterSelectorTemplates(multi=true)::
        local d = self {
          tags: $._config.tags,
          links: [
            {
              asDropdown: true,
              icon: 'external link',
              includeVars: true,
              keepTime: true,
              tags: $._config.tags,
              targetBlank: false,
              title: 'Cortex Dashboards',
              type: 'dashboards',
            },
          ],
        };

        if multi then
          if $._config.singleBinary
          then d.addMultiTemplate('job', 'cortex_build_info', 'job')
          else d
               .addMultiTemplate('cluster', 'cortex_build_info', 'cluster')
               .addMultiTemplate('namespace', 'cortex_build_info{cluster=~"$cluster"}', 'namespace')
        else
          if $._config.singleBinary
          then d.addTemplate('job', 'cortex_build_info', 'job')
          else d
               .addTemplate('cluster', 'cortex_build_info', 'cluster')
               .addTemplate('namespace', 'cortex_build_info{cluster=~"$cluster"}', 'namespace'),

    },

  // The mixin allow specialism of the job selector depending on if its a single binary
  // deployment or a namespaced one.
  jobMatcher(job)::
    if $._config.singleBinary
    then 'job=~"$job"'
    else 'cluster=~"$cluster", job=~"($namespace)/%s"' % job,

  namespaceMatcher()::
    if $._config.singleBinary
    then 'job=~"$job"'
    else 'cluster=~"$cluster", namespace=~"$namespace"',

  jobSelector(job)::
    if $._config.singleBinary
    then [utils.selector.noop('cluster'), utils.selector.re('job', '$job')]
    else [utils.selector.re('cluster', '$cluster'), utils.selector.re('job', '($namespace)/%s' % job)],

  queryPanel(queries, legends, legendLink=null)::
    super.queryPanel(queries, legends, legendLink) + {
      targets: [
        target {
          interval: '1m',
        }
        for target in super.targets
      ],
    },

  // hiddenLegendQueryPanel is a standard query panel designed to handle a large number of series.  it hides the legend, doesn't fill the series and
  //  sorts the tooltip descending
  hiddenLegendQueryPanel(queries, legends, legendLink=null)::
    $.queryPanel(queries, legends, legendLink) +
    {
      legend: { show: false },
      fill: 0,
      tooltip: { sort: 2 },
    },

  qpsPanel(selector)::
    super.qpsPanel(selector) + {
      targets: [
        target {
          interval: '1m',
        }
        for target in super.targets
      ],
    },

  latencyPanel(metricName, selector, multiplier='1e3')::
    super.latencyPanel(metricName, selector, multiplier) + {
      targets: [
        target {
          interval: '1m',
        }
        for target in super.targets
      ],
    },

  successFailurePanel(title, successMetric, failureMetric)::
    $.panel(title) +
    $.queryPanel([successMetric, failureMetric], ['successful', 'failed']) +
    $.stack + {
      aliasColors: {
        successful: '#7EB26D',
        failed: '#E24D42',
      },
    },

  // Displays started, completed and failed rate.
  startedCompletedFailedPanel(title, startedMetric, completedMetric, failedMetric)::
    $.panel(title) +
    $.queryPanel([startedMetric, completedMetric, failedMetric], ['started', 'completed', 'failed']) +
    $.stack + {
      aliasColors: {
        started: '#34CCEB',
        completed: '#7EB26D',
        failed: '#E24D42',
      },
    },

  containerCPUUsagePanel(title, containerName)::
    $.panel(title) +
    $.queryPanel([
      'sum by(pod) (rate(container_cpu_usage_seconds_total{%s,container="%s"}[$__rate_interval]))' % [$.namespaceMatcher(), containerName],
      'min(container_spec_cpu_quota{%s,container="%s"} / container_spec_cpu_period{%s,container="%s"})' % [$.namespaceMatcher(), containerName, $.namespaceMatcher(), containerName],
    ], ['{{pod}}', 'limit']) +
    {
      seriesOverrides: [
        {
          alias: 'limit',
          color: '#E02F44',
          fill: 0,
        },
      ],
      tooltip: { sort: 2 },  // Sort descending.
    },

  containerMemoryWorkingSetPanel(title, containerName)::
    $.panel(title) +
    $.queryPanel([
      // We use "max" instead of "sum" otherwise during a rolling update of a statefulset we will end up
      // summing the memory of the old pod (whose metric will be stale for 5m) to the new pod.
      'max by(pod) (container_memory_working_set_bytes{%s,container="%s"})' % [$.namespaceMatcher(), containerName],
      'min(container_spec_memory_limit_bytes{%s,container="%s"} > 0)' % [$.namespaceMatcher(), containerName],
    ], ['{{pod}}', 'limit']) +
    {
      seriesOverrides: [
        {
          alias: 'limit',
          color: '#E02F44',
          fill: 0,
        },
      ],
      yaxes: $.yaxes('bytes'),
      tooltip: { sort: 2 },  // Sort descending.
    },

  goHeapInUsePanel(title, jobName)::
    $.panel(title) +
    $.queryPanel(
      'sum by(%s) (go_memstats_heap_inuse_bytes{%s})' % [$._config.per_instance_label, $.jobMatcher(jobName)],
      '{{%s}}' % $._config.per_instance_label
    ) +
    {
      yaxes: $.yaxes('bytes'),
      tooltip: { sort: 2 },  // Sort descending.
    },

  newStatPanel(queries, legends='', unit='percentunit', decimals=1, thresholds=[], instant=false, novalue='')::
    super.queryPanel(queries, legends) + {
      type: 'stat',
      targets: [
        target {
          instant: instant,
          interval: '',

          // Reset defaults from queryPanel().
          format: null,
          intervalFactor: null,
          step: null,
        }
        for target in super.targets
      ],
      fieldConfig: {
        defaults: {
          color: { mode: 'thresholds' },
          decimals: decimals,
          thresholds: {
            mode: 'absolute',
            steps: thresholds,
          },
          noValue: novalue,
          unit: unit,
        },
        overrides: [],
      },
    },

  barGauge(queries, legends='', thresholds=[], unit='short', min=null, max=null)::
    super.queryPanel(queries, legends) + {
      type: 'bargauge',
      targets: [
        target {
          // Reset defaults from queryPanel().
          format: null,
          intervalFactor: null,
          step: null,
        }
        for target in super.targets
      ],
      fieldConfig: {
        defaults: {
          color: { mode: 'thresholds' },
          mappings: [],
          max: max,
          min: min,
          thresholds: {
            mode: 'absolute',
            steps: thresholds,
          },
          unit: unit,
        },
      },
      options: {
        displayMode: 'basic',
        orientation: 'horizontal',
        reduceOptions: {
          calcs: ['lastNotNull'],
          fields: '',
          values: false,
        },
      },
    },

  // Switches a panel from lines (default) to bars.
  bars:: {
    bars: true,
    lines: false,
  },

  textPanel(title, content, options={}):: {
    content: content,
    datasource: null,
    description: '',
    mode: 'markdown',
    title: title,
    transparent: true,
    type: 'text',
  } + options,

  objectStorePanels1(title, component)::
    super.row(title)
    .addPanel(
      $.panel('Operations / sec') +
      $.queryPanel('sum by(operation) (rate(thanos_objstore_bucket_operations_total{%s,component="%s"}[$__rate_interval]))' % [$.namespaceMatcher(), component], '{{operation}}') +
      $.stack +
      { yaxes: $.yaxes('rps') },
    )
    .addPanel(
      $.panel('Error rate') +
      $.queryPanel('sum by(operation) (rate(thanos_objstore_bucket_operation_failures_total{%s,component="%s"}[$__rate_interval])) / sum by(operation) (rate(thanos_objstore_bucket_operations_total{%s,component="%s"}[$__rate_interval]))' % [$.namespaceMatcher(), component, $.namespaceMatcher(), component], '{{operation}}') +
      { yaxes: $.yaxes('percentunit') },
    )
    .addPanel(
      $.panel('Op: Attributes') +
      $.latencyPanel('thanos_objstore_bucket_operation_duration_seconds', '{%s,component="%s",operation="attributes"}' % [$.namespaceMatcher(), component]),
    )
    .addPanel(
      $.panel('Op: Exists') +
      $.latencyPanel('thanos_objstore_bucket_operation_duration_seconds', '{%s,component="%s",operation="exists"}' % [$.namespaceMatcher(), component]),
    ),

  // Second row of Object Store stats
  objectStorePanels2(title, component)::
    super.row(title)
    .addPanel(
      $.panel('Op: Get') +
      $.latencyPanel('thanos_objstore_bucket_operation_duration_seconds', '{%s,component="%s",operation="get"}' % [$.namespaceMatcher(), component]),
    )
    .addPanel(
      $.panel('Op: GetRange') +
      $.latencyPanel('thanos_objstore_bucket_operation_duration_seconds', '{%s,component="%s",operation="get_range"}' % [$.namespaceMatcher(), component]),
    )
    .addPanel(
      $.panel('Op: Upload') +
      $.latencyPanel('thanos_objstore_bucket_operation_duration_seconds', '{%s,component="%s",operation="upload"}' % [$.namespaceMatcher(), component]),
    )
    .addPanel(
      $.panel('Op: Delete') +
      $.latencyPanel('thanos_objstore_bucket_operation_duration_seconds', '{%s,component="%s",operation="delete"}' % [$.namespaceMatcher(), component]),
    ),

  thanosMemcachedCache(title, jobName, component, cacheName)::
    super.row(title)
    .addPanel(
      $.panel('QPS') +
      $.queryPanel('sum by(operation) (rate(thanos_memcached_operations_total{%s,component="%s",name="%s"}[$__rate_interval]))' % [$.jobMatcher(jobName), component, cacheName], '{{operation}}') +
      $.stack +
      { yaxes: $.yaxes('ops') },
    )
    .addPanel(
      $.panel('Latency (getmulti)') +
      $.latencyPanel('thanos_memcached_operation_duration_seconds', '{%s,operation="getmulti",component="%s",name="%s"}' % [$.jobMatcher(jobName), component, cacheName])
    )
    .addPanel(
      $.panel('Hit ratio') +
      $.queryPanel('sum(rate(thanos_cache_memcached_hits_total{%s,component="%s",name="%s"}[$__rate_interval])) / sum(rate(thanos_cache_memcached_requests_total{%s,component="%s",name="%s"}[$__rate_interval]))' %
                   [
                     $.jobMatcher(jobName),
                     component,
                     cacheName,
                     $.jobMatcher(jobName),
                     component,
                     cacheName,
                   ], 'items') +
      { yaxes: $.yaxes('percentunit') },
    ),

  filterNodeDiskContainer(containerName)::
    |||
      ignoring(%s) group_right() (label_replace(count by(%s, %s, device) (container_fs_writes_bytes_total{%s,container="%s",device!~".*sda.*"}), "device", "$1", "device", "/dev/(.*)") * 0)
    ||| % [$._config.per_instance_label, $._config.per_node_label, $._config.per_instance_label, $.namespaceMatcher(), containerName],
}
