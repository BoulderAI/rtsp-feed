1. Build RTSP Feed Container

    ```bash
    ./build.sh
    ```

2. Run the rstp-feed container in the background

    ```bash
    ./run-feed.sh BAI_STREAM_02 gs://path-to-google-storage-url 
    ```
    or
    ```bash
    ./run-feed.sh BAI_STREAM_02 /path/to/local/file
    ```
     or
    ```bash
    ./run-feed.sh BAI_STREAM_02 /path/to/local/dir
    ```

3. Stop the container
    Run
    ```bash
    docker-compose down
    ```
    From this directory

Copy the `docker-compose.yml` and `./run-feed.sh` script to another system to
use the container without rebuilding.
