# Trying out the DeepTrace

We were unable to collect traces using DeepTrace. The main factor that contributed to this is the discrepancy between the [DeepTrace Documentation](https://deepshield-ai.github.io/DeepTrace/introduction.html) and the actual state of affairs. While using it we had the impression that the implementation was not finished.

Below is a step-by-step description of our attemp to run a basic deployment of DeepTrace, which includes: following the instructions in the documentation (marked as 📖), problems encountered (marked as ‼️) and our attempts to resolve them (marked as ✅ if successful and as ❌ if not).

### 1. Deploying DeepTrace server

📖 We cloned the DeepTrace GitHub repository.

![alt text](<pictures/Screenshot 2026-06-27 235916.png>)

📖 Next, we filled the configuration file `server/config/config.toml`.

![alt text](<pictures/Screenshot 2026-06-27 235946.png>)

📖 Next, we deployed the server using `scripts/deploy_server.sh` and confirmed it was running.

![alt text](<pictures/Screenshot 2026-06-27 235940.png>)

### 2. Deploying SocialNetwork application

📖 We used the `deploy.sh` script in `tests/workload/socialnetwork` to deploy the application and confirmed it was working.

![alt text](<pictures/Screenshot 2026-06-28 000044.png>)
![alt text](<pictures/Screenshot 2026-06-28 000106.png>)

📖‼️ Next, we attempted to inject data into the application with a builtin script, but it was not found.

![alt text](<pictures/Screenshot 2026-06-28 000507.png>)

✅ We deployed the application from `DeathStarBench` instead.

![alt text](<pictures/Screenshot 2026-06-28 000937.png>)
![alt text](<pictures/Screenshot 2026-06-28 000957.png>)

📖 We succesfully injected data into the application.

![alt text](<pictures/Screenshot 2026-06-28 001103.png>)

### 3. Installing DeepTrace Agent

‼️ We attempted to install the DeepTrace Agent by using the command presented below. However, it ended almost immediately, while the implementation suggested there would be a progress bar visible.

![alt text](<pictures/Screenshot 2026-06-28 001226.png>)

✅ We used a script found in the implementaion of `agent install`. This script downloaded required dependencies and built the agent from source.

![alt text](<pictures/Screenshot 2026-06-28 001622.png>)

### 4. Running DeepTrace Agent

📖‼️ We attemted to run the agent, but we received the following error.

![alt text](<pictures/Screenshot 2026-06-28 001238.png>)

✅ We fixed the error by modifying the implementation at `server/controller/src/agent.py`.

![alt text](<pictures/Screenshot 2026-06-28 002513.png>)

‼️ In the next attempt to run the agent we got the following error.

![alt text](<pictures/Screenshot 2026-06-28 221217.png>)

The documentation did not contain `user_id`.

![alt text](<pictures/Screenshot 2026-06-28 002715.png>)

❌ We attempted to fix it by adding `user_id` entry in `config.toml`.

![alt text](<pictures/Screenshot 2026-06-28 221339.png>)

We also modified the `sync_config` function to inspect agent's state.

![alt text](<pictures/Screenshot 2026-06-28 221442.png>)

After another attempt to run the agent, we noticed that it ignored the `user_id` entry.

![alt text](<pictures/Screenshot 2026-06-28 221457.png>)

✅ We modified implementation to use `user_name` as `user_id`.

![alt text](<pictures/Screenshot 2026-06-28 221524.png>)

‼️ In another attempt agent could not synchronize its configuration file.

![alt text](<pictures/Screenshot 2026-06-28 221641.png>)

✅ We modified `connect` function to perform additional checks.

![alt text](<pictures/Screenshot 2026-06-28 221731.png>)

‼️ In another attempt agent could not connect to the server via ssh. We later confirmed that server had no ssh enabled.

![alt text](<pictures/Screenshot 2026-06-28 221812.png>)

We manually obtained one of SocialNetwork PIDs.

![alt text](<pictures/Screenshot 2026-06-28 222627.png>)
![alt text](<pictures/Screenshot 2026-06-28 222641.png>)

✅ We manually synchronized agent's configuration file `agent/config/deeptrace.toml`.

![alt text](<pictures/Screenshot 2026-06-28 222658.png>)

Before running the agent again, we confirmed that Elastic API was available at `localhost:9200` and accepted credentials from the config.

![alt text](<pictures/Screenshot 2026-06-28 222825.png>)

✅ We abandoned the erroneus `agent run` command and instead we used builtin script used by that command.

![alt text](<pictures/Screenshot 2026-06-28 002042.png>)
![alt text](<pictures/Screenshot 2026-06-28 230521.png>)

### 5. Generating traffic

📖 We generated traffic in SocialNetwork application by using `run_wrk2_baseline.sh`.

![alt text](<pictures/Screenshot 2026-06-28 223131.png>)

### 6. Obtaining traces

📖‼️ We attempted to perform span correlation using DeepTrace.

![alt text](<pictures/Screenshot 2026-06-28 222859.png>)

✅ We fixed the above error by copying agent configuration to `config.toml`.

![alt text](<pictures/Screenshot 2026-06-28 223029.png>)

‼️❌ We ran the command again. It seemed that it received no traces. To be sure, we generated traffic again and repeated the command, but it gave the same output.

![alt text](<pictures/Screenshot 2026-06-28 223039.png>)

📖‼️ We tried to assemble traces. We received the following error.

![alt text](<pictures/Screenshot 2026-06-28 223315.png>)

❌ Further attempts at fixing the DeepTrace yielded no results.

# Conclusions

DeepTrace in its current form is not production-ready. The implementation appears to be unfinished. Additionally there are many discrepancies between documentation and the implementation.

# Current state of DeepTrace

DeepTrace GitHub repository appears to be abandoned.

![alt text](<pictures/deeptrace_repo.png>)

This is evidenced by the existence of another project called "Zerotrace", which is actively developed.

![alt text](<pictures/zerotrace.png>)