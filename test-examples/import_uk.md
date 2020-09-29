# Uk import PostgreSQL tuning

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

## PostgreSQL without modified options

```
Reading in file: /home/renderer/data/data.osm.pbf
Using PBF parser.
Processing: Node(424480k 578.3k/s) Way(61465k 35.53k/s) Relation(634330 2033.1/s)  parse time: 2776s
Node stats: total(424480828), max(7935617037) in 734s
Way stats: total(61465245), max(850639334) in 1730s
Relation stats: total(634330), max(11661144) in 312s
Stopping table: planet_osm_nodes
Stopping table: planet_osm_ways
Sorting data and creating indexes for planet_osm_polygon
Sorting data and creating indexes for planet_osm_roads
Sorting data and creating indexes for planet_osm_line
Stopping table: planet_osm_rels
Sorting data and creating indexes for planet_osm_point
Using native order for clustering
Using native order for clustering
Using native order for clustering
Using native order for clustering
Stopped table: planet_osm_nodes in 0s
Building index on table: planet_osm_ways
Building index on table: planet_osm_rels
Copying planet_osm_roads to cluster by geometry finished
Creating geometry index on planet_osm_roads
Stopped table: planet_osm_rels in 39s
Creating osm_id index on planet_osm_roads
Creating indexes on planet_osm_roads finished
All indexes on planet_osm_roads created in 69s
Completed planet_osm_roads
Copying planet_osm_point to cluster by geometry finished
Creating geometry index on planet_osm_point
Copying planet_osm_line to cluster by geometry finished
Creating geometry index on planet_osm_line
Creating osm_id index on planet_osm_point
Creating indexes on planet_osm_point finished
All indexes on planet_osm_point created in 288s
Completed planet_osm_point
Creating osm_id index on planet_osm_line
Creating indexes on planet_osm_line finished
All indexes on planet_osm_line created in 365s
Completed planet_osm_line
Copying planet_osm_polygon to cluster by geometry finished
Creating geometry index on planet_osm_polygon
Stopped table: planet_osm_ways in 1207s
Creating osm_id index on planet_osm_polygon
Creating indexes on planet_osm_polygon finished
All indexes on planet_osm_polygon created in 2145s
Completed planet_osm_polygon

Osm2pgsql took 4922s overall
```

## PostgreSQL with modified options

```
Reading in file: /home/renderer/data/data.osm.pbf
Using PBF parser.
Processing: Node(424480k 651.0k/s) Way(61465k 35.10k/s) Relation(634330 2202.5/s)  parse time: 2691s
Node stats: total(424480828), max(7935617037) in 652s
Way stats: total(61465245), max(850639334) in 1751s
Relation stats: total(634330), max(11661144) in 288s
Sorting data and creating indexes for planet_osm_point
Stopping table: planet_osm_ways
Sorting data and creating indexes for planet_osm_polygon
Sorting data and creating indexes for planet_osm_roads
Stopping table: planet_osm_rels
Sorting data and creating indexes for planet_osm_line
Stopping table: planet_osm_nodes
Using native order for clustering
Using native order for clustering
Using native order for clustering
Using native order for clustering
Building index on table: planet_osm_rels
Building index on table: planet_osm_ways
Stopped table: planet_osm_nodes in 0s
Copying planet_osm_roads to cluster by geometry finished
Creating geometry index on planet_osm_roads
Stopped table: planet_osm_rels in 28s
Creating osm_id index on planet_osm_roads
Creating indexes on planet_osm_roads finished
All indexes on planet_osm_roads created in 41s
Completed planet_osm_roads
Copying planet_osm_point to cluster by geometry finished
Creating geometry index on planet_osm_point
Copying planet_osm_line to cluster by geometry finished
Creating geometry index on planet_osm_line
Creating osm_id index on planet_osm_point
Creating indexes on planet_osm_point finished
All indexes on planet_osm_point created in 237s
Completed planet_osm_point
Creating osm_id index on planet_osm_line
Creating indexes on planet_osm_line finished
All indexes on planet_osm_line created in 277s
Completed planet_osm_line
Copying planet_osm_polygon to cluster by geometry finished
Creating geometry index on planet_osm_polygon
Stopped table: planet_osm_ways in 992s
Creating osm_id index on planet_osm_polygon
Creating indexes on planet_osm_polygon finished
All indexes on planet_osm_polygon created in 1919s
Completed planet_osm_polygon

Osm2pgsql took 4611s overall
```


