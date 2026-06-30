# DeepTrace evaluation log

Detailed record of the DeepTrace integration attempt. For the overall PoC
context — including why DeepTrace was chosen after DeepFlow could not be
deployed — see [project-summary.md](project-summary.md).

## Outcome

DeepTrace was **not integrated**. No distributed traces were collected despite
deploying the server, installing the agent, generating workload traffic, and
attempting span correlation and trace assembly.

The primary blocker was a persistent gap between the
[DeepTrace documentation](https://deepshield-ai.github.io/DeepTrace/introduction.html)
and the actual implementation. The tooling appeared unfinished and required
local patches to upstream code.

## Legend

Throughout this log:

- **Documented step** — action taken directly from official documentation
- **Issue** — problem encountered during the step
- **Resolution** — attempted fix (successful or not)
- **Unresolved** — blocker that prevented collecting usable traces

The screenshots below are evidence from a manual integration attempt. They
document what was observed during troubleshooting; they are not an automated,
repeatable test transcript.

## Attempt timeline

1. Deploy DeepTrace server.
2. Deploy SocialNetwork workload.
3. Install and run DeepTrace agent.
4. Generate traffic with wrk2.
5. Attempt span correlation and trace assembly.
6. Stop after unresolved trace collection failures.

## 1. Deploying DeepTrace server

**Documented step:** Clone the DeepTrace GitHub repository.

<img src="pictures/screenshot-2026-06-27-235916.png" alt="Cloning the DeepTrace repository" width="900" />

**Documented step:** Fill in `server/config/config.toml`.

<img src="pictures/screenshot-2026-06-27-235946.png" alt="Editing server configuration" width="900" />

**Documented step:** Deploy the server with `scripts/deploy_server.sh` and
confirm it is running.

<img src="pictures/screenshot-2026-06-27-235940.png" alt="Server deployment confirmed" width="900" />

## 2. Deploying SocialNetwork application

**Documented step:** Use the `deploy.sh` script in
`tests/workload/socialnetwork` to deploy the application.

<img src="pictures/screenshot-2026-06-28-000044.png" alt="SocialNetwork deployment via DeepTrace test scripts" width="900" />
<img src="pictures/screenshot-2026-06-28-000106.png" alt="Application health check" width="900" />

**Issue:** The built-in data injection script referenced in the documentation
was not found.

<img src="pictures/screenshot-2026-06-28-000507.png" alt="Missing data injection script" width="900" />

**Resolution (successful):** Deploy SocialNetwork from the DeathStarBench
submodule instead.

<img src="pictures/screenshot-2026-06-28-000937.png" alt="DeathStarBench docker compose up" width="900" />
<img src="pictures/screenshot-2026-06-28-000957.png" alt="Running containers" width="900" />

**Documented step:** Inject data into the application.

<img src="pictures/screenshot-2026-06-28-001103.png" alt="Social graph initialization" width="900" />

## 3. Installing DeepTrace agent

**Issue:** The documented `agent install` command exited immediately. The
implementation suggested a progress bar would be shown.

<img src="pictures/screenshot-2026-06-28-001226.png" alt="Agent install command exiting immediately" width="900" />

**Resolution (successful):** Use the underlying install script from the
`agent install` implementation, which downloaded dependencies and built the
agent from source.

<img src="pictures/screenshot-2026-06-28-001622.png" alt="Agent built from source" width="900" />

## 4. Running DeepTrace agent

**Issue:** Running the agent produced an error in `server/controller/src/agent.py`.

<img src="pictures/screenshot-2026-06-28-001238.png" alt="Initial agent run error" width="900" />

**Resolution (successful):** Patch `server/controller/src/agent.py`.

<img src="pictures/screenshot-2026-06-28-002513.png" alt="Agent.py patch" width="900" />

**Issue:** Next run failed with a `user_id` configuration error. The
documentation did not mention this field.

<img src="pictures/screenshot-2026-06-28-221217.png" alt="user_id configuration error" width="900" />

<img src="pictures/screenshot-2026-06-28-002715.png" alt="Documentation without user_id" width="900" />

**Resolution (unsuccessful):** Add `user_id` to `config.toml`.

<img src="pictures/screenshot-2026-06-28-221339.png" alt="Adding user_id to config" width="900" />

Modified `sync_config` to inspect agent state:

<img src="pictures/screenshot-2026-06-28-221442.png" alt="sync_config debugging" width="900" />

The agent ignored the `user_id` entry:

<img src="pictures/screenshot-2026-06-28-221457.png" alt="user_id ignored" width="900" />

**Resolution (successful):** Map `user_name` to `user_id` in the implementation.

<img src="pictures/screenshot-2026-06-28-221524.png" alt="user_name as user_id workaround" width="900" />

**Issue:** Agent could not synchronize its configuration file.

<img src="pictures/screenshot-2026-06-28-221641.png" alt="Configuration sync failure" width="900" />

**Resolution (successful):** Patch the `connect` function with additional checks.

<img src="pictures/screenshot-2026-06-28-221731.png" alt="connect function patch" width="900" />

**Issue:** Agent could not connect to the server via SSH. The server had SSH
disabled.

<img src="pictures/screenshot-2026-06-28-221812.png" alt="SSH connection failure" width="900" />

Manually obtained a SocialNetwork process PID:

<img src="pictures/screenshot-2026-06-28-222627.png" alt="Finding SocialNetwork PID" width="900" />
<img src="pictures/screenshot-2026-06-28-222641.png" alt="PID selection" width="900" />

**Resolution (successful):** Manually synchronize `agent/config/deeptrace.toml`.

<img src="pictures/screenshot-2026-06-28-222658.png" alt="Manual agent configuration" width="900" />

Confirmed Elasticsearch API availability at `localhost:9200` with config
credentials before the next agent run:

<img src="pictures/screenshot-2026-06-28-222825.png" alt="Elasticsearch health check" width="900" />

**Resolution (successful):** Abandon the broken `agent run` command and invoke
the underlying script directly.

<img src="pictures/screenshot-2026-06-28-002042.png" alt="Underlying agent script" width="900" />
<img src="pictures/screenshot-2026-06-28-230521.png" alt="Agent running via script" width="900" />

## 5. Generating traffic

**Documented step:** Generate traffic using `run_wrk2_baseline.sh`.

<img src="pictures/screenshot-2026-06-28-223131.png" alt="wrk2 baseline run" width="900" />

## 6. Obtaining traces

**Issue:** Span correlation failed initially.

<img src="pictures/screenshot-2026-06-28-222859.png" alt="Span correlation error" width="900" />

**Resolution (successful):** Copy agent configuration to `config.toml`.

<img src="pictures/screenshot-2026-06-28-223029.png" alt="Configuration copy fix" width="900" />

**Issue (unresolved):** Span correlation returned no traces. Re-running after
additional traffic generation produced the same empty result.

<img src="pictures/screenshot-2026-06-28-223039.png" alt="Empty correlation output" width="900" />

**Issue (unresolved):** Trace assembly failed with an error.

<img src="pictures/screenshot-2026-06-28-223315.png" alt="Trace assembly error" width="900" />

Further attempts to fix DeepTrace did not yield usable traces.

## Conclusions

| Area | Assessment |
| --- | --- |
| Documentation accuracy | Poor — missing scripts, undocumented config fields, CLI behaviour differs from docs |
| Agent stability | Required multiple local patches to upstream code |
| Trace collection | Failed — no traces collected after correlation or assembly |
| Production readiness | Not ready — implementation appears unfinished |

DeepTrace in its current form is not suitable for production use or for
reproducible research evaluation without significant engineering effort on
unmaintained code.

## Repository status

The DeepTrace GitHub repository shows no recent activity and appears abandoned.

<img src="pictures/deeptrace_repo.png" alt="DeepTrace repository activity" width="900" />

A successor project called Zerotrace exists and shows active development. This
observation is noted for context only; Zerotrace was not evaluated in this PoC.

<img src="pictures/zerotrace.png" alt="Zerotrace repository" width="900" />
