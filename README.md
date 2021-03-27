# Coronavirus Twitter Analysis

For this project, I scanned all geotagged tweets sent in 2020 to monitor for the spread of the coronavirus on social media.

**Objectives:**

1. Computation with large scale data-sets
1. Work with multilingual text
1. Use the [MapReduce](https://en.wikipedia.org/wiki/MapReduce) divide-and-conquer paradigm to create parallel code

## Background

Approximately 500 million tweets are sent everyday.
Of those tweets, about 1% are *geotagged*.
That is, the user's device includes location information about where the tweets were sent from.
The lambda server's `/data-fast/twitter\ 2020` folder contains all geotagged tweets that were sent in 2020.
In total, there are about 1.1 billion tweets in this dataset.
We can calculate the amount of disk space used by the dataset with the `du` command as follows:

```
$ du -h /data-fast/twitter\ 2020
```

The tweets are stored as follows.
The tweets for each day are stored in a zip file `geoTwitterYY-MM-DD.zip`,
and inside this zip file are 24 text files, one for each hour of the day.
Each text file contains a single tweet per line in JSON format.
JSON is a popular format for storing data that is closely related to python dictionaries.

Vim is able to open compressed zip files,
and I encourage you to use vim to explore the dataset.
For example, run the command
```
$ vim /data-fast/twitter\ 2020/geoTwitter20-01-01.zip
```
Or you can get a "pretty printed" interface with a command like
```
$ unzip -p /data-fast/twitter\ 2020/geoTwitter20-01-01.zip | head -n1 | python3 -m json.tool | vim -
```

MapReduce is a famous procedure for large scale parallel processing that is widely used in industry.
It is a 3-step procedure summarized in the following image:

<img src=mapreduce.png width=100% />

While the partition step was pre-done, I had to use the map and reduce steps.

**Runtime:**

The simplest and most common scenario is that the map procedure takes time O(n) and the reduce procedure takes time O(1).
If you have p<<n processors, then the overall runtime will be O(n/p).
This means that:
1. Doubling the amount of data will cause the analysis to take twice as long;
1. Doubling the number of processors will cause the analysis to take half as long;
1. If you want to add more data and keep the processing time the same, then you need to add a proportional number of processors.

More complex runtimes are possible.
Merge sort over MapReduce is the classic example. 
Here, mapping is equivalent to sorting and so takes time O(n log n),
and reducing is a call to the `_reduce` function that takes time O(n).
But they are both rare in practice and require careful math to describe,
so we will ignore them.
In the merge sort example, it requires p=n processors just to reduce the runtime down to O(n)...
that's a lot of additional computing power for very little gain,
and so is impractical.

## Tasks

1. **Mapping:**
   The `map.py` file processes a single zip file of tweets and tracks the usage of the hashtags on 
   both a language and country level. 
   I created a run_maps.sh script that automatically runs map.py on all files which can be run with:
   ```
   $ ./run_maps.sh
   ```
   This command will take a few hours to days depending on the computer it's run on as it is processing 
   all the tweets within the zip file. I used the `nohup` command to ensure the program continues to run after you 
   disconnect and the `&` operator to ensure that all `map.py` commands run in parallel.
   After the command finishes, you will now have a folder `outputs` that contains multiple files: multiple for .lang 
   and multiple for .country. These files contain JSON formatted information summarizing the tweets.
   
3. **Visualizing:**
   The `visualize.py` file displays the output from running the `map.py` file.
   The `visualize.py` file simply provides a nicer visualization of these dictionaries and is integrated in the reducing step.
   
2. **Reducing:**
   The `reduce.py` file merges the outputs generated by the `map.py` file so that the combined files can be visualized.
   After your `map.py` has run on all the files,
   you should have a large number of files in your `outputs` folder.
   Use the `reduce.py` file to combine all of the `.lang` files into a single file,
   and all of the `.country` files into a different file.
   Then use the `visualize.py` file to count the total number of occurrences of each of the hashtags.

   For each hashtag, you should create an output file in your repo using output redirection
   ```
   $ ./src/visualize.py --input_path=PATH --key=HASHTAG | head > viz/HASHTAG
   ```
   but replace `PATH` with the path to the output of your `reduce.py` file and `HASHTAG` is replaced with the hashtag you are analyzing.

3. **Visualizing:**
   The `visualize.py` file displays the output from running the `map.py` file.
   The `visualize.py` file simply provides a nicer visualization of these dictionaries.

## Results

As we observe the different json files, we can see that there was a huge spike in the use of the affiliated hashtags around
March 10, which is about when the first lockdown took place in the US. We can also see that it was used moderately prior to 
the impact in the US, since it first appeared in China. The use of the hashtag evens out over time, but we can still
see various amounts of the hashtags being used, particularly in the US, where about a third of the hashtags were geotagged.