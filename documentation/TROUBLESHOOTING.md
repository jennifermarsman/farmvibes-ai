# Troubleshooting

This document compiles the most common issues encountered when installing and running FarmVibes.AI platform, grouped into broad categories.

- **Cluster setup:**

    <details>
    <summary> Missing secrets</summary>

    Running a workflow while missing a required secret will yield the following error message:

    ```bash
    Could not retrieve secret {secret_name} from Dapr.
    ```

    Add the missing secrets to the Kubernetes cluster. [Learn more about secrets here](SECRETS.md).

    </details>

    <details>
    <summary> How to change the storage location during cluster creation</summary>

    You may change the storage location by defining the environment variable `FARMVIBES_AI_STORAGE_PATH` prior to installation with the *farmvibes-ai.sh* script.

    </details>

    <details>
    <summary> No route to the Rest-API </summary>

    Building a cluster with the *farmvibes-ai.sh* script will set up a Rest-API service with an address visible only within the cluster. In case the client cannot reach the Rest-API, make sure to restart the cluster with:

    ```bash
    bash farmvibes-ai.sh restart
    ```

    </details>

    <details>
    <summary> Unable to run workflows after machine rebooted </summary>

    After a reboot, make sure to start the cluster with:

    ```bash
    bash farmvibes-ai.sh start
    ```

    </details>

<br>

- **Composing and running workflows:**

    <details>
    <summary> Calling an unknown workflow</summary>

    Calling `client.run()` with a wrong workflow name will yield the following error message:

    ```HTTPError: 400 Client Error: Bad Request for url: http://192.168.49.2:30000/v0/runs. Unable to run workflow with provided parameters. Workflow "WORKFLOW_NAME" unknown```

    Solutions:

  - Double check the workflow name and parameters;
  - Verify that your cluster and repo are up-to-date;

    </details>

    <details>
    <summary> Verifying why a workflow run failed </summary>

    In case a workflow run fails, you might see a similar status table when monitoring a run with `run.monitor()` (please refer to the [client documentation](CLIENT.md) for more information on `monitor`):

    ```bash
    >>> run.monitor()
                        🌎 FarmVibes.AI 🌍 dataset_generation/datagren_crop_segmentation 🌏
                                    Run id: 7b95932f-2428-4036-b4cc-14ef832bf8c2
    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━┓
    ┃ Task Name                          ┃ Status   ┃ Start Time          ┃ End Time            ┃ Duration ┃
    ┡━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━┩
    │ spaceeye.preprocess.s2.s2.download │ failed   │ 2022/10/03 22:22:16 │ 2022/10/03 22:22:20 │ 00:00:00 │
    │ cdl.download_cdl                   │ done     │ 2022/10/03 22:22:12 │ 2022/10/03 22:22:15 │ 00:00:05 │
    │ spaceeye.preprocess.s2.s2.filter   │ done     │ 2022/10/03 22:22:10 │ 2022/10/03 22:22:12 │ 00:00:02 │
    │ spaceeye.preprocess.s2.s2.list     │ done     │ 2022/10/03 22:22:09 │ 2022/10/03 22:22:10 │ 00:00:01 │
    │ cdl.list_cdl                       │ done     │ 2022/10/03 22:22:04 │ 2022/10/03 22:22:09 │ 00:00:04 │
    └────────────────────────────────────┴──────────┴─────────────────────┴─────────────────────┴──────────┘
                                        Last update: 2022/10/03 22:23:59
    ```

    The platform logs the possible reason why a task failed, which might be recovered with `run.reason` and `run.task_details`.

    </details>

    <details>
    <summary> Unable to find ONNX model when running workflows </summary>

    Make sure the ONNX model was added to the FarmVibes.AI cluster:

    ```bash
    bash farmvibes-ai.sh add-onnx <onnx-model>
    ```

    If no output is generated, then your model was successfully added.

    </details>

    <details>
    <summary> Workflow run with 'pending' status indefinitally</summary>

    If the status of a workflow run remains in 'pending', make sure to restart the cluster with:

    ```bash
    bash farmvibes-ai.sh restart
    ```

    </details>

<br>

- **Example notebooks:**

  <details>
  <summary> Unable to import modules when running a notebook</summary>

  Make sure you have installed and activated the conda environment provided with the notebook.

  </details>
