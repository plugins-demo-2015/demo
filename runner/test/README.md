# manual AWS testing

Here are the steps I did on the current AWS cluster to test an EBS migration.

The installation of Flocker is from [FLOC-2084](http://build.clusterhq.com/results/omnibus/missing-size-default-FLOC-2084/ubuntu-14.04/) which is different from yesterday where it was being install from [0.4.1dev3](http://build.clusterhq.com/results/omnibus/0.4.1dev3/ubuntu-14.04/)

There is a 3 node cluster with these IP addresses:

 * control_service - 54.204.134.124 / 10.229.91.29
 * runner_1 - 54.163.111.97 / 10.71.204.72
 * runner_2 - 54.158.107.49 / 10.142.8.207

## testing the HTTP API

I can add keys to the machines if anyone wants to do this - Madhuri I've added your key onto all 3 machines.

First ssh to runner-1:

```
$ ssh ubuntu@54.163.111.97
```

There is a script to create and move a volume using the HTTP API `/root/api.sh`

This is what I did:

```
$ bash ./test.sh list-nodes
$ bash ./test.sh create-volume # this created a volume with no name
$ bash ./test.sh create-volume lime
```

I then checked the config:

```
$ bash ./test.sh list-volumes
```

I then grabbed the datasetid from the volume I just created - `e77e55a0-d70e-46cd-916c-135e0ee5ee5e`

I then wrote some data to the volume:

```
$ echo hello > /flocker/e77e55a0-d70e-46cd-916c-135e0ee5ee5e/file.txt
```

I then moved that volume:

```
$ bash ./test.sh move-volume e77e55a0-d70e-46cd-916c-135e0ee5ee5e
```

And it worked - I could login to runner_2 and do this (once the volume showed up as attached)

```
$ cat /flocker/e77e55a0-d70e-46cd-916c-135e0ee5ee5e/file.txt
hello
```

I then repeated this process 5 times for volumes named `api{1..5}` - it worked for each of them - here is the output of `ls -la /flocker`

```
root@ip-10-142-8-207:/flocker# ls -la
total 32
drwx------  8 root root 4096 Jun  8 14:14 .
drwxr-xr-x 24 root root 4096 Jun  8 14:06 ..
drwxrwxrwx  2 root root 4096 Jun  8 14:11 0f74997e-7130-4006-a373-00b1db394cc8
drwxrwxrwx  2 root root 4096 Jun  8 14:11 1433c5ee-3ae0-45aa-85d7-1aa94bc8263c
drwxrwxrwx  2 root root 4096 Jun  8 14:12 858cec64-8045-490c-b5ed-be58531127ef
drwxrwxrwx  2 root root 4096 Jun  8 14:11 9b8a96cf-4fd9-4f50-9702-0beea0b892db
drwxrwxrwx  2 root root 4096 Jun  8 14:11 e08c1de5-c48e-4f01-bc42-b5183207f1a6
drwxrwxrwx  2 root root 4096 Jun  8 14:05 e77e55a0-d70e-46cd-916c-135e0ee5ee5e
```

## testing the docker volume

For this you need an SSH connection to runner_1 AND runner_2 at the same time.

Each time you run this test - you must replace the volume name with something new.

On runner_1:

```
$ sudo docker run -v plugin2:/data --volume-driver flocker busybox sh -c "echo hello > /data/file.txt"
```

Then on runner_2:

```
$ sudo docker run -v plugin2:/data --volume-driver flocker busybox sh -c "cat /data/file.txt"
```
