<<<<<<< HEAD
=======
# Jarvis Data Engineering Training
>>>>>>> 06b0040 (Fix up readme for linx_sql and added Architecture image)
# Linux System Monitoring Agent

## Introduction

The Linux System Monitoring Agent is a resource monitoring solution designed for Linux cluster environments. The system collects and stores both static hardware specifications and real-time resource usage data from multiple Linux hosts into a centralized PostgreSQL database. This enables infrastructure and operations teams to track resource consumption trends across a cluster, identify performance bottlenecks, and make informed decisions around capacity planning and resource allocation.

The primary users of this system are system administrators and DevOps/data engineers responsible for managing and maintaining Linux server infrastructure. The project is built entirely using Bash scripting for data collection, PostgreSQL for persistent storage, Docker for containerizing the database instance, and Git for version control and collaboration. Automation is handled through Linux's native crontab scheduler, which triggers usage data collection at regular intervals without manual intervention.

---

## Quick Start

**1. Start a PostgreSQL instance using psql_docker.sh**
```bash
./scripts/psql_docker.sh start
```

**2. Create the required tables using ddl.sql**
```bash
psql -h localhost -U postgres -d host_agent -f sql/ddl.sql
```

**3. Register the host's hardware specifications**
```bash
bash scripts/host_info.sh localhost 5432 host_agent postgres password
```

**4. Capture and insert current resource usage**
```bash
bash scripts/host_usage.sh localhost 5432 host_agent postgres password
```

**5. Automate usage collection every minute via crontab**
```bash
crontab -e
# Add the following line:
* * * * * bash /home/rocky/jarvis_data_eng_JeffreyDarlington/linux_sql/scripts/host_usage.sh localhost 5432 host_agent postgres password
```

---

## Implementation

### Architecture

The system follows a lightweight agent-based monitoring architecture. Each Linux host in the cluster runs the monitoring scripts locally. The `host_info.sh` script runs once on initial setup to register hardware specs, while `host_usage.sh` is scheduled via crontab to run every minute. All data flows into a single PostgreSQL instance running inside a Docker container on the monitoring host.

```
<<<<<<< HEAD
[ Linux Host 1 ] --\
[ Linux Host 2 ] ---+--> [ PostgreSQL DB (Docker) ] <-- [ Queries / Analysis ]
[ Linux Host 3 ] --/
=======
![image](/home/rocky/dev/jarvis_data_eng_JeffreyDarlington/linux_sql/assets/cluster_diagram.jpg)
>>>>>>> 06b0040 (Fix up readme for linx_sql and added Architecture image)
```

> Architecture diagram saved to `assets/cluster_diagram.png`

---

### Scripts

**psql_docker.sh** — Manages the lifecycle of the PostgreSQL Docker container. Accepts `start`, `stop`, or `create` as arguments.
```bash
./scripts/psql_docker.sh start
./scripts/psql_docker.sh stop
./scripts/psql_docker.sh create db_username db_password
```

**host_info.sh** — Collects static hardware specifications from the host machine (CPU, memory, architecture) and inserts them into the `host_info` table. Run once per host.
```bash
bash scripts/host_info.sh psql_host psql_port db_name psql_user psql_password
# Example:
bash scripts/host_info.sh localhost 5432 host_agent postgres password
```

**host_usage.sh** — Captures a real-time snapshot of system resource usage (free memory, CPU idle/kernel percentages, disk I/O, available disk space) and inserts it into the `host_usage` table. Designed to run every minute via crontab.
```bash
bash scripts/host_usage.sh psql_host psql_port db_name psql_user psql_password
# Example:
bash scripts/host_usage.sh localhost 5432 host_agent postgres password
```

**crontab** — Schedules `host_usage.sh` to execute automatically every minute.
```bash
* * * * * bash /full/path/to/scripts/host_usage.sh localhost 5432 host_agent postgres password
```

**queries.sql** — Contains analytical SQL queries that address key business questions around infrastructure health and capacity planning. The queries help answer: Which hosts are consistently running low on memory? Are any hosts experiencing unusually high CPU kernel usage that could indicate system-level performance issues? What is the average resource consumption per host over a given time window? These insights allow operations teams to proactively manage infrastructure before failures occur.

---

### Database Modeling

**`host_info`** — Stores static hardware specifications for each registered host. Populated once per machine.

| Column | Data Type | Constraints | Description |
|---|---|---|---|
| id | SERIAL | PRIMARY KEY | Auto-incremented unique identifier |
| hostname | VARCHAR | NOT NULL, UNIQUE | Fully qualified domain name of the host |
| cpu_number | INT2 | NOT NULL | Number of logical CPUs |
| cpu_architecture | VARCHAR | NOT NULL | CPU architecture (e.g. x86_64) |
| cpu_model | VARCHAR | NOT NULL | CPU model name |
| cpu_mhz | FLOAT8 | NOT NULL | CPU clock speed in MHz |
| l2_cache | INT4 | NOT NULL | L2 cache size in KB |
| timestamp | TIMESTAMP | NOT NULL | Time the hardware info was recorded |
| total_mem | INT4 | NOT NULL | Total memory in MB |

**`host_usage`** — Stores time-series resource usage snapshots. Populated every minute via crontab.

| Column | Data Type | Constraints | Description |
|---|---|---|---|
| timestamp | TIMESTAMP | NOT NULL | Time the usage snapshot was recorded |
| host_id | SERIAL | REFERENCES host_info(id) | Foreign key linking to the registered host |
| memory_free | INT4 | NOT NULL | Free memory available in MB |
| cpu_idle | INT2 | NOT NULL | Percentage of CPU time idle |
| cpu_kernel | INT2 | NOT NULL | Percentage of CPU time in kernel mode |
| disk_io | INT4 | NOT NULL | Number of disk I/O operations |
| disk_available | INT4 | NOT NULL | Available disk space on root partition in MB |

---

## Test

Each script was tested manually by executing it directly from the terminal with real argument values and verifying the output against the database.

For `ddl.sql`, the script was executed using `psql -f` and the resulting tables were confirmed using the `\dt` command inside the psql shell. Both `host_info` and `host_usage` tables appeared as expected with the correct schema.

For `host_info.sh`, the script was run with valid connection arguments and the inserted row was verified by querying `SELECT * FROM host_info`. The hostname, CPU specs, and memory values matched the actual machine's hardware as confirmed by `lscpu` and `vmstat`.

For `host_usage.sh`, the script was executed and the resulting `INSERT 0 1` output confirmed a successful insert. The row was verified by querying `SELECT * FROM host_usage`, with timestamp, host_id, and all resource metrics populated correctly.

---

## Deployment

The application is deployed across three components. The PostgreSQL database runs inside a Docker container (`jrvs-psql`) on the GCP virtual machine, providing an isolated and reproducible database environment. The monitoring scripts (`host_info.sh` and `host_usage.sh`) are stored and version-controlled on GitHub under the `linux_sql` project directory, making them accessible and auditable. Resource usage collection is automated through Linux crontab, which schedules `host_usage.sh` to execute every minute without any manual intervention, ensuring continuous data collection.

---

## Improvements

- **Handle hardware updates automatically** — Currently `host_info.sh` fails with a duplicate key error if run more than once on the same host. An `INSERT ... ON CONFLICT DO UPDATE` statement would allow the script to update specs when hardware changes rather than failing silently.

- **Add alerting for critical resource thresholds** — The system currently only stores data without any notification mechanism. Adding a threshold-based alert (e.g. flag when free memory drops below 10% or CPU idle drops below 5%) would make the system proactive rather than purely observational.

- **Extend monitoring to network and process-level metrics** — The current implementation only tracks CPU, memory, and disk. Adding network throughput (`ifstat`) and top process monitoring (`ps aux`) would give a more complete picture of host health and make the system more useful for real incident diagnosis.

2. [Core Java Apps](./core_java) In-progress
3. [Python Data Analytics](./python_data_analytics) In-progress
4. [Spring Boot Trading REST API](./springboot) In-progress
5. [Javascript Front End](./javascript) In-progress
6. [Cloud/DevOps](./cloud_devops) In-progress
