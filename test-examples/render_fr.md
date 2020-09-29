# Tiles rendering benchmark 

## Machine specs


```
       _,met$$$$$gg.          root@Debian-104-buster-64-minimal 
    ,g$$$$$$$$$$$$$$$P.       --------------------------------- 
  ,g$$P"     """Y$$.".        OS: Debian GNU/Linux 10 (buster) x86_64 
 ,$$P'              `$$$.     Host: Z10PA-U8 Series 
',$$P       ,ggs.     `$$b:   Kernel: 4.19.0-9-amd64 
`d$$'     ,$P"'   .    $$$    Uptime: 103 days, 9 mins 
 $$P      d$'     ,    $$P    Packages: 403 (dpkg) 
 $$:      $$.   -    ,d$$'    Shell: bash 5.0.3 
 $$;      Y$b._   _,d$P'      Terminal: /dev/pts/0 
 Y$$.    `.`"Y$$$$P"'         CPU: Intel Xeon E5-1650 v3 (12) @ 3.800GHz 
 `$$b      "-.__              Memory: 474MiB / 128820MiB 
  `Y$$                        SSD Disk (/): 17G / 871G (2%) 
   `Y$$.
     `$$b.                                            
       `Y$$b.
          `"Y$b._
              `"""
```

## With some options

```
listen_addresses = '*'
shared_buffers = 64GB # 25% of RAM as stated in the documentation
wal_level = minimal # since pg12 wal level default is replication
max_wal_senders = 0 # to deactivate replication. Really necessary ?
jit = off
```

Rendering on France for zoom level 10 to 14 using 4 threads

```
./render_list_geo.pl -z 10 -Z 14 -n 4 -a -m ajt -x -0.966797 -X 5.778809 -y 43.357138 -Y 49.224773
```

```
Rendering started at: Thu Sep 17 07:44:51 UTC 2020

Meta tiles rendered: Rendered 16 tiles in 700.33 seconds (0.02 tiles/s)
Total tiles rendered: Rendered 1024 tiles in 700.33 seconds (1.46 tiles/s)
Total tiles handled: Rendered 16 tiles in 700.33 seconds (0.02 tiles/s)
Zoom 10: min: 39.9    avg: 154.2     max: 251.1     over a total of   2466.9s in 16 requests

Meta tiles rendered: Rendered 42 tiles in 658.01 seconds (0.06 tiles/s)
Total tiles rendered: Rendered 2688 tiles in 658.01 seconds (4.09 tiles/s)
Total tiles handled: Rendered 42 tiles in 658.01 seconds (0.06 tiles/s)
Zoom 11: min: 23.8    avg: 59.7     max: 144.8     over a total of   2505.7s in 42 requests

Meta tiles rendered: Rendered 143 tiles in 694.31 seconds (0.21 tiles/s)
Total tiles rendered: Rendered 9152 tiles in 694.31 seconds (13.18 tiles/s)
Total tiles handled: Rendered 143 tiles in 694.31 seconds (0.21 tiles/s)
Zoom 12: min:  6.0    avg: 19.1     max: 120.9     over a total of   2729.0s in 143 requests

Meta tiles rendered: Rendered 500 tiles in 790.37 seconds (0.63 tiles/s)
Total tiles rendered: Rendered 32000 tiles in 790.37 seconds (40.49 tiles/s)
Total tiles handled: Rendered 500 tiles in 790.37 seconds (0.63 tiles/s)
Zoom 13: min:  1.9    avg:  6.3     max: 87.1     over a total of   3133.5s in 500 requests

Meta tiles rendered: Rendered 1911 tiles in 1237.43 seconds (1.54 tiles/s)
Total tiles rendered: Rendered 122304 tiles in 1237.43 seconds (98.84 tiles/s)
Total tiles handled: Rendered 1911 tiles in 1237.43 seconds (1.54 tiles/s)
Zoom 14: min:  0.6    avg:  2.6     max: 54.5     over a total of   4925.2s in 1911 requests

Thu Sep 17 08:52:51 UTC 2020
```

**Total time : 1 hour 8 minutes**

## Adding work_mem = 4GB and adjusting /dev/shm in docker-compose.yml

Rendering on France for zoom level 10 to 14 using 4 threads

```
./render_list_geo.pl -z 10 -Z 14 -n 4 -a -m ajt -x -0.966797 -X 5.778809 -y 43.357138 -Y 49.224773
```

```
Rendering started at: Thu Sep 17 09:13:01 UTC 2020

Meta tiles rendered: Rendered 16 tiles in 510.78 seconds (0.03 tiles/s)
Total tiles rendered: Rendered 1024 tiles in 510.78 seconds (2.00 tiles/s)
Total tiles handled: Rendered 16 tiles in 510.78 seconds (0.03 tiles/s)
Zoom 10: min: 29.7    avg: 119.0     max: 221.1     over a total of   1903.4s in 16 requests

Meta tiles rendered: Rendered 42 tiles in 435.39 seconds (0.10 tiles/s)
Total tiles rendered: Rendered 2688 tiles in 435.39 seconds (6.17 tiles/s)
Total tiles handled: Rendered 42 tiles in 435.39 seconds (0.10 tiles/s)
Zoom 11: min: 18.4    avg: 40.1     max: 114.4     over a total of   1685.4s in 42 requests

Meta tiles rendered: Rendered 143 tiles in 505.46 seconds (0.28 tiles/s)
Total tiles rendered: Rendered 9152 tiles in 505.46 seconds (18.11 tiles/s)
Total tiles handled: Rendered 143 tiles in 505.46 seconds (0.28 tiles/s)
Zoom 12: min:  5.1    avg: 13.9     max: 95.9     over a total of   1993.1s in 143 requests

Meta tiles rendered: Rendered 500 tiles in 677.45 seconds (0.74 tiles/s)
Total tiles rendered: Rendered 32000 tiles in 677.45 seconds (47.24 tiles/s)
Total tiles handled: Rendered 500 tiles in 677.45 seconds (0.74 tiles/s)
Zoom 13: min:  1.8    avg:  5.4     max: 74.4     over a total of   2692.9s in 500 requests

Meta tiles rendered: Rendered 1911 tiles in 1210.52 seconds (1.58 tiles/s)
Total tiles rendered: Rendered 122304 tiles in 1210.52 seconds (101.03 tiles/s)
Total tiles handled: Rendered 1911 tiles in 1210.52 seconds (1.58 tiles/s)
Zoom 14: min:  0.6    avg:  2.5     max: 48.8     over a total of   4827.5s in 1911 requests

Rendering finished at: Thu Sep 17 10:08:41 UTC 2020
```

**Total time : 55 minutes and 40 seconds**
