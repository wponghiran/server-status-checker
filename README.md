# server-status-checker

These scripts allow NRL/ISL members to check the server status by probing the machine once.
They are written in bash and expect script languages (which their interpreters are available on Purdue cluster).

## How to use

1. To check utilization on the current machine, run:
```
bash check_usage.sh
```
![](/images/check_usage.JPG)

2. To enable automatic status report when you log-in to the server, copy check_usage.sh to home directory and add script to be executed at the beginning by running:
```
cp check_usage.sh ~
export 'bash ~/.check_usage.sh' >> ~/.bashrc 
```

3. To check utilization on all machines, run:
```
cp check_usage.sh ~
expect check_usage_all.expect
```
By default, gpu1-13 will be probed. You may change target machines by editing the script.

![](/images/check_usage_all.JPG)

4. To create a shortcut command to check utilization on all machines, run:
```
cp check_usage.sh ~
cp check_usage_all.expect ~
export 'alias stat_all="expect ~/check_usage_all.expect"' >> ~/.bashrc
```

After you start new terminal or reload .bashrc, you will be able to run ```stat_all``` to check all server status.

## Known issues

1. Expect interpreter isn't installed on local linux machines, so check utilization on all machines can be performed only on cbric-gpu machines.

> Last update: 10/4/2020
