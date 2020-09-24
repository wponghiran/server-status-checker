# server-status-checker

These scripts allow NRL/ISL members to check the server status by probing the machine once.
They are written in bash and expect script languages (which their interpreters are available on Purdue cluster).

## How to use

1. To check utilization on the current machine, run:
```
  bash check_usage.sh
```
2. To enable automatic status report when you log-in to the server, copy check_usage.sh to home directory and add script to be executed at the beginning by running:
```
cp check_usage.sh ~
export 'bash ~/.check_usage.sh' >> ~/.bashrc 
```
3.  To check utilization on all machines, run:
```
  expect check_usage_all.expect
```
By default, gpu1-13 will be probed. You may change target machines by editing the script.

> Last update: 9/24/2020
