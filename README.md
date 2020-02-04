# REST+CRUD benchmark using Quarkus

WIP: recommend you don't try just yet until I've verified everything still works :)

This benchmark comes originally from John O'Hara's Quarkus performance blog article.
	[Quarkus Runtime Performance](https://quarkus.io/blog/runtime-performance/)
	[Quarkus RESTEasy git repo](https://github.com/johnaohara/quarkusRestCrudDemo)

This benchmark runs in a Docker container and can be compiled as a Java application
for running on a standard JDK or as a native image (standalone executable).

This directory contains scripts to run this demo across a number of Java compilation
options, across JDK8 and JDK11, and across the Hotspot, OpenJ9, and Graal compiler projects.
The scripts measure server start-up time, footprint under load (Resident Set Size after a
load is applied to the server) and collect the ramp-up curve for (by default) 3 minute runs.
These metrics are all collected from a single run of the benchmark. All benchmark runs are
performed inside a Docker container, but some runs are performed locally on the host to
prepare for the benchmark runs.

The different compilers tested are:
- Hotspot (JDK8, JDK11)
- Hotspot using jaotc without tiered compilation support (experimental in JDK11)
- Hotspot using jaotc with tiered compilation support (experimental in JDK11)
- Hotspot using Graal as JIT (experimental in JDK11)
- OpenJ9 (JDK8, JDK11)
- OpenJ9 with shared classes (Caching JIT) (JDK8, JDK11)
- OpenJ9 with shared classes and -Xtune:virtualized (Caching JIT) (JDK8, JDK11)
- OpenJ9 with a JIT server (technology preview in JDK8, JDK11)
- OpenJ9 with shared classes and a JIT server (technology preview in JDK8, JDK11)
- Native image using Graal (untuned GC parameters, JDK8)
- Native image using Graal (tuned GC parameters, JDK8)

What it means to run a Java application with these different options can be seen in
the script `scriptToRunInsideDocker` which takes command-line options to adjust the
command-line options to configure the JDK to run these different options. With the
exception of the tuned native image option, the only options provided are associated
with activating the appropriate compiler technology.

The various scripts are:
- `download.sh` - downloads JDK8, JDK11 JDKs for Hotspot and OpenJ9 as well as the Graal 19.2.3 distribution that are used on the host machine to prepare for the benchmark runs. This script also pulls the most recent JDK Docker containers from AdoptOpenJDK which will be used in the benchmark runs.
- `build.sh` - performs all the steps required to create the Docker containers used in the benchmark runs, as well as to build native images and do AOT compilation and population runs. Also compiles Convert.java and builds the RESTEast application a few times.
- `run-results.sh` - performs the full set of runs and collects data in the `runs` directory. The last two sets of runs will be automatically kept in `runs-old1` and `runs-old2`. CSV results files will be written to `runs/all.su.txt` (start-up performance data), `runs/all.fp.txt` (footprint after load performance data), and `runs/all.tp.txt` (ramp-up throughput performance data).

The generated data in the `runs/all.*.txt` files are ready to be imported into a spreadsheet or
processed by a graph plotting tool. It would be cool to have the repository display the last resultsbut that's not done yet.

`run-results.sh` uses a number of other scripts including `run-server.sh`, `run-load.sh` and
`run-with-jitserver.sh` to actually start the docker containers.

To start from scratch, do the following:
```
$ git clone https://github.com/mstoodle/compare-java-compilers
$ cd compare-java-compilers
$ ./download.sh | tee download.sh.out
$ cd crud-quarkus
$ ./build.sh | tee build.sh.out
$ ./run-results.sh | tee run-results.sh.out
$ ls -l ./run/all.*.txt
```

