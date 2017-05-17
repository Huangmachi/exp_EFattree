#!/bin/bash
# Copyright (C) 2016 Huang MaChi at Chongqing University
# of Posts and Telecommunications, China.

k=$1
duration=60
out_dir='./results'


# # Plot results.
sudo python ./plot_results.py --k $k --duration $duration --dir $out_dir
