# **Day 10 of Azure Infrastructure Bootcamp**

### 1. Configure VM Insights

### 2. Kusto Queries

* Free MB Space

```Kusto
Perf
| where ObjectName == "LogicalDisk" and CounterName == "Free Megabytes" and InstanceName contains ":" and InstanceName !contains "Users"
| summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer, InstanceName
```

* Available MB Memory

```Kusto
Perf
| where ObjectName == "Memory" and CounterName == "Available MBytes"
| summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer
```

* Percent CPU

```Kusto
Perf  
| where ObjectName == "Processor" and CounterName == "% Processor Time"
| summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer
```

* Windows Firewall Service Stopped

```Kusto
Event
| where RenderedDescription contains "The Windows Firewall service entered the stopped state"
| summarize Occurence = dcount(RenderedDescription) by RenderedDescription, TimeGenerated, Computer
```

* Server restart Query

```Kusto
Event
| where Computer contains "<computername>"
| where EventID == 1074
```

### 3. Log Based alert rule

### 4. Take Free MB Space query and create an alert for value based on query's returned value that will trigger alert

### 5. Create Action Group to send email for triggered alert

### 6. Create Action Rule to Suppress alert during a specified time period

### 7. Create a Metric Based alert

### 8. Create Service Health Alert

### 9. Create simple workbook based on Kusto Queries

### 10. Create Network Connection Monitor

### 11. Explore Network Watcher Tools

### 12. Build a Dashboard
